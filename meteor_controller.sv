module meteor_controller (
	input logic clk,
	input logic reset,
	input logic game_enable, // Input to control when meteors should move
	input logic [5:0] deactivate_meteors, // Signal to deactivate specific meteors
	output logic [9:0] meteor_x [5:0],
	output logic [8:0] meteor_y [5:0],
	output logic [5:0] meteor_active,
	output logic meteor_passed // Signal when a meteor passes the bottom
);
	localparam METEOR_SPEED = 2;
	
	logic [8:0] spawn_counter; // Counter to control meteor spawning frequency
	logic [15:0] lfsr; // LFSR for randomness
	logic [7:0] cycle_counter; // Additional counter for more randomness
	
	// 16-bit LFSR for pseudo-random number generation
	always_ff @(posedge clk) begin
		if (reset) begin
			lfsr <= 16'hACE1; // Non-zero seed
			cycle_counter <= 8'h55; // Different seed for cycle counter
		end else if (game_enable) begin
			// Update LFSR every cycle for randomness
			lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
			cycle_counter <= cycle_counter + 1;
		end
	end
	
	// Use LFSR for random X position across screen width
	logic [9:0] random_x_pos;
	always_comb begin
		// Use multiple LFSR bits to generate random X position (0 to 610)
		// Scale 16-bit LFSR value to screen width range
		random_x_pos = ((lfsr ^ {cycle_counter, cycle_counter}) % 611); // 0 to 610
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			for (int i = 0; i < 6; i++) begin
				meteor_x[i] <= 10'd700; // Off-screen position
				meteor_y[i] <= 9'd500; // Off-screen position
				meteor_active[i] <= 1'b0;
			end
			spawn_counter <= 9'd0;
			meteor_passed <= 1'b0;
		end else if (game_enable) begin // Only update when game is enabled
			spawn_counter <= spawn_counter + 1;
			meteor_passed <= 1'b0; // Default to no meteor passed this cycle
			
			// Handle meteor deactivation due to collision
			for (int i = 0; i < 6; i++) begin
				if (deactivate_meteors[i]) begin
					meteor_active[i] <= 1'b0;
					meteor_x[i] <= 10'd700; // Move off-screen
					meteor_y[i] <= 9'd500;
				end
			end
			
			// Spawn new meteor every 100 cycles
			if (spawn_counter >= 9'd100) begin
				spawn_counter <= 9'd0;
				
				// Find inactive meteor slot
				for (int i = 0; i < 6; i++) begin
					if (!meteor_active[i]) begin
						meteor_active[i] <= 1'b1;
						meteor_y[i] <= 9'd0; // Start at top of screen
						
						// Use random X position across full screen width
						meteor_x[i] <= random_x_pos;
						break; // Exit loop after spawning one meteor
					end
				end
			end
			
			// Move active meteors down (only if not being deactivated this cycle)
			for (int i = 0; i < 6; i++) begin
				if (meteor_active[i] && !deactivate_meteors[i]) begin
					if (meteor_y[i] < 9'd470) begin // Still on screen
						meteor_y[i] <= meteor_y[i] + METEOR_SPEED;
					end else begin
						// Meteor reached bottom, deactivate it and signal it passed
						meteor_active[i] <= 1'b0;
						meteor_x[i] <= 10'd700; // Move off-screen
						meteor_y[i] <= 9'd500;
						meteor_passed <= 1'b1; // Signal that a meteor was dodged
					end
				end
			end
		end else begin
			meteor_passed <= 1'b0;
		end
		// If game_enable is false, meteors freeze in place (no updates)
	end
endmodule