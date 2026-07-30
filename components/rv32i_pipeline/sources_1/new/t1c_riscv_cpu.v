`timescale 1ns/1ps

module riscv_im_f #(
    parameter IMEM_FILE = "rv32i_test.hex"
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        Ext_MemWrite,
    input  wire [31:0] Ext_WriteData,
    input  wire [31:0] Ext_DataAdr,
    output wire        MemWrite,
    output wire [31:0] WriteData,
    output wire [31:0] DataAdr,
    output wire [31:0] ReadData,
    output wire [31:0] PC,
    output wire [31:0] Result
);

    wire [31:0] Instr;
    wire [31:0] InstrMW;
    wire [31:0] DataAdr_rv32;
    wire [31:0] WriteData_rv32;
    wire        MemWrite_rv32;
    wire [2:0]  MemFunct3;

    riscv_cpu rvcpu (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWriteMW(MemWrite_rv32),
        .Mem_WrAddr(DataAdr_rv32),
        .Mem_WrData(WriteData_rv32),
        .ReadData(ReadData),
        .InstrMW(InstrMW),
        .Result(Result)
    );

    instr_mem #(.INIT_FILE(IMEM_FILE)) instrmem (
        .instr_addr(PC),
        .instr(Instr)
    );

    data_mem datamem (
        .clk(clk),
        .wr_en(MemWrite),
        .funct3(MemFunct3),
        .wr_addr(DataAdr),
        .wr_data(WriteData),
        .rd_data_mem(ReadData)
    );

    assign MemWrite  = (Ext_MemWrite && reset) ? 1'b1 : MemWrite_rv32;
    assign MemFunct3 = (Ext_MemWrite && reset) ? 3'b010 : InstrMW[14:12];
    assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;
    assign DataAdr   = reset ? Ext_DataAdr : DataAdr_rv32;

endmodule
