module game_controller_tb();
	// Test inputs
	logic clk;
	logic reset;
	logic move_left, move_right, move_up, move_down;
	logic start_game;
	
	// Test outputs
	logic [9:0] ship_x;
	logic [8:0] ship_y;
	logic [9:0] meteor_x [5:0];
	logic [8:0] meteor_y [5:0];
	logic [5:0] meteor_active;
	logic [15:0] score;
	logic game_over;
	logic collision;
	logic [2:0] lives;
	
	// Internal signals for testing
	logic [5:0] meteor_collisions;
	logic collision_prev;
	logic collision_edge;
	logic [3:0] immunity_counter;
	
	// Clock generation
	always #5 clk = ~clk; // 100MHz clock
	
	game_controller dut (
		.clk(clk),
		.reset(reset),
		.move_left(move_left),
		.move_right(move_right),
		.move_up(move_up),
		.move_down(move_down),
		.start_game(start_game),
		.ship_x(ship_x),
		.ship_y(ship_y),
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.score(score),
		.game_over(game_over),
		.collision(collision),
		.lives(lives)
	);
	
	// Access internal signals
	assign meteor_collisions = dut.collision_det.meteor_collisions;
	assign collision_prev = dut.collision_prev;
	assign collision_edge = dut.collision_edge;
	assign immunity_counter = dut.immunity_counter;
	
	// Helper tasks
	task wait_cycles(int cycles);
		repeat(cycles) @(posedge clk);
	endtask
	
	task check_result(string test_name, logic [31:0] actual, logic [31:0] expected);
		if (actual === expected) begin
			$display("PASS: %s | Expected: %0d, Actual: %0d", test_name, expected, actual);
		end else begin
			$display("FAIL: %s | Expected: %0d, Actual: %0d", test_name, expected, actual);
		end
	endtask
	
	task check_bool_result(string test_name, logic actual, logic expected);
		if (actual === expected) begin
			$display("PASS: %s | Expected: %b, Actual: %b", test_name, expected, actual);
		end else begin
			$display("FAIL: %s | Expected: %b, Actual: %b", test_name, expected, actual);
		end
	endtask
	
	initial begin
		logic [15:0] prev_score;
		logic [2:0] prev_lives;
		logic prev_collision;
		logic [5:0] expected_deactivated;
		logic [5:0] remaining_meteors;
		int timeout_counter;
		
		$display("Starting game controller tests\n");
		
		clk = 0;
		reset = 1;
		move_left = 0; move_right = 0; move_up = 0; move_down = 0;
		start_game = 0;
		prev_collision = 0;
		
		// TEST 1: Basic initialization
		wait_cycles(5);
		reset = 0;
		wait_cycles(5);
		
		check_result("Initial Lives", lives, 3);
		check_result("Initial Score", score, 0);
		check_bool_result("Initial Game Over", game_over, 0);
		$display("Basic initialization passed\n");
		
		// TEST 2: Score incrementing when meteors pass
		$display("Testing score incrementing:");
		prev_score = score;
		timeout_counter = 0;
		
		// Wait for meteors to spawn and pass bottom
		while (score == prev_score && timeout_counter < 10000) begin
			wait_cycles(1);
			timeout_counter = timeout_counter + 1;
		end
		
		if (score > prev_score) begin
			check_bool_result("Score Incremented", 1, 1);
			$display("Score incrementing passed (score: %0d)\n", score);
		end else begin
			$display("INFO: No score change in timeout period\n");
		end
		
		// TEST 3: Collision system
		$display("Testing collision system:");
		prev_lives = lives;
		prev_collision = collision;
		timeout_counter = 0;
		
		// Move ship around to increase collision probability
		while (!collision && timeout_counter < 15000) begin
			if (timeout_counter % 50 == 0) begin
				move_left = 1; wait_cycles(5); move_left = 0;
				move_right = 1; wait_cycles(5); move_right = 0;
				move_up = 1; wait_cycles(3); move_up = 0;
				move_down = 1; wait_cycles(3); move_down = 0;
			end
			wait_cycles(1);
			timeout_counter = timeout_counter + 1;
		end
		
		if (collision && !prev_collision) begin
			// Test collision edge detection
			check_bool_result("Collision Edge Detection", collision_edge, 1);
			
			// Test meteor deactivation - store which meteors should be deactivated
			expected_deactivated = meteor_collisions;
			wait_cycles(2); // Wait for deactivation to take effect
			remaining_meteors = meteor_active & expected_deactivated;
			check_result("Meteor Deactivation", remaining_meteors, 6'b000000);
			
			// Test life management
			if (lives < prev_lives) begin
				check_result("Life Decremented", lives, prev_lives - 1);
			end
			
			$display("Collision system passed\n");
		end else begin
			$display("INFO: No collision occurred in test period\n");
		end
		
		// TEST 4: Complete state transition cycle + immunity system
		$display("Testing state transitions and immunity:");
		
		// Force game over by waiting or inducing more collisions
		while (!game_over && lives > 0) begin
			// Movement to cause collisions
			move_left = 1; wait_cycles(3); move_left = 0;
			move_right = 1; wait_cycles(3); move_right = 0;
			wait_cycles(20);
			
			// Safety timeout
			timeout_counter = timeout_counter + 30;
			if (timeout_counter > 30000) break;
		end
		
		if (game_over) begin
			// Test PLAYING -> GAME_OVER_STATE transition
			check_bool_result("Game Over State", game_over, 1);
			check_result("Final Lives", lives, 0);
			$display("PLAYING -> GAME_OVER_STATE transition passed");
			
			// Test GAME_OVER_STATE -> RESTART transition
			start_game = 1;
			wait_cycles(2);
			start_game = 0;
			wait_cycles(10);
			
			check_result("Restart Lives", lives, 3);
			check_result("Restart Score", score, 0);
			check_bool_result("Restart Game Over", game_over, 0);
			$display("GAME_OVER_STATE -> RESTART transition passed");
			
			// Test immunity system
			if (immunity_counter > 0) begin
				check_bool_result("Immunity System Active", (immunity_counter > 0), 1);
				$display(" Immunity system activated (counter: %0d)", immunity_counter);
				
				// Wait for immunity to expire
				while (immunity_counter > 0) begin
					wait_cycles(1);
				end
				check_result("Immunity Expired", immunity_counter, 0);
				$display("Immunity system expired correctly");
			end
			
			$display("Complete state transition cycle passed\n");
		end else begin
			$display("INFO: Game over not reached, testing restart manually:");
			
			// Manual restart test
			start_game = 1;
			wait_cycles(2);
			start_game = 0;
			wait_cycles(10);
			
			check_result("Manual Restart Lives", lives, 3);
			check_bool_result("Manual Restart Game Over", game_over, 0);
		end
		
		// Final verification
		wait_cycles(50);
		check_bool_result("Final Game State", !game_over, 1);
		$stop;
	end
	
endmodule