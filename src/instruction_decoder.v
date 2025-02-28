`timescale 1ns/1ps

module inst_decode 
(
	opcode,

	alu_ctrl,

	reg_rd,
	reg_rs1,
	reg_rs2,
	reg_rs3,
	
	use_imm,
	immediate,
	write_back
);


input [24:0] opcode;

output [7:0] alu_ctrl;

output [4:0] reg_rd;
output [4:0] reg_rs1;
output [4:0] reg_rs2;
output [4:0] reg_rs3;

output use_imm;
output [15:0]immediate;

output write_back;

assign alu_ctrl = (opcode[24] == 0) ? {opcode[23:21], 5'b11111} :
				  (opcode[23] == 0) ? {opcode[22:20], 5'b10000} :
				  {4'b0000, opcode[18:15]};

assign reg_rd = opcode[4:0];

assign reg_rs1 = (opcode[24] == 0) ? opcode[4:0] :
				 (opcode[23] == 0) ? opcode[9:5] :
				 opcode[9:5];

assign reg_rs2 = (opcode[24] == 0)          ? 5'b00000      :
				 (opcode[23] == 0)          ? opcode[14:10] :
				 (opcode[18:15] == 4'b0001) ? 5'b00000      :
				 opcode[14:10]; 

assign reg_rs3 = (opcode[24] == 0)          ? 5'b00000      :
				 (opcode[23] == 0)          ? opcode[19:15] :
				 5'b00000;

assign use_imm = (opcode[24] == 0)          ? 1 :
				 (opcode[23] == 0)          ? 0 :
				 (opcode[18:15] == 4'b0001) ? 1 :
				 0; 

assign immediate = (opcode[24] == 0)          ? opcode[20:5]                :
				   (opcode[23] == 0)          ? 0                           :
				   (opcode[18:15] == 4'b0001) ? {{11{1'b0}}, opcode[14:10]} :
				   0;

assign write_back = (opcode[24] == 0)              ? 1 :
					(opcode[23] == 0)              ? 1 :
					(opcode[22:15] == 8'b00000000) ? 0 :
					1;

endmodule
