`timescale 1ns/1ps
`define P 20

module mpu_test;

parameter OPCODE_WIDTH = 25;
parameter OPCODE_COUNT = 64;
parameter REG_WIDTH = 128;
parameter REG_COUNT = 32;

reg clk;
reg reset;

reg                              write_inst_en;
reg [OPCODE_WIDTH - 1:0]         write_inst_data;
reg [$clog2(OPCODE_COUNT) - 1:0] write_inst_addr;

wire [(REG_WIDTH * REG_COUNT) - 1:0] reg_data_out;

wire [OPCODE_WIDTH - 1:0] IF_opcode_out;
wire [OPCODE_WIDTH - 1:0] ID_opcode_out;
wire [OPCODE_WIDTH - 1:0] EX_opcode_out;
wire [OPCODE_WIDTH - 1:0] WB_opcode_out;

integer i, j;
integer status;
integer f_in, f_out; // file descriptor

mips_mpu uut 
(
	.clk(clk),
	.reset(reset),

	.write_inst_en(write_inst_en),
	.write_inst_data(write_inst_data),
	.write_inst_addr(write_inst_addr),

	.reg_data_out(reg_data_out),

	.IF_opcode_out(IF_opcode_out),
	.ID_opcode_out(ID_opcode_out),
	.EX_opcode_out(EX_opcode_out),
	.WB_opcode_out(WB_opcode_out)
);

always #((`P) / 2) clk = ~clk;

initial
begin
	f_out = $fopen("output.txt", "w");
	f_in = $fopen("input.txt", "r");
	
	clk = 0;
	reset = 1;
	write_inst_en = 0;
	
	#(`P);

	reset = 0;
	write_inst_en = 1;

	$fwrite(f_out, "---------------- Writing Opcode ----------------\n");

	i = 0;
	while (!$feof(f_in))
	begin
		status = $fscanf(f_in, "%b\n", write_inst_data);
		write_inst_addr = i;

		#(`P);

		i = i + 1;
	end

	$fclose(f_in);

	write_inst_en = 0;

	$fwrite(f_out, "---------------- Performing Simulation ----------------\n");
	$fwrite(f_out, "NOTE: ONLY WORKING WITH FIRST 3 REGISTERS.\n");
	$fwrite(f_out, "will only save the first 3 registers to demonstrate functionallity.\n");

	for (i = 0; i < OPCODE_COUNT; i = i + 1) 
	begin

		$fwrite(f_out, "IF_opcode = %b\n", IF_opcode_out);
		$fwrite(f_out, "ID_opcode = %b\n", ID_opcode_out);
		$fwrite(f_out, "EX_opcode = %b\n", EX_opcode_out);
		$fwrite(f_out, "WB_opcode = %b\n", WB_opcode_out);

		$fwrite(f_out, "\n");

		for (j = 0; j < 3; j = j + 1) // change this to change registers saved. 
		begin
			$fwrite(f_out, "$%d = %h\n", j, reg_data_out[REG_WIDTH * j +: REG_WIDTH]);
		end

		$fwrite(f_out, "\n");

		#(`P);
	end


	$fclose(f_out);
	$finish;

end
endmodule
