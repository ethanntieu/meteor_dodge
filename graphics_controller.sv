module graphics_controller (
	input logic clk,
	input logic [9:0] x,
	input logic [8:0] y,
	input logic [9:0] ship_x,
	input logic [8:0] ship_y,
	input logic [9:0] meteor_x [5:0],
	input logic [8:0] meteor_y [5:0],
	input logic [5:0] meteor_active,
	input logic [15:0] score,
	input logic game_over,
	output logic [7:0] r,
	output logic [7:0] g,
	output logic [7:0] b
);
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam METEOR_SIZE = 30;
	
	always_comb begin
		// Default background color
		r = 8'h00;
		g = 8'h00;
		b = 8'h00;
		
		// Draw ship (white rectangle) - always visible
		if (y >= ship_y && y < ship_y + SHIP_HEIGHT &&
			 x >= ship_x && x < ship_x + SHIP_WIDTH) begin
			r = 8'hFF;
			g = 8'hFF;
			b = 8'hFF;
		end
		
		// Draw meteors (red squares) - only draw active meteors that are on screen
		for (int i = 0; i < 6; i++) begin
			if (meteor_active[i] &&
				 meteor_x[i] < 640 && meteor_y[i] < 480 && // On screen check
				 y >= meteor_y[i] && y < meteor_y[i] + METEOR_SIZE &&
				 x >= meteor_x[i] && x < meteor_x[i] + METEOR_SIZE) begin
				r = 8'hFF;
				g = 8'h00;
				b = 8'h00;
			end
		end
		
		// Game over screen - red tint with pattern when game is over
		if (game_over) begin
			if ((x[4] ^ y[4]) == 1'b1) begin
				r = r | 8'h60; // Add red tint
				g = g >> 1; // Dim other colors
				b = b >> 1;
			end
		end
	end
endmodule