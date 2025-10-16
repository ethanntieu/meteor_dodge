module input_controller_tb();
	// Test inputs
	logic clk;
	logic reset;
	logic n8_left, n8_right, n8_up, n8_down, n8_start;
	
	// Test outputs
	logic move_left, move_right, move_up, move_down, start_game;
	
	// Clock generation
	always #5 clk = ~clk;
	
	input_controller dut (
		.clk(clk),
		.reset(reset),
		.n8_left(n8_left),
		.n8_right(n8_right),
		.n8_up(n8_up),
		.n8_down(n8_down),
		.n8_start(n8_start),
		.move_left(move_left),
		.move_right(move_right),
		.move_up(move_up),
		.move_down(move_down),
		.start_game(start_game)
	);
	
	// Helper tasks
	task wait_cycles(int cycles);
		repeat(cycles) @(posedge clk);
	endtask
	
	task check_bool_result(string test_name, logic actual, logic expected);
		if (actual === expected) begin
			$display("PASS: %s | Expected: %b, Actual: %b", test_name, expected, actual);
		end else begin
			$display("FAIL: %s | Expected: %b, Actual: %b", test_name, expected, actual);
		end
	endtask
	
	initial begin
		$display("Starting input controller tests");
		
		clk = 0;
		reset = 1;
		n8_left = 0; n8_right = 0; n8_up = 0; n8_down = 0; n8_start = 0;
		
		// Test 1: Reset behavior
		wait_cycles(5);
		reset = 0;
		wait_cycles(2);
		check_bool_result("Reset - all outputs low", (move_left | move_right | move_up | move_down | start_game), 1'b0);
		
		// Test 2: Movement direction mapping
		$display("\nTesting movement direction mapping:");
		
		// Test left movement
		n8_left = 1;
		wait_cycles(1);
		check_bool_result("Left movement", move_left, 1'b1);
		n8_left = 0;
		wait_cycles(1);
		check_bool_result("Left movement released", move_left, 1'b0);
		
		// Test right movement
		n8_right = 1;
		wait_cycles(1);
		check_bool_result("Right movement", move_right, 1'b1);
		n8_right = 0;
		wait_cycles(1);
		check_bool_result("Right movement released", move_right, 1'b0);
		
		// Test up movement
		n8_up = 1;
		wait_cycles(1);
		check_bool_result("Up movement", move_up, 1'b1);
		n8_up = 0;
		wait_cycles(1);
		check_bool_result("Up movement released", move_up, 1'b0);
		
		// Test down movement
		n8_down = 1;
		wait_cycles(1);
		check_bool_result("Down movement", move_down, 1'b1);
		n8_down = 0;
		wait_cycles(1);
		check_bool_result("Down movement released", move_down, 1'b0);
		
		// Test 3: Start button edge detection
		$display("\nTesting start button edge detection:");
		
		// Test initial press after reset (should work immediately)
		n8_start = 1;
		wait_cycles(1);
		check_bool_result("Start button first press", start_game, 1'b1);
		wait_cycles(1);
		check_bool_result("Start button held - no retrigger", start_game, 1'b0);
		
		// Release and test immediate re-press (should NOT work due to 2-cycle delay)
		n8_start = 0;
		wait_cycles(1);
		n8_start = 1; // Immediate re-press
		wait_cycles(1);
		check_bool_result("Start button immediate re-press", start_game, 1'b0);
		
		// Release for 2 cycles, then press (should work)
		n8_start = 0;
		wait_cycles(2); // Wait 2 cycles for delay logic
		n8_start = 1;
		wait_cycles(1);
		check_bool_result("Start button after 2-cycle delay", start_game, 1'b1);
		n8_start = 0;
		wait_cycles(1);
		
		// Test 4: Simultaneous movements
		$display("\nTesting simultaneous movements:");
		n8_left = 1;
		n8_up = 1;
		wait_cycles(1);
		check_bool_result("Simultaneous left", move_left, 1'b1);
		check_bool_result("Simultaneous up", move_up, 1'b1);
		check_bool_result("Other movements off", (move_right | move_down), 1'b0);
		
		// Test all four directions simultaneously
		n8_right = 1;
		n8_down = 1;
		wait_cycles(1);
		check_bool_result("All four directions", (move_left & move_right & move_up & move_down), 1'b1);
		
		// Release all
		n8_left = 0; n8_right = 0; n8_up = 0; n8_down = 0;
		wait_cycles(1);
		check_bool_result("All movements released", (move_left | move_right | move_up | move_down), 1'b0);
		
		n8_left = 0;
		n8_start = 0;
		wait_cycles(1);
		
		$stop;
	end
	
endmodule