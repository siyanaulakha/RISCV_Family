`timescale 1ns/1ps

module riscv_cpu (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] PC,
    input  wire [31:0] Instr,
    output wire        MemWriteMW,
    output wire [31:0] Mem_WrAddr,
    output wire [31:0] Mem_WrData,
    input  wire [31:0] ReadData,
    output wire [31:0] InstrMW,
    output wire [31:0] Result
);

    wire       ALUSrc;
    wire       RegWrite;
    wire       Jump;
    wire       Branch;
    wire       Jalr;
    wire       MemWrite;
    wire [1:0] ResultSrc;
    wire [1:0] ImmSrc;
    wire [3:0] ALUControl;
    wire [31:0] InstrD;

    controller c (
        .op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7b5(InstrD[30]),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .Branch(Branch),
        .Jalr(Jalr),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .ResultSrcD(ResultSrc),
        .ALUSrcD(ALUSrc),
        .RegWriteD(RegWrite),
        .ImmSrcD(ImmSrc),
        .ALUControlD(ALUControl),
        .JalrD(Jalr),
        .JumpD(Jump),
        .BranchD(Branch),
        .MemWriteD(MemWrite),
        .PC(PC),
        .Instr(Instr),
        .Mem_WrAddr(Mem_WrAddr),
        .Mem_WrData(Mem_WrData),
        .ReadData(ReadData),
        .InstrD(InstrD),
        .InstrMW(InstrMW),
        .MemWriteMW(MemWriteMW),
        .Result(Result)
    );

endmodule
