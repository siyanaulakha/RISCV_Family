module DE_PL_REG (
    input         clk,
    input         reset,
    input         Flush,
    input  [1:0]  ResultSrcD,
    input         ALUSrcD,
    input         RegWriteD,
    input  [3:0]  ALUControlD,
    input         MemWriteD,
    input  [31:0] RD1D,
    input  [31:0] RD2D,
    input  [31:0] PCD,
    input  [4:0]  RdD,
    input  [4:0]  RS1D,
    input  [4:0]  RS2D,
    input  [31:0] ImmExtD,
    input  [31:0] InstrD,
    input  [31:0] PC4D,
    input         Jump,
    input         Branch,
    input         jalr,

    output reg        RegWriteE,
    output reg [1:0]  ResultSrcE,
    output reg        MemWriteE,
    output reg [3:0]  ALUControlE,
    output reg        ALUSrcE,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] PCE,
    output reg [4:0]  RdE,
    output reg [4:0]  RS1E,
    output reg [4:0]  RS2E,
    output reg [31:0] ImmExtE,
    output reg [31:0] InstrE,
    output reg [31:0] PC4E,
    output reg        JumpE,
    output reg        BranchE,
    output reg        jalrE
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            MemWriteE   <= 1'b0;
            ALUControlE <= 4'b0000;
            ALUSrcE     <= 1'b0;
            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            PCE         <= 32'b0;
            RdE         <= 5'b0;
            RS1E        <= 5'b0;
            RS2E        <= 5'b0;
            ImmExtE     <= 32'b0;
            InstrE      <= 32'b0;
            PC4E        <= 32'b0;
            JumpE       <= 1'b0;
            BranchE     <= 1'b0;
            jalrE       <= 1'b0;
        end else if (Flush) begin
            RegWriteE   <= 1'b0;
            ResultSrcE  <= 2'b00;
            MemWriteE   <= 1'b0;
            ALUControlE <= 4'b0000;
            ALUSrcE     <= 1'b0;
            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            PCE         <= 32'b0;
            RdE         <= 5'b0;
            RS1E        <= 5'b0;
            RS2E        <= 5'b0;
            ImmExtE     <= 32'b0;
            InstrE      <= 32'b0;
            PC4E        <= 32'b0;
            JumpE       <= 1'b0;
            BranchE     <= 1'b0;
            jalrE       <= 1'b0;
        end else begin
            RegWriteE   <= RegWriteD;
            ResultSrcE  <= ResultSrcD;
            MemWriteE   <= MemWriteD;
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;
            RD1E        <= RD1D;
            RD2E        <= RD2D;
            PCE         <= PCD;
            RdE         <= RdD;
            RS1E        <= RS1D;
            RS2E        <= RS2D;
            ImmExtE     <= ImmExtD;
            InstrE      <= InstrD;
            PC4E        <= PC4D;
            JumpE       <= Jump;
            BranchE     <= Branch;
            jalrE       <= jalr;
        end
    end

endmodule
