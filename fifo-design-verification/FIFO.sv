module FIFO(CLOCK, RESET_N, CLEAR_N, READ, WRITE, DATA_IN, DATA_OUT, USE_DW, F_EMPTY_N, F_FULL_N);
	
	parameter DEPTH = 32;
	parameter WIDTH = 8;
	input CLOCK, RESET_N, CLEAR_N, READ, WRITE;
	input [WIDTH-1:0]		DATA_IN;
	output logic F_EMPTY_N, F_FULL_N;
	output logic [$clog2(DEPTH):0]	USE_DW;
	output logic [WIDTH-1:0]		DATA_OUT;
	
	logic encw, encr, enudw, updown, selecc, escri, lectu;
	logic [$clog2(DEPTH):0] contausedw;
	logic [WIDTH-1:0] DATA_OUT_hold;
	logic  [$clog2(DEPTH)-1:0] contaw, contard;
	logic [WIDTH-1:0] salida_ram;
FSM #(.DEPTH(32), .WIDTH(8)) FSM_inst
(
	.CLOCK(CLOCK) ,	// input  CLOCK_sig
	.RESET_N(RESET_N) ,	// input  RESET_N_sig
	.CLEAR_N(CLEAR_N) ,	// input  CLEAR_N_sig
	.READ(READ) ,	// input  READ_sig
	.WRITE(WRITE) ,	// input  WRITE_sig
	.USE_DW(contausedw) ,
	.F_FULL_N(F_FULL_N) ,	// output  F_FULL_N_sig
	.F_EMPTY_N(F_EMPTY_N) ,	// output  F_EMPTY_N_sig
	.ena_cw(encw) ,	// output  ena_cw_sig
	.ena_cr(encr) ,	// output  ena_cr_sig
	.ena_udw(enudw) ,	// output  ena_udw_sig
	.updn_udw(updown) ,	// output  updn_udw_sig
	.sel(selecc) ,	// output  sel_sig
	.wr_ram(escri) ,	// output  wr_ram_sig
	.rd_ram(lectu) 	// output  rd_ram_sig
);


binary_up_down_counter #(.width(5)) countw
(
	.clk(CLOCK) ,	// input  clk_sig
	.enable(encw) ,	// input  enable_sig
	.count_up(1'b1) ,	// input  count_up_sig
	.reset(RESET_N) ,	// input  reset_sig
	.clear(CLEAR_N) ,	// input  clear_sig
	.count(contaw) 	// output [WIDTH-1:0] count_sig
);

binary_up_down_counter #(.width(5)) countr
(
	.clk(CLOCK) ,	// input  clk_sig
	.enable(encr) ,	// input  enable_sig
	.count_up(1'b1) ,	// input  count_up_sig
	.reset(RESET_N) ,	// input  reset_sig
	.clear(CLEAR_N) ,	// input  clear_sig
	.count(contard) 	// output [WIDTH-1:0] count_sig
);

binary_up_down_counter #(.width(6)) use_dw
(
	.clk(CLOCK) ,	// input  clk_sig
	.enable(enudw) ,	// input  enable_sig
	.count_up(updown) ,	// input  count_up_sig
	.reset(RESET_N) ,	// input  reset_sig
	.clear(CLEAR_N) ,	// input  clear_sig
	.count(contausedw) 	// output [WIDTH-1:0] count_sig
);


ram_dp #(.mem_depth(32), .size(8)) ram_dp_inst
(
	.data_in(DATA_IN) ,	// input [size-1:0] data_in_sig
	.wren(escri) ,	// input  wren_sig
	.clock(CLOCK) ,	// input  clock_sig
	.rden(lectu) ,	// input  rden_sig
	.wraddress(contaw) ,
	.rdaddress(contard) ,
	.reset_n(RESET_N) ,
	.data_out(salida_ram) 	// output [size-1:0] data_out_sig
);



always_ff @(posedge CLOCK or negedge RESET_N)
	if (!RESET_N)
		DATA_OUT_hold <= 0;
	else 
		DATA_OUT_hold <= DATA_IN;
	

assign DATA_OUT = (selecc) ? DATA_OUT_hold : salida_ram;
assign USE_DW = contausedw;

	
endmodule
