module input_controller (
	input logic clk,
	input logic reset,
	input logic n8_left,
	input logic n8_right,
	input logic n8_up,
	input logic n8_down,
	input logic n8_start,
	output logic move_left,
	output logic move_right,
	output logic move_up,
	output logic move_down,
	output logic start_game
);
	logic n8_start_prev, n8_start_prev2;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			n8_start_prev <= 1'b0;
			n8_start_prev2 <= 1'b0;
		end else begin
			n8_start_prev2 <= n8_start_prev;
			n8_start_prev <= n8_start;
		end
	end
	
	// Level detection for movement (active while held down)
	// N8 controller outputs are active high
	assign move_left = n8_left;  // A key on keyboard -> left movement
	assign move_right = n8_right;  // D key on keyboard -> right movement
	assign move_up = n8_up;  // W key on keyboard -> up movement
	assign move_down = n8_down;  // S key on keyboard -> down movement
	
	// Edge detection for start game - only trigger on button press
	// Detect rising edge: current high, previous low, and stable for one cycle
	assign start_game = n8_start & ~n8_start_prev & ~n8_start_prev2; // J key for start/restart
	
endmodule