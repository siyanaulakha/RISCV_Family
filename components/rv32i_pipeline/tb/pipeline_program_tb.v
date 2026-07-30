`timescale 1ns/1ps

module pipeline_program_tb;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg Ext_MemWrite = 1'b0;
    reg [31:0] Ext_WriteData = 32'b0;
    reg [31:0] Ext_DataAdr = 32'b0;

    wire MemWrite;
    wire [31:0] WriteData, DataAdr, ReadData, PC, Result;
    integer checks = 0;
    integer failures = 0;

    riscv_im_f #(.IMEM_FILE("rv32i_test.hex")) dut (
        .clk(clk), .reset(reset),
        .Ext_MemWrite(Ext_MemWrite),
        .Ext_WriteData(Ext_WriteData),
        .Ext_DataAdr(Ext_DataAdr),
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
            end else begin
                $display("PASS: x%0d=%08x", index, expected);
            end
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        reset <= 1'b0;

        repeat (500) begin
            @(posedge clk);
            if (^PC === 1'bx) begin
                $display("FAIL: PC contains X/Z at t=%0t", $time);
                $fatal(1);
            end
        end

        check_reg(0,  32'h00000000);
        check_reg(4,  32'h0000013c);
        check_reg(5,  32'h00000009);
        check_reg(7,  32'h00000005);
        check_reg(8,  32'hfffffffb);
        check_reg(9,  32'hfffffffa);
        check_reg(10, 32'h00000005);
        check_reg(11, 32'h00000005);
        check_reg(12, 32'h00000001);
        check_reg(14, 32'h00000005);
        check_reg(15, 32'h00000005);
        check_reg(16, 32'h00000004);
        check_reg(17, 32'h00000003);
        check_reg(18, 32'h00000001);
        check_reg(19, 32'h00000011);
        check_reg(20, 32'h00000008);
        check_reg(21, 32'h00000008);
        check_reg(22, 32'h00000011);
        check_reg(24, 32'h02000000);
        check_reg(25, 32'h02000060);
        check_reg(26, 32'h00000001);
        check_reg(27, 32'hfffffffd);
        check_reg(28, 32'h00000010);
        check_reg(29, 32'h00000001);
        check_reg(30, 32'h0000fffd);
        check_reg(31, 32'h00000130);

        checks = checks + 1;
        if (dut.datamem.data_ram[8][15:8] !== 8'h01) begin
            failures = failures + 1;
            $display("FAIL: SB result mismatch");
        end else $display("PASS: SB memory result");

        checks = checks + 1;
        if (dut.datamem.data_ram[9][31:16] !== 16'hfffd) begin
            failures = failures + 1;
            $display("FAIL: SH result mismatch");
        end else $display("PASS: SH memory result");

        checks = checks + 1;
        if (dut.datamem.data_ram[10] !== 32'h00000010) begin
            failures = failures + 1;
            $display("FAIL: SW result mismatch");
        end else $display("PASS: SW memory result");

        if (failures != 0) begin
            $display("FAIL: pipeline architectural regression %0d/%0d failed", failures, checks);
            $fatal(1);
        end
        $display("PASS: pipeline architectural regression completed; %0d/%0d checks passed", checks, checks);
        $finish;
    end

    initial begin
        #20000;
        $display("FAIL: timeout");
        $fatal(1);
    end
endmodule
