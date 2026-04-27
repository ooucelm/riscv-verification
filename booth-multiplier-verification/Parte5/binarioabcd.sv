module binarioabcd #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic [WIDTH-1:0] bin_in,

    output logic done,
    output logic sign,
    output logic [11:0] bcd_out
);

    typedef enum logic [1:0] {IDLE, LOAD, PROCESS, FINISH} state_t;
    state_t state;

    logic [WIDTH-1:0] magnitude;
    logic [11:0] bcd_reg;
    logic [$clog2(WIDTH)-1:0] count;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            state     <= IDLE;
            done      <= 0;
            sign      <= 0;
            magnitude <= 0;
            bcd_reg   <= 0;
            count     <= 0;
        end
        else begin
            case (state)

            IDLE: begin
                done <= 0;
                if (start)
                    state <= LOAD;
            end

            LOAD: begin
                sign <= bin_in[WIDTH-1];

                if (bin_in[WIDTH-1])
                    magnitude <= (~bin_in + 1);
                else
                    magnitude <= bin_in;

                bcd_reg <= 0;
                count   <= 0;

                state <= PROCESS;
            end

            PROCESS: begin

                if (bcd_reg[3:0]   >= 5) bcd_reg[3:0]   <= bcd_reg[3:0]   + 3;
                if (bcd_reg[7:4]   >= 5) bcd_reg[7:4]   <= bcd_reg[7:4]   + 3;
                if (bcd_reg[11:8]  >= 5) bcd_reg[11:8]  <= bcd_reg[11:8]  + 3;

                {bcd_reg, magnitude} <= {bcd_reg, magnitude} << 1;

                if (count == WIDTH-1)
                    state <= FINISH;

                count <= count + 1;
            end

            FINISH: begin
                done <= 1;
                if (!start)
                    state <= IDLE;
            end

            endcase
        end
    end

    assign bcd_out = bcd_reg;

endmodule