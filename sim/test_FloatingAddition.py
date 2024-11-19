import math
import os
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer
import struct
import random


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
    expected = a + b
    tolerance = max(get_tolerance(a), get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


@cocotb.test()
async def test_add_basic(dut):
    await run_test(dut, 0.0, 0.0)
    await run_test(dut, 1.0, 1.0)
    await run_test(dut, -1.0, -1.0)
    await run_test(dut, 1.0, -1.0)
    await run_test(dut, -1.0, 1.0)


@cocotb.test()
async def test_random_add_simple(dut):
    """Test floating point addition with random values"""
    for _ in range(100):
        # Generate random float values
        a = random.uniform(-100, 100)
        b = random.uniform(-100, 100)

        await run_test(dut, a, b)


@cocotb.test()
async def test_random_add_full_range(dut):
    """Test floating point addition with random values"""
    for _ in range(1000):
        # Generate random float values
        # 3.4028235e38 is the highest value in ieee754 single precision float.
        # So 1.7e38 has to be handleable for sure
        a = random.uniform(-1.7e38, 1.7e38)
        b = random.uniform(-1.7e38, 1.7e38)

        await run_test(dut, a, b)


def test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent / "src"

    sources = [proj_path/"FloatingAddition.v", proj_path/"FloatingCompare.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="FloatingAddition",
    )

    runner.test(hdl_toplevel="FloatingAddition",
                test_module="test_FloatingAddition")


if __name__ == "__main__":
    test_runner()
