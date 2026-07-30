module IF_PL_REG #(
    parameter WIDTH = 32
) (
    input                  clk,
    input                  reset,
    input      [WIDTH-1:0] Instr,
    input      [WIDTH-1:0] PC_in,
    input      [WIDTH-1:0] PC4_in,
    input                  Stall,
    input                  Flush,
    output reg [WIDTH-1:0] InstrF,
    output reg [WIDTH-1:0] PCF,
    output reg [WIDTH-1:0] PC4_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            InstrF  <= {WIDTH{1'b0}};
            PCF     <= {WIDTH{1'b0}};
            PC4_out <= {WIDTH{1'b0}};
        end else if (Flush) begin
            InstrF  <= {WIDTH{1'b0}};
            PCF     <= {WIDTH{1'b0}};
            PC4_out <= {WIDTH{1'b0}};
        end else if (!Stall) begin
            InstrF  <= Instr;
            PCF     <= PC_in;
            PC4_out <= PC4_in;
        end
    end

endmodule
