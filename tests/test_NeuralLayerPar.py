import os

import cocotb
import numpy as np

import assertions
import test_types
import utils


class NeuralLayerParTest(test_types.BaseTest):
    # code from this and NeuralLayerSeqTest might be abstracted
    def __init__(self, dut, in_: np.ndarray, weights: np.ndarray, bias: np.ndarray, in_size: int, out_size: int):
        self.dut = dut
        self.in_ = in_
        self.weights = weights
        self.bias = bias
        self.in_size = in_size
        self.out_size = out_size
        self.result = None

    def assign_input(self):
        getattr(self.dut, "in").value = utils.array_to_packed_integer(
            self.in_.flatten())
        self.dut.weights.value = utils.array_to_packed_integer(
            self.weights.flatten())
        self.dut.bias.value = utils.array_to_packed_integer(
            self.bias.flatten())

    def assign_output(self):
        self.result = utils.packed_integer_to_array(
            self.dut.result.value, self.out_size)

    def assert_result(self):
        assertions.assert_layer_forward_pass(
            self.in_, self.weights, self.bias, 0, self.result)


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
    test = NeuralLayerParTest(dut, data, weights, bias, in_size, out_size)
    await test.exec_test()


@cocotb.test()
async def test_neural_layer_seq_random(dut):
    in_size, out_size = get_sizes()
    min_max = (-100, 100)

    for _ in range(100):
        data = np.random.uniform(*min_max, size=(in_size, 1))
        weights = np.random.uniform(*min_max, size=(out_size, in_size))
        bias = np.random.uniform(*min_max, size=(out_size, 1))
        test = NeuralLayerParTest(dut, data, weights, bias, in_size, out_size)
        await test.exec_test()
