`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 03:35:14
// Design Name: 
// Module Name: data_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input    clk, wr_en,
    input    [2:0] funct3,        
    input    [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output reg [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

localparam integer WORD_ADDR_WIDTH =
    (MEM_SIZE <= 1) ? 1 : $clog2(MEM_SIZE);
wire [WORD_ADDR_WIDTH-1:0] word_addr =
    wr_addr[WORD_ADDR_WIDTH+1:2];

// synchronous write logic
always @(posedge clk) begin
    if (wr_en) begin
        case (funct3)
            3'b000: begin // store byte (sb)
                case (wr_addr[1:0])
                    2'b00: data_ram[word_addr][ 7: 0] <= wr_data[7:0];
                    2'b01: data_ram[word_addr][15: 8] <= wr_data[7:0];
                    2'b10: data_ram[word_addr][23:16] <= wr_data[7:0];
                    2'b11: data_ram[word_addr][31:24] <= wr_data[7:0];
                endcase
            end
            3'b001: begin // store halfword (sh)
                case (wr_addr[1:0])
                    2'b00: data_ram[word_addr][15: 0] <= wr_data[15:0];
                    2'b10: data_ram[word_addr][31:16] <= wr_data[15:0]; // 2'b10 is valid for halfword store
                    default: ; // misaligned halfword store: no write
                endcase
            end
            3'b010: data_ram[word_addr] <= wr_data; // store word (sw)
            default: ; // unsupported store width: no write
        endcase
    end    
end

// asynchronous read logic
always @(*) begin
    // Defined output for unsupported or misaligned accesses.
    // This prevents unintended latch inference.
    rd_data_mem = {DATA_WIDTH{1'b0}};

    case (funct3)
        3'b000: begin // load byte (lb)
            case (wr_addr[1:0])
                2'b00:
                    rd_data_mem =
                        {{24{data_ram[word_addr][7]}},
                         data_ram[word_addr][7:0]};
                2'b01:
                    rd_data_mem =
                        {{24{data_ram[word_addr][15]}},
                         data_ram[word_addr][15:8]};
                2'b10:
                    rd_data_mem =
                        {{24{data_ram[word_addr][23]}},
                         data_ram[word_addr][23:16]};
                2'b11:
                    rd_data_mem =
                        {{24{data_ram[word_addr][31]}},
                         data_ram[word_addr][31:24]};
                default:
                    rd_data_mem = {DATA_WIDTH{1'b0}};
            endcase
        end

        3'b001: begin // load halfword (lh)
            case (wr_addr[1:0])
                2'b00:
                    rd_data_mem =
                        {{16{data_ram[word_addr][15]}},
                         data_ram[word_addr][15:0]};
                2'b10:
                    rd_data_mem =
                        {{16{data_ram[word_addr][31]}},
                         data_ram[word_addr][31:16]};
                default:
                    rd_data_mem = {DATA_WIDTH{1'b0}};
            endcase
        end

        3'b010: begin // load word (lw)
            rd_data_mem = data_ram[word_addr];
        end

        3'b100: begin // load byte unsigned (lbu)
            case (wr_addr[1:0])
                2'b00:
                    rd_data_mem =
                        {24'b0, data_ram[word_addr][7:0]};
                2'b01:
                    rd_data_mem =
                        {24'b0, data_ram[word_addr][15:8]};
                2'b10:
                    rd_data_mem =
                        {24'b0, data_ram[word_addr][23:16]};
                2'b11:
                    rd_data_mem =
                        {24'b0, data_ram[word_addr][31:24]};
                default:
                    rd_data_mem = {DATA_WIDTH{1'b0}};
            endcase
        end

        3'b101: begin // load halfword unsigned (lhu)
            case (wr_addr[1:0])
                2'b00:
                    rd_data_mem =
                        {16'b0, data_ram[word_addr][15:0]};
                2'b10:
                    rd_data_mem =
                        {16'b0, data_ram[word_addr][31:16]};
                default:
                    rd_data_mem = {DATA_WIDTH{1'b0}};
            endcase
        end

        default: begin
            rd_data_mem = {DATA_WIDTH{1'b0}};
        end
    endcase
end

endmodule

