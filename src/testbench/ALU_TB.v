`timescale 1ns/1ps
`define P 20

`define MAX_SHORT  16'h7FFF
`define MIN_SHORT  16'h8000
`define MAX_INT    32'h7FFFFFFF
`define MIN_INT    32'h80000000
`define MAX_LONG   64'h7FFFFFFFFFFFFFFF
`define MIN_LONG   64'h8000000000000000

`include "..\instruction_set.v"

module alu_test;

parameter REG_WIDTH = 128;
parameter LONG_WIDTH = 64;
parameter WORD_WIDTH = 32;
parameter HWORD_WIDTH = 16;
parameter CTRL_WIDTH = 8;

// ALU Control Signal.
reg  [CTRL_WIDTH - 1:0] ctrl;

// Input Signals. 
reg  [REG_WIDTH - 1:0]  reg_rs1;
reg  [REG_WIDTH - 1:0]  reg_rs2;
reg  [REG_WIDTH - 1:0]  reg_rs3;

// Output Signal.
wire [REG_WIDTH - 1:0]  reg_rd;

reg  [WORD_WIDTH - 1:0]  number_word;
reg  [HWORD_WIDTH - 1:0] number_half_word;
reg  [LONG_WIDTH - 1:0] number_long;

integer i, j;
integer f; // file descriptor

alu uut  
(
	.ctrl(ctrl),

	.reg_rs1(reg_rs1),
	.reg_rs2(reg_rs2),
	.reg_rs3(reg_rs3),

	.reg_rd(reg_rd)
);

initial
begin
	ctrl = 0;
	reg_rs1 = 0;
	reg_rs2 = 0;
	reg_rs3 = 0;

	f = $fopen("output.txt", "w");
	
	#(`P);

	$fwrite(f, "---------------- R4 Instructions ----------------\n");

	$fwrite(f, "ctrl: op_group_R4L\n");
	ctrl[5:0] = `op_group_R4L;
	for(i = 0; i < 4; i = i + 1)
	begin
		ctrl[7:6] = $unsigned(i);
		$fwrite(f, "ctrl AS/HL: %b\n", ctrl[7:6]);

		reg_rs3[31:0] = 44;
		reg_rs2[31:0] = 37;

		reg_rs3[63:32] = `MAX_INT;
		reg_rs2[63:32] = 23;

		reg_rs1[63:0] = `MAX_INT;

		reg_rs3[95:64] = `MIN_INT;
		reg_rs2[95:64] = 23;

		reg_rs3[127:96] = 32'hFFFFFFFF;
		reg_rs2[127:96] = 32'hFFFFFFFF;

		reg_rs1[127:64] = `MAX_LONG;

		#(`P)

		for (j = 0; j < 4; j = j + 2)
		begin
			$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[LONG_WIDTH * (j/2) +: LONG_WIDTH]));
			$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[WORD_WIDTH * (j + ctrl[6]) +: WORD_WIDTH]));
			$fwrite(f, "input rs3: %d\n", $signed(reg_rs3[WORD_WIDTH * (j + ctrl[6]) +: WORD_WIDTH]));
			$fwrite(f, "output: %d\n", $signed(reg_rd[LONG_WIDTH * (j/2) +: LONG_WIDTH]));
			$fwrite(f, "\n");
		end
	end

	$fwrite(f, "ctrl: op_group_R4I\n");
	ctrl[5:0] = `op_group_R4I;
	for(i = 0; i < 4; i = i + 1)
	begin
		ctrl[7:6] = $unsigned(i);
		$fwrite(f, "ctrl AS/HL: %b\n", ctrl[7:6]);

		reg_rs3[15:0] = 44;
		reg_rs2[15:0] = 37;

		reg_rs3[31:16] = 16'hFFFF;
		reg_rs2[31:16] = 16'h0001;

		reg_rs1[31:0] = 64;

		reg_rs3[47:32] = 16'hFFFF;
		reg_rs2[47:32] = 16'hFFFF;

		reg_rs3[63:48] = `MAX_SHORT;
		reg_rs2[63:48] = -23;

		reg_rs1[63:32] = `MIN_INT;

		reg_rs3[79:64] = `MAX_SHORT;
		reg_rs2[79:64] = 23;

		reg_rs3[95:80] = `MIN_SHORT;
		reg_rs2[95:80] = -23;

		reg_rs1[95:64] = `MAX_INT;

		reg_rs3[111:96] = `MIN_SHORT;
		reg_rs2[111:96] = +23;

		reg_rs3[127:112] = 16'hFF00;
		reg_rs2[127:112] = 16'h0303;

		reg_rs1[127:96] = 0;

		#(`P)

		for (j = 0; j < 8; j = j + 2)
		begin
			$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[WORD_WIDTH * (j/2) +: WORD_WIDTH]));
			$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[HWORD_WIDTH * (j + ctrl[6]) +: HWORD_WIDTH]));
			$fwrite(f, "input rs3: %d\n", $signed(reg_rs3[HWORD_WIDTH * (j + ctrl[6]) +: HWORD_WIDTH]));
			$fwrite(f, "output: %d\n", $signed(reg_rd[WORD_WIDTH * (j/2) +: WORD_WIDTH]));
			$fwrite(f, "\n");
		end
	end

	$fwrite(f, "---------------- R3 Instructions ----------------\n");

	$fwrite(f, "ctrl: op_SLHI\n");
	ctrl = `op_SLHI;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	$fwrite(f, "Immediate: %b\n", reg_rs2[3:0]);
	$fwrite(f, "\n");

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %b\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_AU\n");
	ctrl = `op_AU;

	reg_rs1[31:0] = 44;
	reg_rs2[31:0] = 37;

	reg_rs1[63:32] = `MAX_INT;
	reg_rs2[63:32] = -23;

	reg_rs1[95:64] = `MIN_INT;
	reg_rs2[95:64] = 23;

	reg_rs1[127:96] = 32'hFFFFFFFF;
	reg_rs2[127:96] = 32'hFFFFFFFF;

	#(`P);

	for (i = 0; i < 4; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", reg_rs1[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "input rs2: %d\n", reg_rs2[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_CNT1H\n");
	ctrl = `op_CNT1H;

	reg_rs1[15:0] = 44;

	reg_rs1[31:16] = 16'hFFFF;

	reg_rs1[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;

	reg_rs1[79:64] = 16'b1010110011001010;

	reg_rs1[95:80] = `MIN_SHORT;

	reg_rs1[111:96] = 64;

	reg_rs1[127:112] = 16'hFF00;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_AHS\n");
	ctrl = `op_AHS;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "output: %d\n", $signed(reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_AND\n");
	ctrl = `op_AND;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "input rs2: %b\n", reg_rs2[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %b\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_BCW\n");
	ctrl = `op_BCW;

	reg_rs1[31:0] = 44;

	reg_rs1[63:32] = `MAX_INT;

	reg_rs1[95:64] = `MIN_INT;

	reg_rs1[127:96] = 32'hFFFFFFFF;

	#(`P);

	for (i = 0; i < 4; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", reg_rs1[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_MAXWS\n");
	ctrl = `op_MAXWS;

	reg_rs1[31:0] = 44;
	reg_rs2[31:0] = 37;

	reg_rs1[63:32] = `MAX_INT;
	reg_rs2[63:32] = -23;

	reg_rs1[95:64] = `MIN_INT;
	reg_rs2[95:64] = 23;

	reg_rs1[127:96] = 32'hFFFFFFFF;
	reg_rs2[127:96] = 32'hFFFFFFFF;

	#(`P);

	for (i = 0; i < 4; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "output: %d\n", $signed(reg_rd[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_MINWS\n");
	ctrl = `op_MINWS;

	reg_rs1[31:0] = 44;
	reg_rs2[31:0] = 37;

	reg_rs1[63:32] = `MAX_INT;
	reg_rs2[63:32] = -23;

	reg_rs1[95:64] = `MIN_INT;
	reg_rs2[95:64] = 23;

	reg_rs1[127:96] = 32'hFFFFFFFF;
	reg_rs2[127:96] = 32'hFFFFFFFF;

	#(`P);

	for (i = 0; i < 4; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "output: %d\n", $signed(reg_rd[WORD_WIDTH * i +: WORD_WIDTH]));
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_MLHU\n");
	ctrl = `op_MLHU;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	#(`P);

	for (i = 0; i < 8; i = i + 2)
	begin
		$fwrite(f, "input rs1: %d\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "input rs2: %d\n", reg_rs2[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[WORD_WIDTH * (i/2) +: WORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_MLHCU\n");
	ctrl = `op_MLHCU;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	#(`P);

	$fwrite (f, "Immediate: %b\n", reg_rs2[4:0]);
	$fwrite(f, "\n");

	for (i = 0; i < 8; i = i + 2)
	begin
		$fwrite(f, "input rs1: %d\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[WORD_WIDTH * (i/2) +: WORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_OR\n");
	ctrl = `op_OR;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "input rs2: %b\n", reg_rs2[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %b\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_CLZH\n");
	ctrl = `op_CLZH;

	reg_rs1[15:0] = 44;

	reg_rs1[31:16] = 16'hFFFF;

	reg_rs1[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;

	reg_rs1[79:64] = 16'b1010110011001010;

	reg_rs1[95:80] = `MIN_SHORT;

	reg_rs1[111:96] = 64;

	reg_rs1[127:112] = 16'hFF00;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_RLH\n");
	ctrl = `op_RLH;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	$fwrite (f, "Immediate: %b\n", reg_rs2[3:0]);
	$fwrite(f, "\n");

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %b\n", reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "output: %b\n", reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_SFWU\n");
	ctrl = `op_SFWU;

	reg_rs1[31:0] = 37;
	reg_rs2[31:0] = 44;

	reg_rs1[63:32] = `MAX_INT;
	reg_rs2[63:32] = -23;

	reg_rs1[95:64] = `MIN_INT;
	reg_rs2[95:64] = 23;

	reg_rs1[127:96] = 32'hFFFFFFFF;
	reg_rs2[127:96] = 32'hFFFFFFFF;

	#(`P);

	for (i = 0; i < 4; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", reg_rs1[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "input rs2: %d\n", reg_rs2[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "output: %d\n", reg_rd[WORD_WIDTH * i +: WORD_WIDTH]);
		$fwrite(f, "\n");
	end

	$fwrite(f, "ctrl: op_SFHS\n");
	ctrl = `op_SFHS;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;
	reg_rs2[31:16] = 16'h0001;

	reg_rs1[47:32] = 16'hFFFF;
	reg_rs2[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;
	reg_rs2[63:48] = -23;

	reg_rs1[79:64] = `MAX_SHORT;
	reg_rs2[79:64] = 23;

	reg_rs1[95:80] = `MIN_SHORT;
	reg_rs2[95:80] = -23;

	reg_rs1[111:96] = `MIN_SHORT;
	reg_rs2[111:96] = +23;

	reg_rs1[127:112] = 16'hFF00;
	reg_rs2[127:112] = 16'h0303;

	#(`P);

	for (i = 0; i < 8; i = i + 1)
	begin
		$fwrite(f, "input rs1: %d\n", $signed(reg_rs1[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "input rs2: %d\n", $signed(reg_rs2[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "output: %d\n", $signed(reg_rd[HWORD_WIDTH * i +: HWORD_WIDTH]));
		$fwrite(f, "\n");
	end


	$fwrite(f, "---------------- Load Immediate ----------------\n");
	$fwrite(f, "ctrl: op_LI\n");
	ctrl = `op_LI;

	reg_rs1[15:0] = 44;
	reg_rs2[15:0] = 37;

	reg_rs1[31:16] = 16'hFFFF;

	reg_rs1[47:32] = 16'hFFFF;

	reg_rs1[63:48] = `MAX_SHORT;

	reg_rs1[79:64] = `MAX_SHORT;

	reg_rs1[95:80] = `MIN_SHORT;

	reg_rs1[111:96] = `MIN_SHORT;

	reg_rs1[127:112] = 16'hFF00;


	for (i = 0; i < 8; i = i + 1)
	begin
		ctrl[7:5] = i;

		#(`P);

		$fwrite(f, "input rs1: %h\n", $signed(reg_rs1));
		$fwrite(f, "output: %h\n", $signed(reg_rd));
		$fwrite(f, "\n");
	end
	
	$fclose(f);
	$finish;
end
endmodule
