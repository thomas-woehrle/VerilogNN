import os

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import utils
import test_types


class NeuralLayerSeqTest(test_types.BaseTest):
    def __init__(self, dut, data, weights, bias):
        self.dut = dut
        self.data = data
        self.weights = weights
        self.bias = bias

    def assign_input(self):
        self.dut.data.value = utils.array_to_packed_integer(
            self.data.flatten())
        self.dut.weights.value = utils.array_to_packed_integer(
            self.weights.flatten())
        self.dut.bias.value = utils.array_to_packed_integer(
            self.bias.flatten())

    def assign_output(self):
        pass

    def assert_result(self):
        pass

    async def exec_test(self):
        self.assign_input()
        await Timer(1)

        await cocotb.start(Clock(self.dut.clk, 1, "ns").start())

        while not self.dut.done.value:
            await Timer(1, "ns")

        self.assign_output()
        self.assert_result()


def get_sizes():
    """IN_SIZE and OUT_SIZE are parameters of NeuralLayerSeq, determining the width of the layer.
    They are set via key=value pairs when invocating the test and turned into env variables in runner.py"""
    return int(os.getenv("IN_SIZE")), int(os.getenv("OUT_SIZE"))


@cocotb.test()
async def test_basic(dut):
    in_size, out_size = get_sizes()
    min_max = (-10, 10)
    data = np.random.uniform(*min_max, size=(in_size, 1))
    weights = np.random.uniform(*min_max, size=(out_size, in_size))
    bias = np.random.uniform(*min_max, size=(out_size, 1))
    test = NeuralLayerSeqTest(dut, data, weights, bias)

    await test.exec_test()
