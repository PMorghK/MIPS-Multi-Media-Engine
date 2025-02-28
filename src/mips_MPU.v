`timescale 1ns/1ps

module mips_mpu
(
	clk,
	reset,

	write_inst_en,
	write_inst_data,
	write_inst_addr,
	
	reg_data_out,
	
	IF_opcode_out,
	ID_opcode_out,
	EX_opcode_out,
	WB_opcode_out
);

parameter OPCODE_WIDTH = 25;
parameter OPCODE_COUNT = 64;
parameter REG_WIDTH = 128;
parameter REG_COUNT = 32;

input clk;
input reset;

input                              write_inst_en;
input [OPCODE_WIDTH - 1:0]         write_inst_data;
input [$clog2(OPCODE_COUNT) - 1:0] write_inst_addr;

output [(REG_WIDTH * REG_COUNT) - 1:0] reg_data_out;

output [OPCODE_WIDTH - 1:0] IF_opcode_out;
output [OPCODE_WIDTH - 1:0] ID_opcode_out;
output [OPCODE_WIDTH - 1:0] EX_opcode_out;
output [OPCODE_WIDTH - 1:0] WB_opcode_out;

// --------------------------------------------------------
// ---------------- REGISTERS AND WIRES -------------------
// --------------------------------------------------------

reg [$clog2(OPCODE_COUNT) - 1:0] program_counter;

// ---------------- STAGE : IF - BEGIN --------------------

wire [OPCODE_WIDTH - 1:0] IF_opcode;

// ---------------- STAGE : IF - END ----------------------

reg [OPCODE_WIDTH - 1:0] IF_ID_opcode;

// ---------------- STAGE : ID - BEGIN --------------------

wire [OPCODE_WIDTH - 1:0] ID_opcode;

wire [7:0] ID_ALU_ctrl;

wire [$clog2(REG_COUNT) - 1:0] ID_rd_addr;
wire [$clog2(REG_COUNT) - 1:0] ID_rs1_addr;
wire [$clog2(REG_COUNT) - 1:0] ID_rs2_addr;
wire [$clog2(REG_COUNT) - 1:0] ID_rs3_addr;

wire [REG_WIDTH - 1:0] ID_rs1_data;
wire [REG_WIDTH - 1:0] ID_rs2_data;
wire [REG_WIDTH - 1:0] ID_rs3_data;

wire        ID_use_imm;
wire [15:0] immediate;

wire ID_wb;

// ---------------- STAGE : ID - END ----------------------

reg [OPCODE_WIDTH - 1:0] ID_EX_opcode;

reg                           ID_EX_wb;
reg [$clog2(REG_COUNT) - 1:0] ID_EX_rd_addr;

reg [7:0] ID_EX_ALU_ctrl;

reg [REG_WIDTH - 1:0] ID_EX_rs1_data;
reg [REG_WIDTH - 1:0] ID_EX_rs2_data;
reg [REG_WIDTH - 1:0] ID_EX_rs3_data;

reg [$clog2(REG_COUNT) - 1:0] ID_EX_rs1_addr;
reg [$clog2(REG_COUNT) - 1:0] ID_EX_rs2_addr;
reg [$clog2(REG_COUNT) - 1:0] ID_EX_rs3_addr;

reg        ID_EX_use_imm;

// ---------------- STAGE : EX - BEGIN --------------------

wire [OPCODE_WIDTH - 1:0] EX_opcode;

wire                           EX_wb;
wire [$clog2(REG_COUNT) - 1:0] EX_rd_addr;

wire [7:0] EX_ALU_ctrl;

wire [REG_WIDTH - 1:0] EX_rs1_data;
wire [REG_WIDTH - 1:0] EX_rs2_data;
wire [REG_WIDTH - 1:0] EX_rs3_data;

wire [$clog2(REG_COUNT) - 1:0] EX_rs1_addr;
wire [$clog2(REG_COUNT) - 1:0] EX_rs2_addr;
wire [$clog2(REG_COUNT) - 1:0] EX_rs3_addr;

wire  EX_use_imm;

wire [REG_WIDTH - 1:0] EX_ALU_out;

// ---------------- STAGE : EX - END ----------------------

reg [OPCODE_WIDTH - 1:0]      EX_WB_opcode;

reg                           EX_WB_wb;
reg [$clog2(REG_COUNT) - 1:0] EX_WB_rd_addr;
reg [REG_WIDTH - 1:0]         EX_WB_ALU_out;

// ---------------- STAGE : WB - BEGIN --------------------

wire [OPCODE_WIDTH - 1:0] WB_opcode;

wire                           WB_wb;
wire [$clog2(REG_COUNT) - 1:0] WB_rd_addr;
wire [REG_WIDTH - 1:0]         WB_ALU_out;

// ---------------- STAGE : WB - END ----------------------

// --------------------------------------------------------
// ---------------- CONNECTION DESCRIPTION ----------------
// --------------------------------------------------------

always @ (posedge clk)
begin
	if (reset == 1 || write_inst_en == 1)
		program_counter <= {$clog2(OPCODE_COUNT){1'b0}};
	
	else
		program_counter <= program_counter + 1;
end

// ---------------- STAGE : IF - BEGIN --------------------

inst_buff inst_buff 
(
	.clk(clk),
	.reset(reset),

	.write_en(write_inst_en),
	.buffer_write_data(write_inst_data),
	.buffer_write_addr(write_inst_addr),

	.buffer_addr(program_counter),
	.buffer_out(IF_opcode)
);

// ---------------- STAGE : IF - END ----------------

always @ (posedge clk)
begin
	if (reset == 1 || write_inst_en == 1)
		IF_ID_opcode <= {2'b11, {(OPCODE_WIDTH - 2){1'b0}}};
	
	else
		IF_ID_opcode <= IF_opcode;
end

// ---------------- STAGE : ID - BEGIN ----------------

assign ID_opcode = IF_ID_opcode;

inst_decode inst_decode
(
	.opcode(ID_opcode),

	.alu_ctrl(ID_ALU_ctrl),

	.reg_rd(ID_rd_addr),
	.reg_rs1(ID_rs1_addr),
	.reg_rs2(ID_rs2_addr),
	.reg_rs3(ID_rs3_addr),

	.use_imm(ID_use_imm),
	.immediate(immediate),

	.write_back(ID_wb)
);

reg_file reg_file
(
	.clk(clk),
	.reset(reset),

	.write_en(WB_wb),
	.write_addr(WB_rd_addr),

	.read_addr1(ID_rs1_addr),
	.read_addr2(ID_rs2_addr),
	.read_addr3(ID_rs3_addr),

	.write_data(WB_ALU_out),

	.read_data1(ID_rs1_data),
	.read_data2(ID_rs2_data),
	.read_data3(ID_rs3_data),

	.reg_data_all(reg_data_out)
);

// ---------------- STAGE : ID - END ----------------

always @ (posedge clk)
begin 
	if (reset == 1 || write_inst_en == 1)
	begin
		ID_EX_opcode <= {2'b11, {(OPCODE_WIDTH - 2){1'b0}}};

		ID_EX_wb <= 0;
		ID_EX_rd_addr <= 0;

		ID_EX_ALU_ctrl <= 0;

		ID_EX_rs1_data <= 0;
		ID_EX_rs2_data <= 0;
		ID_EX_rs3_data <= 0;

		ID_EX_rs1_addr <= 0;
		ID_EX_rs2_addr <= 0;
		ID_EX_rs3_addr <= 0;

		ID_EX_use_imm <= 0;
	end
	
	else
	begin
		ID_EX_opcode <= ID_opcode;

		ID_EX_wb <= ID_wb;
		ID_EX_rd_addr <= ID_rd_addr;

		ID_EX_ALU_ctrl <= ID_ALU_ctrl;

		ID_EX_rs1_data <= ID_rs1_data;
		ID_EX_rs2_data <= (ID_use_imm == 1) ? {{112{1'b0}}, immediate} : ID_rs2_data;
		ID_EX_rs3_data <= ID_rs3_data;

		ID_EX_rs1_addr <= ID_rs1_addr;
		ID_EX_rs2_addr <= ID_rs2_addr;
		ID_EX_rs3_addr <= ID_rs3_addr;

		ID_EX_use_imm <= ID_use_imm;
	end
end

// ---------------- STAGE : EX - BEGIN ----------------

assign EX_opcode = ID_EX_opcode;

assign EX_wb = ID_EX_wb;
assign EX_rd_addr = ID_EX_rd_addr;

assign EX_ALU_ctrl = ID_EX_ALU_ctrl;

assign EX_rs1_addr = ID_EX_rs1_addr;
assign EX_rs2_addr = ID_EX_rs2_addr;
assign EX_rs3_addr = ID_EX_rs3_addr;

assign EX_use_imm = ID_EX_use_imm;

// NOTE: DATA FORWARDING YAY.
assign EX_rs1_data = ((WB_wb == 1) && (WB_rd_addr == EX_rs1_addr) && (WB_rd_addr != 5'b00000)) ? WB_ALU_out :
	                 ID_EX_rs1_data;

assign EX_rs2_data = ((WB_wb == 1) && (WB_rd_addr == EX_rs2_addr) && (WB_rd_addr != 5'b00000) && (EX_use_imm == 0)) ? WB_ALU_out :
					 ID_EX_rs2_data;

assign EX_rs3_data = ((WB_wb == 1) && (WB_rd_addr == EX_rs3_addr) && (WB_rd_addr != 5'b00000)) ? WB_ALU_out :
					 ID_EX_rs3_data;


alu alu
(
	.ctrl(EX_ALU_ctrl),

	.reg_rs1(EX_rs1_data),
	.reg_rs2(EX_rs2_data),
	.reg_rs3(EX_rs3_data),

	.reg_rd(EX_ALU_out)
);

// ---------------- STAGE : EX - END ----------------

always @ (posedge clk)
begin
	if (reset == 1 || write_inst_en == 1)
	begin
		EX_WB_opcode <= {2'b11, {(OPCODE_WIDTH - 2){1'b0}}};
		EX_WB_wb <= 0;
		EX_WB_rd_addr <= 0;
		EX_WB_ALU_out <= 0;
	end
	
	else
	begin
		EX_WB_opcode <= EX_opcode;

		EX_WB_wb <= EX_wb;
		EX_WB_rd_addr <= EX_rd_addr;
		EX_WB_ALU_out <= EX_ALU_out;
	end
end

// ---------------- STAGE : WB - BEGIN ----------------

assign WB_opcode = EX_WB_opcode;

assign WB_wb = EX_WB_wb;
assign WB_rd_addr = EX_WB_rd_addr;
assign WB_ALU_out = EX_WB_ALU_out;

// ---------------- STAGE : WB - END ----------------

assign IF_opcode_out = IF_opcode;
assign ID_opcode_out = ID_opcode;
assign EX_opcode_out = EX_opcode;
assign WB_opcode_out = WB_opcode;

endmodule
