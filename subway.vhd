LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY subway IS
    PORT (
        v_sync    : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        red       : OUT STD_LOGIC;
        green     : OUT STD_LOGIC;
        blue      : OUT STD_LOGIC;
        up        : IN STD_LOGIC;
        down      : IN STD_LOGIC;
        left      : IN STD_LOGIC;
        right     : IN STD_LOGIC;
        LED0 : OUT std_logic;
		LED1 : OUT std_logic;
		LED2 : OUT std_logic;
		LED3 : OUT std_logic;
		LED4 : OUT std_logic;
		LED5 : OUT std_logic;
		LED6 : OUT std_logic;
		LED7 : OUT std_logic;
		LED8 : OUT std_logic;
		LED9 : OUT std_logic;
		LED10 : OUT std_logic;
		LED11 : OUT std_logic;
		LED12 : OUT std_logic;
		LED13 : OUT std_logic;
		LED14 : OUT std_logic;
		LED15 : OUT std_logic;
		LED16_B : OUT std_logic;
		LED17_R : OUT std_logic; 
		c_counter :  OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reset     : IN STD_LOGIC;
        seconds_bcd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- Seconds in BCD
    );
END subway;

ARCHITECTURE Behavioral OF subway IS
    -- signals and variables for SURFER
    CONSTANT size  : INTEGER := 16;
    SIGNAL c_counter_temp : std_logic_vector(15 downto 0);
    SIGNAl c_reset : std_logic_vector(15 downto 0) :=X"0000";
    SIGNAL runner_on : STD_LOGIC; -- indicates whether runner is over current pixel position
    SIGNAL runner_dead : STD_LOGIC := '0';
    SIGNAL game_active : STD_LOGIC := '0'; -- Indicates if the game is active
    SIGNAL runner_dead_on : STD_LOGIC;
    SIGNAL runner_deadx  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450 - (size/2), 11);
    SIGNAL runner_deady  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600 - (size * 4), 11);
    -- current runner position - initialized to center of screen
    SIGNAL runner_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450 - (size/2), 11);
    SIGNAL runner_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600 - (size * 4), 11);
    SIGNAL runner_hop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001000";
    SIGNAL direction  : INTEGER := 8;
    Signal flag : std_logic := '1';
    signal flagreset : std_logic := '0';
    
    SIGNAL coin_size : INTEGER := 42;

    SIGNAL  train_size : INTEGER := 100;
    SIGNAL train1_on : STD_LOGIC; -- indicates whether train1 is over current pixel position

    -- current train 1 position 
    SIGNAL train1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(230 - (train_size/2), 11);
    SIGNAL train1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    -- current train motion - initialized to +3 pixels/frame
    SIGNAL train1_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000101";

    -- train 2 -
    SIGNAL train2_on : STD_LOGIC; -- indicates whether train1 is over current pixel position
    -- current train position 
    SIGNAL train2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(475 - (train_size/2), 11);
    SIGNAL train2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    -- current train motion - initialized to +4 pixels/frame
    SIGNAL train2_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000010";

    -- train 3 -
    SIGNAL train3_on : STD_LOGIC; -- indicates whether train1 is over current pixel position
    -- current train position 
    SIGNAL train3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(730 - (train_size/2), 11);
    SIGNAL train3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11);
    
    --coin_1--
    SIGNAL coin1_on : STD_LOGIC;
    SIGNAl coin1_xr : std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200 - (coin_size/2), 11);  
    SIGNAL coin1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(260 - (coin_size/2), 11);
    SIGNAL coin1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
     

    SIGNAL coin1_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000111";
    
    --coin_2--
    SIGNAL coin2_on : STD_LOGIC;
    SIGNAl coin2_xr : std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(700 - (coin_size/2), 11); 
    SIGNAL coin2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650 - (coin_size/2), 11);
    SIGNAL coin2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);

    SIGNAL coin2_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000011";
    --coin_3--
    
    
    
    
    -- current train motion - initialized to +5 pixels/frame
    SIGNAL train3_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000011";   
    
    SIGNAL seconds : INTEGER RANGE 0 TO 99 := 0; -- Seconds counter
    SIGNAL stopwatch_active : STD_LOGIC := '0'; -- Controls the stopwatch
    Signal ledsec :  INTEGER RANGE 0 TO 59 := 0;
    SIGNAl r_counter : INTEGER RANGE 0 TO 20 := 0;
    SIGNAl r_var : STD_LOGIC;
    SIGNAl b : INTEGER := 5;

BEGIN
    -- THIS IS WHERE THE COLORS WERE DONE FOR DRAWING 
    -- Default background is white
    red <= train1_on OR runner_on OR coin1_on OR coin2_on;  -- Red for Train 1 and Runner (as black is all colors combined)
    green <= train2_on OR runner_on OR coin1_on OR coin2_on; -- Green for Train 2 and Runner
    blue <= train3_on OR runner_on OR coin1_on OR coin2_on;  -- Blue for Train 3 and Runner
    
    stopwatch : PROCESS (v_sync)
        VARIABLE frame_counter : INTEGER := 0; -- Counts frames for 1-second intervals
    BEGIN
        IF rising_edge(v_sync) THEN
        c_counter <= c_counter_temp;
        -- Handle reset
        IF reset = '1' THEN
            frame_counter := 0; -- Reset frame counter
            seconds <= 0;       -- Reset seconds counter
            --c_counter_temp <= x"0000";
            seconds_bcd <= CONV_STD_LOGIC_VECTOR(0, 8); -- Reset BCD output
        -- Only update stopwatch if active
        ELSIF stopwatch_active = '1' THEN
            -- Increment frame counter (assume 60Hz frame rate)
            frame_counter := frame_counter + 1;

            -- Every 60 frames (1 second at 60Hz), increment the seconds
            IF frame_counter = 60 THEN
               frame_counter := 0; -- Reset frame counter
                seconds <= seconds + 1;
                r_counter <= r_counter + 1;

                -- Reset seconds if it exceeds 99 (for two-digit display)
                IF seconds = 400 THEN
                    seconds <= 0;
                END IF;

                -- Update BCD output
                seconds_bcd <= CONV_STD_LOGIC_VECTOR((seconds MOD 10) + (seconds / 10) * 16, 8);
                END IF;
            END IF;
    END IF;
    END PROCESS;
    
    random : process (r_counter, r_var, b) is
    BEGIN
    IF (r_counter > b)
    then r_var <= '1';
    end if;
    
    END Process;

    fdraw : PROCESS (runner_x, runner_y, pixel_row, pixel_col, runner_dead) IS
    BEGIN
        IF NOT (runner_dead = '1') THEN
            IF (pixel_col >= runner_x - size) AND
               (pixel_col <= runner_x + size) AND
               (pixel_row >= runner_y - size) AND
               (pixel_row <= runner_y + size) THEN
                runner_on <= '1';
            ELSE
                runner_on <= '0';
            END IF;
         ELSIF runner_dead = '1' THEN
            IF (pixel_col >= runner_deadx - size) AND
              (pixel_col <= runner_deadx + size) AND
               (pixel_row >= runner_deady - size) AND
               (pixel_row <= runner_deady + size) THEN
                runner_dead_on <= '1';
                runner_on <= '0';
        END IF;
         END IF;
        END PROCESS;

    -- process to move runner once every frame (i.e. once every vsync pulse)
    mrunner : PROCESS
    BEGIN
       WAIT UNTIL rising_edge(v_sync);
       IF reset = '1' THEN
        -- Reset the game
        runner_x <= CONV_STD_LOGIC_VECTOR(450 - (size/2), 11);
        runner_y <= CONV_STD_LOGIC_VECTOR(600 - (size * 4), 11);
        runner_dead <= '0';
        game_active <= '1';
        stopwatch_active <= '1'; -- Start stopwatch
        LED0 <= '1';
        LED1 <= '1';
        LED2 <= '1';
        LED3 <= '1';
        LED4 <= '1';
        LED5 <= '1';
        LED6 <= '1';
        LED7 <= '1';
        LED8 <= '1';
        LED9 <= '1';
        LED10 <= '1';
        LED11 <= '1';
        LED12 <= '1';
        LED13 <= '1';
        LED14 <= '1';
        LED15 <= '1';

        ELSE
        -- Handle other game states
        -- Only allow horizontal movement
        IF left = '1' THEN
            direction <= 3; -- Move left
        ELSIF right = '1' THEN
            direction <= 4; -- Move right
        ELSIF reset = '1' THEN
            direction <= 5; -- Reset the game
        ELSE
            direction <= 0; -- No movement
        END IF;

        IF direction = 3 THEN
            runner_x <= runner_x - runner_hop; -- Move left
        ELSIF direction = 4 THEN
            runner_x <= runner_x + runner_hop; -- Move right
        ELSIF direction = 5 THEN
        -- Reset the game
        runner_x <= CONV_STD_LOGIC_VECTOR(450 - (size/2), 11);
        runner_y <= CONV_STD_LOGIC_VECTOR(600 - (size * 4), 11);
        runner_dead <= '0';
        game_active <= '1';
        stopwatch_active <= '1'; -- Start stopwatch
        LED0 <= '1';
        LED1 <= '1';
        LED2 <= '1';
        LED3 <= '1';
        LED4 <= '1';
        LED5 <= '1';
        LED6 <= '1';
        LED7 <= '1';
        LED8 <= '1';
        LED9 <= '1';
        LED10 <= '1';
        LED11 <= '1';
        LED12 <= '1';
        LED13 <= '1';
        LED14 <= '1';
        LED15 <= '1';
        
       

    ELSIF runner_dead = '1' THEN
        game_active <= '0'; -- Stop the game
        stopwatch_active <= '0'; -- Stop stopwatch
        LED0 <= '0';
        LED1 <= '0';
        LED2 <= '0';
        LED3 <= '0';
        LED4 <= '0';
        LED5 <= '0';
        LED6 <= '0';
        LED7 <= '0';
        LED8 <= '0';
        LED9 <= '0';
        LED10 <= '0';
        LED11 <= '0';
        LED12 <= '0';
        LED13 <= '0';
        LED14 <= '0';
        LED15 <= '0';
    END IF;
    END IF;
    ---collision detection for coins
 IF r_var <= '0' THEN      
 IF (((runner_x >= coin1_x - coin_size AND runner_x <= coin1_x + coin_size)
        AND (runner_y >= coin1_y - coin_size AND runner_y <= coin1_y + coin_size)) OR
            ((runner_x >= coin2_x - coin_size AND runner_x <= coin2_x + coin_size)
        AND (runner_y >= coin2_y - coin_size AND runner_y <= coin2_y + coin_size))) then-- OR
          --  ((runner_x >= coin3_x - coin_size AND runner_x <= coin3_x + coin_size)
       -- AND (runner_y >= coin3_y - coin_size AND runner_y <= coin3_y + coin_size))
        IF flag = '1' then
         c_counter_temp <= c_counter_temp + 1;
          ledsec <= seconds;-- + 1;        
         flag <= '0';    
         LED16_B <= '1';
         LED17_R <= '1';                  
   END IF;
        ELSE
        flag <= '1';
        END IF;
        if seconds > ledsec + 4 then -- OR seconds = 0 then
         LED16_B <= '0';
         LED17_R <= '0';
        end if;
        else
         IF (((runner_x >= coin1_xr - coin_size AND runner_x <= coin1_xr + coin_size)
        AND (runner_y >= coin1_y - coin_size AND runner_y <= coin1_y + coin_size)) OR
            ((runner_x >= coin2_xr - coin_size AND runner_x <= coin2_xr + coin_size)
        AND (runner_y >= coin2_y - coin_size AND runner_y <= coin2_y + coin_size))) then-- OR
          --  ((runner_x >= coin3_x - coin_size AND runner_x <= coin3_x + coin_size)
       -- AND (runner_y >= coin3_y - coin_size AND runner_y <= coin3_y + coin_size))
        IF flag = '1' then
         c_counter_temp <= c_counter_temp + 1;
          ledsec <= seconds;-- + 1;        
         flag <= '0';    
         LED16_B <= '1';
         LED17_R <= '1';                  
        END IF;
        ELSE
        flag <= '1';
        END IF;
        if seconds > ledsec + 4 then -- OR seconds = 0 then
         LED16_B <= '0';
         LED17_R <= '0';
        end if;
        END IF;
          --- collision detection for train1, 2 and 3
        -- Check for collision between runner and any train
        IF ((runner_x >= train1_x - train_size AND runner_x <= train1_x + train_size) 
        AND (runner_y >= train1_y - train_size AND runner_y <= train1_y + train_size)) OR 
            ((runner_x >= train2_x - train_size AND runner_x <= train2_x + train_size) 
        AND (runner_y >= train2_y - train_size AND runner_y <= train2_y + train_size)) OR
            ((runner_x >= train3_x - train_size AND runner_x <= train3_x + train_size) 
        AND (runner_y >= train3_y - train_size AND runner_y <= train3_y + train_size))
        THEN
    -- Mark the runner as dead and save its position
    runner_dead <= '1';
    game_active <= '0'; -- Stop game when runner dies
    c_counter_temp <= x"0000";
    runner_deadx <= runner_x;
    runner_deady <= runner_y;
END IF;

       END PROCESS;
       
    --process to draw train1, train2, train3
    t1draw : PROCESS (train1_x, train1_y, pixel_row, pixel_col, train_size) IS
    BEGIN
        IF (pixel_col >= train1_x - train_size) AND
         (pixel_col <= train1_x + train_size) AND
             (pixel_row >= train1_y - train_size) AND
             (pixel_row <= train1_y + train_size) THEN
                train1_on <= '1';
        ELSE
            train1_on <= '0';
        END IF;
        END PROCESS;
        -- process to move train1 once every frame (i.e. once every vsync pulse)
        -- Process to move train1 once every frame (i.e. once every vsync pulse)
mtrain1 : PROCESS
BEGIN
    WAIT UNTIL rising_edge(v_sync);
    -- Check if train1 reaches the bottom of the screen
    IF game_active = '1' THEN
        IF train1_y + train_size >= 800 THEN
            train1_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train1 to top
        ELSIF reset = '1' THEN
            train1_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train1 to top
        ELSE
            train1_y <= train1_y + train1_y_motion; -- Move train1 down
        END IF;
    END IF;
END PROCESS;

t2draw : PROCESS (train2_x, train2_y, pixel_row, pixel_col, train_size) IS
BEGIN
    IF (pixel_col >= train2_x - train_size) AND
       (pixel_col <= train2_x + train_size) AND
       (pixel_row >= train2_y - train_size) AND
       (pixel_row <= train2_y + train_size) THEN
        train2_on <= '1';
    ELSE
        train2_on <= '0';
    END IF;
END PROCESS;

-- Process to move train2 once every frame (i.e. once every vsync pulse)
mtrain2 : PROCESS
BEGIN
    WAIT UNTIL rising_edge(v_sync);
    -- Check if train2 reaches the bottom of the screen
    IF game_active = '1' THEN
        IF train2_y + train_size >= 800 THEN
            train2_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train2 to top
        ELSIF reset = '1' THEN
            train2_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train2 to top
        ELSE
            train2_y <= train2_y + train2_y_motion; -- Move train2 down
        END IF;
    END IF;
END PROCESS;

t3draw : PROCESS (train3_x, train3_y, pixel_row, pixel_col, train_size) IS
BEGIN
    IF (pixel_col >= train3_x - train_size) AND
       (pixel_col <= train3_x + train_size) AND
       (pixel_row >= train3_y - train_size) AND
       (pixel_row <= train3_y + train_size) THEN
        train3_on <= '1';
    ELSE
        train3_on <= '0';
    END IF;
END PROCESS;

-- Process to move train3 once every frame (i.e. once every vsync pulse)
mtrain3 : PROCESS
BEGIN
    WAIT UNTIL rising_edge(v_sync);
    -- Check if train3 reaches the bottom of the screen
    IF game_active = '1' THEN
        IF train3_y + train_size >= 800 THEN
            train3_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train3 to top
        ELSIF reset = '1' THEN
            train3_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset train3 to top
        ELSE
            train3_y <= train3_y + train3_y_motion; -- Move train3 down
        END IF;
    END IF;
END PROCESS;

	c1draw : PROCESS (coin1_x, coin1_y, pixel_row, pixel_col, r_var, coin1_xr) IS
	BEGIN
	IF r_var <= '0' then
	
		IF ((((conv_integer(pixel_row) - conv_integer(coin1_y))*(conv_integer(pixel_row) - conv_integer(coin1_y)))+((conv_integer(pixel_col) - conv_integer(coin1_x))*(conv_integer(pixel_col) - conv_integer(coin1_x))))<=(size*size)) THEN

				coin1_on <= '1';
		ELSE
			coin1_on <= '0';
			end if;
			else
					IF ((((conv_integer(pixel_row) - conv_integer(coin1_y))*(conv_integer(pixel_row) - conv_integer(coin1_y)))+((conv_integer(pixel_col) - conv_integer(coin1_xr))*(conv_integer(pixel_col) - conv_integer(coin1_xr))))<=(size*size)) THEN

				coin1_on <= '1';
		ELSE
			coin1_on <= '0';
			end if;
			end if;
			end process;
		c2draw : PROCESS (coin2_x, coin2_y, pixel_row, pixel_col, r_var, coin2_xr) IS
	BEGIN
	IF r_var <= '0' then
		IF ((((conv_integer(pixel_row) - conv_integer(coin2_y))*(conv_integer(pixel_row) - conv_integer(coin2_y)))+((conv_integer(pixel_col) - conv_integer(coin2_x))*(conv_integer(pixel_col) - conv_integer(coin2_x))))<=(size*size)) THEN

				coin2_on <= '1';
		ELSE
			coin2_on <= '0';
		end if;
		ELSE 
		IF ((((conv_integer(pixel_row) - conv_integer(coin2_y))*(conv_integer(pixel_row) - conv_integer(coin2_y)))+((conv_integer(pixel_col) - conv_integer(coin2_xr))*(conv_integer(pixel_col) - conv_integer(coin2_xr))))<=(size*size)) THEN

				coin2_on <= '1';
		ELSE
			coin2_on <= '0';
			end if;
			end if;
			end process;
			
	c1 : PROCESS
BEGIN
    WAIT UNTIL rising_edge(v_sync);
    IF game_active = '1' THEN
        IF coin1_y + coin_size >= 800 THEN
            coin1_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset coin1 to top
            --flagreset <= '1';
        ELSIF reset = '1' THEN
            
            --flagreset <= '1';
            coin1_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset coin1 to top
        ELSE
            coin1_y <= coin1_y + coin1_y_motion; -- Move coin1 down
            --flagreset <= '0';
        END IF;
    END IF;
END PROCESS;
	c2 : PROCESS
BEGIN
    WAIT UNTIL rising_edge(v_sync);
    IF game_active = '1' THEN
        IF coin2_y + coin_size >= 800 THEN
            coin2_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset coin2 to top
        ELSIF reset = '1' THEN           
            coin2_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset coin2 to top
        ELSE
            coin2_y <= coin2_y + coin2_y_motion; -- Move coin2 down
        END IF;
    END IF;
END PROCESS;
END BEHAVIORAL;
