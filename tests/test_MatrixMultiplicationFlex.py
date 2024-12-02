import random

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import assertions
import utils
import test_types

# When introducing a test for MatrixMultiplicationPar in the future, parts of this can be reused


class MatrixMultiplicationFlexTest(test_types.BaseTest):
    def __init__(self, dut, A: np.ndarray, B: np.ndarray):
        self.dut = dut
        self.A = A
        self.B_T = B.transpose()
        self.l = None
        self.m = None
        self.n = None
        self.clk = Clock(self.dut.clk, 1, "ns")
        self.result = None

    def assign_input(self):
        assert len(self.A.shape) == len(self.B_T.shape) == 2
        assert self.A.shape[1] == self.B_T.shape[1]
        self.dut.A.value = utils.array_to_packed_integer(self.A.flatten())
        self.dut.B_T.value = utils.array_to_packed_integer(self.B_T.flatten())
        self.l = self.A.shape[0]
        self.m = self.A.shape[1]
        self.n = self.B_T.shape[0]  # B_T is transposed
        self.dut.l.value = self.l
        self.dut.m.value = self.m
        self.dut.n.value = self.n

    def assign_output(self):
        temp = utils.packed_integer_to_array(
            self.dut.result.value, self.l * self.n)
        self.result = np.array(temp).reshape(self.l, self.n)

    def assert_result(self):
        try:
            for i in range(self.result.shape[0]):
                for j in range(self.result.shape[1]):
                    assertions.assert_vector_multiplication(
                        self.A[i], self.B_T[j], self.result[i][j])
        except AssertionError as e:
            print("Tried to calculate:")
            print(f"{self.A} @ \n{self.B_T.transpose()}")
            raise e

    async def exec_test(self):
        self.assign_input()

        await Timer(1)
        await cocotb.start(self.clk.start())

        while not self.dut.done.value:
            await Timer(1)

        self.assign_output()
        self.assert_result()


# Currently assumed:
# A of shape l x m, B of shape m x n where n == 1, l, m <= 3


@cocotb.test()
async def test_matrix_multiplication_flex_basic(dut):
    a = np.array([[1, 1, 1], [2, 2, 2]], dtype=np.float32)
    b = np.array([1, 1, 1], dtype=np.float32).reshape(3, 1)

    test = MatrixMultiplicationFlexTest(dut, a, b)
    await test.exec_test()


@cocotb.test()
async def test_matrix_multiplication_flex_random_simple(dut):
    test = MatrixMultiplicationFlexTest(dut, np.array([]), np.array([]))

    for _ in range(100):
        print(_)
        l = random.randint(1, 3)
        m = random.randint(1, 3)
        a = np.random.uniform(-100, 100, size=(l, m))
        b = np.random.uniform(-100, 100, size=(m, 1))
        test.A = a
        test.B_T = b.transpose()
        await test.exec_test()
