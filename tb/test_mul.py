import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def reset_dut(dut):
    """Reset IntMul and establish known input values."""

    dut.reset.value = 1

    dut.istream_val.value = 0
    dut.istream_msg.value = 0
    dut.ostream_rdy.value = 0

    # Hold reset for a few clock cycles
    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.reset.value = 0
    await RisingEdge(dut.clk)


async def multiply(dut, a, b, timeout=100):
    """
    Send one multiplication request to IntMul and return its result.

    This treats the DUT as a black box and communicates only through
    the val/rdy interface.
    """

    # Pack operands into the 64-bit input message
    dut.istream_msg.value = ((a & 0xFFFFFFFF) << 32) | (b & 0xFFFFFFFF)
    dut.istream_val.value = 1

    # Wait until the DUT accepts the request
    cycles = 0

    while True:
        await RisingEdge(dut.clk)
        cycles += 1

        if dut.istream_rdy.value == 1:
            break

        assert cycles < timeout, "Timed out waiting for istream_rdy"

    # Stop presenting the request
    dut.istream_val.value = 0

    # Consumer is ready to accept the result
    dut.ostream_rdy.value = 1

    # Wait for result
    cycles = 0

    while True:
        await RisingEdge(dut.clk)
        cycles += 1

        if dut.ostream_val.value == 1:
            result = int(dut.ostream_msg.value)
            break

        assert cycles < timeout, "Timed out waiting for ostream_val"

    return result

async def multiply_with_latency(dut, a, b, timeout=100):
    """
    Send one multiplication request and return:
        (result, latency)

    latency = number of cycles from input acceptance
              until ostream_val is observed.
    """

    dut.istream_msg.value = ((a & 0xFFFFFFFF) << 32) | (b & 0xFFFFFFFF)
    dut.istream_val.value = 1
    dut.ostream_rdy.value = 1

    # Wait for input handshake
    while True:
        await RisingEdge(dut.clk)

        if dut.istream_rdy.value == 1:
            break

    dut.istream_val.value = 0

    # Count cycles until result becomes valid
    cycles = 0

    while True:
        await RisingEdge(dut.clk)
        cycles += 1

        if dut.ostream_val.value == 1:
            result = int(dut.ostream_msg.value)
            return result, cycles

        assert cycles < timeout, "Timed out waiting for ostream_val"


@cocotb.test()
async def test_basic(dut):
    """A few easy directed tests."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    test_cases = [
        (0, 0),
        (1, 1),
        (2, 3),
        (4, 5),
        (7, 8),
        (10, 10),
    ]

    for a, b in test_cases:

        result = await multiply(dut, a, b)

        expected = (a * b) & 0xFFFFFFFF

        assert result == expected, (
            f"{a} * {b}: expected {expected}, got {result}"
        )


@cocotb.test()
async def test_random(dut):
    """Randomized unsigned multiplication testing."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    random.seed(0xDEADBEEF)

    for _ in range(10000):

        a = random.getrandbits(32)
        b = random.getrandbits(32)

        result = await multiply(dut, a, b)

        expected = (a * b) & 0xFFFFFFFF

        assert result == expected, (
            f"0x{a:08x} * 0x{b:08x}: "
            f"expected 0x{expected:08x}, "
            f"got 0x{result:08x}"
        )

@cocotb.test()
async def test_edge_cases(dut):
    """Test interesting 32-bit operand patterns."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    test_cases = [
        (0x00000000, 0xFFFFFFFF),
        (0xFFFFFFFF, 0x00000000),

        (0x00000001, 0xFFFFFFFF),
        (0xFFFFFFFF, 0x00000001),

        (0xFFFFFFFF, 0xFFFFFFFF),

        (0x80000000, 0x00000001),
        (0x00000001, 0x80000000),

        (0x80000000, 0x00000002),
        (0x00000002, 0x80000000),

        (0xAAAAAAAA, 0x55555555),
        (0x55555555, 0xAAAAAAAA),

        (0x00010000, 0x00010000),
        (0x7FFFFFFF, 0x00000002),
    ]

    for a, b in test_cases:

        result = await multiply(dut, a, b)

        expected = (a * b) & 0xFFFFFFFF

        assert result == expected, (
            f"0x{a:08x} * 0x{b:08x}: "
            f"expected 0x{expected:08x}, "
            f"got 0x{result:08x}"
        )

@cocotb.test()
async def test_sequential_transactions(dut):
    """Send multiple transactions without resetting between them."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    transactions = [
        (2, 3),
        (7, 9),
        (100, 200),
        (0x1234, 0x5678),
        (0xFFFFFFFF, 2),
        (17, 31),
        (0, 123456),
        (12345, 6789),
    ]

    for i, (a, b) in enumerate(transactions):

        result = await multiply(dut, a, b)

        expected = (a * b) & 0xFFFFFFFF

        assert result == expected, (
            f"Transaction {i}: "
            f"0x{a:08x} * 0x{b:08x}: "
            f"expected 0x{expected:08x}, "
            f"got 0x{result:08x}"
        )

@cocotb.test()
async def test_output_backpressure(dut):
    """Hold ostream_rdy low and verify the output remains available."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    a = 37
    b = 19

    expected = (a * b) & 0xFFFFFFFF

    # Send request
    dut.istream_msg.value = ((a & 0xFFFFFFFF) << 32) | (b & 0xFFFFFFFF)
    dut.istream_val.value = 1

    while True:
        await RisingEdge(dut.clk)

        if dut.istream_rdy.value == 1:
            break

    dut.istream_val.value = 0

    # Intentionally refuse the output
    dut.ostream_rdy.value = 0

    # Wait until DUT says result is valid
    cycles = 0

    while dut.ostream_val.value != 1:
        await RisingEdge(dut.clk)

        cycles += 1

        assert cycles < 100, "Timed out waiting for ostream_val"

    # Capture result
    held_result = int(dut.ostream_msg.value)

    assert held_result == expected, (
        f"Expected 0x{expected:08x}, got 0x{held_result:08x}"
    )

    # Apply backpressure for several cycles
    for _ in range(5):

        await RisingEdge(dut.clk)

        assert dut.ostream_val.value == 1, (
            "ostream_val dropped while ostream_rdy was low"
        )

        assert int(dut.ostream_msg.value) == held_result, (
            "ostream_msg changed while output was stalled"
        )

    # Finally accept result
    dut.ostream_rdy.value = 1

    await RisingEdge(dut.clk)

@cocotb.test()
async def test_variable_latency(dut):
    """Measure latency for different multiplier bit patterns."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    a = 0x12345678

    test_cases = [
        0x00000000,
        0x00000001,
        0x00000002,
        0x00000010,
        0x00000100,
        0x00010000,
        0x80000000,
        0x55555555,
        0xAAAAAAAA,
        0xFFFFFFFF,
    ]

    latencies = []

    for b in test_cases:

        result, cycles = await multiply_with_latency(dut, a, b)

        expected = (a * b) & 0xFFFFFFFF

        assert result == expected, (
            f"0x{a:08x} * 0x{b:08x}: "
            f"expected 0x{expected:08x}, "
            f"got 0x{result:08x}"
        )

        latencies.append((b, cycles))

        dut._log.info(
            f"B = 0x{b:08x} | latency = {cycles} cycles"
        )

    # Confirm that the implementation is actually variable latency
    unique_latencies = {cycles for _, cycles in latencies}

    assert len(unique_latencies) > 1, (
        "All test cases had identical latency; "
        "variable-latency behavior was not observed"
    )