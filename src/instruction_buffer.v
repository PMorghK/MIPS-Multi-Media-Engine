`timescale 1ns/1ps

module inst_buff 
(
	clk,
	reset,

	write_en,
	buffer_write_data,
	buffer_write_addr,
	buffer_addr,

	buffer_out
);

parameter INST_WIDTH = 25;
parameter INST_COUNT = 64;

input                            clk;
input                            reset;

input                            write_en;
input [INST_WIDTH - 1:0]		 buffer_write_data;
input [$clog2(INST_COUNT) - 1:0] buffer_write_addr;
input [$clog2(INST_COUNT) - 1:0] buffer_addr;

output reg [INST_WIDTH - 1:0]    buffer_out;

reg [INST_WIDTH - 1:0] buffer [INST_COUNT - 1:0];

integer i;

always @ (posedge clk)
begin
	if (reset == 1)
		for(i = 0; i < INST_COUNT; i = i + 1)
			buffer[i] <= {2'b11, {(INST_WIDTH - 2){1'b0}}};

	else if (write_en == 1)
		buffer[buffer_write_addr] <= buffer_write_data;
end

always @ (*)
begin
	 buffer_out <= buffer[buffer_addr];
end

endmodule
