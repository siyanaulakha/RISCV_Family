`timescale 1ns/1ps

module alu_decoder (
    input  wire       opb5,
    input  wire [2:0] funct3,
    input  wire       funct7b5,
    input  wire [1:0] ALUOp,
    output reg  [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // address/addition

            2'b01: begin
                // Branch comparisons. Equality branches subtract; relational
                // branches produce an explicit one-bit less-than result.
                case (funct3)
                    3'b000,
                    3'b001: ALUControl = 4'b0001; // BEQ/BNE: SUB
                    3'b100,
                    3'b101: ALUControl = 4'b0101; // BLT/BGE: signed SLT
                    3'b110,
                    3'b111: ALUControl = 4'b1001; // BLTU/BGEU: unsigned SLTU
                    default: ALUControl = 4'b0001;
                endcase
            end

            default: begin
                case (funct3)
                    3'b000:
                        ALUControl = (funct7b5 && opb5) ? 4'b0001 : 4'b0000;
                    3'b001: ALUControl = 4'b0111; // SLL/SLLI
                    3'b010: ALUControl = 4'b0101; // SLT/SLTI
                    3'b011: ALUControl = 4'b1001; // SLTU/SLTIU
                    3'b100: ALUControl = 4'b0100; // XOR/XORI
                    3'b101: ALUControl = funct7b5 ? 4'b1000 : 4'b0110;
                    3'b110: ALUControl = 4'b0011; // OR/ORI
                    3'b111: ALUControl = 4'b0010; // AND/ANDI
                    default: ALUControl = 4'b0000;
                endcase
            end
        endcase
    end

endmodule
