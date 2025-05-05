# CPE-487 Final Project
# Subway Surfers
## Expected Behavior:

## Hardware Needed:

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
