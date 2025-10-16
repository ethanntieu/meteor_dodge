module game_controller (
	input logic clk,
	input logic reset,
	input logic move_left,
	input logic move_right,
	input logic move_up,
	input logic move_down,
	input logic start_game,
	output logic [9:0] ship_x,
	output logic [8:0] ship_y,
	output logic [9:0] meteor_x [5:0],
	output logic [8:0] meteor_y [5:0],
	output logic [5:0] meteor_active,
	output logic [15:0] score,
	output logic game_over,
	output logic collision,
	output logic [2:0] lives
);
	// Game parameters
	localparam SHIP_WIDTH = 40;
	localparam SHIP_HEIGHT = 15;
	localparam METEOR_SIZE = 30;
	localparam METEOR_SPEED = 2;
	localparam SHIP_SPEED = 2;
	localparam INITIAL_LIVES = 3;
	
	// Game state
	typedef enum logic [1:0] {PLAYING, GAME_OVER_STATE, RESTART} game_state_t;
	game_state_t game_state;
	
	// Internal signals with proper initialization
	logic ship_reset = 1'b0;
	logic meteor_reset = 1'b0;
	logic game_active; // Signal to control when game elements should be active
	logic meteor_passed; // Signal from meteor controller when meteor passes
	logic collision_prev = 1'b0; // Previous collision state for edge detection
	logic collision_edge; // Collision edge detection
	logic [3:0] immunity_counter = 4'd0; // Counter for collision immunity after restart
	logic [5:0] meteor_collisions; // Individual meteor collision signals
	logic [5:0] deactivate_meteors = 6'b000000; // Signal to deactivate specific meteors
	
	// Initialize output signals
	initial begin
		game_state = PLAYING;
		game_over = 1'b0;
		score = 16'd0;
		lives = INITIAL_LIVES;
	end
	
	// Game is active only when playing
	assign game_active = (game_state == PLAYING);
	
	// Collision edge detection - only trigger on new collisions, during PLAYING state, and after immunity period
	assign collision_edge = collision & ~collision_prev & (game_state == PLAYING) & (immunity_counter == 4'd0);
	
	// Ship controller
	ship_controller ship_ctrl (
		.clk(clk),
		.reset(reset || ship_reset),
		.move_left(move_left && game_active),
		.move_right(move_right && game_active),
		.move_up(move_up && game_active),
		.move_down(move_down && game_active),
		.ship_x(ship_x),
		.ship_y(ship_y)
	);
	
	// Meteor controller - pass enable signal to control updates and deactivation signals
	meteor_controller meteor_ctrl (
		.clk(clk),
		.reset(reset || meteor_reset),
		.game_enable(game_active), // Enable signal to freeze meteors
		.deactivate_meteors(deactivate_meteors), // Deactivate specific meteors
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.meteor_passed(meteor_passed)
	);
	
	// Collision detector
	collision_detector collision_det (
		.ship_x(ship_x),
		.ship_y(ship_y),
		.meteor_x(meteor_x),
		.meteor_y(meteor_y),
		.meteor_active(meteor_active),
		.collision(collision),
		.meteor_collisions(meteor_collisions) // Individual collision signals
	);
	
	// Game state machine and scoring
	always_ff @(posedge clk) begin
		if (reset) begin
			// Hard reset - completely reset everything to initial state
			game_state <= PLAYING;
			game_over <= 1'b0;
			score <= 16'd0;
			lives <= INITIAL_LIVES; // Start with 3 lives
			ship_reset <= 1'b0;
			meteor_reset <= 1'b0;
			collision_prev <= 1'b0;
			immunity_counter <= 4'd0;
			deactivate_meteors <= 6'b000000; // Initialize deactivation signals
		end else begin
			// Update collision history for edge detection
			collision_prev <= collision;
			
			// Count down immunity counter
			if (immunity_counter > 4'd0) begin
				immunity_counter <= immunity_counter - 1;
			end
			
			// Default: don't reset modules unless explicitly needed
			ship_reset <= 1'b0;
			meteor_reset <= 1'b0;
			deactivate_meteors <= 6'b000000; // Default to no deactivation
			
			case (game_state)
				PLAYING: begin
					// Increment score when meteors are successfully dodged (pass bottom)
					if (meteor_passed && score < 16'hFFFF) begin
						score <= score + 1;
					end
					
					// Check for NEW collision (edge detection prevents multiple hits)
					if (collision_edge) begin
						// Deactivate meteors that collided with the ship
						deactivate_meteors <= meteor_collisions;
						
						if (lives > 3'd1) begin
							// Lose a life but keep playing - meteors that collided disappear
							lives <= lives - 1;
							// No meteor reset - meteors continue falling, colliding ones disappear
						end else begin
							// Last life lost - game over
							lives <= 3'd0;
							game_state <= GAME_OVER_STATE;
							game_over <= 1'b1;
						end
					end
				end
				
				GAME_OVER_STATE: begin
					// Stay in game over state until start button pressed
					if (start_game) begin
						game_state <= RESTART;
					end
				end
				
				RESTART: begin
					// Reset everything and go back to playing
					game_state <= PLAYING;
					game_over <= 1'b0;
					score <= 16'd0;
					lives <= INITIAL_LIVES; // Reset to 3 lives
					collision_prev <= 1'b0; // Clear collision history
					immunity_counter <= 4'd15; // Give 15 cycles of immunity after restart
					ship_reset <= 1'b1; // Reset ship to center
					meteor_reset <= 1'b1; // Clear meteors on restart
				end
			endcase
		end
	end
	
endmodule