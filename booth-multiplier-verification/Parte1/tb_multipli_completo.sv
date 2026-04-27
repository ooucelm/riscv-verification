parameter tamano = 8;
class Bus;
	randc logic signed [tamano-1:0] A;
	randc logic signed [tamano-1:0] B;
	constraint A_pos {A[tamano-1] == 1'b0;}
	constraint A_neg {A[tamano-1] == 1'b1;}
	constraint B_pos {B[tamano-1] == 1'b0;}
	constraint B_neg {B[tamano-1] == 1'b1;}
endclass

`timescale 1ns/1ps
// -----------------------------------------------------------------
// INTERFAZ
// -----------------------------------------------------------------
interface test_if (
	input bit reloj ,
	input bit rst);
	logic empieza;
	logic termina;
	logic signed [tamano-1:0] data1_in;
	logic signed [tamano-1:0] data2_in;
	logic signed [2*tamano-1:0] data_out;
	
	clocking md @(posedge reloj);
		input #1ns data_out;
		input #1ns data1_in;
		input #1ns data2_in;
		input #1ns empieza;
		input #1ns termina;
   endclocking:md;
	
	clocking sd @(posedge reloj);
		input #2ns  data_out;
		output #2ns data1_in;
		output #2ns data2_in;
		input #2ns  termina;
		output #2ns empieza; 
	endclocking:sd;
	
  	modport monitor (clocking md);
   modport test (clocking sd);
   modport duv (
  		input          reloj,
  		input        	rst,
  		output         termina,
  		input         	empieza,
  		input  			data1_in,
  		input  			data2_in,
  		output    		data_out
		);

endinterface

class Scoreboard;
	reg [2*tamano-1:0] cola_targets [$];
	reg [2*tamano-1:0] target, pretarget, salida_obtenida;
	reg FINAL;
	virtual test_if.monitor mports;
	
	function new (virtual test_if.monitor mpuertos);
	begin
		this.mports = mpuertos;
	end
	endfunction
	
	task monitor_input;
		begin
			while(1)
				begin       
					@(mports.md);
					if (mports.md.empieza==1'b1)
						begin
							pretarget = $signed(mports.md.data1_in)*$signed(mports.md.data2_in);
							cola_targets = {pretarget,cola_targets};
						end
				end
		end
	endtask
		
	task monitor_output;
		begin
			while(1)
				begin
					@(mports.md);
					if (mports.md.termina==1'b1)
						begin
							FINAL = mports.md.termina;
							target = cola_targets.pop_back();
							salida_obtenida = mports.md.data_out;
							assert (salida_obtenida == target) else $error("operacion mal realizada: la multiplicacion de %d con %d es %d y tu diste %d", mports.md.data1_in, mports.md.data2_in, target, salida_obtenida);
						end
				end
		end
	endtask
endclass


// -----------------------------------------------------------------
// PROGRAM: bloque de verificación activo
// -----------------------------------------------------------------
program estimulos
	(test_if.test testar,
	test_if.monitor monitorizar  
	);
	
covergroup ValoresAB;
	cvA:coverpoint monitorizar.md.data1_in {
		//bins pos[8] = {[0:(2**(tamano-1)-1)]};
		//bins neg[8] = {[-(2**(tamano-1)):-1]};
		bins binsdata1[128]= {[-(2**(tamano-1)):(2**(tamano-1)-1)]};
		}
	cvB:coverpoint monitorizar.md.data2_in {
		//bins pos[8] = {[0:(2**(tamano-1)-1)]};
		//bins neg[8] = {[-(2**(tamano-1)):-1]};
		bins binsdata2[128]= {[-(2**(tamano-1)):(2**(tamano-1)-1)]};
		}
	cruce: cross cvA,cvB;
endgroup;

//Declaramos los objetos 
Bus busInst;
ValoresAB veamos;
Scoreboard sb;
//	event comprobar;

initial 
	begin 
		busInst=new;
		veamos=new;
		sb=new(monitorizar);
		fork
			sb.monitor_input;		//lanzo monitoriz cambio entrada y calculo el target
			sb.monitor_output;		//lanzo el monitoriz cambio salida y comparacion ideal
		join_none
		testar.sd.empieza <= 1'b0;
		testar.sd.data1_in <= 25;
		testar.sd.data2_in <= 100;
		repeat(3) @(testar.sd);
		testar.sd.empieza <= 1'b1;
		@(testar.sd);
		testar.sd.empieza <= 1'b0;
		@(negedge testar.sd.termina);

		$display("Pruebo positivo x positivo (AxB)");
		
		while (veamos.cruce.get_coverage()<25)  
		begin
			busInst.A_pos.constraint_mode(1);
			busInst.A_neg.constraint_mode(0);
			busInst.B_pos.constraint_mode(1);
			busInst.B_neg.constraint_mode(0);
			assert(busInst.randomize()) else $error("Falló randomize()");
			testar.sd.data1_in <= busInst.A;
			testar.sd.data2_in <= busInst.B;
			 @(testar.sd);
			veamos.sample();
			@(testar.sd);
			testar.sd.empieza <= 1'b1;
			@(testar.sd);
			testar.sd.empieza <= 1'b0;
			@(negedge testar.sd.termina);
		end
		

		$display("Pruebo negativo x negativo (AxB)");
		while (veamos.cruce.get_coverage()<50) 
		begin
			busInst.A_pos.constraint_mode(0);
			busInst.A_neg.constraint_mode(1);
			busInst.B_pos.constraint_mode(0);
			busInst.B_neg.constraint_mode(1);
			assert(busInst.randomize()) else $error("Falló randomize()");
			testar.sd.data1_in <= busInst.A;
			testar.sd.data2_in <= busInst.B;
			 @(testar.sd);
			veamos.sample();
			@(testar.sd);
			testar.sd.empieza <= 1'b1;
			@(testar.sd);
			testar.sd.empieza <= 1'b0;
			@(negedge testar.sd.termina);
		end
		

		$display("Pruebo positivo x negativo (AxB)");
		while (veamos.cruce.get_coverage()<75)
		begin
			busInst.A_pos.constraint_mode(1);
			busInst.A_neg.constraint_mode(0);
			busInst.B_pos.constraint_mode(0);
			busInst.B_neg.constraint_mode(1);
			assert(busInst.randomize()) else $error("Falló randomize()");
			testar.sd.data1_in <= busInst.A;
			testar.sd.data2_in <= busInst.B;
			 @(testar.sd);
			veamos.sample();
			@(testar.sd);
			testar.sd.empieza <= 1'b1;
			@(testar.sd);
			testar.sd.empieza <= 1'b0;
			@(negedge testar.sd.termina);
		end
		$display("Pruebo negativo x positivo (AxB)");
		while (veamos.cruce.get_coverage()<100) 
		begin
			busInst.A_pos.constraint_mode(0);
			busInst.A_neg.constraint_mode(1);
			busInst.B_pos.constraint_mode(1);
			busInst.B_neg.constraint_mode(0);
			assert(busInst.randomize()) else $error("Falló randomize()");
			testar.sd.data1_in <= busInst.A;
			testar.sd.data2_in <= busInst.B;
			 @(testar.sd);
			veamos.sample();
			@(testar.sd);
			testar.sd.empieza <= 1'b1;
			@(testar.sd);
			testar.sd.empieza <= 1'b0;
			@(negedge testar.sd.termina);
		end
		$stop;
	end
endprogram		

module tb_multipli_completo();

	reg CLOCK, RESET;
	//Instanciamos el interfaz
	test_if interfaz(.reloj(CLOCK),.rst(RESET));
	//Instacia del DUV
	multipli duv (
		 .CLOCK (CLOCK),
		 .RESET (RESET),
		 .END_MULT (interfaz.termina),    // conectar a la señal del interface
		 .A (interfaz.data1_in),
		 .B (interfaz.data2_in),
		 .S (interfaz.data_out),
		 .START (interfaz.empieza)
	);

	//Instancia del program
	estimulos estim1 (.testar(interfaz),.monitorizar(interfaz));
	
	//Clock generation
	always
	begin
		CLOCK = 1'b0;
		CLOCK = #50 1'b1;
		#50;
	end 

	// RESET
	initial
	begin
	  RESET=1'b1;
	  # 1  RESET=1'b0;
		#99 RESET = 1'b1;
	end

	initial 
	begin
		$dumpfile("multiplicador.vcd");
		$dumpvars(1, tb_multipli_completo.duv);
	end	
	
endmodule
