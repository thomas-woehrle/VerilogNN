import cocotb
import numpy as np

import assertions
import test_types


class VectorAdditionTest(test_types.VectorBaseTest):
    def assert_result(self):
        for i in range(len(self.result)):
            assertions.assert_addition(self.A[i], self.B[i], self.result[i])


@cocotb.test()
async def test_vector_add_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorAdditionTest(dut, a, b).exec_test()
