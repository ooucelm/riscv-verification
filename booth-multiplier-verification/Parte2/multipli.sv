module multipli(CLOCK, RESET, END_MULT, A, B, S, START);

input CLOCK, RESET;
input logic START;
input logic signed [7:0] A, B;		//CONECTADO A LOS SWITCHES
output logic signed [15:0] S;		//CONECTADOS A LOS LCDS
output logic END_MULT;

//vuestro código

enum logic  [2:0] {idle, init, op, shift, notify} state;
logic Fin_Mult, X;
logic signed [16:0] Accu; //Extendido a 2n para solucionar el problema del overflow en algunas operaciones
logic [$clog2(8):0] Count;
logic signed [7:0] LO;
logic signed [8:0] M;

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
				M <= {B[7],B};
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
				state <= (Count==8) ? notify : op;
				{Accu,LO,X} <= {Accu[8],Accu[8],Accu,LO[7:1]};
				end
				
			notify:
				begin
				state <= (START) ? notify : idle;
				end
		endcase

assign END_MULT = (state==notify) ? 1'b1 : 1'b0;
assign S = {Accu[7:0],LO};
//fin de vuestro codigo

endmodule
