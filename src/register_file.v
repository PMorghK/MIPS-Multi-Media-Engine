`timescale 1ns/1ps

module reg_file 
(
	clk,
	reset,

	write_en,
	write_addr,

	read_addr1,
	read_addr2,
	read_addr3,
	
	write_data,

	read_data1,
	read_data2,
	read_data3,

	reg_data_all 
);

parameter REG_WIDTH = 128;
parameter REG_COUNT = 32;

input clk;
input reset;

input write_en;
input [$clog2(REG_COUNT) - 1:0] write_addr;

input [$clog2(REG_COUNT) - 1:0] read_addr1;
input [$clog2(REG_COUNT) - 1:0] read_addr2;
input [$clog2(REG_COUNT) - 1:0] read_addr3;

input  [REG_WIDTH - 1:0]        write_data;

output reg [REG_WIDTH - 1:0]    read_data1;
output reg [REG_WIDTH - 1:0]    read_data2;
output reg [REG_WIDTH - 1:0]    read_data3;

output [REG_WIDTH * REG_COUNT - 1:0] reg_data_all;

reg [REG_WIDTH - 1:0] data [REG_COUNT - 1:0];

integer i;
genvar g;

always @ (posedge clk)
begin
	if (reset)
		for (i = 0; i < REG_COUNT; i = i + 1)
			data[i] <= {REG_WIDTH{1'b0}};

	else
		if ((write_addr != 0) && (write_en == 1))
			data[write_addr] <= write_data;
end

always @ (*)
begin
	// data_1
	if ((write_en == 1) && (write_addr == read_addr1) && (read_addr1 != 0))
		read_data1 <= write_data;

	else if (read_addr1 == 0)
		read_data1 <= {REG_WIDTH{1'b0}};

	else
		read_data1 <= data[read_addr1];
	
	// data_2
	if ((write_en == 1) && (write_addr == read_addr2) && (read_addr2 != 0))
		read_data2 <= write_data;

	else if (read_addr2 == 0)
		read_data2 <= {REG_WIDTH{1'b0}};

	else
		read_data2 <= data[read_addr2];

	// data_3
	if ((write_en == 1) && (write_addr == read_addr3) && (read_addr3 != 0))
		read_data3 <= write_data;

	else if (read_addr3 == 0)
		read_data3 <= {REG_WIDTH{1'b0}};

	else
		read_data3 <= data[read_addr3];
end

generate 
	for (g = 0; g < REG_COUNT; g = g + 1)
	begin
		assign reg_data_all[REG_WIDTH * g +: REG_WIDTH] = data[g];
	end
endgenerate

endmodule
