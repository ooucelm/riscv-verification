module multipli_segmentado
#(parameter tamano = 8)
(
    input logic CLOCK,
    input logic RESET,
    input logic START,
    input logic signed [tamano-1:0] A,
    input logic signed [tamano-1:0] B,
    output logic signed [2*tamano-1:0] S,
    output logic END_MULT
);

logic signed [2*tamano:0] Accu_pip [0:tamano];
logic signed [tamano-1:0] LO_pip [0:tamano];
logic X_pip [0:tamano];
logic signed [tamano:0] M;
logic [tamano:0] END_MULT_shift;
logic signed [2*tamano:0] Accu_next [0:tamano-1];
integer i;

always_ff @(posedge CLOCK or negedge RESET) begin
    if (!RESET) begin
        for (i=0; i<=tamano; i=i+1) begin
            Accu_pip[i] <= '0;
            LO_pip[i] <= '0;
            X_pip[i] <= 1'b0;
        end
        M <= '0;
        END_MULT_shift <= '0;
    end 
	 else 
	 begin
        END_MULT_shift <= {START, END_MULT_shift[tamano:1]};

        Accu_pip[0] <= '0;
        LO_pip[0] <= A;
        M <= {B[tamano-1], B};
        X_pip[0] <= 1'b0;

        for (i=0; i<tamano; i=i+1) begin
            Accu_next[i] = (!(({LO_pip[i][1],LO_pip[i][0],X_pip[i]} == 3'b000) ||
                               ({LO_pip[i][1],LO_pip[i][0],X_pip[i]} == 3'b111))) ?
                            ((LO_pip[i][0]^X_pip[i]) ? 
                                ((LO_pip[i][1]==1'b1) ? Accu_pip[i]-M : Accu_pip[i]+M)
                                : ((LO_pip[i][1]==1'b1) ? Accu_pip[i]-(M<<<1) : Accu_pip[i]+(M<<<1)))
                            : Accu_pip[i];

            {Accu_pip[i+1], LO_pip[i+1], X_pip[i+1]} <= 
                {Accu_next[i][tamano], Accu_next[i][tamano], Accu_next[i], LO_pip[i][tamano-1:1]};
        end
    end
end

assign END_MULT = END_MULT_shift[0];
assign S = {Accu_pip[tamano][tamano-1:0], LO_pip[tamano]};

endmodule
