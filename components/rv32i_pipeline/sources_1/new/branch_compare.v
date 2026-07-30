`timescale 1ns/1ps

module branch_compare (
    input  wire [2:0] funct3,
    input  wire       zero,
    input  wire       less_than,
    output reg        take
);

    always @(*) begin
        case (funct3)
            3'b000: take =  zero;       // BEQ
            3'b001: take = !zero;       // BNE
            3'b100: take =  less_than;  // BLT
            3'b101: take = !less_than;  // BGE
            3'b110: take =  less_than;  // BLTU
            3'b111: take = !less_than;  // BGEU
            default: take = 1'b0;
        endcase
    end

endmodule
