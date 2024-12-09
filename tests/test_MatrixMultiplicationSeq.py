import os

import cocotb
import numpy as np
from cocotb.clock import Clock

import test_MatrixMultiplicationFlex
import utils


class MatrixMultiplicationSeqTest(test_MatrixMultiplicationFlex.MatrixMultiplicationFlexTest):
    def __init__(self, dut, A: np.ndarray, B: np.ndarray):
        self.dut = dut
        self.A = A
        self.B_T = B.transpose() if B is not None else B
        self.l = None
        self.m = None
        self.n = None
        self.clk = Clock(self.dut.clk, 1, "ns")
        self.result = None

    def assign_input(self):
        assert len(self.A.shape) == len(self.B_T.shape) == 2, (
            f"len(self.A.shape): {self.A.shape}\n"
            f"len(self.B.shape): {self.B_T.shape}\n"
        )
        assert self.A.shape[1] == self.B_T.shape[1]
        self.dut.A.value = utils.array_to_packed_integer(self.A.flatten())
        self.dut.B_T.value = utils.array_to_packed_integer(self.B_T.flatten())
        self.l = self.A.shape[0]
        self.m = self.A.shape[1]
        self.n = self.B_T.shape[0]  # B_T is transposed


def get_lmn():
    return int(os.getenv('L')), int(os.getenv('M')), int(os.getenv('N'))


MIN_MAX = (-10, 10)


@cocotb.test()
async def test_matrix_multiplication_seq_basic(dut):
    l, m, n = get_lmn()
    a = np.random.uniform(*MIN_MAX, size=(l, m))
    b = np.random.uniform(*MIN_MAX, size=(m, n))

    test = MatrixMultiplicationSeqTest(dut, a, b)
    await test.exec_test()


@cocotb.test()
async def test_matrix_multiplication_seq_random(dut):
    l, m, n = get_lmn()
    test = MatrixMultiplicationSeqTest(dut, None, None)

    for _ in range(100):
        a = np.random.uniform(*MIN_MAX, size=(l, m))
        b = np.random.uniform(*MIN_MAX, size=(m, n))

        test.A = a
        test.B_T = b.transpose()
        await test.exec_test()
