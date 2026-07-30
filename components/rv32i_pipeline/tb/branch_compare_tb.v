`timescale 1ns/1ps

module branch_compare_tb;
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [2:0]  funct3;
    wire [3:0]  alu_control;
    wire [31:0] alu_out;
    wire        zero;
    wire        take;

    integer checks = 0;
    integer failures = 0;

    alu_decoder decode (
        .opb5(1'b1),
        .funct3(funct3),
        .funct7b5(1'b0),
        .ALUOp(2'b01),
        .ALUControl(alu_control)
    );

    alu compare_alu (
        .a(a),
        .b(b),
        .alu_ctrl(alu_control),
        .alu_out(alu_out),
        .zero(zero)
    );

    branch_compare compare (
        .funct3(funct3),
        .zero(zero),
        .less_than(alu_out[0]),
        .take(take)
    );

    task check;
        input [8*48-1:0] label;
        input [2:0] f3;
        input [31:0] lhs;
        input [31:0] rhs;
        input expected;
        begin
            funct3 = f3;
            a = lhs;
            b = rhs;
            #1;
            checks = checks + 1;
            if (take !== expected) begin
                failures = failures + 1;
                $display("FAIL: %0s a=%08x b=%08x expected=%0d got=%0d", label, a, b, expected, take);
            end else begin
                $display("PASS: %0s a=%08x b=%08x taken=%0d", label, a, b, take);
            end
        end
    endtask

    initial begin
        check("BEQ equal",                         3'b000, 32'd5,        32'd5,        1'b1);
        check("BEQ not equal",                     3'b000, 32'd5,        32'd6,        1'b0);
        check("BNE not equal",                     3'b001, 32'd5,        32'd6,        1'b1);
        check("BNE equal",                         3'b001, 32'd5,        32'd5,        1'b0);
        check("BLT signed minimum less than one",  3'b100, 32'h80000000, 32'h00000001, 1'b1);
        check("BLT positive max vs negative one",  3'b100, 32'h7fffffff, 32'hffffffff, 1'b0);
        check("BGE positive max vs negative one",  3'b101, 32'h7fffffff, 32'hffffffff, 1'b1);
        check("BGE signed minimum vs one",         3'b101, 32'h80000000, 32'h00000001, 1'b0);
        check("BLTU zero less than unsigned max",  3'b110, 32'h00000000, 32'hffffffff, 1'b1);
        check("BLTU unsigned max vs zero",         3'b110, 32'hffffffff, 32'h00000000, 1'b0);
        check("BGEU unsigned max vs zero",         3'b111, 32'hffffffff, 32'h00000000, 1'b1);
        check("BGEU zero vs unsigned max",         3'b111, 32'h00000000, 32'hffffffff, 1'b0);

        if (failures != 0) begin
            $display("FAIL: branch regression %0d/%0d failed", failures, checks);
            $fatal(1);
        end
        $display("PASS: branch regression completed; %0d/%0d checks passed", checks, checks);
        $finish;
    end
endmodule
