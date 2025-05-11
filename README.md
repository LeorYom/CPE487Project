# CPE-487 Final Project
# Subway Surfers
![image](https://github.com/user-attachments/assets/0652e8ab-f38b-4ba7-8480-8d589c972d5c)  
## Expected Behavior:
* Our Project is based off of the game Subway Surfers
* It starts off in the middle and you are able to move your player left and right to avoid the trains
* The objective is to pick up the most amount of coins without hitting any obstacles
  ![Demo](https://github.com/LeorYom/CPE487Project/blob/main/IMG_2297-ezgif.com-video-to-gif-converter%20(1).gif)
## Hardware Needed:
* Computer: current Mac (OS X) or PC (Windows 7+)
* Nexys A7-100T FPGA Board
* Micro-USB Cable
* VGA Cable
* Monitor/TV with VGA input or VGA adapter
## How to play:
### 1. Create a new RTL project _siren_ in Vivado Quick Start

* Create the source files of file type VHDL

* Create a new constraint file of file type XDC

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from dac_if.vhd, tone.vhd, wail.vhd, siren.vhd

* Click constraints and copy and paste the code
* As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.
### 2. Run synthesis

### 3. Run implementation

### 3b. (optional, generally not recommended as it is difficult to extract information from and can cause Vivado shutdown) Open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download it to the Nexys A7-100T board

### 5. Now you can play!

* Click BTNC to start the game

* The trains will move down the screen with the coins

* Try to catch as many coins as possible without hitting any of the trains!!!

* The player will be able to avoid the obstacles with BTNL and BTNR to move the subway surfer left and right 
## Inputs and Outputs
### Inputs
* Left, Right, and reset buttons
* f_data, f_data2, and Dig
* clk_in1
### Outputs
* All 17 LEDs: LED0, LED1, LED2,...,LED15, LED16_B, LED17_R
* Anode and Seg
* clk_out1
* seconds_bcd and c_counter
## Modules
### vga_sync.vhd
* The `vga_sync.vhd` module is responsible for generating VGA timing signals and determining pixel positions on the screen.
* It operates horizontal (`h_cnt`) and vertical (`v_cnt`) counters to track the location of each pixel.

* This module produces the `hsync` and `vsync` signals required by the VGA display for synchronization.

* It outputs the current pixel’s row and column (`pixel_row` and `pixel_col`) to indicate its position on the screen.

* It also controls whether RGB signals are active using the `video_on` signal, which disables video output during synchronization periods.

* Inputs:

	- Pixel clock (`pixel_clk`) provided by `clk_wiz_0`

	- Red, green, and blue color data

* Outputs:

	- VGA synchronization signals `(hsync`, `vsync`)

	- Coordinates of the active pixel (`pixel_row`, `pixel_col`)
### vga_top.vhd
* The `vga_top.vhd` file serves as the main module that integrates and manages all the submodules and coordinates the system’s overall behavior.
* It creates instances of the `vga_sync`, `subway`, `leddec`, and `clk_wiz_0` modules.

* It processes input from the control buttons (`left`, `right`, and `reset`) to manage the runner's movement.

* VGA signal data, such as pixel positions and RGB values, is sent to the `vga_sync` module for display handling.

* The `subway` module’s `seconds_bcd` output is forwarded to the leddec module to drive the 8-segment display.

* Module roles and connections:

* Clock: The `clk_wiz_0` module generates the appropriate VGA clock signal.

* Subway: Handles the game's logic, including the runner's position and collision detection with coins and trains.

* Display: The `leddec` module manages time-multiplexing for the 8-segment LED display.
### subway.vhd
* `subway.vhd` – Game Logic and Object Control
* This module manages the movement and position of the runner character, as well as the trains, coins, and the logic for the coin counter. This module also also handles collision detection for both coins and trains and manages the stopwatch counter which is also the score.

* Responds to input signals (left, right, reset) to update the runner’s horizontal position.

* Continuously moves the trains and coins (`train1`, `train2`, `train3`, `coin1`, `coin2`) downward and resets their positions once they pass the bottom.

*  All of the bottom LEDs, (`LED0`, `LED1`, `LED2`,... `LED15`) turn on when you start the game and turn off when you lose.

*  The other two coins, (`LED16_B`, `LED17_R`) turn on when you hit a coin and turn off if you are not on a coin streak. 
   
* Detects collisions between the runner and the trains to determine game events.

* Detects collisions between the runner and the coins to determine the main objective of the game.

* Registers a collision of a coin with the runner to add to the counter of coins collected.

* Contains stopwatch functionality that tracks how long the player has survived while the game is running.

* Implements a function to create irregular movement for the coins.

* Key Signals:
	- `runner_x`, `runner_y`: Current coordinates of the runner.

	- `train1_x`, `train1_y`, etc.: Current positions of each train.

	- `coin1_x`, `coin1_y`, etc.: Current positions of each coin.

	- `seconds`: Internal counter for elapsed time, converted to BCD for display.

	- `r_counter` and `r_var` for iregular coin movement

* Outputs:
	- VGA RGB values (`red`, `green`, `blue`) for visual output.

	- Elapsed time in BCD format (`seconds_bcd`) for display on the 8-segment display.

	- Coin Counter (`c_counter`) to register, count, and display coin collection.

### subway.xdc
* The `subway.xdc` file defines the physical constraints for the FPGA design, including pin assignments for inputs, outputs, and the clock.

	- Assigns the FPGA board’s buttons (BTNL, BTNR, BTNC, BTND, BTNU) to their corresponding hardware ports.

	- Sets up the input clock source (e.g., 100 MHz) for the `clk_wiz_0` module.

	- Connects VGA output signals (`hsync`, `vsync`, `red`, `green`, `blue`) to the correct physical pins on the FPGA to enable video display.
### leddec.vhd
* This module uses the `dig` input as a multiplexing clock to determine which of the four 8-segment displays is currently active.

* It decodes the `seconds_bcd` input to generate the correct signals for the segment lines (`CA` to `CG`), enabling the display of the appropriate digits.

* By rapidly cycling through all four digits, it creates the illusion that all displays are lit simultaneously.

* Inputs:

	- `dig`: 3-bit signal that selects which digit is active at any moment.

	- `f_data`: 8-bit input carrying the BCD values to be shown.

	- `f_data2`: 16-bit input carrying the coin counter value to be shown

* Outputs:

	- `anode`: Enables both of the four digit displays (`AN0`–`AN7`).

	- `seg`: Controls the segment lines to form the digits on the active display.
### clk_wiz_0_clk_wiz.vhd
* The `clk_wiz_0_clk_wiz.vhd` file is a supporting module for `clk_wiz_0`, containing the core logic for clock signal generation.

* It defines the internal configuration of clock dividers and multipliers needed to produce the desired output frequencies.
### clk_wiz_0.vhd
* The `clk_wiz_0.vhd` module provides the necessary clock signals for the system, typically without modification.

* It takes the main input clock from the FPGA (e.g., 100 MHz) and generates a 25 MHz clock required by the `vga_sync` module.

* Additional clock outputs can be configured if other components need different frequencies.

* This module is created using the Xilinx Clocking Wizard, which allows custom clock frequency generation based on system requirements.

## Modifications
### vga_sync.vhd
* For all the constants, it needs to be changed to fit your display.
```
    CONSTANT H      : INTEGER := 900; 
    CONSTANT V      : INTEGER := 600; 
    CONSTANT H_FP   : INTEGER := 40; 
    CONSTANT H_BP   : INTEGER := 88; 
    CONSTANT H_SYNC : INTEGER := 128; 
    CONSTANT V_FP   : INTEGER := 1; 
    CONSTANT V_BP   : INTEGER := 23;  
    CONSTANT V_SYNC : INTEGER := 4;    
    CONSTANT FREQ   : INTEGER := 60;  
```
* Ensured that it connects to the VGA monitor correctly. 
### vga_top.vhd
* Anode in the port map must be changed from (3 downto 0) to (7 downto 0). This is required for the display to utilize all 8 digits.
* In architecture behavioral include a signal c_counter_score : std_logic_vector (15 downto 0). This is a variable required for the process of counting the coins collected.
* In component subway port map include c_counter as an out variable (15 downto 0), which is also required for the coin counter.
* Leddec port map must change f_data to (7 downto0), add f_data2 std logic vector (15 downto 0), and change anode to (7 downto 0).
* In add_runner port map add c_counter => c_counter_score
* In led_driver : leddec port map add f_data2 => c_counter_score, and remove "00000000" from f_data.

### subway.vhd
* The entity name was changed from runner to subway.
* We added 2 coins on each side for the players to collect. The coin is reset back to the top once it reaches the bottom. 
* The coins flow at different speeds and drops at a different coordinate each time adding randomness to the game.
* Added 17 LEDS from the board. 15 of the LEDS are green and the other 2 LEDs are blue and red. The 15 LEDS pop up when someone is alive in the game. The red and blue LEDs only popup when your on a hot streak collecting all the coins.
* We created a flag so that the coin is only being collected once each time it is hit. The flag is connected to the coin counter on the FPGA display, so each time the coin is hit the counter is activated and counts by one.
```
IF (((runner_x >= coin1_x - coin_size AND runner_x <= coin1_x + coin_size)
        AND (runner_y >= coin1_y - coin_size AND runner_y <= coin1_y + coin_size)) OR
            ((runner_x >= coin2_x - coin_size AND runner_x <= coin2_x + coin_size)
        AND (runner_y >= coin2_y - coin_size AND runner_y <= coin2_y + coin_size))) then
         
        IF flag = '1' then
         c_counter_temp <= c_counter_temp + 1;
          ledsec <= seconds;       
         flag <= '0';    
         LED16_B <= '1';
         LED17_R <= '1';                  
        END IF;
        ELSE
        flag <= '1';
        END IF;
        if seconds > ledsec + 4 then
         LED16_B <= '0';
         LED17_R <= '0';
        end if;
```

### subway.xdc
* Added all 8 anode pins for the display.
```
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {anode[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {anode[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {anode[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {anode[3]}]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { anode[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { anode[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { anode[6] }]; #IO_L23P_T3_35 Sch=an[6]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { anode[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]
```
* Added all 17 LEDS to connect to the LEDs on the FPGA.
```
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { LED0 }]; #IO_L18P_T2_A24_15 Sch=led[0]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { LED1 }]; #IO_L24P_T3_RS1_15 Sch=led[1]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { LED2 }]; #IO_L17N_T2_A25_15 Sch=led[2]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { LED3 }]; #IO_L8P_T1_D11_14 Sch=led[3]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { LED4 }]; #IO_L7P_T1_D09_14 Sch=led[4]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { LED5 }]; #IO_L18N_T2_A11_D27_14 Sch=led[5]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { LED6 }]; #IO_L17P_T2_A14_D30_14 Sch=led[6]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { LED7 }]; #IO_L18P_T2_A12_D28_14 Sch=led[7]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { LED8 }]; #IO_L16N_T2_A15_D31_14 Sch=led[8]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { LED9 }]; #IO_L14N_T2_SRCC_14 Sch=led[9]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { LED10 }]; #IO_L22P_T3_A05_D21_14 Sch=led[10]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { LED11 }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[11]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { LED12 }]; #IO_L16P_T2_CSI_B_14 Sch=led[12]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { LED13 }]; #IO_L22N_T3_A04_D20_14 Sch=led[13]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { LED14 }]; #IO_L20N_T3_A07_D23_14 Sch=led[14]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { LED15 }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=led[15]
set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { LED16_B }]; #IO_L5P_T0_D06_14 Sch=led16_b
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { LED17_R }]; #IO_L11N_T1_SRCC_14 Sch=led17_r
```
### leddec.vhd
* In the port map, change dig from (1 downto 0) to (2 downto 0). Also change f_data from (15 downto 0) to (7 downto 0).Change anode from (3 down to 0) to (7 down to 0). This allows for all digits in the display to be used.

```
ENTITY leddec IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		f_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		f_data2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END leddec;

ARCHITECTURE Behavioral OF leddec IS
SIGNAL f_data_temp : std_logic_vector(15 downto 0);
SIGNAL data : std_logic_vector(3 downto 0);
```
* Include f_data2 IN (15 downto 0) in port map. This is for the secondary counter that counts coins.
* In architecture behavioral of leddec, add a new signal f_data_temp as (15 downto 0).
  
``` SIGNAL f_data_temp : std_logic_vector(15 downto 0); ```
* Under begin, before data <=, add f_data_temp <= "00000000" & f_data;
* Data is now <= f_data_temp, and dig is "000", to "001", "010", "011" because the entire display is being used now, using 4 bits each: f_data_temp(3 downto 0), f_data_temp(7 downto 4), and so on.
* f_data2 handles "100", "101", "110", and "111"/Else. Also moving from 4 bits each.

``` data <= f_data_temp(3 DOWNTO 0) WHEN dig = "000" ELSE

			   f_data_temp(7 DOWNTO 4) WHEN dig = "001" ELSE

			   f_data_temp(11 DOWNTO 8) WHEN dig = "010" ELSE
			   
         f_data_temp(15 DOWNTo 12) WHEN dig = "011" ELSE
			   
         f_data2(3 DOWNTO 0) WHEN dig = "100" ELSE

			   f_data2(7 DOWNTO 4) WHEN dig = "101" ELSE

			   f_data2(11 DOWNTO 8) WHEN dig = "110" ELSE

			   f_data2(15 DOWNTO 12);
``` 
* These two data types, f_data_temp and f_data 2 each represent the two different counters being displayed: the score counter and the coin counter repectively.
* Under the anode section, turn on all 8 anodes and change the dig values from 00, 01... to 000, 001...
``` anode <= "11111110" WHEN dig = "000" ELSE --0
	           "11111101" WHEN dig = "001" ELSE --1
	           "11111011" WHEN dig = "010" ELSE --2
	           "11110111" WHEN dig = "011" ELSE --3
	           "11101111" WHEN dig = "100" ELSE --4
	           "11011111" WHEN dig = "101" ELSE --5
	           "10111111" WHEN dig = "110" ELSE --6
	           "01111111" WHEN dig = "111" ELSE --7
	           "11111111";
``` 
## Responsibilities 
### This is a list of what we worked on in the projects
### Ryan Tierney
* Found a way to use all the display boards. 4 displays for the seconds/score counter and the other 4 displays for the coin counter.
* Implement the coin entities, including their drawing and behavior.
* Started the coin counter, and getting the counter to be applied onto the left 4 displays.
* Allowed the coins to change position each time it regenerated in the game allowing randomness. 
### Leor Yomtobian
* Configuring all the LEDs on the board and incorporating it in the game, including the streak LED that activates after collecting enough coins
* Created the flag system for the coin counter coin counter allowing them to be counted correctly
* Modified the speed, shape, and position of the train entities to better fit the object of the game
* Modified vga_sync, vga_top, and subway.xdc to allow for the implementation of the new game mechanics
## Timeline
* 4/24/2025 - Final idea for project was decided and initial work began, which started with getting the source code to be displayed properly onto the monitor that was being used.
* 4/28/2025 - Coin entities were created, including the drawing and movement of the coins. The shaping of the coins was to be circular, and this equation was implemented into the code.
* 5/2/2025 - Coin counter system was started, basic logic to detect coin collision with runner and to create an incrementer for a coin counter. LED's were implemented to be on at all times.
* 5/6/2025 - Bugs with coin counter were fixed, coin counter logic was finalized. LED system to turn on for coin streaks was implemented and finalized.
* 5/8/2025 - Randomness to coin movement was implemented, debugging of the score counter was complete.
## Difficulties
1.  The red and blue led's would only flash for a nanosecond which made it very difficult to see if you hit a coin or not since the coin was using flag so it would count by one. We saw that the counter would work perfectly if it was seconds + 4, which would keep the light on for a second. We tried using one second or two seconds for the light, but we dealt with many issues. The issues were either double counting the coin, the light staying on forever, only working on every other coin. We realized it would only work at 4 seconds or higher which is how we came up with the coin streak.
2.  The coin counter would register a coin count multiple times per a single contact with the coin. This issue was resolved by immplementing a using the flag and flag reset signals that can be found in subway.vhd: 
```
    Signal flag : std_logic := '1';
    signal flagreset : std_logic := '0';
```

3.  The score counter from the original code would reset after just 64 seconds. This bug was fixed in the subway.vhd file by changing the line (IF seconds...) from what it was previously, to:
   ```
              IF seconds = 400 THEN
                    seconds <= 0;
                END IF;
   ```
The following demonstration shows the score counter exceeding 64 seconds:
![Demo](https://github.com/LeorYom/CPE487Project/blob/main/IMG_2299-ezgif.com-video-to-gif-converter%20(2).gif)
 
  
  
