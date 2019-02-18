module parking_system(clk, 
counter, c3, c2, c1, c0,
reservedSwitch, enterButton,
in0, in1, in2, in3,
red1, green1, yellow1, trig1, echo1,
red2, green2, yellow2, trig2, echo2,
red3, green3, yellow3, trig3, echo3,
red4, green4, yellow4, trig4, echo4,
trigIn, echoIn, trigOut, echoOut);

	output counter;
	output c3, c2, c1, c0;
	output red1, green1, yellow1, trig1;
	output red2, green2, yellow2, trig2;
	output red3, green3, yellow3, trig3;
	output red4, green4, yellow4, trig4;
	output trigIn, trigOut;
	
	input clk, reservedSwitch, enterButton;
	input in0, in1, in2, in3;
	input echo1, echo2;
	input echo3, echo4; 
	input echoIn, echoOut;
	 
	reg[7:0] counter;
	reg[7:0] c3, c2, c1, c0;
	reg reserved1, reserved2, reserved3, reserved4;
	reg unlocked1, unlocked2, unlocked3, unlocked4;
	parking_slot s1(red1, green1, yellow1, reserved1, trig1, echo1, clk);
	parking_slot s2(red2, green2, yellow2, reserved2, trig2, echo2, clk);
	parking_slot s3(red3, green3, yellow3, reserved3, trig3, echo3, clk);
	parking_slot s4(red4, green4, yellow4, reserved4, trig4, echo4, clk);
	
	wire detectedIn, detectedOut;
	ultrasonic inGate(detectedIn, trigIn, echoIn, clk);
	ultrasonic outGate(detectedOut, trigOut, echoOut, clk);
	
	parameter timerValue = 15 * 50000000; //15 * 1 second
	parameter refreshDisplayTime = 5 * 50000000;
	
	parameter zero = ~(8'b00111111), one = ~(8'b00000110), two = ~(8'b01011011), 
	three = ~(8'b01001111), four = ~(8'b01100110);
	
	reg[2:0] freeSpots = 4;
	integer timer1 = 0, timer2 = 0, timer3 = 0, timer4 = 0;
	integer displayTimer = 0;
	
	reg oldReservedSwitch;
	reg oldInGate, oldOutGate;
	reg oldReserved1, oldReserved2;
	reg oldReserved3, oldReserved4;
	integer pass, displayedPass, pass1, pass2, pass3, pass4;
	integer enteredPassword;
	
	initial
		begin
			oldReservedSwitch = reservedSwitch;
			oldInGate = detectedIn;
			oldOutGate = detectedOut;
			oldReserved1 = reserved1;
			oldReserved2 = reserved2;
			oldReserved3 = reserved3;
			oldReserved4 = reserved4;
			unlocked1 = 1;
			unlocked2 = 1;
			unlocked3 = 1;
			unlocked4 = 1;
			pass = 1;
			displayedPass = 0;
			c3 <= zero;
			c2 <= zero;
			c1 <= zero;
			c0 <= zero;
		end

	always @ (posedge clk)
		begin
		
			//refreshing the display
			if(displayTimer > 0)
				begin
					displayTimer = displayTimer - 1;
				end
			else
				begin
					displayedPass = 0;
				end
		
			//Applying a reservation
			
			if(reservedSwitch != oldReservedSwitch)
				begin
					oldReservedSwitch = reservedSwitch;
					pass = pass + 1;
					if(pass > 15)
						pass = 1;
					if(green1)
						begin
							timer1 <= timerValue;
							unlocked1 = 0;
							pass1 = pass;
							displayedPass = pass;
							displayTimer = refreshDisplayTime;
						end
					else if(green2)
						begin
							timer2 <= timerValue;
							unlocked2 = 0;
							pass2 = pass;
							displayedPass = pass;
							displayTimer = refreshDisplayTime;
						end
					else if(green3)
						begin
							timer3 <= timerValue;
							unlocked3 = 0;
							pass3 = pass;
							displayedPass = pass;
							displayTimer = refreshDisplayTime;
						end
					else if(green4)
						begin
							timer4 <= timerValue;
							unlocked4 = 0;
							pass4 = pass;
							displayedPass = pass;
							displayTimer = refreshDisplayTime;
						end
				end
			
			//Checking in a reservation
			
			if(enterButton == 0)
				begin
					enteredPassword = in0 + in1*2 + in2*4 + in3*8;
					if(yellow1 && enteredPassword == pass1)
						begin
							timer1 <= 0;
							unlocked1 = 1;
						end
					else if(yellow2 && enteredPassword == pass2)
						begin
							timer2 <= 0;
							unlocked2 = 1;
						end
					else if(yellow3 && enteredPassword == pass3)
						begin
							timer3 <= 0;
							unlocked3 = 1;
						end
					else if(yellow4 && enteredPassword == pass4)
						begin
							timer4 <= 0;
							unlocked4 = 1;
						end
				end
			
			
			//Checking the timers for reservations
			
			if(timer1 > 0 && !unlocked1)
				begin
					reserved1 <= 1;
					timer1 <= timer1 - 1;
				end
			else
				reserved1 <= 0;
				
			if(timer2 > 0 && !unlocked2)
				begin
					reserved2 <= 1;
					timer2 <= timer2 - 1;
				end
			else
				reserved2 <= 0;
				
			if(timer3 > 0 && !unlocked3)
				begin
					reserved3 <= 1;
					timer3 <= timer3 - 1;
				end
			else
				reserved3 <= 0;
				
			if(timer4 > 0 && !unlocked4)
				begin
					reserved4 <= 1;
					timer4 <= timer4 - 1;
				end
			else
				reserved4 <= 0;
				
			//incrementing and decrementing the freespots 
			//based on gates and reservations
			
			if(oldInGate != detectedIn)
				begin
					oldInGate = detectedIn;
					if(detectedIn == 1)
						begin
							if(freeSpots > 0)
								freeSpots = freeSpots - 1;
						end
				end
				
			if(oldOutGate != detectedOut)
				begin
					oldOutGate = detectedOut;
					if(detectedOut == 1)
						begin
							if(freeSpots < 4)
								freeSpots = freeSpots + 1;
						end
				end
				
			if(oldReserved1 != reserved1)
				begin
					oldReserved1 = reserved1;
					if(reserved1 == 1)
						begin
							if(freeSpots > 0)
								freeSpots = freeSpots - 1;
						end
					else
						begin
							if(freeSpots < 4)
								freeSpots = freeSpots + 1;
						end
				end
				
			if(oldReserved2 != reserved2)
				begin
					oldReserved2 = reserved2;
					if(reserved2 == 1)
						begin
							if(freeSpots > 0)
								freeSpots = freeSpots - 1;
						end
					else
						begin
							if(freeSpots < 4)
								freeSpots = freeSpots + 1;
						end
				end
				
			if(oldReserved3 != reserved3)
				begin
					oldReserved3 = reserved3;
					if(reserved3 == 1)
						begin
							if(freeSpots > 0)
								freeSpots = freeSpots - 1;
						end
					else
						begin
							if(freeSpots < 4)
								freeSpots = freeSpots + 1;
						end
				end
				
			if(oldReserved4 != reserved4)
				begin
					oldReserved4 = reserved4;
					if(reserved4 == 1)
						begin
							if(freeSpots > 0)
								freeSpots = freeSpots - 1;
						end
					else
						begin
							if(freeSpots < 4)
								freeSpots = freeSpots + 1;
						end
				end
			
		end
  
	always @ (freeSpots)
		begin
			case(freeSpots)
				0 : counter = zero;
				1 : counter = one;
				2 : counter = two;
				3 : counter = three;
				4 : counter = four;
			endcase
		end
		
	always @ (displayedPass)
		begin
			case(displayedPass)
				0 : begin c3 <= zero; c2 <= zero; c1 <= zero; c0 <= zero; end
				1 : begin c3 <= zero; c2 <= zero; c1 <= zero; c0 <= one; end
				2 : begin c3 <= zero; c2 <= zero; c1 <= one; c0 <= zero; end
				3 : begin c3 <= zero; c2 <= zero; c1 <= one; c0 <= one; end
				4 : begin c3 <= zero; c2 <= one; c1 <= zero; c0 <= zero; end
				5 : begin c3 <= zero; c2 <= one; c1 <= zero; c0 <= one; end
				6 : begin c3 <= zero; c2 <= one; c1 <= one; c0 <= zero; end
				7 : begin c3 <= zero; c2 <= one; c1 <= one; c0 <= one; end
				8 : begin c3 <= one; c2 <= zero; c1 <= zero; c0 <= zero; end
				9 : begin c3 <= one; c2 <= zero; c1 <= zero; c0 <= one; end
				10 : begin c3 <= one; c2 <= zero; c1 <= one; c0 <= zero; end
				11 : begin c3 <= one; c2 <= zero; c1 <= one; c0 <= one; end
				12 : begin c3 <= one; c2 <= one; c1 <= zero; c0 <= zero; end
				13 : begin c3 <= one; c2 <= one; c1 <= zero; c0 <= one; end
				14 : begin c3 <= one; c2 <= one; c1 <= one; c0 <= zero; end
				15 : begin c3 <= one; c2 <= one; c1 <= one; c0 <= one; end
			endcase
		end
	
endmodule

module ultrasonic(detected, trig, echo, clk);
	output detected, trig;
	input echo, clk;
	reg detected, trig;
	integer cycle, dist_cycle, dist; 
	parameter trigger_time = 500, refresh_time = 25000000;
	initial
		begin
			cycle <= 0;
			dist <= 0;
			dist_cycle <= 0;
			detected <= 0;
		end
	
	always @(posedge clk)
		begin
			cycle = cycle + 1;
			if(cycle < trigger_time)
				trig <= 1;
			else if(cycle < refresh_time)
				begin
					trig <= 0;
					if(echo)
						dist_cycle = dist_cycle + 1;
				end
			else
				begin
					dist = (dist_cycle * 34300) / (100000000);
					if(2 < dist && dist < 10)
						detected <= 1;
					else
						detected <= 0;
					cycle <= 0;
					dist_cycle <= 0;
				end
		end
		
endmodule

module parking_slot(red, green, yellow, reserved, trig, echo, clk);
	output red, green, yellow, trig;
	input echo, reserved, clk;
	reg red, green, yellow;
	wire detected;
	ultrasonic sensor(detected, trig, echo, clk);
	initial
		begin
			red <= 0;
			green <= 0;
			yellow <= 0;
		end
	always @(posedge clk)
		begin
			if(reserved)
				begin
					yellow <= 1;
					green <= 0;
					red <= 0;
				end
			else
				begin
					yellow <= 0;
					if(detected)
						begin
							red <= 1;
							green <= 0;
						end
					else
						begin
							red <= 0;
							green <= 1;
						end
				end
		end

endmodule
