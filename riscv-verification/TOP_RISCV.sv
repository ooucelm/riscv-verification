module TOP_RISCV(CLOCK, RST_n);

input CLOCK, RST_n;

logic [31:0] PC_addr, instr_rom, alu_result, dataram_rd_sig, dataram_wr_sig;
logic ena_wr_sig, ena_rd_sig;


ROM #(.ANCHO(32), .LARGO(1024), .INIT_FILE("")) ROM_inst
(
	.addr(PC_addr[11:2]) , //solo 10 bits porque es lo que dicta el parametro LARGO de nuestra ROM
	.dout(instr_rom) 	// output [ANCHO-1:0] dout_sig
);

TOP_CORE TOP_CORE_inst
(
	.instr(instr_rom) ,	// input [31:0] instr_sig
	.dataram_rd(dataram_rd_sig) ,	// input [31:0] datareg_wr_sig
	.CLOCK(CLOCK) ,	// input  CLOCK_sig
	.RST_n(RST_n) ,	// input  RST_n_sig
	.PC(PC_addr) ,	// output [31:0] PC_sig
	.ena_wr(ena_wr_sig) ,	// output  ena_wr_sig
	.ena_rd(ena_rd_sig) ,	// output  ena_rd_sig
	.alu_out_ext(alu_result) ,	// output [31:0] alu_out_ext_sig
	.dataram_wr(dataram_wr_sig) 	// output [31:0] dataram_wr_sig
);

RAM #(.INIT_FILE("")) RAM_inst
(
	.CLK(CLOCK) ,	// input  clk_sig
	.write_enable(ena_wr_sig) ,	// input  write_enable_sig
	.read_enable(ena_rd_sig) ,	// input  read_enable_sig
	.addr(alu_result[11:2]) , //solo 10 bits porque es lo que dicta el parametro LARGO de nuestra ROM
	.din(dataram_wr_sig) ,	// input [ANCHO-1:0] din_sig
	.dout(dataram_rd_sig) 	// output [ANCHO-1:0] dout_sig
);

endmodule
