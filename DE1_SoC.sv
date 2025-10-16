module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS,
					 V_GPIO);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input CLOCK_50;
	output [7:0] VGA_R, VGA_G, VGA_B;
	output VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	// Only declare the GPIO pins we actually need (26, 27, 28)
	inout [28:26] V_GPIO;
	
	// Internal signals
	logic reset, game_clk;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	// Game state signals
	logic [9:0] ship_x;
	logic [8:0] ship_y;
	logic [9:0] meteor_x [5:0];
	logic [8:0] meteor_y [5:0];
	logic [5:0] meteor_active;
	logic [15:0] score;
	logic game_over, collision;
	logic [2:0] lives;
	
	// N8 Controller signals
	logic n8_latch, n8_pulse;
	logic n8_up, n8_down, n8_left, n8_right;
	logic n8_select, n8_start, n8_a, n8_b;
	
	// Input signals from N8 controller
	logic move_left_sig, move_right_sig, move_up_sig, move_down_sig, start_game_sig;
	
	// Reset functionality disabled for N8 controller version
	// Game restart is handled by the start button through game logic
	assign reset = 1'b0;
	
	// N8 Controller GPIO connections
	assign V_GPIO[27] = n8_pulse;  // Pulse signal
	assign V_GPIO[26] = n8_latch;  // Latch signal
	// V_GPIO[28] is data input from LabsLand system
	
	// Clock generation
	clock_divider clk_div (
		.clk_in(CLOCK_50),
		.reset(reset),
		.game_clk(game_clk)
	);
	
	// N8 Controller driver
	n8_driver n8_ctrl (
		.clk(CLOCK_50),
		.data_in(V_GPIO[28]),
		.latch(n8_latch),
		.pulse(n8_pulse),
		.up(n8_up),
		.down(n8_down),
		.left(n8_left),
		.right(n8_right),
		.select(n8_select),
		.start(n8_start),
		.a(n8_a),
		.b(n8_b)
	);
	
	// Input handling using N8 controller
	input_controller input_ctrl (
		.clk(game_clk),
		.reset(reset),
		.n8_left(n8_left),
		.n8_right(n8_right),
		.n8_up(n8_up),
		.n8_down(n8_down),
		.n8_start(n8_start),
		.move_left(move_left_sig),
		.move_right(move_right_sig),
		.move_up(move_up_sig),
		.move_down(move_down_sig),
		.start_game(start_game_sig)
	);
	
	// Game logic
	game_controller game_ctrl (
		.clk(game_clk),
		.reset(reset),
		.move_left(move_left_sig),
		.move_right(move_right_sig),
		.move_up(move_up_sig),
		.move_down(move_down_sig),
		.start_game(start_game_sig),
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
	
	// Graphics renderer
	graphics_controller graphics_ctrl (
		.clk(CLOCK_50),
		.x(x),
		.y(y),
		.ship_x(ship_x),
		.ship_y(ship_y),
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.score(score),
		.game_over(game_over),
		.r(r),
		.g(g),
		.b(b)
	);
	
	// VGA driver
	video_driver #(.WIDTH(640), .HEIGHT(480)) vga_driver (
		.CLOCK_50(CLOCK_50),
		.reset(reset),
		.x(x),
		.y(y),
		.r(r),
		.g(g),
		.b(b),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_VS(VGA_VS)
	);
	
	// Seven segment displays for score
	score_display score_disp (
		.score(score),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3)
	);
	
	// Turn off unused HEX displays
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	
	// LED display for lives
	always_comb begin
		case (lives)
			3'd3: LEDR = 10'b0000000111; // 3 LEDs on (LEDR[2:0])
			3'd2: LEDR = 10'b0000000011; // 2 LEDs on (LEDR[1:0])
			3'd1: LEDR = 10'b0000000001; // 1 LED on (LEDR[0])
			default: LEDR = 10'b0000000000; // All LEDs off
		endcase
	end
	
endmodule