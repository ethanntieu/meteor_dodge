module collision_detector_tb();
	// Test inputs
	logic [9:0] ship_x;
	logic [8:0] ship_y;
	logic [9:0] meteor_x [5:0];
	logic [8:0] meteor_y [5:0];
	logic [5:0] meteor_active;
	
	// Test outputs
	logic collision;
	logic [5:0] meteor_collisions;
	
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam METEOR_SIZE = 30;
	
	collision_detector dut (
		.ship_x(ship_x),
		.ship_y(ship_y),
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.collision(collision),
		.meteor_collisions(meteor_collisions)
	);
	
	// Helper task to initialize all meteors as inactive and off-screen
	task reset_meteors();
		meteor_active = 6'b000000;
		for (int i = 0; i < 6; i++) begin
			meteor_x[i] = 10'd700; // Off-screen
			meteor_y[i] = 9'd500;  // Off-screen
		end
	endtask
	
	// Helper task to check expected result
	task check_result(logic expected_collision, logic [5:0] expected_individual, string Test_name);
		if (collision !== expected_collision) begin
			$display("FAIL: %s - Expected collision: %b, Got: %b", Test_name, expected_collision, collision);
		end else if (meteor_collisions !== expected_individual) begin
			$display("FAIL: %s - Expected individual collisions: %b, Got: %b", Test_name, expected_individual, meteor_collisions);
		end else begin
			$display("PASS: %s - Overall: %b, Individual: %b", Test_name, collision, meteor_collisions);
		end
	endtask
	
	initial begin
		$display("Starting collision detector tests");
		
		// Initialize ship position (center of screen)
		ship_x = 10'd300;
		ship_y = 9'd240;
		
		// Test 1: No collision - all meteors inactive 
		reset_meteors();
		#10;
		check_result(1'b0, 6'b000000, "No collision - all meteors inactive");
		
		// Test 2: No collision - meteors active but far away 
		reset_meteors();
		meteor_active = 6'b111111; // All active
		meteor_x[0] = 10'd100;  meteor_y[0] = 9'd100; // Far left
		meteor_x[1] = 10'd500;  meteor_y[1] = 9'd100; // Far right  
		meteor_x[2] = 10'd300;  meteor_y[2] = 9'd50; // Far above
		meteor_x[3] = 10'd300;  meteor_y[3] = 9'd400; // Far below
		meteor_x[4] = 10'd600;  meteor_y[4] = 9'd300; // Far away
		meteor_x[5] = 10'd50;   meteor_y[5] = 9'd350; // Far away
		#10;
		check_result(1'b0, 6'b000000, "No collision - meteors active but far away");
		
		// Test 3: Single meteor collision - meteor 0
		reset_meteors();
		meteor_active[0] = 1'b1;
		meteor_x[0] = ship_x + 5; // Partially overlapping
		meteor_y[0] = ship_y + 5;
		#10;
		check_result(1'b1, 6'b000001, "Single collision - meteor 0");
		
		// Test 4: Single meteor collision - meteor 3  
		reset_meteors();
		meteor_active[3] = 1'b1;
		meteor_x[3] = ship_x + 10; // Partially overlapping
		meteor_y[3] = ship_y + 8;
		#10;
		check_result(1'b1, 6'b001000, "Single collision - meteor 3");
		
		// Test 5: Multiple meteor collision - meteors 1 and 4
		reset_meteors();
		meteor_active[1] = 1'b1;
		meteor_active[4] = 1'b1;
		meteor_x[1] = ship_x + 5; meteor_y[1] = ship_y + 5; // Meteor 1 colliding
		meteor_x[4] = ship_x + 10; meteor_y[4] = ship_y + 8; // Meteor 4 colliding
		#10;
		check_result(1'b1, 6'b010010, "Multiple collision - meteors 1 and 4");
		
		// Test 6: Boundary test - meteor just touching ship edge
		reset_meteors();
		meteor_active[2] = 1'b1;
		meteor_x[2] = ship_x + SHIP_WIDTH - 1; // Just touching right edge
		meteor_y[2] = ship_y + SHIP_HEIGHT - 1; // Just touching bottom edge
		#10;
		check_result(1'b1, 6'b000100, "Boundary collision - meteor 2 touching edge");

		$stop;
	end
	
endmodule