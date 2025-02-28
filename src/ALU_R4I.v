`timescale 1ns/1ps

`define MAX_INT    32'h7FFFFFFF
`define MIN_INT    32'h80000000
`define MAX_LONG   64'h7FFFFFFFFFFFFFFF
`define MIN_LONG   64'h8000000000000000

module int_mult_AS
(

	// Control Signal.
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
parameter CTRL_WIDTH = 2;

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

wire [(HWORD_WIDTH * 2) - 1:0] mult_output [(REG_WIDTH / WORD_WIDTH) - 1:0];
wire [(WORD_WIDTH * 2) - 1:0] mult_output_extended [(REG_WIDTH / WORD_WIDTH) - 1:0];
wire [2:0] select [(REG_WIDTH / WORD_WIDTH) - 1:0];

wire [(WORD_WIDTH * 2) - 1:0] total_output [(REG_WIDTH / WORD_WIDTH) - 1:0];

generate
	for(g = 0; g < (REG_WIDTH / WORD_WIDTH); g = g + 1)
	begin
		assign select[g] = {$unsigned(g) ,ctrl[0]};
		assign mult_output[g] = $signed(get_hword(reg_rs2, select[g], 1)) * $signed(get_hword(reg_rs3, select[g], 1));
		assign mult_output_extended[g] = {{32{mult_output[g][31]}}, mult_output[g]};
		assign total_output[g] = (ctrl[1] == 0) ? 
		$signed(mult_output_extended[g]) + $signed(get_word(reg_rs1, g, 1)) :
		$signed(mult_output_extended[g]) - $signed(get_word(reg_rs1, g, 1));
		
		assign reg_rd[(g + 1) * WORD_WIDTH - 1:g * WORD_WIDTH] = truncate_word(total_output[g], 1);
	end
endgenerate

endmodule
