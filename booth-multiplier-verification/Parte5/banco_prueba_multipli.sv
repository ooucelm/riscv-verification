//En este módulo realizamos la verificacion fisica del multiplicador
module banco_prueba_multipli(CLOCK, RESET, START, A, B, HEX0,HEX1,HEX2,HEX4,HEX5,HEX6,HEX7);
input CLOCK, RESET, START;
input [3:0] A, B;
output [6:0] HEX0,HEX1,HEX2,HEX4,HEX5,HEX6,HEX7;

logic  [7:0] result;
logic signA, signB, signS;
logic [3:0] bcdA;
logic [3:0] bcdB;
logic [7:0] bcdS;

multipli #(.tamano(4)) multipli_inst
(
	.CLOCK(CLOCK) ,	// input  CLOCK_sig
	.RESET(RESET) ,	// input  RESET_sig
	.END_MULT() ,	// output  END_MULT_sig
	.A(A) ,	// input [tamano-1:0] A_sig
	.B(B) ,	// input [tamano-1:0] B_sig
	.S(result) ,	// output [2*tamano-1:0] S_sig
	.START(!START) 	// input  START_sig
);


binarioabcd binarioabcd_A
(
	.clk(CLOCK) ,	// input  clk_sig
	.reset(RESET) ,	// input  reset_sig
	.start(!START) ,	// input  start_sig
	.bin_in(A) ,	// input [WIDTH-1:0] bin_in_sig
	.done() ,	// output  done_sig
	.sign(signA) ,	// output  sign_sig
	.bcd_out(bcdA) 	// output [11:0] bcd_out_sig
);

defparam binarioabcd_A.WIDTH = 4;

binarioabcd binarioabcd_B
(
	.clk(CLOCK) ,	// input  clk_sig
	.reset(RESET) ,	// input  reset_sig
	.start(!START) ,	// input  start_sig
	.bin_in(B) ,	// input [WIDTH-1:0] bin_in_sig
	.done() ,	// output  done_sig
	.sign(signB) ,	// output  sign_sig
	.bcd_out(bcdB) 	// output [11:0] bcd_out_sig
);

defparam binarioabcd_B.WIDTH = 4;

binarioabcd binarioabcd_S
(
	.clk(CLOCK) ,	// input  clk_sig
	.reset(RESET) ,	// input  reset_sig
	.start(!START) ,	// input  start_sig
	.bin_in(result) ,	// input [WIDTH-1:0] bin_in_sig
	.done() ,	// output  done_sig
	.sign(signS) ,	// output  sign_sig
	.bcd_out(bcdS) 	// output [11:0] bcd_out_sig
);

defparam binarioabcd_S.WIDTH = 8;


conversor7seg conversor7seg_inst
(
    .A_bcd(bcdA),
    .B_bcd(bcdB),
    .S_bcd(bcdS),
    .negA(signA),
    .negB(signB),
    .negS(signS),
    .HEX0(HEX0), 
	 .HEX1(HEX1), 
	 .HEX2(HEX2), 
	 .HEX4(HEX4), 
	 .HEX5(HEX5), 
	 .HEX6(HEX6), 
	 .HEX7(HEX7)
);
	 

endmodule
