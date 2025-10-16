module collision_detector (
	input logic [9:0] ship_x,
	input logic [8:0] ship_y,
	input logic [9:0] meteor_x [5:0],
	input logic [8:0] meteor_y [5:0],
	input logic [5:0] meteor_active,
	output logic collision,
	output logic [5:0] meteor_collisions // Individual collision signals
);
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam METEOR_SIZE = 30;
	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;
	
	logic [5:0] individual_collisions;
	
	// Check collision for each meteor separately
	always_comb begin
		for (int i = 0; i < 6; i++) begin
			individual_collisions[i] = 1'b0;
			
			if (meteor_active[i]) begin
				// Check if meteor and ship rectangles overlap
				// Both objects must be within screen bounds (use <= for edge positions)
				if ((meteor_x[i] <= (SCREEN_WIDTH - METEOR_SIZE)) && 
					 (meteor_y[i] <= (SCREEN_HEIGHT - METEOR_SIZE)) &&
					 (ship_x <= (SCREEN_WIDTH - SHIP_WIDTH)) && 
					 (ship_y <= (SCREEN_HEIGHT - SHIP_HEIGHT))) begin
					
					// Rectangle overlap detection
					if ((meteor_x[i] + METEOR_SIZE > ship_x) && 
						 (meteor_x[i] < ship_x + SHIP_WIDTH) &&
						 (meteor_y[i] + METEOR_SIZE > ship_y) && 
						 (meteor_y[i] < ship_y + SHIP_HEIGHT)) begin
						individual_collisions[i] = 1'b1;
					end
				end
			end
		end
		
		// Overall collision is OR of all individual collisions
		collision = |individual_collisions;
		// Output individual collision signals
		meteor_collisions = individual_collisions;
	end
endmodule