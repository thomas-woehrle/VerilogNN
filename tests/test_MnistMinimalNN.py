import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import utils
import test_types


IN_WIDTH = 784
L1_WIDTH = 128
L2_WIDTH = 64
OUT_WIDTH = 10


class MnistMinimalNNTest(test_types.BaseTest):
    def __init__(self, dut, in_, l1_weights, l1_biases, l2_weights, l2_biases, out_weights, out_biases):
        self.dut = dut
        self.in_ = in_
        self.l1_weights = l1_weights
        self.l1_biases = l1_biases
        self.l2_weights = l2_weights
        self.l2_biases = l2_biases
        self.out_weights = out_weights
        self.out_biases = out_biases
        self.out = None

    def assign_input(self):
        getattr(self.dut, "in").value = utils.array_to_packed_integer(self.in_)
        self.dut.l1_weights.value = utils.array_to_packed_integer(
            self.l1_weights.flatten())
        self.dut.l1_biases.value = utils.array_to_packed_integer(
            self.l1_biases.flatten())
        self.dut.l2_weights.value = utils.array_to_packed_integer(
            self.l2_weights.flatten())
        self.dut.l2_biases.value = utils.array_to_packed_integer(
            self.l2_biases.flatten())
        self.dut.out_weights.value = utils.array_to_packed_integer(
            self.out_weights.flatten())
        self.dut.out_biases.value = utils.array_to_packed_integer(
            self.out_biases.flatten())

    def assign_output(self):
        self.out = utils.packed_integer_to_array(
            self.dut.out.value, len(self.dut.out_biases))

    def assert_result(self):
        assert True

    async def exec_test(self):
        self.assign_input()
        await Timer(1)

        print("out_weights:")
        print(utils.packed_integer_to_array(
            self.dut.out_weights.value, OUT_WIDTH * L2_WIDTH))

        await cocotb.start(Clock(self.dut.clk, 1, "ns").start())

        counter = 0
        out_signals = (0, 0, 0, 0)
        l1_out = 0
        l2_out = 0
        out = 0
        while not self.dut.done.value:
            await Timer(1, "ns")
            new_out_signals = self.dut.l1_done.value, self.dut.l2_done.value, self.dut.out_done.value, self.dut.done.value
            if (new_out_signals != out_signals):
                print(f"Out signals changed after {counter} ns")
                out_signals = new_out_signals
                print(out_signals)
                l1_out = self.dut.l1_out.value
                l2_out = self.dut.l2_out.value
                out = self.dut.out.value
                print(f"l1_out: {l1_out}")
                print(f"l2_out: {l2_out}")
                print(f"out: {out}")
            counter += 1

        self.assign_output()
        self.assert_result()


"""
We do not have to worry about the second operand of the matrix multiplication being transposed,
because it is always gonna be a vector of shape N x 1.
"""


@cocotb.test()
async def test_basic(dut):
    min_max = (-10, 10)
    in_ = np.random.uniform(
        *min_max, size=(IN_WIDTH, 1)).astype(np.float32)
    l1_weights = np.random.uniform(
        *min_max, size=(L1_WIDTH, IN_WIDTH)).astype(np.float32)
    l1_biases = np.random.uniform(
        *min_max, size=(L1_WIDTH, 1)).astype(np.float32)
    l2_weights = np.random.uniform(
        *min_max, size=(L2_WIDTH, L1_WIDTH)).astype(np.float32)
    l2_biases = np.random.uniform(
        *min_max, size=(L2_WIDTH, 1)).astype(np.float32)
    out_weights = np.random.uniform(
        *min_max, size=(OUT_WIDTH, L2_WIDTH)).astype(np.float32)
    out_biases = np.random.uniform(
        *min_max, size=(OUT_WIDTH, 1)).astype(np.float32)

    test = MnistMinimalNNTest(
        dut, in_, l1_weights, l1_biases, l2_weights, l2_biases, out_weights, out_biases)
    await test.exec_test()
