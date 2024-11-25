import utils


def assert_addition(a, b, result):
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"
