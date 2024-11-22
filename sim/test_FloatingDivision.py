import math
import os
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer
import struct
import random


IEEE754_MAX_VAL = 3.4028235e38


def float_to_ieee754(value: float) -> int:
    """Convert a float to its IEEE 754 single-precision binary representation as an Integer"""
    return struct.unpack('>I', struct.pack('>f', value))[0]


def ieee754_to_float(value):
    """Convert IEEE-754 binary back to float"""
    # Convert BinaryValue to integer
    return struct.unpack('>f', struct.pack('>I', value))[0]


def get_tolerance(value):
    """Calculate the tolerance for a value, considering that 6 digits can be represented precisely"""
    if value == 0:
        n_digits = 1
    else:
        n_digits = math.floor(math.log10(abs(value))) + 1

    return 10 ** (-6 + n_digits)


def assert_convertability(x):
    tolerance = get_tolerance(x)
    assert abs(x - ieee754_to_float(float_to_ieee754(x))
               ) < tolerance, f"Value {x} not convertible"


async def run_test(dut, a, b):
    assert_convertability(a)
    assert_convertability(b)

    dut.A.value = float_to_ieee754(a)
    dut.B.value = float_to_ieee754(b)

    await Timer(1)

    result = ieee754_to_float(dut.result.value)
    expected = a / b
    # TODO check whether this is the right level
    tolerance = max(get_tolerance(a), get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} / {b} = {result} (expected {expected})"


@cocotb.test()
async def test_multiplication_basic(dut):
    await run_test(dut, 1.0, 1.0)
    await run_test(dut, -1.0, -1.0)
    await run_test(dut, 1.0, -1.0)
    await run_test(dut, -1.0, 1.0)
    await run_test(dut, 0.5, 0.5)
    await run_test(dut, -0.5, -0.5)


@cocotb.test()
async def test_random_multiplication_simple(dut):
    """Test floating point multiplication with simple random values"""
    for _ in range(100):
        # Generate random float values
        a = random.uniform(-100, 100)
        b = random.uniform(-100, 100)

        await run_test(dut, a, b)


@cocotb.test()
async def test_random_add_full_range(dut):
    """Test floating point multiplication with random values from the full range"""
    max_safe_val = math.sqrt(IEEE754_MAX_VAL)
    for _ in range(1000):
        # Generate random float values
        a = random.uniform(-max_safe_val, max_safe_val)
        b = random.uniform(-max_safe_val, max_safe_val)

        await run_test(dut, a, b)


def test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent / "src"

    sources = [proj_path/"FloatingDivision.v", proj_path /
               "FloatingMultiplication.v", proj_path/"FloatingAddition.v", proj_path/"FloatingCompare.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="FloatingDivision",
    )

    runner.test(hdl_toplevel="FloatingDivision",
                test_module="test_FloatingDivision")


if __name__ == "__main__":
    test_runner()
