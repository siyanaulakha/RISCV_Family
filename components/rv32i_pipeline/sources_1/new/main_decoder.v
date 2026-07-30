`timescale 1ns/1ps

module main_decoder (
    input  wire [6:0] op,
    output wire [1:0] ResultSrc,
    output wire       MemWrite,
    output reg        Branch,
    output wire       ALUSrc,
    output wire       RegWrite,
    output wire       Jump,
    output wire       Jalr,
    output wire [1:0] ImmSrc,
    output wire [1:0] ALUOp
);

    reg [10:0] controls;

    always @(*) begin
        Branch  = 1'b0;
        controls = 11'b0_00_0_0_00_00_0_0;

        casez (op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_Jalr
            7'b0000011: controls = 11'b1_00_1_0_01_00_0_0; // loads
            7'b0100011: controls = 11'b0_01_1_1_00_00_0_0; // stores
            7'b0110011: controls = 11'b1_00_0_0_00_10_0_0; // register ALU
            7'b1100011: begin
                controls = 11'b0_10_0_0_00_01_0_0;          // branches
                Branch   = 1'b1;
            end
            7'b0010011: controls = 11'b1_00_1_0_00_10_0_0; // immediate ALU
            7'b1101111: controls = 11'b1_11_0_0_10_00_1_0; // JAL
            7'b1100111: controls = 11'b1_00_1_0_10_00_0_1; // JALR
            7'b0?10111: controls = 11'b1_00_0_0_11_00_0_0; // LUI/AUIPC
            default:    controls = 11'b0_00_0_0_00_00_0_0;
        endcase
    end

    assign {
        RegWrite,
        ImmSrc,
        ALUSrc,
        MemWrite,
        ResultSrc,
        ALUOp,
        Jump,
        Jalr
    } = controls;

endmodule
