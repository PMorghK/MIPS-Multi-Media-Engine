`timescale 1ns/1ps

`define MAX_UINT 32'hFFFFFFFF

`define MAX_SHORT  16'h7FFF
`define MIN_SHORT  16'h8000
`define MAX_INT    32'h7FFFFFFF
`define MIN_INT    32'h80000000
`define MAX_LONG   64'h7FFFFFFFFFFFFFFF
`define MIN_LONG   64'h8000000000000000

`include "instruction_set.v"

module alu
(
	// ALU Control Signal.
	ctrl, 

	// Input Signals. 
	reg_rs1,
	reg_rs2,
	reg_rs3,

	// Output Signal.
	reg_rd
);

parameter REG_WIDTH = 128;
parameter LONG_WIDTH = 64;
parameter WORD_WIDTH = 32;
parameter HWORD_WIDTH = 16;
parameter CTRL_WIDTH = 8;

// ALU Control Signal.
input  [CTRL_WIDTH - 1:0] ctrl;

// Input Signals. 
input  [REG_WIDTH - 1:0]  reg_rs1;
input  [REG_WIDTH - 1:0]  reg_rs2;
input  [REG_WIDTH - 1:0]  reg_rs3;

// Output Signal.
output [REG_WIDTH - 1:0]  reg_rd;

// --------------- FUNCTIONS --------------- 

// Extend Functions.
function [(WORD_WIDTH * 2) - 1:0] get_word;
	input [REG_WIDTH - 1:0] reg_in;
	input [1:0] 			select;
	input 					is_signed;

	begin
		case (select)
			2'b00 : get_word = is_signed == 1 ? {{32{reg_in[31]}}, reg_in[31:0]} : {{32{1'b0}}, reg_in[31:0]};
			2'b01 : get_word = is_signed == 1 ? {{32{reg_in[63]}}, reg_in[63:32]} : {{32{1'b0}}, reg_in[63:32]};
			2'b10 : get_word = is_signed == 1 ? {{32{reg_in[95]}}, reg_in[95:64]} : {{32{1'b0}}, reg_in[95:64]};
			2'b11 : get_word = is_signed == 1 ? {{32{reg_in[127]}}, reg_in[127:96]} : {{32{1'b0}}, reg_in[127:96]};
		endcase
	end
endfunction

function [(HWORD_WIDTH * 2) - 1:0] get_hword;
	input [REG_WIDTH - 1:0] reg_in;
	input [2:0] 			select;
	input 					is_signed;

	begin
		case (select)
			3'b000 : get_hword = is_signed == 1 ? {{16{reg_in[15]}}, reg_in[15:0]} : {{16{1'b0}}, reg_in[15:0]};
			3'b001 : get_hword = is_signed == 1 ? {{16{reg_in[31]}}, reg_in[31:16]} : {{16{1'b0}}, reg_in[31:16]};
			3'b010 : get_hword = is_signed == 1 ? {{16{reg_in[47]}}, reg_in[47:32]} : {{16{1'b0}}, reg_in[47:32]};
			3'b011 : get_hword = is_signed == 1 ? {{16{reg_in[63]}}, reg_in[63:48]} : {{16{1'b0}}, reg_in[63:48]};
			3'b100 : get_hword = is_signed == 1 ? {{16{reg_in[79]}}, reg_in[79:64]} : {{16{1'b0}}, reg_in[79:64]};
			3'b101 : get_hword = is_signed == 1 ? {{16{reg_in[95]}}, reg_in[95:80]} : {{16{1'b0}}, reg_in[95:80]};
			3'b110 : get_hword = is_signed == 1 ? {{16{reg_in[111]}}, reg_in[111:96]} : {{16{1'b0}}, reg_in[111:96]};
			3'b111 : get_hword = is_signed == 1 ? {{16{reg_in[127]}}, reg_in[127:112]} : {{16{1'b0}}, reg_in[127:112]};
		endcase
	end
endfunction

// Truncate Functions.
function [HWORD_WIDTH - 1:0] truncate_hword;
	input [(HWORD_WIDTH * 2) - 1:0] big_hword;
	input 						   with_saturation;

	begin
		if (with_saturation == 1 && ($signed(big_hword) > $signed(`MAX_SHORT))) truncate_hword = `MAX_SHORT;
		else if (with_saturation == 1 && ($signed(big_hword) < $signed(`MIN_SHORT))) truncate_hword = `MIN_SHORT;
		else truncate_hword = big_hword[HWORD_WIDTH - 1:0];
	end
endfunction 

function [WORD_WIDTH - 1:0] truncate_word;
	input [(WORD_WIDTH * 2) - 1:0] big_word;
	input 						   with_saturation;

	begin
		if (with_saturation == 1 && ($signed(big_word) > $signed(`MAX_INT))) truncate_word = `MAX_INT;
		else if (with_saturation == 1 && ($signed(big_word) < $signed(`MIN_INT))) truncate_word = `MIN_INT;
		else truncate_word = big_word[WORD_WIDTH - 1:0];
	end
endfunction 



// --------------- STRUCTURAL ---------------

genvar g;
integer i;

// Operation Load Immediate. `op_LI
wire [REG_WIDTH - 1:0] op_LI_output;

generate 
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_LI_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] = (g != $unsigned(ctrl[7:5])) ?
			truncate_hword(get_hword(reg_rs1, g, 1), 0) : 
			truncate_hword(get_hword(reg_rs2, 0, 1), 0);
	end
endgenerate

// Operation Shift Left Halfword Immediate. `op_SLHI
wire [REG_WIDTH - 1:0] op_SLHI_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_SLHI_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] = 
			truncate_hword(get_hword(reg_rs1, g, 0) << $unsigned(reg_rs2[3:0]), 0);
	end
endgenerate

// Operation Add Word Unsigned. `op_AU
wire [(WORD_WIDTH * 2) - 1:0] op_AU_temp [(REG_WIDTH / WORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_AU_output;

generate
	for (g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign op_AU_temp[g] = get_word(reg_rs1, g, 0) + get_word(reg_rs2, g, 0);
		assign op_AU_output[(WORD_WIDTH * (g + 1)) - 1:(WORD_WIDTH * g)] = ($unsigned(op_AU_temp[g]) > `MAX_UINT) ?
			`MAX_UINT : truncate_word(op_AU_temp[g], 0);
	end
endgenerate

// Operation Count 1's in Halfword. `op_CNT1H
wire [(HWORD_WIDTH * 2) - 1:0] op_CNT1H_temp [(REG_WIDTH / HWORD_WIDTH) - 1:0];
reg  [HWORD_WIDTH - 1:0] op_CNT1H_count [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_CNT1H_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_CNT1H_temp[g] = get_hword(reg_rs1, g, 0);

		always @(*)
		begin
			op_CNT1H_count[g] = 16'b0;

			for (i = 0; i < HWORD_WIDTH; i = i + 1)
			begin
				if (op_CNT1H_temp[g][i] == 1)
					op_CNT1H_count[g] = op_CNT1H_count[g] + 1;
			end
		end

		assign op_CNT1H_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] =
			op_CNT1H_count[g];
	end
endgenerate

// Operation Add Halfword Saturated. `op_AHS
wire [(HWORD_WIDTH * 2) - 1:0] op_AHS_temp [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_AHS_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_AHS_temp[g] = $signed(get_hword(reg_rs1, g, 1)) + $signed(get_hword(reg_rs2, g, 1));
		assign op_AHS_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] =
			truncate_hword(op_AHS_temp[g], 1);
	end
endgenerate

// Operation Bitwise Logical AND. `op_AND
wire [REG_WIDTH - 1:0] op_AND_output;

assign op_AND_output = reg_rs1 & reg_rs2;

// Operation Brodcast Word. `op_BCW
wire [REG_WIDTH - 1:0] op_BCW_output;

generate
	for (g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign op_BCW_output[(WORD_WIDTH * (g + 1)) - 1:(WORD_WIDTH * g)] = 
			reg_rs1[WORD_WIDTH - 1:0];
	end
endgenerate

// Operation Max Signed Word. `op_MAXWS
wire [REG_WIDTH - 1:0] op_MAXWS_output;

generate
	for (g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign op_MAXWS_output[(WORD_WIDTH * (g + 1)) - 1:(WORD_WIDTH * g)] = 
			$signed(get_word(reg_rs1, g, 1)) > $signed(get_word(reg_rs2, g, 1)) ?
			truncate_word(get_word(reg_rs1, g, 1), 0) : 
			truncate_word(get_word(reg_rs2, g, 1), 0);
	end
endgenerate

// Operation Min Signed Word. `op_MINWS
wire [REG_WIDTH - 1:0] op_MINWS_output;

generate
	for (g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign op_MINWS_output[(WORD_WIDTH * (g + 1)) - 1:(WORD_WIDTH * g)] = 
			$signed(get_word(reg_rs1, g, 1)) > $signed(get_word(reg_rs2, g, 1)) ?
			truncate_word(get_word(reg_rs2, g, 1), 0) : 
			truncate_word(get_word(reg_rs1, g, 1), 0);
	end
endgenerate

// Operation Multiply Low Halfword Unsigned. `op_MLHU
wire [REG_WIDTH - 1:0] op_MLHU_output;

generate 
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 2)
	begin
		assign op_MLHU_output[(WORD_WIDTH * (1 + (g / 2))) - 1:(WORD_WIDTH * (g / 2))] = 
			$unsigned(get_hword(reg_rs1, g, 0)) * $unsigned(get_hword(reg_rs2, g, 0));
	end
endgenerate

// Operation Multiply Low Halfword Unsigned w/Constant. `op_MLHCU
wire [REG_WIDTH - 1:0] op_MLHCU_output;
generate 
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 2)
	begin
		assign op_MLHCU_output[(WORD_WIDTH * (1 + (g / 2))) - 1:(WORD_WIDTH * (g / 2))] = 
			$unsigned(get_hword(reg_rs1, g, 0)) * $unsigned({27'b0, reg_rs2[4:0]});
	end
endgenerate

// Operation Bitwise Logical OR. `op_OR
wire [REG_WIDTH - 1:0] op_OR_output;

assign op_OR_output = reg_rs1 | reg_rs2;

// Operation Count Leading Zeros in Halfword. `op_CLZH
wire [HWORD_WIDTH - 1:0] op_CLZH_temp [(REG_WIDTH / HWORD_WIDTH) - 1:0];
reg  [HWORD_WIDTH - 1:0] op_CLZH_count [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0]   op_CLZH_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_CLZH_temp[g] = truncate_hword(get_hword(reg_rs1, g, 0), 0);

		always @(*)
		begin
			i = HWORD_WIDTH - 1;

			while (op_CLZH_temp[g][i] == 0 && i > -1)
			begin
				i = i - 1;
			end
			
			op_CLZH_count[g] = 16 - i - 1;
		end

		assign op_CLZH_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] =
			op_CLZH_count[g];
	end
endgenerate

// Operation Rotate Left bits in Halfwords. `op_RLH
wire [HWORD_WIDTH - 1:0] op_RLH_shift [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [HWORD_WIDTH - 1:0] op_RLH_rotate [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_RLH_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_RLH_shift[g] = truncate_hword(get_hword(reg_rs1, g, 0) << $unsigned(reg_rs2[3:0]), 0);
		assign op_RLH_rotate[g] = truncate_hword(get_hword(reg_rs1, g, 0) >> (16 - $unsigned(reg_rs2[3:0])), 0);
		assign op_RLH_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] = 
			op_RLH_shift[g] | op_RLH_rotate[g];
	end
endgenerate

// Operation Subtract From Word Unsigned. `op_SFWU
wire [(WORD_WIDTH * 2) - 1:0] op_SFWU_temp [(REG_WIDTH / WORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_SFWU_output;

generate
	for (g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign op_SFWU_temp[g] = $unsigned(get_word(reg_rs2, g, 0)) - $unsigned(get_word(reg_rs1, g, 0));
		assign op_SFWU_output[(WORD_WIDTH * (g + 1)) - 1:(WORD_WIDTH * g)] = 
			($signed(op_SFWU_temp[g]) < 0) ? 0 : 
			($signed(op_SFWU_temp[g]) > $unsigned(`MAX_UINT)) ? `MAX_UINT : 
			truncate_word(op_SFWU_temp[g], 0);
	end
endgenerate

// Operation Subtract From Halfword Saturated. `op_SFHS
wire [(HWORD_WIDTH * 2) - 1:0] op_SFHS_temp [(REG_WIDTH / HWORD_WIDTH) - 1:0];
wire [REG_WIDTH - 1:0] op_SFHS_output;

generate
	for (g = 0; g < (REG_WIDTH / HWORD_WIDTH); g = g + 1)
	begin
		assign op_SFHS_temp[g] = $signed(get_hword(reg_rs2, g, 1)) - $signed(get_hword(reg_rs1, g, 1));
		assign op_SFHS_output[(HWORD_WIDTH * (g + 1)) - 1:(HWORD_WIDTH * g)] =
			truncate_hword(op_SFHS_temp[g], 1);
	end
endgenerate

// Operation Group R4. `op_group_R4I & `op_group_R4L
wire [REG_WIDTH - 1:0] op_group_R4L_output;
wire [REG_WIDTH - 1:0] op_group_R4I_output;

long_mult_AS compute_R4L
(
	.ctrl(ctrl[6:5]),
	
	.reg_rs1(reg_rs1),
	.reg_rs2(reg_rs2),
	.reg_rs3(reg_rs3),

	.reg_rd(op_group_R4L_output)
);

int_mult_AS compute_R4I
(
	.ctrl(ctrl[6:5]),
	
	.reg_rs1(reg_rs1),
	.reg_rs2(reg_rs2),
	.reg_rs3(reg_rs3),

	.reg_rd(op_group_R4I_output)
);
// --------------- OUTPUT SELECT ---------------

assign reg_rd = (ctrl == `op_SLHI)  ? op_SLHI_output  : 
				(ctrl == `op_AU)    ? op_AU_output    : 
				(ctrl == `op_CNT1H) ? op_CNT1H_output : 
				(ctrl == `op_AHS)   ? op_AHS_output   : 
				(ctrl == `op_AND)   ? op_AND_output   : 
				(ctrl == `op_BCW)   ? op_BCW_output   : 
				(ctrl == `op_MAXWS) ? op_MAXWS_output : 
				(ctrl == `op_MINWS) ? op_MINWS_output : 
				(ctrl == `op_MLHU)  ? op_MLHU_output  : 
				(ctrl == `op_MLHCU) ? op_MLHCU_output : 
				(ctrl == `op_OR)    ? op_OR_output    : 
				(ctrl == `op_CLZH)  ? op_CLZH_output  : 
				(ctrl == `op_RLH)   ? op_RLH_output   : 
				(ctrl == `op_SFWU)  ? op_SFWU_output  : 
				(ctrl == `op_SFHS)  ? op_SFHS_output  :

				(ctrl[4:0] == `op_LI)   ? op_LI_output    : 
				(ctrl[5:0] == `op_group_R4L) ? op_group_R4L_output : 
				(ctrl[5:0] == `op_group_R4I) ? op_group_R4I_output : 
				                      
				128'b0;

endmodule
