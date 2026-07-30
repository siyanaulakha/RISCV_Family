`timescale 1ns/1ps

module pipeline_hazard_program_tb;
    reg clk = 1'b0;
    reg reset = 1'b1;
    wire MemWrite;
    wire [31:0] WriteData, DataAdr, ReadData, PC, Result;
    integer checks = 0;
    integer failures = 0;

    riscv_im_f #(.IMEM_FILE("hazard_test.hex")) dut (
        .clk(clk), .reset(reset),
        .Ext_MemWrite(1'b0),
        .Ext_WriteData(32'b0),
        .Ext_DataAdr(32'b0),
        .MemWrite(MemWrite), .WriteData(WriteData),
        .DataAdr(DataAdr), .ReadData(ReadData),
        .PC(PC), .Result(Result)
    );

    always #5 clk = ~clk;

    task check_reg;
        input [4:0] index;
        input [31:0] expected;
        begin
            checks = checks + 1;
            if (dut.rvcpu.dp.rf.reg_file_arr[index] !== expected) begin
                failures = failures + 1;
                $display("FAIL: x%0d expected=%08x got=%08x", index, expected,
                         dut.rvcpu.dp.rf.reg_file_arr[index]);
            end else $display("PASS: x%0d=%08x", index, expected);
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        reset <= 1'b0;
        repeat (120) @(posedge clk);

        check_reg(1,  32'h00000005);
        check_reg(2,  32'h0000000a);
        check_reg(3,  32'h0000000f);
        check_reg(4,  32'h0000000f);
        check_reg(5,  32'h00000014);
        check_reg(6,  32'h00000002);
        check_reg(7,  32'h00000014);
        check_reg(8,  32'h12345000);
        check_reg(9,  32'h12345001);
        check_reg(10, 32'h00001030);
        check_reg(11, 32'h00001031);
        check_reg(12, 32'h0000003c);
        check_reg(13, 32'h00000002);
        check_reg(14, 32'h00000051);
        check_reg(15, 32'h0000004c);
        check_reg(16, 32'h00000002);

        checks = checks + 1;
        if (dut.datamem.data_ram[0] !== 32'h0000000f) begin
            failures = failures + 1;
            $display("FAIL: forwarded store/load expected memory[0]=15 got=%08x",
                     dut.datamem.data_ram[0]);
        end else $display("PASS: store-data forwarding and load result");

        if (failures != 0) begin
            $display("FAIL: pipeline hazard program %0d/%0d failed", failures, checks);
            $fatal(1);
        end
        $display("PASS: pipeline hazard program completed; %0d/%0d checks passed", checks, checks);
        $finish;
    end

    initial begin
        #10000;
        $display("FAIL: timeout");
        $fatal(1);
    end
endmodule
