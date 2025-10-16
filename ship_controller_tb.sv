module ship_controller_tb();
	// Test inputs
	logic clk;
	logic reset;
	logic move_left, move_right, move_up, move_down;
	
	// Test outputs
	logic [9:0] ship_x;
	logic [8:0] ship_y;
	
	// Parameters from ship_controller
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam SHIP_SPEED = 2;
	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;
	localparam SHIP_START_X = 300;
	localparam SHIP_START_Y = 450;
	
	// Clock generation
	always #5 clk = ~clk;

	ship_controller dut (
		.clk(clk),
		.reset(reset),
		.move_left(move_left),
		.move_right(move_right),
		.move_up(move_up),
		.move_down(move_down),
		.ship_x(ship_x),
		.ship_y(ship_y)
	);
	
	// Helper tasks
	task wait_cycles(int cycles);
		repeat(cycles) @(posedge clk);
	endtask
	
	task check_result(string test_name, logic [9:0] actual_x, logic [8:0] actual_y, logic [9:0] expected_x, logic [8:0] expected_y);
		if (actual_x === expected_x && actual_y === expected_y) begin
			$display("PASS: %s | Expected: (%0d, %0d), Actual: (%0d, %0d)", test_name, expected_x, expected_y, actual_x, actual_y);
		end else begin
			$display("FAIL: %s | Expected: (%0d, %0d), Actual: (%0d, %0d)", test_name, expected_x, expected_y, actual_x, actual_y);
		end
	endtask
	
	initial begin
		$display("Starting ship controller tests");
		
		clk = 0;
		reset = 1;
		move_left = 0; move_right = 0; move_up = 0; move_down = 0;
		
		// Test 1: Reset to center-bottom position
		wait_cycles(5);
		reset = 0;
		wait_cycles(5);
		check_result("Reset position", ship_x, ship_y, SHIP_START_X, SHIP_START_Y);
		
		// Test 2: Horizontal movement - right
		move_right = 1;
		wait_cycles(2);
		move_right = 0;
		wait_cycles(1); // Wait for signal to propagate
		check_result("Move right", ship_x, ship_y, SHIP_START_X + 2*SHIP_SPEED, SHIP_START_Y);
		
		// Test 3: Horizontal movement - left
		move_left = 1;
		wait_cycles(2);
		move_left = 0;
		wait_cycles(1); // Wait for signal to propagate
		check_result("Move left", ship_x, ship_y, SHIP_START_X, SHIP_START_Y);
		
		// Test 4: Left boundary check
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		// Move left until boundary
		move_left = 1;
		wait_cycles(200); // Should hit boundary
		move_left = 0;
		
		if (ship_x >= 0 && ship_x < SHIP_SPEED) begin
			$display("PASS: Left boundary check - ship stopped at x=%0d", ship_x);
		end else begin
			$display("FAIL: Left boundary check - ship at x=%0d", ship_x);
		end
		
		// Test 5: Right boundary check
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		// Move right until boundary
		move_right = 1;
		wait_cycles(200); // Should hit boundary
		move_right = 0;
		
		if (ship_x <= (SCREEN_WIDTH - SHIP_WIDTH) && ship_x > (SCREEN_WIDTH - SHIP_WIDTH - SHIP_SPEED)) begin
			$display("PASS: Right boundary check - ship stopped at x=%0d", ship_x);
		end else begin
			$display("FAIL: Right boundary check - ship at x=%0d", ship_x);
		end
		
		// Test 6: Vertical movement - up
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		move_up = 1;
		wait_cycles(2);
		move_up = 0;
		wait_cycles(1); // Wait for signal to propagate
		check_result("Move up", ship_x, ship_y, SHIP_START_X, SHIP_START_Y - 2*SHIP_SPEED);
		
		// Test 7: Vertical movement - down
		move_down = 1;
		wait_cycles(1);
		move_down = 0;
		wait_cycles(1); // Wait for signal to propagate
		check_result("Move down", ship_x, ship_y, SHIP_START_X, SHIP_START_Y - 2*SHIP_SPEED + 1*SHIP_SPEED);
		
		// Test 8: Top boundary check
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		move_up = 1;
		wait_cycles(300); // Should hit top boundary
		move_up = 0;
		
		if (ship_y >= 0 && ship_y < SHIP_SPEED) begin
			$display("PASS: Top boundary check - ship stopped at y=%0d", ship_y);
		end else begin
			$display("FAIL: Top boundary check - ship at y=%0d", ship_y);
		end
		
		// Test 9: Bottom boundary check
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		move_down = 1;
		wait_cycles(50); // Should hit bottom boundary quickly
		move_down = 0;
		
		if (ship_y <= (SCREEN_HEIGHT - SHIP_HEIGHT) && ship_y > (SCREEN_HEIGHT - SHIP_HEIGHT - SHIP_SPEED)) begin
			$display("PASS: Bottom boundary check - ship stopped at y=%0d", ship_y);
		end else begin
			$display("FAIL: Bottom boundary check - ship at y=%0d", ship_y);
		end
		
		// Test 10: Simultaneous movement (diagonal)
		reset = 1;
		wait_cycles(2);
		reset = 0;
		wait_cycles(2);
		
		// Move diagonally up-right
		move_up = 1;
		move_right = 1;
		wait_cycles(2);
		move_up = 0;
		move_right = 0;
		wait_cycles(1); // Wait for signal to propagate
		check_result("Diagonal movement", ship_x, ship_y, SHIP_START_X + 2*SHIP_SPEED, SHIP_START_Y - 2*SHIP_SPEED);
		
		$stop;
	end
	
endmodule