import cocotb
import numpy as np
from cocotb.triggers import Timer

import utils


def vector_from_np(array):
    """Generate vector from the given array. Assumes 1-dimensional array."""
    return [utils.float_to_ieee754(x) for x in array]


def np_array_from_vector(vector):
    return np.array([utils.ieee754_to_float(x) for x in vector])


def pack_vector(vector):
    """Pack list of 32-bit values into single value, which can be assigned to a wire"""
    result = 0
    for i, val in enumerate(vector):
        result |= (val << (32 * i))
    return result


def unpack_vector(packed_value, width):
    """Unpack single value into list of 32-bit values"""
    mask = (1 << 32) - 1
    return [(packed_value >> (32 * i)) & mask for i in range(width)]


def assert_addition(a, b, result):
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


def assert_vector_addition(a, b, result):
    for i in range(len(result)):
        assert_addition(a[i], b[i], result[i])


async def run_test(dut, a, b, assert_fct):
    """Runs test for a, b as inputs calling assert_fct at the end.

    Args:
        dut: The devivce under test.
        a: The first input, human-readable.
        b: The second input, human-readable.
        assert_fct: Assert function to be used. Expected to accept a, b and result all human-readable.
    """
    dut.A.value = pack_vector(vector_from_np(a))
    dut.B.value = pack_vector(vector_from_np(b))

    await Timer(1)

    result = np_array_from_vector(unpack_vector(dut.result.value, 3))
    assert_fct(a, b, result)


@cocotb.test()
async def test_vector_add_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await run_test(dut, a, b, assert_vector_addition)
