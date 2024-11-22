import os
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer

import utils


async def run_test(dut, a, b):
    utils.assert_convertibility(a)
    utils.assert_convertibility(b)

    dut.A.value = utils.float_to_ieee754(a)
    dut.B.value = utils.float_to_ieee754(b)

    await Timer(1)

    result = utils.ieee754_to_float(dut.result.value)
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


@cocotb.test()
async def test_add_basic(dut):
    utils.pairwise_run_fct(dut, [-1.0, -0.5, 0.0, 0.5, 1.0], run_test)


@cocotb.test()
async def test_random_add_simple(dut):
    """Test floating point addition with basic random values"""
    max_val = 100
    for _ in range(1000):
        await utils.sample_and_run_fct(dut, -max_val, max_val, run_test)


@cocotb.test()
async def test_random_add_full_range(dut):
    """Test floating point addition with random values from the full range"""
    max_val = utils.IEEE754_MAX_VAL / 2
    for _ in range(1000):
        await utils.sample_and_run_fct(dut, -max_val, max_val, run_test)
