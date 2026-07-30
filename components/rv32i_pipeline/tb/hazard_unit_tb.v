`timescale 1ns/1ps

module hazard_unit_tb;
    reg [4:0] RS1D, RS2D, RS1E, RS2E, RdE, RdMW, RdWB;
    reg UsesRS1D, UsesRS2D, RegWriteMW, RegWriteWB, RedirectE;
    reg [1:0] ResultSrcE;
    wire [1:0] ForwardAE, ForwardBE;
    wire StallPC, StallF, FlushF, FlushD;

    integer checks = 0;
    integer failures = 0;

    HAZARD_UNIT dut (
        .RS1D(RS1D), .RS2D(RS2D),
        .UsesRS1D(UsesRS1D), .UsesRS2D(UsesRS2D),
        .RS1E(RS1E), .RS2E(RS2E),
        .RdE(RdE), .RdMW(RdMW), .RdWB(RdWB),
        .RegWriteMW(RegWriteMW), .RegWriteWB(RegWriteWB),
        .ResultSrcE(ResultSrcE), .RedirectE(RedirectE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
        .StallPC(StallPC), .StallF(StallF),
        .FlushF(FlushF), .FlushD(FlushD)
    );

    task clear_inputs;
        begin
            RS1D=0; RS2D=0; UsesRS1D=0; UsesRS2D=0;
            RS1E=0; RS2E=0; RdE=0; RdMW=0; RdWB=0;
            RegWriteMW=0; RegWriteWB=0; ResultSrcE=0; RedirectE=0;
        end
    endtask

    task check_case;
        input [8*40-1:0] label;
        input [1:0] exp_a, exp_b;
        input exp_stall, exp_flush;
        begin
            #1; checks = checks + 1;
            if ((ForwardAE !== exp_a) || (ForwardBE !== exp_b) ||
                (StallPC !== exp_stall) || (StallF !== exp_stall) ||
                (FlushF !== exp_flush) ||
                (FlushD !== (exp_flush || exp_stall))) begin
                failures = failures + 1;
                $display("FAIL: %0s FA=%b FB=%b stall=%b/%b flush=%b/%b", label,
                         ForwardAE, ForwardBE, StallPC, StallF, FlushF, FlushD);
            end else begin
                $display("PASS: %0s", label);
            end
        end
    endtask

    initial begin
        clear_inputs(); check_case("no hazard", 2'b00, 2'b00, 0, 0);

        clear_inputs(); RS1E=5; RdMW=5; RegWriteMW=1;
        check_case("forward A from memory", 2'b10, 2'b00, 0, 0);

        clear_inputs(); RS2E=7; RdWB=7; RegWriteWB=1;
        check_case("forward B from writeback", 2'b00, 2'b01, 0, 0);

        clear_inputs(); RS1E=9; RdMW=9; RdWB=9; RegWriteMW=1; RegWriteWB=1;
        check_case("memory forwarding has priority", 2'b10, 2'b00, 0, 0);

        clear_inputs(); RS1E=0; RdMW=0; RegWriteMW=1;
        check_case("x0 is never forwarded", 2'b00, 2'b00, 0, 0);

        clear_inputs(); ResultSrcE=2'b01; RdE=3; RS1D=3; UsesRS1D=1;
        check_case("load-use dependency on rs1", 2'b00, 2'b00, 1, 0);

        clear_inputs(); ResultSrcE=2'b01; RdE=4; RS2D=4; UsesRS2D=1;
        check_case("load-use dependency on used rs2", 2'b00, 2'b00, 1, 0);

        clear_inputs(); ResultSrcE=2'b01; RdE=4; RS2D=4; UsesRS2D=0;
        check_case("immediate bits do not create false rs2 stall", 2'b00, 2'b00, 0, 0);

        clear_inputs(); ResultSrcE=2'b00; RdE=3; RS1D=3; UsesRS1D=1;
        check_case("non-load producer does not stall", 2'b00, 2'b00, 0, 0);

        clear_inputs(); RedirectE=1;
        check_case("redirect flushes younger stages", 2'b00, 2'b00, 0, 1);

        clear_inputs(); RedirectE=1; ResultSrcE=2'b01; RdE=3; RS1D=3; UsesRS1D=1;
        check_case("redirect has priority over load stall", 2'b00, 2'b00, 0, 1);

        if (failures != 0) begin
            $display("FAIL: hazard regression %0d/%0d failed", failures, checks);
            $fatal(1);
        end
        $display("PASS: hazard regression completed; %0d/%0d checks passed", checks, checks);
        $finish;
    end
endmodule
