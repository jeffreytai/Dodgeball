`timescale 1ns/1ps

module dodgeball_tb;
	reg clk, rst;
	wire [7:0] rgb;
	wire hsync, vsync;
	wire [11:0] x, y;
	dodgeball UUT(.clk_100mhz(clk),.rst(rst),.hsync(hsync), .vsync(vsync), .rgb(rgb));
	vga_sync vga0(.clk(clk),.hsync(hsync), .vsync(vsync),.x(x), .y(y));
	
	initial
	begin
		clk <= 1'b0;
		rst <= 1'b1;
	end
	
	always
	begin
		#5 clk <= ~clk;
		rst <= 1'b0;
	end
	
endmodule
