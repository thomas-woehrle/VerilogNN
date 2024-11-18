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


def assert_convertability(x):
    tolerance = 1e-1
    assert abs(x - ieee754_to_float(float_to_ieee754(x))
               ) < tolerance, f"Value {x} not convertible"


async def run_test(dut, a, b, tolerance=1e-3):
    assert_convertability(a)
    assert_convertability(b)

    dut.A.value = float_to_ieee754(a)
    dut.B.value = float_to_ieee754(b)

    await Timer(1)

    result = ieee754_to_float(dut.result.value)
    expected = a + b

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


@cocotb.test()
async def test_simple_add(dut):
    a = 1.0
    b = 1.0
    await run_test(dut, a, b)


@cocotb.test()
async def test_random_add(dut):
    """Test floating point addition with random values"""
    for _ in range(100):
        # Generate random float values
        a = random.uniform(-100, 100)
        b = random.uniform(-100, 100)

        await run_test(dut, a, b, tolerance=1e-3)


def test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent / "src"

    # proj_path/"FloatingCompare.v"] don't know why this is not needed in the sources
    sources = [proj_path/"FloatingAddition.v", ]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="FloatingAddition",
    )

    runner.test(hdl_toplevel="FloatingAddition",
                test_module="test_FloatingAddition")


if __name__ == "__main__":
    test_runner()
