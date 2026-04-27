`timescale 1ns/1ps
module tb_TOP_CORE_seg();
	localparam T = 20;
	
	logic [31:0] instr, datareg_wr, PC, alu_out_ext, dataram_wr, dataram_rd_sig;
	logic CLOCK, RST_n, ena_wr, ena_rd, MemtoReg_sig;
	
	logic [31:0] [31:0] registro; //x0=registro[0],x1=registro[1], ect
	logic [31:0] rs1, rs2, inm_ext_32, PC_esperado1, PC_esperado2, expected_addr, rd_addr_value; // Contenido de 32 bits
	logic [11:0] inm_orshamt, inm;
	logic [2:0] func3;
	logic [31:0] resultado_esperado;
	logic true_false;
	logic [19:0] inm_tipoU;
	logic [20:0] inm_Jal;
	logic [4:0] rd_addr;
	
	TOP_CORE_seg duv
	(
		.instr(instr) ,	// input [31:0] instr_sig
		.dataram_rd(alu_out_ext) ,	// input [31:0] datareg_wr_sig
		.CLOCK(CLOCK) ,	// input  CLOCK_sig
		.RST_n(RST_n) ,	// input  RST_n_sig
		.PC(PC) ,	// output [31:0] PC_sig
		.ena_wr(ena_wr) ,	// output  ena_wr_sig
		.ena_rd(ena_rd) ,	// output  ena_rd_sig
		.alu_out_ext(alu_out_ext) ,	// output [31:0] alu_out_ext_sig
		.dataram_wr(dataram_wr) 	// output [31:0] dataram_wr_sig
	);

	class instruccionRandom;
		rand logic [31:0] instr;

		constraint R_format {
			instr[6:0] == 7'b0110011;
			instr[31:25] == 7'b0000000 ||
			instr[31:25] == 7'b0100000 && instr[14:12] == 3'b000 ||
			instr[31:25] == 7'b0100000 && instr[14:12] == 3'b101;
		} 
				
		constraint I_format {
			instr[6:0] == 7'b0010011;
			
			(instr[14:12] == 3'b001) -> (instr[31:25] == 7'b0000000);
			(instr[14:12] == 3'b101) -> (instr[31:25] inside {7'b0000000, 7'b0100000});
		}
		
		
		constraint B_format {
			instr[6:0] == 7'b1100011;
			instr[14:12] == 3'b000 ||
			instr[14:12] == 3'b001 ||
			instr[14:12] == 3'b100 ||
			instr[14:12] == 3'b101 ||
			instr[14:12] == 3'b110 ||
			instr[14:12] == 3'b111;		
		}
		
		constraint U_format {
			instr[6:0] == 7'b0010111 || instr[6:0] == 7'b0110111; //AUIPC or LUI
		}
		
		constraint carga_format {
			instr[6:0] == 7'b0000011;
			instr[14:12] == 3'b010;
		}
		
		constraint S_format {
			instr[6:0] == 7'b0100011;
			instr[14:12] == 3'b010;
		}
		
		constraint Jal_format {
			instr[6:0] == 7'b1101111;
		}
		
		constraint Jalr_format {
			instr[6:0] == 7'b1100111;
			instr[14:12] == 3'b000;
		}
	endclass


	// --- COVERGROUPS ---
	
	// R_TYPE (ACTIVO)
	covergroup R_type;
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		rs2_cp: coverpoint instr[24:20] {
			bins val[4] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		cruceR: cross rd_cp, rs1_cp, rs2_cp, func3_cp;
	endgroup;
	
	
	
	covergroup I_type;
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		inm_cp: coverpoint $signed(instr[31:20]) {
			bins val[4] = {[-2048:2047]};
		} 
		cruceI: cross rd_cp, rs1_cp, func3_cp, inm_cp;
	endgroup;


	covergroup B_type; 
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		rs2_cp: coverpoint instr[24:20] {
			bins val[4] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		inm_cp: coverpoint $signed({instr[31],instr[7],instr[30:25],instr[11:8]}) {
			bins val[4] = {[-2048:2047]};
		}
		cruceB: cross rs1_cp, rs2_cp, inm_cp;
	endgroup;
	
	covergroup U_type; 
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		inm_cp: coverpoint $signed({instr[31:12]}) {
			bins val[8] = {[-524288:524287]};
		}
		cruceU: cross rd_cp, inm_cp;
	endgroup;

	covergroup carga_type;
		inm_cp: coverpoint $signed({instr[31:20]}) {
			bins val[8] = {[-2048:2047]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		cruce_carg: cross inm_cp, rs1_cp, rd_cp;
	endgroup;
	
	covergroup S_type;
		inm_cp: coverpoint $signed({instr[31:25],instr[11:7]}) {
			bins val[] = {[-2048:2047]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		cruceS: cross inm_cp, rs1_cp;
	endgroup;
	
	covergroup Jal_type;
		inm_cp: coverpoint $signed({instr[31:12]})	{
			bins val[4] = {[-524288:524287]};
		}
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		cruceJal: cross rd_cp, inm_cp;
	endgroup;
	
	covergroup Jalr_type;
		inm_cp: coverpoint $signed({instr[31:20]})	{
			bins val[4] = {[-2048:2047]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		cruceJalr: cross rd_cp, inm_cp, rs1_cp;
	endgroup;
	
	//Declaracion de objetos
	instruccionRandom busInst = new;
	R_type veamosR = new;
	I_type veamosI = new;
	B_type veamosB = new;
	U_type veamosU = new;
	carga_type veamos_car = new;
	S_type veamosS = new;
	Jal_type veamosJal = new;
	Jalr_type veamosJalr = new;
	
	//DEFINICION DEL CLOCK
	always
	begin
		#(T/2) CLOCK = ~CLOCK;
	end
	
	// TASK PARA INICIALIZAR REGISTROS (Evita valores 'X')
	task init_registros;
		begin
			for (int i = 0; i < 32; i++) begin
				duv.banco_registros_inst.registro[i] = $random;
			end
			duv.banco_registros_inst.registro[0] = 32'h0; // R0 siempre es 0
		end
	endtask
	
	assign registro = duv.banco_registros_inst.registro;
	
task R_instructions;
		begin
			// 2. INICIO DE LA LÓGICA
			busInst.R_format.constraint_mode(1);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr; 
			
			rs1 = registro[instr[19:15]];
			rs2 = registro[instr[24:20]];
			func3 = instr[14:12];
			
			case(func3)
				 3'b000: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 + rs2; 
					  else
							resultado_esperado = rs1 - rs2; 
				 end
				 3'b001: resultado_esperado = rs1 << rs2[4:0];
				 3'b010: resultado_esperado = ($signed(rs1) < $signed(rs2)) ? 32'd1 : 32'd0;
				 3'b011: resultado_esperado = (rs1 < rs2) ? 32'd1 : 32'd0; 
				 3'b100: resultado_esperado = rs1 ^ rs2;
				 3'b101: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 >> rs2[4:0];
					  else
							resultado_esperado = $signed(rs1) >>> rs2[4:0];
				 end
				 3'b110:	resultado_esperado = rs1 | rs2;
				 3'b111: resultado_esperado = rs1 & rs2;
				 default: resultado_esperado = '0;
			endcase
			
			repeat(5) @(negedge CLOCK);
			assert (alu_out_ext == resultado_esperado) else $error("operacion tipo R mal realizada");

			veamosR.sample();
		end
	endtask
	
	task I_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(1);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			rs1 = registro[instr[19:15]];
			inm_orshamt = instr[31:20];
			inm_ext_32 = {{20{inm_orshamt[11]}}, inm_orshamt};
			func3 = instr[14:12];
			case(func3)
				 3'b000: resultado_esperado = rs1 + inm_ext_32; //addi
				 3'b001: resultado_esperado = rs1 << inm_orshamt[4:0];  //slli
				 3'b010: resultado_esperado = ($signed(rs1) < $signed(inm_ext_32)) ? 32'd1 : 32'd0; //slti
				 3'b011: resultado_esperado = (rs1 < $signed(inm_ext_32)) ? 32'd1 : 32'd0; //sltiu
				 3'b100: resultado_esperado = rs1 ^ inm_ext_32; //xori
				 3'b101: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 >> inm_orshamt[4:0]; //srli
					  else
							resultado_esperado = $signed(rs1) >>> inm_orshamt[4:0]; //srai
				 end
				 3'b110:	resultado_esperado = rs1 | inm_ext_32; //ori
				 3'b111: resultado_esperado = rs1 & inm_ext_32; //andi
				 default: resultado_esperado = '0;
			endcase
			
			repeat(5) @(negedge CLOCK);
			assert (alu_out_ext == resultado_esperado) else $error("operacion tipo I mal realizada");

			veamosI.sample();
			
		end
	endtask
	
	task B_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(1);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			rs1 = registro[instr[19:15]];
			rs2 = registro[instr[24:20]];
			func3 = instr[14:12];
			inm = {instr[31], instr[7], instr[30:25], instr[11:8]};
			inm_ext_32 = {{19{instr[31]}}, inm, 1'b0};
			
						
			case(func3)
			   3'b000: true_false = (rs1 == rs2); // BEQ  → SUB
			   3'b001: true_false = (rs1 != rs2); // BNE  → SUB (cambiado)
			   3'b100: true_false = ($signed(rs1) < $signed(rs2)); // BLT  → SLT
			   3'b110: true_false = (rs1 < rs2); // BLTU → SLTU
			   3'b101: true_false = ($signed(rs1) >= $signed(rs2)); // BGE  → SLT
			   3'b111: true_false = (rs1 >= rs2); // BGEU → SLTU
			   default: true_false = 1'b0;
			endcase
			repeat(5) @(negedge CLOCK);
			resultado_esperado = (true_false) ? (PC + inm_ext_32) : (PC + 4);
			if (true_false == 1'b1)
				begin
				repeat(4) @(negedge CLOCK);
				assert (resultado_esperado == PC) else $error("operacion tipo B mal realizada");
				end
			else if (true_false == 1'b0)
				begin
				@(negedge CLOCK);
				assert (resultado_esperado == PC) else $error("operacion tipo B mal realizada");
				end

			veamosB.sample();
			
		end
	endtask
	
	task U_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(1);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			inm_tipoU = instr[31:12];
			//repeat(5) @(negedge CLOCK);
			if (instr[6:0] == 7'b0010111)
				resultado_esperado = {inm_tipoU, 12'b0} + PC; //AUIPC
			else	
				resultado_esperado = {inm_tipoU, 12'b0};
			
			repeat(4) @(negedge CLOCK);
			assert (resultado_esperado == alu_out_ext) else $error("operacion tipo U mal realizada");
			veamosU.sample();
			
		end
	endtask
	
	task carga_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(1);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			

			
			//expected_addr = rs1 + {{20{inm[11]}},inm}; //para comprobar que la direccion esperada coincide con la que usamos en memoria
			
			repeat(5) @(negedge CLOCK);
			inm = instr[31:20];
			rs1 = registro[instr[19:15]];
			rd_addr = instr[11:7];
			expected_addr = rs1 + {{20{inm[11]}},inm}; //para comprobar que la direccion esperada coincide con la que usamos en memoria
			assert (expected_addr == alu_out_ext) else $error("la direccion en la operacion de carga no es correcta");
			assert (duv.banco_registros_inst.RegWrite == 1'b1) else $error("el banco de registros no lee ninguna palabra");
			assert (duv.CONTROL_inst.ALUSrc == 1'b1) else $error("el inmediato no se usa en el calculo de la direccion");
			assert (ena_rd == 1'b1) else $error("no se lee ningun dato de la RAM");
			assert (duv.banco_registros_inst.writeReg == rd_addr) else $error("el dato no se guarda en la direccion que corresponde");


			veamos_car.sample();
			
		end
	endtask

	task S_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(1);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			inm = {instr[31:25],instr[11:7]};
			rs1 = registro[instr[19:15]];
			rs2 = registro[instr[24:20]]; //dato que queremos escribir en mem 
			
			expected_addr = rs1 + {{20{inm[11]}},inm}; //para comprobar que la direccion esperada coincide con la que usamos en memoria
			
			repeat(5) @(negedge CLOCK);
			assert (expected_addr == alu_out_ext) else $error("la direccion en la operacion de store word no es correcta");
			assert (duv.banco_registros_inst.RegWrite == 1'b0) else $error("el banco de registros no debe leer ninguna palabra");
			assert (duv.CONTROL_inst.ALUSrc == 1'b1) else $error("el inmediato no se usa en el calculo de la direccion");
			assert (ena_wr == 1'b1) else $error("no se habilita la escritura en la RAM");
			assert (duv.banco_registros_inst.readData2 == rs2) else $error("el dato que se guarda no coincide con el del registro (objetivo)");
		
			veamosS.sample();
			
		end
	endtask
	
	task Jal_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(0);
			busInst.Jal_format.constraint_mode(1);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			inm_Jal = {instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
			inm_ext_32 = {{11{instr[31]}}, inm_Jal};
			rd_addr = instr[11:7];
			PC_esperado1 = PC + inm_ext_32;
			PC_esperado2 = PC + 4;
			repeat(5) @(negedge CLOCK);
			assert (PC_esperado1 == PC) else $error("El salto en PC no se ha realizado de manera correcta");
			assert (duv.CONTROL_inst.Jal == 1'b1) else $error("Jal no se activa de manera correcta, revisad el Control");
			@(negedge CLOCK);
			rd_addr_value = duv.banco_registros_inst.registro[rd_addr];
			#2
			if (rd_addr != 0)
				begin
					assert (PC_esperado2 == rd_addr_value) else $error("no hemos guardado la direccion de retorno correctamente");
				end
			veamosJal.sample();
			
		end
	endtask
	
	task Jalr_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(0);
			busInst.B_format.constraint_mode(0);
			busInst.U_format.constraint_mode(0);
			busInst.carga_format.constraint_mode(0);
			busInst.S_format.constraint_mode(0);
			busInst.Jalr_format.constraint_mode(1);
			busInst.Jal_format.constraint_mode(0);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			inm = instr[31:20];
			inm_ext_32 = {{20{instr[31]}}, inm};
			rd_addr = instr[11:7];
			func3 = instr[14:12];
			PC_esperado2 = PC + 4;
			repeat(2) @(negedge CLOCK);
			rs1 = registro[instr[19:15]];
			PC_esperado1 = rs1 + inm_ext_32;
			repeat(3) @(negedge CLOCK);
			assert (PC_esperado1 == PC) else $error("El salto en PC no se ha realizado de manera correcta");
			assert (duv.CONTROL_inst.Jalr == 1'b1) else $error("Jalr no se activa de manera correcta, revisad el Control");
			@(negedge CLOCK);
			rd_addr_value = duv.banco_registros_inst.registro[rd_addr];
			#2
			if (rd_addr != 0)
				begin
					assert (PC_esperado2 == rd_addr_value) else $error("no hemos guardado la direccion de retorno correctamente");
				end
			veamosJalr.sample();
			
		end
	endtask

	
	task reset;
		begin
			RST_n = 1'b0; // Activamos Reset
			
			instr = 32'h00000000; 
			datareg_wr = 32'b0; 
			// ----------------------------------------

			@(negedge CLOCK); // Esperamos unos ciclos con el Reset activo
			RST_n = 1'b1; // Soltamos Reset
		end
		endtask
			
	initial
	begin
		CLOCK = 0;
		// Inicializamos memoria		
		reset();
		
 		@(negedge CLOCK);
		while (veamosR.cruceR.get_coverage() < 70)
			
			begin
				#5
				reset();
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				R_instructions;
			end

		@(negedge CLOCK);
		while (veamosI.cruceI.get_coverage() < 70)
			
			begin
				#5
				reset();
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				I_instructions;
			end
			
		@(negedge CLOCK);
		while (veamosB.cruceB.get_coverage() < 100)
			
			begin
				// #5
				// reset();
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				B_instructions;
			end
			
		@(negedge CLOCK);
		while (veamosU.cruceU.get_coverage() < 100)
			
			begin
				// #5
				// reset();
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				U_instructions;
			end 
			
		 @(negedge CLOCK);
		 while (veamos_car.cruce_carg.get_coverage() < 50)
			
			 begin
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				 carga_instructions;
			 end
			 
		 @(negedge CLOCK);
		 while (veamosS.cruceS.get_coverage() < 50)
			
			 begin
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				 S_instructions;
			 end
 
		@(negedge CLOCK);
		 while (veamosJal.cruceJal.get_coverage() < 50)
			
			 begin
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#2
				 Jal_instructions;
			 end
		 
		@(negedge CLOCK);
		 while (veamosJalr.cruceJalr.get_coverage() < 50)
			
			 begin
				repeat(4) @(posedge CLOCK);
				init_registros();
				repeat(15) @(posedge CLOCK);
				#5
				 Jalr_instructions;
			 end
		 
		$display("Test finished");
		$stop;	
	end
	
	
endmodule
