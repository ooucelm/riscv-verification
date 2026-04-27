module multipli_segmentado
(
    input logic CLOCK,
    input logic RESET,
    input logic START,
    input logic signed [7:0] A,
    input logic signed [7:0] B,
    output logic signed [15:0] S,
    output logic END_MULT
);

logic signed [16:0] Accu_pip [0:8];
logic signed [7:0] LO_pip [0:8];
logic X_pip [0:8];
logic signed [8:0] M;
logic [8:0] END_MULT_shift;
logic signed [16:0] Accu_next [0:7];
integer i;

always_ff @(posedge CLOCK or negedge RESET) begin
    if (!RESET) begin
        for (i=0; i<=8; i=i+1) begin
            Accu_pip[i] <= '0;
            LO_pip[i] <= '0;
            X_pip[i] <= 1'b0;
        end
        M <= '0;
        END_MULT_shift <= '0;
    end else begin
        END_MULT_shift <= {START, END_MULT_shift[8:1]};

        Accu_pip[0] <= '0;
        LO_pip[0] <= A;
        M <= {B[7], B};
        X_pip[0] <= 1'b0;

        for (i=0; i<8; i=i+1) begin
            Accu_next[i] = (!(({LO_pip[i][1],LO_pip[i][0],X_pip[i]} == 3'b000) ||
                               ({LO_pip[i][1],LO_pip[i][0],X_pip[i]} == 3'b111))) ?
                            ((LO_pip[i][0]^X_pip[i]) ? 
                                ((LO_pip[i][1]==1'b1) ? Accu_pip[i]-M : Accu_pip[i]+M)
                                : ((LO_pip[i][1]==1'b1) ? Accu_pip[i]-(M<<<1) : Accu_pip[i]+(M<<<1)))
                            : Accu_pip[i];

            {Accu_pip[i+1], LO_pip[i+1], X_pip[i+1]} <= 
                {Accu_next[i][8], Accu_next[i][8], Accu_next[i], LO_pip[i][7:1]};
        end
    end
end

assign END_MULT = END_MULT_shift[0];
assign S = {Accu_pip[8][7:0], LO_pip[8]};

endmodule
