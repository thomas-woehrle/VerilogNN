import cocotb
import numpy as np

import utils
import test_types


def assert_addition(a, b, result):
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


class VectorAdditionTest(test_types.VectorBaseTest):
    def assert_result(self):
        for i in range(len(self.result)):
            assert_addition(self.A[i], self.B[i], self.result[i])


@cocotb.test()
async def test_vector_add_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorAdditionTest(dut, a, b).exec_test()
