`timescale 1ns/1ps

module HAZARD_UNIT (
    input  wire [4:0] RS1D,
    input  wire [4:0] RS2D,
    input  wire       UsesRS1D,
    input  wire       UsesRS2D,
    input  wire [4:0] RS1E,
    input  wire [4:0] RS2E,
    input  wire [4:0] RdE,
    input  wire [4:0] RdMW,
    input  wire [4:0] RdWB,
    input  wire       RegWriteMW,
    input  wire       RegWriteWB,
    input  wire [1:0] ResultSrcE,
    input  wire       RedirectE,
    output reg  [1:0] ForwardAE,
    output reg  [1:0] ForwardBE,
    output reg        StallPC,
    output reg        StallF,
    output reg        FlushF,
    output reg        FlushD
);

    wire load_in_execute;
    wire load_use_hazard;

    assign load_in_execute = (ResultSrcE == 2'b01);
    assign load_use_hazard = load_in_execute && (RdE != 5'd0) &&
        ((UsesRS1D && (RS1D == RdE)) ||
         (UsesRS2D && (RS2D == RdE)));

    always @(*) begin
        if (RegWriteMW && (RdMW != 5'd0) && (RS1E == RdMW))
            ForwardAE = 2'b10;
        else if (RegWriteWB && (RdWB != 5'd0) && (RS1E == RdWB))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
    end

    always @(*) begin
        if (RegWriteMW && (RdMW != 5'd0) && (RS2E == RdMW))
            ForwardBE = 2'b10;
        else if (RegWriteWB && (RdWB != 5'd0) && (RS2E == RdWB))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    always @(*) begin
        StallPC = 1'b0;
        StallF  = 1'b0;
        FlushF  = 1'b0;
        FlushD  = 1'b0;

        // A taken branch/jump has priority because younger instructions must
        // be discarded even if one of them also resembles a load dependency.
        if (RedirectE) begin
            FlushF = 1'b1;
            FlushD = 1'b1;
        end else if (load_use_hazard) begin
            StallPC = 1'b1;
            StallF  = 1'b1;
            FlushD  = 1'b1;
        end
    end

endmodule
