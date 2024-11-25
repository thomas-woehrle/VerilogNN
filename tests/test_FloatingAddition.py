import cocotb

import assertions
import utils
import test_types


class FloatingAdditionTest(test_types.FloatingPointBaseTest):
    def assert_result(self):
        assertions.assert_addition(self.A, self.B, self.result)


@cocotb.test()
async def test_add_basic(dut):
    test = FloatingAdditionTest(dut, None, None)
    for a in utils.BASIC_VALUES:
        for b in utils.BASIC_VALUES:
            test.A = a
            test.B = b
            await test.exec_test()


@cocotb.test()
async def test_random_add_simple(dut):
    test = FloatingAdditionTest(dut, None, None)
    max_val = 100
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()


@cocotb.test()
async def test_random_add_full_range(dut):
    test = FloatingAdditionTest(dut, None, None)
    max_val = utils.IEEE754_MAX_VAL / 2
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()
