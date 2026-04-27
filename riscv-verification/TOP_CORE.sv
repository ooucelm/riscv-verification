module TOP_CORE(instr, CLOCK, RST_n, dataram_rd, PC, ena_wr, ena_rd, alu_out_ext, dataram_wr);

input [31:0] instr;
input RST_n, CLOCK;
input logic [31:0] dataram_rd; //salida de la ram

output logic [31:0] PC;
output logic ena_wr, ena_rd; //entrada habilita ram lectura/escritura
output logic [31:0] alu_out_ext; //entrada ram
output logic [31:0] dataram_wr;

logic [31:0] PC_siguiente;
logic [31:0] regis_A, regis_B, valor_A, valor_B, inm_out;
logic ALUSrc_sig, Branch_sig, PCSrc, zero_sig, RegWrite_sig, MemRead_sig, MemWrite_sig, Jal_sig, Jalr_sig;
logic [1:0] AuipcLui_sig;
logic [2:0] ALUOp_sig;
logic [3:0] instruction_bits_sig, ALU_operation;
logic [1:0] MemtoReg_sig; //habilita mux de ram
logic [31:0] datareg_wr; //salida mux memtoreg


always_ff @(posedge CLOCK or negedge RST_n)
	if (!RST_n)
		PC <= '0;
	else 
		PC <= PC_siguiente;
		
CONTROL CONTROL_inst
(
	.instruction(instr) ,	// input [31:0] instruction_sig
	.Branch(Branch_sig) ,	// output  Branch_sig
	.MemRead(MemRead_sig) ,	// output  MemRead_sig
	.MemtoReg(MemtoReg_sig) ,	// output [1:0] MemtoReg_sig
	.ALUOp(ALUOp_sig) ,	// output [2:0] ALUOp_sig
	.MemWrite(MemWrite_sig) ,	// output  MemWrite_sig
	.ALUSrc(ALUSrc_sig) ,	// output  ALUSrc_sig
	.RegWrite(RegWrite_sig) ,	// output  RegWrite_sig
	.Jal(Jal_sig) ,	// output  Jal_sig
	.Jalr(Jalr_sig) ,	// output  Jalr_sig
	.AuipcLui(AuipcLui_sig) 	// output [1:0] AuipcLui_sig
);
		
banco_registros banco_registros_inst
(
	.CLK(CLOCK),	// input  CLK_sig
	.RST_n(RST_n),	// input  RST_n_sig
	.readReg1(instr[19:15]),	// input [4:0] readReg1_sig
	.readReg2(instr[24:20]),	// input [4:0] readReg2_sig
	.writeReg(instr[11:7]),	// input [4:0] writeReg_sig
	.writeData(datareg_wr),	// salida mux MemtoReg						
	.readData1(regis_A),	// output [31:0] readData1_sig
	.readData2(regis_B),	// output [31:0] readData2_sig
	.RegWrite(RegWrite_sig) 	// input  RegWrite_sig
);

// Mux 3 a 1 para entrada A de la ALU
    always_comb begin
        case (AuipcLui_sig)
            2'b00: valor_A = PC;        
            2'b01: valor_A = 32'd0;     
            2'b10: valor_A = regis_A;   
            default: valor_A = regis_A;
        endcase
    end
		
ALU ALU_inst
(
	.A(valor_A),	// mux 3 a 1 
	.B(valor_B),	// mux indica si ReadData2 o immGen, seleccion=ALUSrc
	.ALU_control(ALU_operation),	// controlado por modulo alu control
	.ALU_result(alu_out_ext),	// decision del salto
	.zero(zero_sig) 	// output  zero_sig
);

Inm_Gen Inm_Gen_inst
(
	.inst(instr[31:0]) ,	// input [31:0] inst_sig
	.inm(inm_out) 	// output [31:0] inm_sig
);

ALU_CONTROL ALU_CONTROL_inst
(
	.ALUOp(ALUOp_sig),
	.instruction_bits(instruction_bits_sig),
	.ALU_control(ALU_operation)
);

assign PCSrc = (zero_sig & Branch_sig) || Jal_sig; // & Jal; // Esta puerta AND es de 3 entradas zero_sig,  Branch_sig y Jal, si el jal esta activado activa el mux para que pase el pc+4
// La señal Jal y Jal R salen de Alu Control, hay que cambiar ese modulo para que genere esas señales. 
assign PC_siguiente = PCSrc ? (PC + inm_out) : // para las señales Jal y Jalr; la señal Jal pone a 1 directamente el PCSrc
                      Jalr_sig  ? alu_out_ext :
                              (PC + 4);
assign valor_B = (ALUSrc_sig) ? inm_out : regis_B; //mux que selecciona entrada B alu
assign ena_wr = MemWrite_sig;
assign ena_rd = MemRead_sig;
assign instruction_bits_sig = {instr[30],instr[14:12]};
assign dataram_wr = regis_B;
assign datareg_wr = (MemtoReg_sig == 2'b01) ? dataram_rd : ((MemtoReg_sig == 2'b00) ? alu_out_ext : PC + 4);
endmodule
