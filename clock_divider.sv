module clock_divider (
	input logic clk_in,
	input logic reset,
	output logic game_clk
);
	logic [18:0] counter;
	
	always_ff @(posedge clk_in) begin
		if (reset) begin
			counter <= 19'b0;
			game_clk <= 1'b0;
		end else begin
			counter <= counter + 1'b1;
			// Generate game clock every 131072 cycles (2^17)
			// This provides moderate slowdown for reasonable gameplay timing
			if (counter == 19'h1FFFF) begin
				counter <= 19'b0;
				game_clk <= ~game_clk;
			end
		end
	end
endmodule