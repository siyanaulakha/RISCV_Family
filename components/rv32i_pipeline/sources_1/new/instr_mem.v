`timescale 1ns/1ps

module instr_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE   = 512,
    parameter INIT_FILE  = "rv32i_test.hex"
)(
    input  wire [ADDR_WIDTH-1:0] instr_addr,
    output wire [DATA_WIDTH-1:0] instr
);

    reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];
    localparam integer WORD_ADDR_WIDTH =
        (MEM_SIZE <= 1) ? 1 : $clog2(MEM_SIZE);
    integer i;

    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1)
            instr_ram[i] = 32'h00000013; // NOP
        $readmemh(INIT_FILE, instr_ram);
    end

    assign instr = instr_ram[instr_addr[WORD_ADDR_WIDTH+1:2]];

endmodule
