# CPE-487 Final Project
# Subway Surfers
## Expected Behavior:

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


## Modifications
### vga_top.vhd
* Anode in the port map must be changed from (3 downto 0) to (7 downto 0). This is required for the display to utilize all 8 digits.
* In architecture behavioral include a signal c_counter_score : std_logic_vector (15 downto 0). This is a variable required for the process of counting the coins collected.
* In component subway port map include c_counter as an out variable (15 downto 0), which is also required for the coin counter.
* Leddec port map must change f_data to (7 downto0), add f_data2 std logic vector (15 downto 0), and change anode to (7 downto 0).
* In add_runner port map add c_counter => c_counter_score
* In led_driver : leddec port map add f_data2 => c_counter_score, and remove "00000000" from f_data.

### subway.vhd
* 



### leddec.vhd
* In the port map, change dig from (1 downto 0) to (2 downto 0). Also change f_data from (15 downto 0) to (7 downto 0).Change anode from (3 down to 0) to (7 down to 0). This allows for all digits in the display to be used.
* Include f_data2 IN (15 downto 0) in port map. This is for the secondary counter that counts coins.
* In architecture behavioral of leddec, add a new signal f_data_temp as (15 downto 0).
* Under begin, before data <=, add f_data_temp <= "00000000" & f_data;
* Data is now <= f_data_temp, and dig is "000", to "001", "010", "011" because the entire display is being used now, using 4 bits each: f_data_temp(3 downto 0), f_data_temp(7 downto 4), and so on.
* f_data2 handles "100", "101", "110", and "111"/Else. Also moving from 4 bits each.
* These two data types, f_data_temp and f_data 2 each represent the two different counters being displayed: the score counter and the coin counter repectively.
* Under the anode section, turn on all 8 anodes and change the dig values from 00, 01... to 000, 001 type of counting.

  
  
