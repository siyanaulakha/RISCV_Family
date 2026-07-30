`timescale 1ns/1ps

module riscv_smoke_tb;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg Ext_MemWrite = 1'b0;
    reg [31:0] Ext_WriteData = 32'b0;
    reg [31:0] Ext_DataAdr = 32'b0;

    wire MemWrite;
    wire [31:0] WriteData, DataAdr, ReadData, PC, Result;

    RISC_V_IM dut (
        .clk(clk), .reset(reset),
        .Ext_MemWrite(Ext_MemWrite),
        .Ext_WriteData(Ext_WriteData),
        .Ext_DataAdr(Ext_DataAdr),
        .MemWrite(MemWrite), .WriteData(WriteData),
        .DataAdr(DataAdr), .ReadData(ReadData),
        .PC(PC), .Result(Result)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("riscv_smoke.vcd");
        $dumpvars(0, riscv_smoke_tb);

        repeat (3) @(posedge clk);
        reset <= 1'b0;
        repeat (20) begin
            @(posedge clk);
            if (^PC === 1'bx) begin
                $display("FAIL: PC contains X/Z at t=%0t", $time);
                $fatal(1);
            end
        end
        $display("PASS: smoke test completed; final PC=0x%08x", PC);
        $finish;
    end

    initial begin
        #5000;
        $display("FAIL: timeout");
        $fatal(1);
    end
endmodule
