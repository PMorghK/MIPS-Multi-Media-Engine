// CTRL Signal Definitions;

// Load Immediate
`define op_LI    5'b11111

// R3 Instruction Group
`define op_NOP   8'b00000000
`define op_SLHI  8'b00000001
`define op_AU    8'b00000010
`define op_CNT1H 8'b00000011
`define op_AHS   8'b00000100
`define op_AND   8'b00000101
`define op_BCW   8'b00000110
`define op_MAXWS 8'b00000111
`define op_MINWS 8'b00001000
`define op_MLHU  8'b00001001
`define op_MLHCU 8'b00001010
`define op_OR    8'b00001011
`define op_CLZH  8'b00001100
`define op_RLH   8'b00001101
`define op_SFWU  8'b00001110
`define op_SFHS  8'b00001111

// R4 Instruction Group
`define op_group_R4I 6'b010000
`define op_group_R4L 6'b110000
