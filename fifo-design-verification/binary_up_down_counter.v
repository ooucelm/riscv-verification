// Quartus Prime Verilog Template
// Binary up/down counter

module binary_up_down_counter
#(parameter width=$clog2(32))
(
	input clk, enable, count_up, reset, clear,
	output reg [width-1:0] count
);

	// Reset if needed, increment or decrement if counting is enabled
	always @ (posedge clk or negedge reset or negedge clear)
	begin
		if (!reset)
			count <= 1'b0;
		else if (!clear)
			count <= 1'b0;
		else if (enable == 1'b1)
			count <= count + (count_up ? 1'b1 : -1'b1);
	end

endmodule
