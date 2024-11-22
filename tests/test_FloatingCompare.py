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

    result = dut.result.value
    expected = 1 if a >= b else 0

    assert result == expected, \
        f"Mismatch: {a} >= {b} = {result} (expected {expected})"


@cocotb.test()
async def test_compare_basic(dut):
    utils.pairwise_run_fct(dut, [-1.0, -0.5, 0.0, 0.5, 1.0], run_test)


@cocotb.test()
async def test_random_compare_simple(dut):
    max_val = 100
    for _ in range(1000):
        await utils.sample_and_run_fct(dut, -max_val, max_val, run_test)


@cocotb.test()
async def test_random_compare_full_range(dut):
    max_val = utils.IEEE754_MAX_VAL
    for _ in range(1000):
        await utils.sample_and_run_fct(dut, -max_val, max_val, run_test)


def test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent / "src"

    sources = [proj_path/"FloatingCompare.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="FloatingCompare",
    )

    runner.test(hdl_toplevel="FloatingCompare",
                test_module="test_FloatingCompare")


if __name__ == "__main__":
    test_runner()
