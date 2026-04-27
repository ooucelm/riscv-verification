`timescale 1ps/1ps

module tb_FIFO ();
	 parameter T = 20;
	 parameter WIDTH = 8;
	 parameter DEPTH = 32;
	 // DUV instance
	 reg CLOCK, RESET_N, CLEAR_N, READ, WRITE;
	 reg [WIDTH-1:0] DATA_IN;
	 wire [WIDTH-1:0] DATA_OUT;
	 wire [$clog2(DEPTH):0] USE_DW;
	 wire F_EMPTY_N, F_FULL_N;
 

FIFO #(.DEPTH(DEPTH), .WIDTH(WIDTH)) duv
(
	.CLOCK(CLOCK) ,	// input  CLOCK_sig
	.RESET_N(RESET_N) ,	// input  RESET_N_sig
	.CLEAR_N(CLEAR_N) ,	// input  CLEAR_N_sig
	.READ(READ) ,	// input  READ_sig
	.WRITE(WRITE) ,	// input  WRITE_sig
	.DATA_IN(DATA_IN) ,	// input [WIDTH-1:0] DATA_IN_sig
	.DATA_OUT(DATA_OUT) ,	// output [WIDTH-1:0] DATA_OUT_sig
	.USE_DW(USE_DW) ,
	.F_EMPTY_N(F_EMPTY_N) ,	// output  F_EMPTY_N_sig
	.F_FULL_N(F_FULL_N) 	// output  F_FULL_N_sig
);
	

 
	// Clock generation
	always
	begin
	#(T/2) CLOCK = ~CLOCK;
	end
	 
	// Tasks y aserciones
//	task genera_dato;
//		begin
//			DATA_IN = $random;
//			repeat(10) @(negedge CLOCK);
//		end
//	endtask
	
	task lectura;
		begin
			READ = 1;
			repeat(1) @(negedge CLOCK);
			READ = 0;
			repeat(10) @(negedge CLOCK);
		end
	endtask

	task escritura;
		begin
			DATA_IN = $random;
			repeat(5) @(negedge CLOCK);
			WRITE = 1;
			repeat(1) @(negedge CLOCK);
			WRITE = 0;
			repeat(10) @(negedge CLOCK);
		end
	endtask
	
	task inicializar;
		begin
			CLOCK = 0;
			RESET_N	= 0;
			CLEAR_N = 0;
			READ = 0;
			WRITE = 0;
		end
	endtask
	
	task desac_rst;
		begin
			RESET_N = 1;
			CLEAR_N = 1;
		end
	endtask

	task simultaneo;
		begin
			READ = 1;
			WRITE = 1;
			#(T*2)
			DATA_IN = $random;
			#(T*2)
			DATA_IN = $random;
			#(T*2)
			DATA_IN = $random;
			#(T*10)
			READ = 0;
			WRITE = 0;
		end
	endtask
	 
	initial
	begin
	inicializar();
	repeat(10) @(negedge CLOCK);
	desac_rst();
//llenamos la FIFO
	repeat(32) escritura();
	repeat(15) @(negedge CLOCK);
//intentamos escribir con la fifo llena
	repeat(2) escritura();
	repeat(10) @(negedge CLOCK);
//vaciamos la FIFO
	repeat(32) lectura();
	repeat(10) @(negedge CLOCK);
//intentamos leer con la fifo vacia
	repeat(2) lectura();
	repeat(10) @(negedge CLOCK);
//comprobamos si use_dw cuenta correctamente
	repeat(5) escritura();
	repeat(5) lectura();
//comprobamos el funcionamiento del clear_n
	repeat(10) escritura();
	CLEAR_N = 0;
	repeat(10) @(negedge CLOCK)
	CLEAR_N = 1;
//comprobamos el funcionamiento del reset_n
	repeat(5) escritura();
	repeat(3) lectura();
	RESET_N = 0;
	repeat(10) @(negedge CLOCK)
	RESET_N = 1;
//read y write simultáneos con fifo vacia 
	simultaneo();
//read y write simultáneos con fifo semillena
	repeat(5) @(negedge CLOCK)
	DATA_IN = $random;
	repeat(4) escritura();
	simultaneo();	
	repeat(6) lectura();
	repeat(5) @(negedge CLOCK);
	
	assert (USE_DW <= 32) else $error("La FIFO ha sobrepasado su límite de palabras");
	assert (USE_DW >= 0) else $error("Error del contador (USE_DW negativo)");
	assert (!(!F_FULL_N && !F_EMPTY_N)) $error("La FIFO no puede estar llena y vacía a la vez");
	$display("Running testbench");
	$stop;
	end
	
endmodule
