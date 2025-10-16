module meteor_controller_tb();
	// Test inputs
	logic clk;
	logic reset;
	logic game_enable;
	logic [5:0] deactivate_meteors;
	
	// Test outputs
	logic [9:0] meteor_x [5:0];
	logic [8:0] meteor_y [5:0];
	logic [5:0] meteor_active;
	logic meteor_passed;
	
	// Clock generation
	always #5 clk = ~clk;
	
	meteor_controller dut (
		.clk(clk),
		.reset(reset),
		.game_enable(game_enable),
		.deactivate_meteors(deactivate_meteors),
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.meteor_passed(meteor_passed)
	);
	
	// Helper tasks
	task wait_cycles(int cycles);
		repeat(cycles) @(posedge clk);
	endtask
	
	task check_result(string test_name, logic actual, logic expected);
		if (actual === expected) begin
			$display("PASS: %s", test_name);
		end else begin
			$display("FAIL: %s - Expected: %b, Got: %b", test_name, expected, actual);
		end
	endtask
	
	initial begin
		logic [9:0] first_x, second_x;
		logic positions_different;
		logic [5:0] meteors_before;
		logic deactivation_worked;
		logic [8:0] frozen_positions [5:0];
		logic meteors_frozen;
		logic passed_detected;
		int timeout;
		logic found_moving_meteor;
		int moving_meteor_index;
		logic [8:0] start_y, mid_y, frozen_y;
		
		$display("Starting meteor controller tests");
		
		// Initialize
		clk = 0;
		reset = 1;
		game_enable = 0;
		deactivate_meteors = 6'b000000;
		
		// Test 1: Initialization
		wait_cycles(5);
		reset = 0;
		wait_cycles(5);
		check_result("Initial state - no active meteors", (meteor_active == 6'b000000), 1'b1);
		check_result("Initial state - meteor_passed false", meteor_passed, 1'b0);
		
		// Test 2: Game enable functionality
		$display("\nTesting game enable:");
		game_enable = 0;
		wait_cycles(110); // More than spawn period
		check_result("No spawn when game disabled", (meteor_active == 6'b000000), 1'b1);
		
		game_enable = 1;
		wait_cycles(110);
		check_result("Meteors spawn when game enabled", (meteor_active != 6'b000000), 1'b1);
		
		// Test 3: LFSR positioning and spawning
		$display("\nTesting LFSR positioning:");
		positions_different = 1'b0;
		
		// Wait for first meteor
		while (meteor_active == 6'b000000) wait_cycles(5);
		first_x = meteor_x[0];
		
		// Wait for second meteor spawn
		wait_cycles(110);
		for (int i = 0; i < 6; i++) begin
			if (meteor_active[i] && meteor_x[i] != first_x) begin
				positions_different = 1'b1;
				second_x = meteor_x[i];
				break;
			end
		end
		
		check_result("LFSR generates different positions", positions_different, 1'b1);
		$display("  First meteor x: %0d, Second meteor x: %0d", first_x, second_x);
		
		// Test 4: Selective meteor deactivation
		$display("\nTesting selective deactivation:");
		wait_cycles(50); // Ensure we have active meteors
		
		meteors_before = meteor_active;
		if (meteors_before[0] || meteors_before[1]) begin
			deactivate_meteors = 6'b000011; // Deactivate meteors 0 and 1
			wait_cycles(2);
			deactivate_meteors = 6'b000000;
			
			deactivation_worked = 1'b1;
			if (meteors_before[0] && meteor_active[0]) deactivation_worked = 1'b0;
			if (meteors_before[1] && meteor_active[1]) deactivation_worked = 1'b0;
			
			check_result("Selective meteor deactivation", deactivation_worked, 1'b1);
			$display("  Before: %b, After: %b", meteors_before, meteor_active);
		end else begin
			$display("  INFO: No meteors 0 or 1 active for deactivation test");
		end
		
		// Test 5: Game freeze functionality
		$display("\nTesting game freeze:");
		
		// Wait for meteors to be active and moving
		wait_cycles(50);
		
		// Find an active meteor and track its movement
		found_moving_meteor = 1'b0;
		moving_meteor_index = 0;
		
		// Find first active meteor
		for (int i = 0; i < 6; i++) begin
			if (meteor_active[i]) begin
				moving_meteor_index = i;
				start_y = meteor_y[i];
				found_moving_meteor = 1'b1;
				break;
			end
		end
		
		if (found_moving_meteor) begin
			// Let it move for a bit
			wait_cycles(20);
			mid_y = meteor_y[moving_meteor_index];
			
			if (mid_y > start_y) begin
				$display("  Meteor %0d moving: %0d -> %0d", moving_meteor_index, start_y, mid_y);
				
				// Now freeze the game
				game_enable = 0;
				wait_cycles(1); // Let the disable take effect
				frozen_y = meteor_y[moving_meteor_index];
				wait_cycles(20);
				
				// Check if it stopped moving
				if (meteor_y[moving_meteor_index] == frozen_y) begin
					check_result("Meteors freeze when game disabled", 1'b1, 1'b1);
				end else begin
					$display("  Meteor continued moving: %0d -> %0d", frozen_y, meteor_y[moving_meteor_index]);
					check_result("Meteors freeze when game disabled", 1'b0, 1'b1);
				end
			end
		end
		
		// Test 6: Meteor passed signal
		$display("\nTesting meteor_passed signal:");
		game_enable = 1;
		passed_detected = 1'b0;
		
		for (timeout = 0; timeout < 200 && !passed_detected; timeout++) begin
			wait_cycles(5);
			if (meteor_passed) passed_detected = 1'b1;
		end
		
		check_result("meteor_passed signal detected", passed_detected, 1'b1);
		
		$stop;
	end
	
endmodule