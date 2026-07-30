`timescale 1ns/1ps

module branch_compare_tb;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [2:0]  funct3;

    wire [31:0] alu_out;
    wire [3:0]  alu_control;
    wire        zero;
    wire        less_than;

    wire [1:0] result_src;
    wire [1:0] imm_src;
    wire       mem_write;
    wire       pc_src;
    wire       alu_src;
    wire       reg_write;
    wire       jalr;

    integer checks;
    integer failures;

    assign less_than = alu_out[0];

    alu branch_alu (
        .a(a),
        .b(b),
        .alu_ctrl(alu_control),
        .alu_out(alu_out),
        .zero(zero)
    );

    controller branch_controller (
        .op(7'b1100011),
        .funct3(funct3),
        .funct7b5(1'b0),
        .Zero(zero),
        .LessThan(less_than),
        .ResultSrc(result_src),
        .MemWrite(mem_write),
        .PCSrc(pc_src),
        .ALUSrc(alu_src),
        .RegWrite(reg_write),
        .Jalr(jalr),
        .ImmSrc(imm_src),
        .ALUControl(alu_control)
    );

    task automatic check_branch;
        input [2:0] funct3_value;
        input [31:0] lhs;
        input [31:0] rhs;
        input expected_taken;
        input [3:0] expected_control;
        input [8*48-1:0] test_name;

        begin
            funct3 = funct3_value;
            a = lhs;
            b = rhs;

            #1;
            checks = checks + 1;

            if ((pc_src !== expected_taken) ||
                (alu_control !== expected_control)) begin

                failures = failures + 1;

                $display(
                    "FAIL: %0s a=%08x b=%08x taken=%b expected=%b control=%b expected_control=%b",
                    test_name,
                    a,
                    b,
                    pc_src,
                    expected_taken,
                    alu_control,
                    expected_control
                );
            end
            else begin
                $display(
                    "PASS: %0s a=%08x b=%08x taken=%b",
                    test_name,
                    a,
                    b,
                    pc_src
                );
            end
        end
    endtask

    initial begin
        checks = 0;
        failures = 0;
        a = 0;
        b = 0;
        funct3 = 0;

        #1;

        check_branch(
            3'b000, 32'd5, 32'd5,
            1'b1, 4'b0001, "BEQ equal"
        );

        check_branch(
            3'b000, 32'd5, 32'd6,
            1'b0, 4'b0001, "BEQ not equal"
        );

        check_branch(
            3'b001, 32'd5, 32'd6,
            1'b1, 4'b0001, "BNE not equal"
        );

        check_branch(
            3'b001, 32'd5, 32'd5,
            1'b0, 4'b0001, "BNE equal"
        );

        check_branch(
            3'b100, 32'h80000000, 32'h00000001,
            1'b1, 4'b0101, "BLT signed minimum less than one"
        );

        check_branch(
            3'b100, 32'h7fffffff, 32'hffffffff,
            1'b0, 4'b0101, "BLT positive maximum vs negative one"
        );

        check_branch(
            3'b101, 32'h7fffffff, 32'hffffffff,
            1'b1, 4'b0101, "BGE positive maximum vs negative one"
        );

        check_branch(
            3'b101, 32'h80000000, 32'h00000001,
            1'b0, 4'b0101, "BGE signed minimum vs one"
        );

        check_branch(
            3'b110, 32'h00000000, 32'hffffffff,
            1'b1, 4'b1001, "BLTU zero less than unsigned maximum"
        );

        check_branch(
            3'b110, 32'hffffffff, 32'h00000000,
            1'b0, 4'b1001, "BLTU unsigned maximum vs zero"
        );

        check_branch(
            3'b111, 32'hffffffff, 32'h00000000,
            1'b1, 4'b1001, "BGEU unsigned maximum vs zero"
        );

        check_branch(
            3'b111, 32'h00000000, 32'hffffffff,
            1'b0, 4'b1001, "BGEU zero vs unsigned maximum"
        );

        if (failures == 0) begin
            $display(
                "PASS: branch-directed regression completed; %0d/%0d checks passed",
                checks,
                checks
            );
            $finish;
        end
        else begin
            $display(
                "FAIL: branch-directed regression completed; %0d failures across %0d checks",
                failures,
                checks
            );
            $fatal(1);
        end
    end

endmodule
