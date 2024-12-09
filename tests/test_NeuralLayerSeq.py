import os

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import assertions
import test_types
import utils


class NeuralLayerSeqTest(test_types.BaseTest):
    def __init__(self, dut, data: np.ndarray, weights: np.ndarray, bias: np.ndarray, in_size: int, out_size: int):
        self.dut = dut
        self.data = data
        self.weights = weights
        self.bias = bias
        self.in_size = in_size
        self.out_size = out_size
        self.result = None

    def assign_input(self):
        self.dut.data.value = utils.array_to_packed_integer(
            self.data.flatten())
        self.dut.weights.value = utils.array_to_packed_integer(
            self.weights.flatten())
        self.dut.bias.value = utils.array_to_packed_integer(
            self.bias.flatten())

    def assign_output(self):
        self.result = utils.packed_integer_to_array(
            self.dut.result.value, self.out_size)

    def assert_result(self):
        assertions.assert_layer_forward_pass(
            self.data, self.weights, self.bias, 0, self.result)

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
async def test_neural_layer_seq_basic(dut):
    in_size, out_size = get_sizes()
    min_max = (-10, 10)

    data = np.random.uniform(*min_max, size=(in_size, 1))
    weights = np.random.uniform(*min_max, size=(out_size, in_size))
    bias = np.random.uniform(*min_max, size=(out_size, 1))
    test = NeuralLayerSeqTest(dut, data, weights, bias, in_size, out_size)
    await test.exec_test()


@cocotb.test()
async def test_neural_layer_seq_random(dut):
    in_size, out_size = get_sizes()
    min_max = (-100, 100)

    for _ in range(100):
        print(_)
        data = np.random.uniform(*min_max, size=(in_size, 1))
        weights = np.random.uniform(*min_max, size=(out_size, in_size))
        bias = np.random.uniform(*min_max, size=(out_size, 1))
        print("Data: ", data)
        print("Weights: ", weights)
        print("Bias: ", bias)
        test = NeuralLayerSeqTest(dut, data, weights, bias, in_size, out_size)
        await test.exec_test()
