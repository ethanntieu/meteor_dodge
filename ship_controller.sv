module ship_controller (
	input logic clk,
	input logic reset,
	input logic move_left,
	input logic move_right,
	input logic move_up,
	input logic move_down,
	output logic [9:0] ship_x,
	output logic [8:0] ship_y
);
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam SHIP_SPEED = 2; // Movement speed for both directions
	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;
	localparam SHIP_START_X = 300; // Center horizontally: (640-40)/2 = 300
	localparam SHIP_START_Y = 450; // Near bottom but with some margin
	
	// Initialize ship position at startup
	initial begin
		ship_x = SHIP_START_X;
		ship_y = SHIP_START_Y;
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ship_x <= SHIP_START_X; // Reset to center horizontally
			ship_y <= SHIP_START_Y; // Reset to near bottom
		end else begin
			// Horizontal movement
			if (move_left && ship_x >= SHIP_SPEED) begin
				ship_x <= ship_x - SHIP_SPEED;
			end else if (move_right && ship_x <= (SCREEN_WIDTH - SHIP_WIDTH - SHIP_SPEED)) begin
				ship_x <= ship_x + SHIP_SPEED;
			end
			
			// Vertical movement
			if (move_up && ship_y >= SHIP_SPEED) begin
				ship_y <= ship_y - SHIP_SPEED;
			end else if (move_down && ship_y <= (SCREEN_HEIGHT - SHIP_HEIGHT - SHIP_SPEED)) begin
				ship_y <= ship_y + SHIP_SPEED;
			end
		end
	end
endmodule