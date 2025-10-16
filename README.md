# Meteor Dodge

A VGA-based reaction game for the DE1-SoC FPGA board where players control a spaceship to dodge falling meteors.

## Project Overview

**Meteor Dodge** is a hardware-implemented arcade-style game created as a final project for CSE/EE 371 (Digital Circuits and Systems). Players navigate a spaceship horizontally and vertically across the screen, avoiding randomly-spawning meteors that fall from the top. The game features collision detection, scoring, and a lives system.

## Features

- **VGA Graphics Display**: Full 640x480 resolution gameplay with smooth rendering
- **N8 Controller Input**: Use WASD keys for movement (up, down, left, right) and J key to start/restart
- **Dynamic Gameplay**: 
  - Random meteor spawning using LFSR (Linear Feedback Shift Register)
  - Up to 6 meteors on screen simultaneously
  - Score tracking displayed on 7-segment displays
  - Lives system (3 lives) shown on LEDs
- **Collision System**: 
  - Precise rectangle-based collision detection
  - Individual meteor deactivation on collision
  - Brief immunity period after game restart
- **State Machine**: Smooth transitions between playing and game over states

## Hardware Requirements

- DE1-SoC FPGA Development Board (Cyclone V)
- VGA monitor
- Access to LabsLand remote lab system with N8 controller interface

## Controls

| Key | Action |
|-----|--------|
| W | Move Up |
| S | Move Down |
| A | Move Left |
| D | Move Right |
| J | Start/Restart Game |

## Architecture

The project is organized into modular SystemVerilog components:

### Core Modules

- **`DE1_SoC.sv`**: Top-level module integrating all components
- **`game_controller.sv`**: Main game state machine and logic
- **`ship_controller.sv`**: Player ship movement with boundary checking
- **`meteor_controller.sv`**: Meteor spawning, movement, and management
- **`collision_detector.sv`**: Detects collisions between ship and meteors
- **`graphics_controller.sv`**: Renders all game objects to VGA display

### Supporting Modules

- **`n8_driver.sv`**: N8 controller input driver
- **`input_controller.sv`**: Debouncing and input processing
- **`score_display.sv`**: Converts score to 7-segment display
- **`clock_divider.sv`**: Generates game clock from 50MHz system clock
- **`video_driver.sv`**: VGA timing and display controller
- **`binary_to_decimal_converter.sv`**: Score conversion logic
- **`seven_seg_decoder.sv`**: 7-segment display decoder

### Test Benches

- `game_controller_tb.sv`
- `collision_detector_tb.sv`
- `meteor_controller_tb.sv`
- `ship_controller_tb.sv`

## Game Mechanics

### Scoring
- Score increases by 1 for each meteor that successfully passes the bottom of the screen
- Score is displayed in decimal on HEX displays (0-9999)

### Lives System
- Start with 3 lives (shown as lit LEDs)
- Lose 1 life per collision with a meteor
- Colliding meteor disappears immediately
- Game over when all lives are lost

### Meteor Behavior
- Spawn at random X positions at the top of screen
- Fall at constant speed (2 pixels per game clock cycle)
- New meteor spawns every 100 game clock cycles
- Maximum of 6 active meteors at once

### Ship Controls
- Movement speed: 2 pixels per game clock cycle
- Full 2D movement (horizontal and vertical)
- Constrained to screen boundaries

## Building and Running

1. **Open in Quartus Prime**:
   ```bash
   quartus DE1_SoC.qpf
   ```

2. **Compile the design**:
   - Processing > Start Compilation
   - Or use: `quartus_sh --flow compile DE1_SoC`

3. **Program the FPGA**:
   - Tools > Programmer
   - Load the generated `.sof` file
   - Click "Start"

4. **For LabsLand**: Upload the `.sof` file through the web interface

## Project Structure

```
.
├── DE1_SoC.sv                          # Top-level module
├── game_controller.sv                   # Main game logic
├── ship_controller.sv                   # Player ship control
├── meteor_controller.sv                 # Meteor spawning/movement
├── collision_detector.sv                # Collision detection
├── graphics_controller.sv               # VGA rendering
├── n8_driver.sv                         # N8 controller driver
├── serial_driver.sv                     # Serial communication
├── input_controller.sv                  # Input processing
├── score_display.sv                     # Score display logic
├── clock_divider.sv                     # Clock generation
├── video_driver.sv                      # VGA driver
├── binary_to_decimal_converter.sv       # BCD conversion
├── seven_seg_decoder.sv                 # 7-segment decoder
├── *_tb.sv                              # Test benches
├── altera_up_avalon_video_vga_timing.v # VGA timing (Altera IP)
├── CLOCK25_PLL.v                        # PLL for 25MHz clock
└── CLOCK25_PLL_0002.v                   # PLL implementation

```

## Design Decisions

### Vertical Movement Addition
The original proposal only included horizontal movement, but vertical movement was added to increase gameplay depth and difficulty.

### Lives System vs. Instant Game Over
A 3-lives system was implemented instead of instant game over to make the game more forgiving and engaging.

### Meteor Deactivation on Collision
When a collision occurs, the specific meteor(s) involved disappear, allowing remaining meteors to continue falling rather than resetting all game objects.

### Immunity Period
A brief immunity period (15 game clock cycles) after restart prevents immediate re-collision during respawn.

## Technical Highlights

- **LFSR-based Randomization**: 16-bit LFSR generates pseudo-random meteor spawn positions
- **Edge Detection**: Collision response uses edge detection to prevent multiple triggers
- **Modular Design**: Clear separation of concerns across modules
- **Comprehensive Testing**: Test benches for all major gameplay components

## Authors

- Ethan Tieu
- Sathvik Kanuri
