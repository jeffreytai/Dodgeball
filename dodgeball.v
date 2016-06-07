
module dodgeball(clk_100mhz,rst,pause,btn_up,btn_left,btn_down,btn_right,sw,CA,CB,CC,CD,CE,CF,CG,AN0,AN1,AN2,AN3,hsync,vsync,rgb);
	input clk_100mhz, rst, pause, btn_up, btn_left, btn_down, btn_right;
	input [2:0] sw;
	output CA,CB,CC,CD,CE,CF,CG,AN0,AN1,AN2,AN3,hsync,vsync;
	output [7:0] rgb;
	wire clk_1hz, tc1, tc2, tc3;
	wire [3:0] val1, val2, val3, val4;
	wire [11:0] x, y;
	wire up, down, left, right;
	wire [1:0] random;
	
	wire gameover;
	
	vga_sync vga0(.clk(clk_100mhz),.hsync(hsync), .vsync(vsync),.x(x), .y(y));
	
	clock_1hz c1(.clk_100mhz(clk_100mhz),.clk_1hz(clk_1hz),.rst(rst),.random(random),.gameover(gameover));
	
	counter10 ctr1(.clk(clk_1hz),.rst(rst),.pause(pause),.val(val1),.tc(tc1));
	counter10 ctr2(.clk(tc1),.rst(rst),.pause(pause),.val(val2),.tc(tc2));
	counter10 ctr3(.clk(tc2),.rst(rst),.pause(pause),.val(val3),.tc(tc3));
	counter10 ctr4(.clk(tc3),.rst(rst),.pause(pause),.val(val4));
	
	//debouncer d1(.clk_100mhz(clk_100mhz), .in(btn_up), .out(up), .rst(rst));
	//debouncer d2(.clk_100mhz(clk_100mhz), .in(btn_down), .out(down), .rst(rst));
	//debouncer d3(.clk_100mhz(clk_100mhz), .in(btn_left), .out(left), .rst(rst));
	//debouncer d4(.clk_100mhz(clk_100mhz), .in(btn_right), .out(right), .rst(rst));
	
	
	
	display disp(.clk_100mhz(clk_100mhz),.rst(rst),.val1(val1),.val2(val2),.val3(val3),.val4(val4),.CA(CA),.CB(CB),.CC(CC),.CD(CD),.CE(CE),.CF(CF),.CG(CG),.AN0(AN0),.AN1(AN1),.AN2(AN2),.AN3(AN3));
	graphic grap(.clk_100mhz(clk_100mhz),.rst(rst), .pause(pause), .sw(sw), .up(btn_up), .down(btn_down), .left(btn_left), .right(btn_right), .x(x), .y(y), .rgb(rgb),.random(random),.gameover(gameover));

endmodule


module clock_1hz(clk_100mhz,clk_1hz,rst,random,gameover);

	input clk_100mhz, rst, gameover;
	output reg clk_1hz;
	output reg [1:0] random;
	reg [25:0] a;

	always @ (posedge clk_100mhz)
	begin
		if (rst)
		begin
			a <= 26'b000000000000000000000000000;
			clk_1hz <= 1'b1;
		end
		else if (gameover)
			a <= a;
		else if (a == 26'b10111110101111000010000000)
		begin
			a <= 26'b000000000000000000000000000;
			clk_1hz <= ~clk_1hz;
		end
		else
		begin
			a <= a + 1'b1;
			random[1] <= a[1];
			random[0] <= a[0];
		end
	end
	
endmodule 



module counter10(clk,rst,pause,val,tc);
	
	input clk, rst, pause;
	output reg [3:0] val;
	output reg tc;
	
	always @ (posedge clk or posedge rst or posedge pause)
	begin
		if(rst)
		begin
			val <= 4'b0000;
			tc <= 1'b0;
		end
		else if(pause)
			val <= val;
		else if(val == 4'b1001)
		begin
			val <= 4'b0000;
			tc <= 1'b1;
		end
		else
		begin
			val <= val + 1'b1;
			tc <= 1'b0;
		end 
	end
	
endmodule


module debouncer(clk_100mhz, in, out, rst);
	input clk_100mhz, in, rst;
	output reg out;
	reg [16:0] counter;
	reg clk_763hz;
	
	always @ (posedge clk_100mhz)
	begin
		if (counter == 17'b11111111111111111)
		begin
			clk_763hz <= 1'b1;
			counter <= 17'b00000000000000000;
		end
		else
		begin
			counter <= counter + 1'b1;
			clk_763hz <= 1'b0;
		end
	end
	
	reg [2:0] step_d;
	
	always @ (posedge clk_100mhz)
	begin
     if (rst)
       begin
          step_d[2:0]  <= 0;
       end
     else if (clk_763hz)
       begin
          step_d[2:0]  <= {in, step_d[2:1]};
       end
	end
	
	always @ (posedge clk_100mhz)
     if (rst)
       out <= 1'b0;
     else
       out <= ~step_d[0] & step_d[1] & clk_763hz;
	
	
endmodule

module display(clk_100mhz,rst,val1,val2,val3,val4,CA,CB,CC,CD,CE,CF,CG,AN0,AN1,AN2,AN3);
	input clk_100mhz, rst;
	input [3:0] val1, val2, val3, val4;
	output CA,CB,CC,CD,CE,CF,CG;
	output reg AN0,AN1,AN2,AN3;
	reg [3:0] val;
	
	decoder my_decoder(.bval(val),.CA(CA),.CB(CB),.CC(CC),.CD(CD),.CE(CE),.CF(CF),.CG(CG));
	
	wire clk_250hz;
	clock_250hz my_clock(.clk_100mhz(clk_100mhz),.clk_250hz(clk_250hz),.rst(rst));
	
	reg [1:0] counter;
	
	
	always @ (posedge clk_250hz or posedge rst)
	begin
		if(rst)
			counter <= 2'b00;
		else
		begin
			if (counter == 2'b00)
			begin
				val <= val1;
				AN0 <= 1'b0;
				AN1 <= 1'b1;
				AN2 <= 1'b1;
				AN3 <= 1'b1;
				counter <= counter + 1'b1;
			end
			else if (counter == 2'b01)
			begin
				val <= val2;
				AN0 <= 1'b1;
				AN1 <= 1'b0;
				AN2 <= 1'b1;
				AN3 <= 1'b1;
				counter <= counter + 1'b1;
			end
			else if (counter == 2'b10)
			begin
				val <= val3;
				AN0 <= 1'b1;
				AN1 <= 1'b1;
				AN2 <= 1'b0;
				AN3 <= 1'b1;
				counter <= counter + 1'b1;
			end
			else
			begin
				counter <= 2'b00;
				val <= val4;
				AN0 <= 1'b1;
				AN1 <= 1'b1;
				AN2 <= 1'b1;
				AN3 <= 1'b0;
			end	
		end
	end
endmodule


module clock_250hz(clk_100mhz,clk_250hz,rst);

	input clk_100mhz, rst;
	output reg clk_250hz;
	reg [17:0] a;
	always @ (posedge clk_100mhz)
	begin
		if (rst)
		begin
			a <= 18'b0000000000000000000;
			clk_250hz <= 1'b1;
		end
		else if (a == 18'b110000110101000000)
		begin
			a <= 18'b0000000000000000000;
			clk_250hz <= ~clk_250hz;
		end
		else
			a <= a + 1'b1;
	end
	
endmodule 


module decoder(bval,CA,CB,CC,CD,CE,CF,CG);

	input [3:0] bval;
	output reg CA,CB,CC,CD,CE,CF,CG;

	always @ (*)
	begin
	if (bval == 4'b0000)
		begin
			CA = 0;
			CB = 0;
			CC = 0;
			CD = 0; 
			CE = 0;
			CF = 0;
			CG = 1;
		end
		
		else if (bval == 4'b0001)
		begin
			CA = 1;
			CB = 0;
			CC = 0;
			CD = 1; 
			CE = 1;
			CF = 1;
			CG = 1;
		end
		
		else if (bval == 4'b0010)
		begin
			CA = 0;
			CB = 0;
			CC = 1;
			CD = 0; 
			CE = 0;
			CF = 1;
			CG = 0;
		end
		
		else if (bval == 4'b0011)
		begin
			CA = 0;
			CB = 0;
			CC = 0;
			CD = 0; 
			CE = 1;
			CF = 1;
			CG = 0;
		end
		
		else if (bval == 4'b0100)
		begin
			CA = 1;
			CB = 0;
			CC = 0;
			CD = 1; 
			CE = 1;
			CF = 0;
			CG = 0;
		end
		
		else if (bval == 4'b0101)
		begin
			CA = 0;
			CB = 1;
			CC = 0;
			CD = 0; 
			CE = 1;
			CF = 0;
			CG = 0;
		end
		
		else if (bval == 4'b0110)
		begin
			CA = 0;
			CB = 1;
			CC = 0;
			CD = 0; 
			CE = 0;
			CF = 0;
			CG = 0;
		end
		
		else if (bval == 4'b0111)
		begin
			CA = 0;
			CB = 0;
			CC = 0;
			CD = 1; 
			CE = 1;
			CF = 1;
			CG = 1;
		end
		
		else if (bval == 4'b1000)
		begin
			CA = 0;
			CB = 0;
			CC = 0;
			CD = 0; 
			CE = 0;
			CF = 0;
			CG = 0;
		end
		
		else if (bval == 4'b1001)
		begin
			CA = 0;
			CB = 0;
			CC = 0;
			CD = 1; 
			CE = 1;
			CF = 0;
			CG = 0;
		end
		
		else
		begin
			CA = 1;
			CB = 1;
			CC = 1;
			CD = 1; 
			CE = 1;
			CF = 1;
			CG = 1;
		end
	end

endmodule