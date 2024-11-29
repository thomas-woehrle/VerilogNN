import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer

import test_VectorAddition


class VectorAdditionFlexTest(test_VectorAddition.VectorAdditionTest):
    def __init__(self, dut, A: list[float], B: list[float]):
        super().__init__(dut, A, B)
        self.clk = Clock(self.dut.clk, 1, units="ns")
        assert len(A), len(B)
        self.l = len(A)

    def assign_input(self):
        # clk is already assigned
        # Assigns A and B
        super().assign_input()
        self.dut.l.value = self.l

    async def exec_test(self):
        self.assign_input()

        await Timer(1, "ns")
        await cocotb.start(self.clk.start())

        await Timer(self.l + 1, "ns")

        assert (self.dut.done.value, 1)

        # x bits should be resolved to 0, since the Flex module creates vectors bigger than actually filled
        # export COCOTB_RESOLVE_X=ZEROS
        self.assign_output(width=self.l)
        self.assert_result()


@cocotb.test()
async def test_vector_addition_flex_basic(dut):
    test = VectorAdditionFlexTest(dut, [1.0], [1.0])
    await test.exec_test()
