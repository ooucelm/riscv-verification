module conversor7seg (
    input  logic [3:0] A_bcd,
    input  logic [3:0] B_bcd,
    input  logic [7:0] S_bcd,
    input  logic negA,
    input  logic negB,
    input  logic negS,
    output logic [6:0] HEX0, HEX1, HEX2, HEX4, HEX5, HEX6, HEX7
);

    always_comb begin
        
        // SIGNOS
        HEX7 = (negA) ? 7'b0111111 : 7'b1111111;
        HEX5 = (negB) ? 7'b0111111 : 7'b1111111;
        HEX2 = (negS) ? 7'b0111111 : 7'b1111111;

        // Dígito A
        unique case (A_bcd)
            4'h0: HEX6 = 7'b1000000;
            4'h1: HEX6 = 7'b1111001;
            4'h2: HEX6 = 7'b0100100;
            4'h3: HEX6 = 7'b0110000;
            4'h4: HEX6 = 7'b0011001;
            4'h5: HEX6 = 7'b0010010;
            4'h6: HEX6 = 7'b0000010;
            4'h7: HEX6 = 7'b1111000;
            4'h8: HEX6 = 7'b0000000;
            4'h9: HEX6 = 7'b0010000;
            default: HEX6 = 7'b1111111;
        endcase

        // Dígito B
        unique case (B_bcd)
            4'h0: HEX4 = 7'b1000000;
            4'h1: HEX4 = 7'b1111001;
            4'h2: HEX4 = 7'b0100100;
            4'h3: HEX4 = 7'b0110000;
            4'h4: HEX4 = 7'b0011001;
            4'h5: HEX4 = 7'b0010010;
            4'h6: HEX4 = 7'b0000010;
            4'h7: HEX4 = 7'b1111000;
            4'h8: HEX4 = 7'b0000000;
            4'h9: HEX4 = 7'b0010000;
            default: HEX4 = 7'b1111111;
        endcase

        // Unidades de S
        unique case (S_bcd[3:0])
            4'h0: HEX0 = 7'b1000000;
            4'h1: HEX0 = 7'b1111001;
            4'h2: HEX0 = 7'b0100100;
            4'h3: HEX0 = 7'b0110000;
            4'h4: HEX0 = 7'b0011001;
            4'h5: HEX0 = 7'b0010010;
            4'h6: HEX0 = 7'b0000010;
            4'h7: HEX0 = 7'b1111000;
            4'h8: HEX0 = 7'b0000000;
            4'h9: HEX0 = 7'b0010000;
            default: HEX0 = 7'b1111111;
        endcase

        // Decenas de S
        unique case (S_bcd[7:4])
            4'h0: HEX1 = 7'b1000000;
            4'h1: HEX1 = 7'b1111001;
            4'h2: HEX1 = 7'b0100100;
            4'h3: HEX1 = 7'b0110000;
            4'h4: HEX1 = 7'b0011001;
            4'h5: HEX1 = 7'b0010010;
            4'h6: HEX1 = 7'b0000010;
            4'h7: HEX1 = 7'b1111000;
            4'h8: HEX1 = 7'b0000000;
            4'h9: HEX1 = 7'b0010000;
            default: HEX1 = 7'b1111111;
        endcase

    end

endmodule
