`timescale 1ns/1ps

module tb_multipli_simple();
	parameter T = 20;
	parameter tamano = 8;
	
	//Duv instance
	reg CLOCK, RESET;
	reg START;
	reg signed [tamano-1:0] A, B;
	wire signed [2*tamano-1:0] S;
	wire END_MULT;
	
	multipli #(.tamano(tamano)) duv
	(
		.CLOCK(CLOCK) ,	// input  CLOCK_sig
		.RESET(RESET) ,	// input  RESET_sig
		.END_MULT(END_MULT) ,	// output  END_MULT_sig
		.A(A) ,	// input [tamano-1:0] A_sig
		.B(B) ,	// input [tamano-1:0] B_sig
		.S(S) ,	// output [2*tamano-1:0] S_sig
		.START(START) 	// input  START_sig
	);	
	
	class RCSG;
		rand logic [tamano-1:0] A;
		rand logic [tamano-1:0] B;
		constraint A_pos {A[tamano-1] == 1'b0;}
		constraint A_neg {A[tamano-1] == 1'b1;}
		constraint B_pos {B[tamano-1] == 1'b0;}
		constraint B_neg {B[tamano-1] == 1'b1;}
	endclass
	
	covergroup ValoresAB		@(posedge END_MULT);
		coverpoint A {
			bins pos[32] = {[0:(2**(tamano-1)-1)]};
			bins neg[32] = {[-(2**(tamano-1)):-1]};
			}
		coverpoint B {
			bins pos[32] = {[0:(2**(tamano-1)-1)]};
			bins neg[32] = {[-(2**(tamano-1)):-1]};
			}
		cruce: cross A,B;
	endgroup;
	
	//Declaracion de objetos
	RCSG busInst = new;
	ValoresAB veamos = new;
	
	//Clock generation
	always 
	begin 
	#(T/2) CLOCK = ~CLOCK;
	end
	
	//Tasks
	task reset;
	begin
		RESET = 0;
		repeat(5) @(negedge CLOCK);
		RESET = 1;
	end
	endtask
	
	task write;
		begin
			A = $random;
			B = $random;
			START = 1'b1;
			repeat(1) @(negedge CLOCK);
			START = 1'b0;
		end
	endtask
	
// Ambos son positivos
	task ambos_posit;
		begin
			busInst.A_pos.constraint_mode(1);
			busInst.A_neg.constraint_mode(0);
			busInst.B_pos.constraint_mode(1);
			busInst.B_neg.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			A = busInst.A;
			B = busInst.B;
			
			assert ((A>=0)&(B>=0))		else $error("No son ambos positivos.");
			START = 1'b1;
			repeat(1) @(negedge CLOCK);
			START = 1'b0;
		end
	endtask
//Ambos son negativos
	task ambos_negat;
		begin
			busInst.A_pos.constraint_mode(0);
			busInst.A_neg.constraint_mode(1);
			busInst.B_pos.constraint_mode(0);
			busInst.B_neg.constraint_mode(1);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			A = busInst.A;
			B = busInst.B;

			assert((A<0)&(B<0)) else $error("No son ambos negativos.");
			START = 1'b1;
			repeat(1) @(negedge CLOCK);
			START = 1'b0;
		end
	endtask
// A es positivo y B negativo
	task pos_neg;
		begin
			busInst.A_pos.constraint_mode(1);
			busInst.A_neg.constraint_mode(0);
			busInst.B_pos.constraint_mode(0);
			busInst.B_neg.constraint_mode(1);

			assert(busInst.randomize()) else $error("Falló randomize()");
			A = busInst.A;
			B = busInst.B;

			assert((A>=0)&(B<0)) else $error("No se cumple A positivo y B negativo %d,%d",A,B);
			
			START = 1'b1;
			repeat(1) @(negedge CLOCK);
			START = 1'b0;
		end
	endtask
// A es negativo y B positivo
	task neg_pos;
		begin
			busInst.A_pos.constraint_mode(0);
			busInst.A_neg.constraint_mode(1);
			busInst.B_pos.constraint_mode(1);
			busInst.B_neg.constraint_mode(0);
			
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			A = busInst.A;
			B = busInst.B;

			assert((A<0)&(B>=0)) else $error("No se cumple A negativo y B positivo %d,%d",A,B);

			START = 1'b1;
			repeat(1) @(negedge CLOCK);
			START = 1'b0;
		end
	endtask
		
	task inicializar;
		begin
			CLOCK = 0;
			A = 0;
			B = 0;
			START = 0;
		end
	endtask

// Comprobamos que la multiplicacion se realiza de manera correcta
	assert property (@(posedge CLOCK) END_MULT |-> ($signed(S) == $signed(A)*$signed(B)))	else	$error("El multiplicador no realiza su funcion %d,%d,%d",A,B,S);


	
	
	initial 
	begin
	$display("Running testbench");

	inicializar();
	reset();

// Comprobaciones iniciales para ver si funciona multiplicador
	write();
	repeat(20) @(negedge CLOCK);
	write();
	repeat(20) @(negedge CLOCK);
	write();
	repeat(20) @(negedge CLOCK);
	write();
	repeat(20) @(negedge CLOCK);
	write();
	repeat(20) @(negedge CLOCK);

////Comprobamos 3 veces cada caso
	ambos_posit();
	repeat(20) @(negedge CLOCK);
	ambos_posit();
	repeat(20) @(negedge CLOCK);
	ambos_posit();
	repeat(20) @(negedge CLOCK);
	
	ambos_negat();
	repeat(20) @(negedge CLOCK);
	ambos_negat();
	repeat(20) @(negedge CLOCK);
	ambos_negat();
	repeat(20) @(negedge CLOCK);

	pos_neg();
	repeat(20) @(negedge CLOCK);
	pos_neg();
	repeat(20) @(negedge CLOCK);
	pos_neg();
	repeat(20) @(negedge CLOCK);
	
	neg_pos();
	repeat(20) @(negedge CLOCK);
	neg_pos();
	repeat(20) @(negedge CLOCK);
	neg_pos();
	repeat(20) @(negedge CLOCK);

// Realizamos el trigger manual de nuestro covergroup ValoresAB
	while (veamos.cruce.get_coverage()<70)
		begin
			ambos_posit();
			repeat(20) @(negedge CLOCK);
			ambos_negat();
			repeat(20) @(negedge CLOCK);
			pos_neg();
			repeat(20) @(negedge CLOCK);
			neg_pos();
			repeat(20) @(negedge CLOCK);
		end
		
	$stop;
	end
	
	
endmodule

