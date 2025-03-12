import numpy as np

import utils


def assert_addition(a, b, result):
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


def assert_multiplication(a, b, result):
    expected = a * b
    tolerance = utils.get_tolerance(a * b)

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} * {b} = {result} (expected {expected})"


def assert_divsion(a, b, result):
    expected = a / b
    # not sure whether this is the right level
    tolerance = max(
        utils.get_tolerance(a),
        utils.get_tolerance(b),
        utils.get_tolerance(a / b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {
            a} / {b} = {result} (expected {expected}, tolerance: {tolerance})"


def assert_vector_multiplication(a, b, result):
    expected = a @ b
    # not sure about this
    tolerance = utils.get_dot_product_tolerance(a, b)

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {
            a} @ {b} = {result} (expected: {expected}; tolerance: {tolerance})"


def assert_layer_forward_pass(data, weights, bias, activation, result):
    # TODO allow different activations than relu (=0)
    def relu(x):
        return np.maximum(0, x)

    expected = relu(weights @ data + bias).flatten()
    # this is not precise, but I don't know how to do this differently atm and it works okay.
    # It could be higher or lower than this.
    tolerance = max(utils.get_tolerances_for_array(data).max(),
                    utils.get_tolerances_for_array(weights).max(),
                    utils.get_tolerances_for_array(bias.max())) * 10e1

    assert np.all(abs(result - expected) < tolerance), (
        f"Layer forward pass is incorrect. \n"
        f"Actual:\n{result} \n"
        f"Expected:\n{expected} \n"
        f"Tolerance: {tolerance}"
    )
