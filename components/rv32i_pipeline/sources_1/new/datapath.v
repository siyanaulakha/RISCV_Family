`timescale 1ns/1ps

module datapath (
    input  wire        clk,
    input  wire        reset,
    input  wire [1:0]  ResultSrcD,
    input  wire        ALUSrcD,
    input  wire        RegWriteD,
    input  wire [1:0]  ImmSrcD,
    input  wire [3:0]  ALUControlD,
    input  wire        JalrD,
    input  wire        JumpD,
    input  wire        BranchD,
    input  wire        MemWriteD,
    output wire [31:0] PC,
    input  wire [31:0] Instr,
    output wire [31:0] Mem_WrAddr,
    output wire [31:0] Mem_WrData,
    input  wire [31:0] ReadData,
    output wire [31:0] InstrD,
    output wire [31:0] InstrMW,
    output wire        MemWriteMW,
    output wire [31:0] Result
);

    // Fetch/decode state.
    wire [31:0] PCPlus4;
    wire [31:0] PCNext;
    wire [31:0] PCD;
    wire [31:0] PC4D;
    wire [31:0] RD1D;
    wire [31:0] RD2D;
    wire [31:0] ImmExtD;

    // Decode source-use information prevents false load-use stalls on fields
    // that are immediate bits rather than register specifiers.
    reg UsesRS1D;
    reg UsesRS2D;

    // Execute-stage state.
    wire        RegWriteE;
    wire [1:0]  ResultSrcE;
    wire        MemWriteE;
    wire [3:0]  ALUControlE;
    wire        ALUSrcE;
    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] PCE;
    wire [4:0]  RdE;
    wire [4:0]  RS1E;
    wire [4:0]  RS2E;
    wire [31:0] ImmExtE;
    wire [31:0] InstrE;
    wire [31:0] PC4E;
    wire        JumpE;
    wire        BranchE;
    wire        JalrE;

    wire [1:0]  ForwardAE;
    wire [1:0]  ForwardBE;
    wire [31:0] SrcA;
    wire [31:0] RD2EF;
    wire [31:0] SrcB;
    wire [31:0] ALUResult;
    wire        Zero;
    wire        LessThan;
    wire        TakeBranchE;
    wire [31:0] PCTargetE;
    wire [31:0] JalrTargetE;
    wire        RedirectE;

    wire [31:0] AuiPC;
    wire [31:0] LauiPC;

    // Memory-stage state.
    wire        RegWriteMW;
    wire [1:0]  ResultSrcMW;
    wire [31:0] ALUResultMW;
    wire [31:0] LauiPCMW;
    wire [31:0] RD2MW;
    wire [4:0]  RdMW;
    wire [31:0] PC4MW;
    wire [31:0] PCMW;
    wire [31:0] ForwardValueMW;

    // Writeback-stage state.
    wire        RegWriteWB;
    wire [1:0]  ResultSrcWB;
    wire [31:0] ALUResultWB;
    wire [31:0] LauiPCWB;
    wire [31:0] ReadDataWB;
    wire [4:0]  RdWB;
    wire [31:0] PC4WB;
    wire [31:0] PCWB;

    // Hazard controls.
    wire StallPC;
    wire StallF;
    wire FlushF;
    wire FlushD;

    always @(*) begin
        UsesRS1D = 1'b0;
        UsesRS2D = 1'b0;

        case (InstrD[6:0])
            7'b0110011: begin UsesRS1D = 1'b1; UsesRS2D = 1'b1; end // R
            7'b0010011: begin UsesRS1D = 1'b1; UsesRS2D = 1'b0; end // I ALU
            7'b0000011: begin UsesRS1D = 1'b1; UsesRS2D = 1'b0; end // load
            7'b0100011: begin UsesRS1D = 1'b1; UsesRS2D = 1'b1; end // store
            7'b1100011: begin UsesRS1D = 1'b1; UsesRS2D = 1'b1; end // branch
            7'b1100111: begin UsesRS1D = 1'b1; UsesRS2D = 1'b0; end // JALR
            default:    begin UsesRS1D = 1'b0; UsesRS2D = 1'b0; end
        endcase
    end

    // Fetch and next-PC logic.
    adder pcadd4 (
        .a(PC),
        .b(32'd4),
        .sum(PCPlus4)
    );

    adder pcaddtarget (
        .a(PCE),
        .b(ImmExtE),
        .sum(PCTargetE)
    );

    assign JalrTargetE = {ALUResult[31:1], 1'b0};
    assign RedirectE   = (TakeBranchE && BranchE) || JumpE || JalrE;
    assign PCNext      = JalrE ? JalrTargetE :
                         (((TakeBranchE && BranchE) || JumpE) ?
                          PCTargetE : PCPlus4);

    reset_ff #(32) pcreg (
        .clk(clk),
        .rst(reset),
        .stall(StallPC),
        .d(PCNext),
        .q(PC)
    );

    IF_PL_REG if_id (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .PC_in(PC),
        .PC4_in(PCPlus4),
        .Stall(StallF),
        .Flush(FlushF),
        .InstrF(InstrD),
        .PCF(PCD),
        .PC4_out(PC4D)
    );

    // Decode stage.
    reg_file rf (
        .clk(clk),
        .wr_en(RegWriteWB),
        .rd_addr1(InstrD[19:15]),
        .rd_addr2(InstrD[24:20]),
        .wr_addr(RdWB),
        .wr_data(Result),
        .rd_data1(RD1D),
        .rd_data2(RD2D)
    );

    imm_extend ext (
        .instr(InstrD[31:7]),
        .immsrc(ImmSrcD),
        .immext(ImmExtD)
    );

    DE_PL_REG id_ex (
        .clk(clk),
        .reset(reset),
        .Flush(FlushD),
        .ResultSrcD(ResultSrcD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        .ALUControlD(ALUControlD),
        .MemWriteD(MemWriteD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .PCD(PCD),
        .RdD(InstrD[11:7]),
        .RS1D(InstrD[19:15]),
        .RS2D(InstrD[24:20]),
        .ImmExtD(ImmExtD),
        .InstrD(InstrD),
        .PC4D(PC4D),
        .Jump(JumpD),
        .Branch(BranchD),
        .jalr(JalrD),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .RdE(RdE),
        .RS1E(RS1E),
        .RS2E(RS2E),
        .ImmExtE(ImmExtE),
        .InstrE(InstrE),
        .PC4E(PC4E),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .jalrE(JalrE)
    );

    // Execute stage with EX/MEM and MEM/WB forwarding.
    mux3 #(32) forward_a (
        .d0(RD1E),
        .d1(Result),
        .d2(ForwardValueMW),
        .sel(ForwardAE),
        .y(SrcA)
    );

    mux3 #(32) forward_b (
        .d0(RD2E),
        .d1(Result),
        .d2(ForwardValueMW),
        .sel(ForwardBE),
        .y(RD2EF)
    );

    mux2 #(32) src_b_mux (
        .d0(RD2EF),
        .d1(ImmExtE),
        .sel(ALUSrcE),
        .y(SrcB)
    );

    alu execute_alu (
        .a(SrcA),
        .b(SrcB),
        .alu_ctrl(ALUControlE),
        .alu_out(ALUResult),
        .zero(Zero)
    );

    assign LessThan = ALUResult[0];

    branch_compare branch_cmp (
        .funct3(InstrE[14:12]),
        .zero(Zero),
        .less_than(LessThan),
        .take(TakeBranchE)
    );

    adder #(32) auipc_adder (
        .a({InstrE[31:12], 12'b0}),
        .b(PCE),
        .sum(AuiPC)
    );

    mux2 #(32) lui_auipc_mux (
        .d0(AuiPC),
        .d1({InstrE[31:12], 12'b0}),
        .sel(InstrE[5]),
        .y(LauiPC)
    );

    MW_PL_REG ex_mem (
        .clk(clk),
        .reset(reset),
        .PCE(PCE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .ALUResult(ALUResult),
        .LauiPC(LauiPC),
        .RD2E(RD2EF),
        .InstrE(InstrE),
        .RdE(RdE),
        .PC4E(PC4E),
        .PCMW(PCMW),
        .RegWriteMW(RegWriteMW),
        .ResultSrcMW(ResultSrcMW),
        .MemWriteMW(MemWriteMW),
        .ALUResultMW(ALUResultMW),
        .LauiPCMW(LauiPCMW),
        .RD2MW(RD2MW),
        .InstrMW(InstrMW),
        .RdMW(RdMW),
        .PC4MW(PC4MW)
    );

    assign Mem_WrAddr = ALUResultMW;
    assign Mem_WrData = RD2MW;

    // This is the value available from the memory stage for forwarding.
    // Loads are still interlocked for one cycle, but the correct load value is
    // selected here as well as JAL and LUI/AUIPC results.
    mux4 #(32) memory_result_mux (
        .d0(ALUResultMW),
        .d1(ReadData),
        .d2(PC4MW),
        .d3(LauiPCMW),
        .sel(ResultSrcMW),
        .y(ForwardValueMW)
    );

    WB_PL_REG mem_wb (
        .clk(clk),
        .reset(reset),
        .PCMW(PCMW),
        .RegWriteMW(RegWriteMW),
        .ResultSrcMW(ResultSrcMW),
        .ALUResultMW(ALUResultMW),
        .LauiPCMW(LauiPCMW),
        .ReadData(ReadData),
        .RdMW(RdMW),
        .PC4MW(PC4MW),
        .PCWB(PCWB),
        .RegWriteWB(RegWriteWB),
        .ResultSrcWB(ResultSrcWB),
        .ALUResultWB(ALUResultWB),
        .LauiPCWB(LauiPCWB),
        .ReadDataWB(ReadDataWB),
        .RdWB(RdWB),
        .PC4WB(PC4WB)
    );

    mux4 #(32) writeback_result_mux (
        .d0(ALUResultWB),
        .d1(ReadDataWB),
        .d2(PC4WB),
        .d3(LauiPCWB),
        .sel(ResultSrcWB),
        .y(Result)
    );

    HAZARD_UNIT hazard_unit (
        .RS1D(InstrD[19:15]),
        .RS2D(InstrD[24:20]),
        .UsesRS1D(UsesRS1D),
        .UsesRS2D(UsesRS2D),
        .RS1E(RS1E),
        .RS2E(RS2E),
        .RdE(RdE),
        .RdMW(RdMW),
        .RdWB(RdWB),
        .RegWriteMW(RegWriteMW),
        .RegWriteWB(RegWriteWB),
        .ResultSrcE(ResultSrcE),
        .RedirectE(RedirectE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallPC(StallPC),
        .StallF(StallF),
        .FlushF(FlushF),
        .FlushD(FlushD)
    );

endmodule
