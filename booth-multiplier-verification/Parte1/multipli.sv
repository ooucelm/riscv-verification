module multipli(CLOCK, RESET, END_MULT, A, B, S, START);
parameter tamano=8;

input CLOCK, RESET;
input logic START;
input logic signed [tamano-1:0] A, B;		//CONECTADO A LOS SWITCHES
output logic signed [2*tamano-1:0] S;		//CONECTADOS A LOS LCDS
output logic END_MULT;

//vuestro código

enum logic  [2:0] {idle, init, op, shift, notify} state;
logic Fin_Mult, X;
logic signed [2*tamano:0] Accu; //Extendido a 2n para solucionar el problema del overflow en algunas operaciones
logic [$clog2(tamano):0] Count;
logic signed [tamano-1:0] LO;
logic signed [tamano:0] M;

always_ff @(posedge CLOCK or negedge RESET)
	if (!RESET)
		begin
		state <= idle;
		Accu <= 0;
		Count <= 0;
		LO <= 0;
		M <= 0;
		X <= 0;
		end
		
	else 
		case(state)
			idle:	
				begin
				state <= (START) ? init : idle;
				end
			init:
				begin
				state <= op;
				Accu <= 0;
				Count <= 0;
				LO <= A;
				M <= {B[tamano-1],B};
				X <= 1'b0;
				end
			op:
				begin
				Count <= Count+2'd2;
				state <= shift;
				
				if (!(({LO[1],LO[0],X} == 3'b000)||({LO[1],LO[0],X} == 3'b111)))
					if ((LO[0]^X)&&(LO[1]==1'b1))
						Accu <= Accu-M;
					else if ((LO[0]^X)&&(LO[1]!=1'b1))
						Accu <= Accu+M;
					else if ((!(LO[0]^X)&&(LO[1]!=1'b1)))
						Accu <= Accu+(M<<<1);
					else if ((!(LO[0]^X))&&(LO[1]==1'b1))
						Accu <= Accu-(M<<<1);
				end
			shift:
				begin
				state <= (Count==tamano) ? notify : op;
				{Accu,LO,X} <= {Accu[tamano],Accu[tamano],Accu,LO[tamano-1:1]};
				end
				
			notify:
				begin
				state <= (START) ? notify : idle;
				end
		endcase

assign END_MULT = (state==notify) ? 1'b1 : 1'b0;
assign S = {Accu[tamano-1:0],LO};
//fin de vuestro codigo

endmodule
