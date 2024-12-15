module Tetris(
    input wire clk,           // System clock
    input wire btn_left,      // Left button
    input wire btn_right,     // Right button
    input wire pause,         // Pause button
    input wire btn_fast,      // fast button
	input wire btn_rotate,	  // Rotate button
	input reset,			  // Reset button
    output reg [5:0] row,     // Active row output
    output reg [5:0] col,     // Active column output
    output reg [6:0] seg,	  // seven segment display
    output reg game_over,	  // Game over LED Blink
    output reg LED,
    inout LED_COM,
    output de1,
    output de2,
    output de3
);

    reg [2:0] dot_row;        // Current row position of the block (top-left corner of 2x2 block)
    reg [2:0] dot_col;        // Current column position of the block
    reg [21:0] count_0;       // Counter for button control clock
    reg [1:0] count_1;        // Counter for falling clock
	reg [2:0] count_2;		  // Counter for row remove
	reg [6:0] count_3;		  // Counter for display
    reg [5:0] state [5:0];    // 6*6 matrix representing stored blocks
    reg [2:0] scan_row;       // Current row being scanned for display
    reg clk_0;                // Clock output for main always block
    
	reg k;					  // Controlling rotate option
	
	// Block patterns for 2x2 shapes (stored as two rows for easier manipulation)
	
    reg [5:0] block_pattern[1:0];  // Stores 2x2 shape pattern in two row 
    reg [2:0] shape_counter;       // To cycle through shapes sequentially
	reg [2:0] score;			   // Counting Score
	integer i;

    initial begin
        dot_row = 0;                // Start the block at the top row
        dot_col = 3;                // Start the block in the center column

        // Initialize state to all 0s
        state[0] = 6'b000000;
        state[1] = 6'b000000;
        state[2] = 6'b000000;
        state[3] = 6'b000000;
        state[4] = 6'b000000;
        state[5] = 6'b000000;
        
        
        clk_0 = 0;
        shape_counter = 0;  // Start with the first shape
		count_1=0;
		count_2=0;
		count_3=0;
		score=0;
		game_over=0;
		LED =0;
		
		// Initialize the first shape pattern
        block_pattern[0] = 6'b000011; // Square shape, row 1: 
        block_pattern[1] = 6'b000011; // Square shape, row 2: 
		
		k=0;
    end
	
	assign de1=1;
	assign de2=0;
	assign de3=1;
	assign LED_COM=1;

    // Clock divider for button control (5 Hz)
    always @(posedge clk) 
    begin
        if (!pause) 
        begin           			
            count_0 <= count_0 + 21'b1;
            if (count_0 >= 800000) 
            begin 
                count_0 <= 0;
                clk_0 <= ~clk_0;    
			end
        end
    end

    // Sequential shape selection and block falling logic
    always @(posedge clk_0) 
	begin
	
		if(reset)
		begin
			state[0] <= 6'b000000;
			state[1] <= 6'b000000;
			state[2] <= 6'b000000;
			state[3] <= 6'b000000;
			state[4] <= 6'b000000;
			state[5] <= 6'b000000;
			
			dot_row <= 0;
			dot_col <= 3;
			score=0;
			game_over=0;
			LED <=0;
			
		end
  
		state[dot_row]   <= state[dot_row] | (block_pattern[0] << dot_col);
		state[dot_row+1] <= state[dot_row+1] | (block_pattern[1] << dot_col);
		
		// Filled row remove
		
		count_2<=count_2+2'b1;
		if(count_2>3)
		begin
			count_1<=0;
			
			if(game_over)
			begin
				LED<=~LED;
			end
			
			if (state[2] == 6'b111111) 
			begin
				score=score+1;
				for ( i=2 ;i>1 ; i=i-1)
				begin
					state[i]<=state[i-1];
				end
			end
			
			if (state[3] == 6'b111111) 
			begin
				score=score+1;
				for ( i=3 ;i>1 ; i=i-1)
				begin
					state[i]<=state[i-1];
				end
			end
			
			if (state[4] == 6'b111111) 
			begin
				score=score+1;
				for ( i=4 ;i>1 ; i=i-1)
				begin
					state[i]<=state[i-1];
				end
			end
			
			if (state[5] == 6'b111111) 
			begin
				score=score+1;
				for ( i=5 ;i>1 ; i=i-1)
				begin
					state[i]<=state[i-1];
				end
			end
		end
		
        if (btn_left == 0 && dot_col > 0 && (state[dot_row + 1] & (block_pattern[1] << (dot_col - 1))) == 0) 
		begin
			dot_col <= dot_col - 3'b1;
			state[dot_row]     <= state[dot_row]     & ~(block_pattern[0] << dot_col);
			state[dot_row + 1] <= state[dot_row + 1] & ~(block_pattern[1] << dot_col);
		end
		
		if (btn_right == 0 && dot_col < 4 && (state[dot_row + 1] & (block_pattern[1] << (dot_col + 1))) == 0) 
		begin
			dot_col <= dot_col + 3'b1;
			state[dot_row]     <= state[dot_row]     & ~(block_pattern[0] << dot_col);
			state[dot_row + 1] <= state[dot_row + 1] & ~(block_pattern[1] << dot_col);
		end
		
		if(btn_rotate)
		begin
			case (shape_counter)
			
			1: begin // L-shape
				if(k)
				begin
					block_pattern[0] <= 6'b00000001;
					block_pattern[1] <= 6'b00000011;
				end
				else
				begin
					block_pattern[0] <= 6'b00000010;
					block_pattern[1] <= 6'b00000011;
				end
			end
			
			2: begin // I-shape
				if(k)
				begin
					block_pattern[0] <= 6'b00000001;
					block_pattern[1] <= 6'b00000001;
				end
				else
				begin
					block_pattern[0] <= 6'b00000000;
					block_pattern[1] <= 6'b00000011;
				end
			end
			
			3: begin // I-shape
				if(k)
				begin
					block_pattern[0] <= 6'b00000000;
					block_pattern[1] <= 6'b00000011;
				end
				else
				begin
					block_pattern[0] <= 6'b00000001;
					block_pattern[1] <= 6'b00000001;
				end
			end
			
			4: begin // Reverse L-shape
				if(k)
				begin
					block_pattern[0] <= 6'b00000011;
					block_pattern[1] <= 6'b00000001;
				end
				else
				begin
					block_pattern[0] <= 6'b00000011;
					block_pattern[1] <= 6'b00000010;
				end
			end
			endcase
			k=~k;
			state[dot_row]     <= state[dot_row]     & ~(block_pattern[0] << dot_col);
			state[dot_row + 1] <= state[dot_row + 1] & ~(block_pattern[1] << dot_col);
			
		end

		// Vertical movement (falling)
		if(btn_fast)
		begin
			count_1<=2'b11;
		end
		else
		begin
			count_1<=count_1+2'b1;
		end
		
		if (count_1>=3)
		begin
			count_1<=0;
			
			// Check if the 2x2 block can fall
			if (dot_row <4 &&(state[dot_row + 2] & (block_pattern[1] << dot_col)) == 0) 
			begin
				dot_row <= dot_row + 1;
				state[dot_row]     <= state[dot_row]     & ~(block_pattern[0] << dot_col);
				state[dot_row + 1] <= state[dot_row + 1] & ~(block_pattern[1] << dot_col);
			end
			
			else 
			begin
				if(!dot_row)
				begin
					score=0;
					game_over=1;
				end
				dot_row <= 0;
				dot_col <= 3;
				
				shape_counter = (shape_counter + 3'b1) % 5; // Cycle through shapes
				k=0;
				
				case (shape_counter)
				0: begin // Square shape
					block_pattern[0] <= 6'b00000011;
					block_pattern[1] <= 6'b00000011;
				end
				1: begin // L-shape
					block_pattern[0] <= 6'b00000001;
					block_pattern[1] <= 6'b00000011;
				end
				2: begin // I-shape
					block_pattern[0] <= 6'b00000001;
					block_pattern[1] <= 6'b00000001;
				end
				3: begin // Dash shape
					block_pattern[0] <= 6'b00000000;
					block_pattern[1] <= 6'b00000011;
				end
				4: begin // Reverse L-shape
					block_pattern[0] <= 6'b00000011;
					block_pattern[1] <= 6'b00000001;
				end
				endcase
			end
		end
			

            
	end
	
	
	always @(score) 
	begin 
		case (score) //case statement, we have assumed ‘1’ means turning led off 
			0 : seg = ~7'b0000001; //abcdefg 
			1 : seg = ~7'b1001111; 
			2 : seg = ~7'b0010010; 
			3 : seg = ~7'b0000110; 
			4 : seg = ~7'b1001100; 
			5 : seg = ~7'b0100100; 
			6 : seg = ~7'b0100000; 
			7 : seg = ~7'b0001111; 
			8 : seg = ~7'b0000000; 
			9 : seg = ~7'b0000100; 
			//switch off 7 segment character when the bcd digit is not a decimal number. 
			default : seg = ~7'b1111111;  
		endcase 
	end


    // Display control
    always @(posedge clk) begin
        // Scanning through each row
		if(&count_3) begin
			row <= 8'b1 << scan_row;   // Active low row select
			col <= state[scan_row];    // Output the corresponding pattern for the selected row
			// Increment scan_row for next row
			scan_row <= scan_row + 3'b1;
		end
		count_3 <= count_3 +7'b1;
	end

endmodule