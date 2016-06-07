`define bound_up 0
`define bound_down 480
`define bound_left 0
`define bound_right 640

module graphic(clk_100mhz, rst, pause, sw, up, down, left, right, x, y, rgb, random, gameover);
	input clk_100mhz, rst, pause, up, down, left, right;
	input [11:0] x, y;
	input [2:0] sw, random;
	output reg [7:0] rgb;
	output reg gameover;
	
	parameter player_color			= 8'b11111111;
	parameter background_color		= 8'b01001000;
	parameter null_color				= 8'b00000000;
	parameter ball_color				= 8'b11111100;
	
	parameter player_r		= 12'd10;
	parameter ball_r			= 12'd10;
	parameter collision_r   = 12'd20;
	
	parameter center_x 		= 12'd320;
	parameter center_y 		= 12'd240;
	parameter bound_up 		= 12'd0;
	parameter bound_down 	= 12'd480;
	parameter bound_left 	= 12'd0;
	parameter bound_right 	= 12'd640;
	
	reg [11:0] player_x, player_y;
	reg [11:0] ball1_x, ball1_y;
	reg [11:0] ball2_x, ball2_y;
	reg [11:0] ball3_x, ball3_y;
	reg [11:0] ball4_x, ball4_y;
	reg [11:0] ball5_x, ball5_y;
	
	reg [2:0] dir1, dir2, dir3, dir4, dir5;
	
	
	reg [2:0] new_dir1, new_dir2, new_dir3, new_dir4, new_dir5;
	
	wire [5:1] collision_ret;
	
	inBall collision1(.ballX(ball1_x), .ballY(ball1_y), .posX(player_x), .posY(player_y), .rad(collision_r), .ret(collision_ret[1]));
	inBall collision2(.ballX(ball2_x), .ballY(ball2_y), .posX(player_x), .posY(player_y), .rad(collision_r), .ret(collision_ret[2]));
	inBall collision3(.ballX(ball3_x), .ballY(ball3_y), .posX(player_x), .posY(player_y), .rad(collision_r), .ret(collision_ret[3]));
	inBall collision4(.ballX(ball4_x), .ballY(ball4_y), .posX(player_x), .posY(player_y), .rad(collision_r), .ret(collision_ret[4]));
	inBall collision5(.ballX(ball5_x), .ballY(ball5_y), .posX(player_x), .posY(player_y), .rad(collision_r), .ret(collision_ret[5]));

	wire collision_happened;
	
	assign collision_happened = collision_ret[1] || collision_ret[2] || collision_ret[3] || collision_ret[4] || collision_ret[5];
	
	
	wire clk = (x == 11'd0 && y == 11'd0);
	
	always @ (posedge clk or posedge rst)
	begin
		if (rst)
		begin
			player_x <= center_x;
			player_y <= center_y;
		end
		else if (gameover)
			gameover <= gameover;
		else if (up && (player_y - player_r > bound_up))
			player_y <= player_y - 1'd1;
		else if (down && (player_y + player_r < bound_down))
			player_y <= player_y + 1'd1;
		else if (left && (player_x - player_r > bound_left))
			player_x <= player_x - 1'd1;
		else if (right && (player_x + player_r < bound_right))
			player_x <= player_x + 1'd1;
	end
	
	
	always @ (posedge clk or posedge rst)
	begin
		if (rst)
		begin
			ball1_x <= 12'd50;
			ball2_x <= 12'd50;
			ball3_x <= 12'd590;
			ball4_x <= 12'd590;
			ball5_x <= 12'd50 + random*10;
			ball1_y <= 12'd30;
			ball2_y <= 12'd450;
			ball3_y <= 12'd30;
			ball4_y <= 12'd450;
			ball5_y <= 12'd150 + random*10;
			dir1 <= random[2:1];
			dir2 <= random[1:0];
			dir3 <= random[2:1];
			dir4 <= random[1:0];
			dir5 <= random[2:1];
			gameover <= 0;
		end
		else if (gameover)
			gameover <= gameover;
		else if (collision_happened)
		begin
			gameover <= 1;
		end
		else
		begin
			// Ball 1
			if (dir1 == 2'b00) //left-up
			begin
				ball1_x <= ball1_x - 1;
				ball1_y <= ball1_y - 1;
			end
			else if (dir1 == 2'b01) //left-down
			begin
				ball1_x <= ball1_x - 1;
				ball1_y <= ball1_y + 1;
			end
			else if (dir1 == 2'b10) //right-up
			begin
				ball1_x <= ball1_x + 1;
				ball1_y <= ball1_y - 1;
			end 
			else //dir == 11, right-down
			begin
				ball1_x <= ball1_x + 1;
				ball1_y <= ball1_y + 1;
			end
			
			if(ball1_y - ball_r <= bound_up)
			begin
				dir1[0] <= 1;
				ball1_y <= ball1_y + 1;
			end
			else if(ball1_y + ball_r >= bound_down)
			begin
				dir1[0] <= 0;
				ball1_y <= ball1_y - 1;
			end
			else
				dir1[0] <= dir1[0];
			
			if (ball1_x - ball_r <= bound_left)
			begin
				dir1[1] <= 1;
				ball1_x <= ball1_x + 1;
			end
			else if(ball1_x + ball_r >= bound_right)
			begin
				dir1[1] <= 0;
				ball1_x <= ball1_x - 1;
			end
			else
				dir1[1] <= dir1[1];
			
			// Ball 2
			if (dir2 == 2'b00) //left-up
			begin
				ball2_x <= ball2_x - 1;
				ball2_y <= ball2_y - 1;
			end
			else if (dir2 == 2'b01) //left-down
			begin
				ball2_x <= ball2_x - 1;
				ball2_y <= ball2_y + 1;
			end
			else if (dir2 == 2'b10) //right-up
			begin
				ball2_x <= ball2_x + 1;
				ball2_y <= ball2_y - 1;
			end 
			else //dir == 11, right-down
			begin
				ball2_x <= ball2_x + 1;
				ball2_y <= ball2_y + 1;
			end
			
			if(ball2_y - ball_r <= bound_up)
			begin
				dir2[0] <= 1;
				ball2_y <= ball2_y + 1;
			end
			else if(ball2_y + ball_r >= bound_down)
			begin
				dir2[0] <= 0;
				ball2_y <= ball2_y - 1;
			end
			else
				dir2[0] <= dir2[0];
			
			if (ball2_x - ball_r <= bound_left)
			begin
				dir2[1] <= 1;
				ball2_x <= ball2_x + 1;
			end
			else if(ball2_x + ball_r >= bound_right)
			begin
				dir2[1] <= 0;
				ball2_x <= ball2_x - 1;
			end
			else
				dir2[1] <= dir2[1];
				
				
			// Ball 3
			if (dir3 == 2'b00) //left-up
			begin
				ball3_x <= ball3_x - 1;
				ball3_y <= ball3_y - 1;
			end
			else if (dir3 == 2'b01) //left-down
			begin
				ball3_x <= ball3_x - 1;
				ball3_y <= ball3_y + 1;
			end
			else if (dir3 == 2'b10) //right-up
			begin
				ball3_x <= ball3_x + 1;
				ball3_y <= ball3_y - 1;
			end 
			else //dir == 11, right-down
			begin
				ball3_x <= ball3_x + 1;
				ball3_y <= ball3_y + 1;
			end
			
			if(ball3_y - ball_r <= bound_up)
			begin
				dir3[0] <= 1;
				ball3_y <= ball3_y + 1;
			end
			else if(ball3_y + ball_r >= bound_down)
			begin
				dir3[0] <= 0;
				ball3_y <= ball3_y - 1;
			end
			else
				dir3[0] <= dir3[0];
			
			if (ball3_x - ball_r <= bound_left)
			begin
				dir3[1] <= 1;
				ball3_x <= ball3_x + 1;
			end
			else if(ball3_x + ball_r >= bound_right)
			begin
				dir3[1] <= 0;
				ball3_x <= ball3_x - 1;
			end
			else
				dir3[1] <= dir3[1];
			
			
			// Ball 4
			if (dir4 == 2'b00) //left-up
			begin
				ball4_x <= ball4_x - 1;
				ball4_y <= ball4_y - 1;
			end
			else if (dir4 == 2'b01) //left-down
			begin
				ball4_x <= ball4_x - 1;
				ball4_y <= ball4_y + 1;
			end
			else if (dir4 == 2'b10) //right-up
			begin
				ball4_x <= ball4_x + 1;
				ball4_y <= ball4_y - 1;
			end 
			else //dir == 11, right-down
			begin
				ball4_x <= ball4_x + 1;
				ball4_y <= ball4_y + 1;
			end
			
			if(ball4_y - ball_r <= bound_up)
			begin
				dir4[0] <= 1;
				ball4_y <= ball4_y + 1;
			end
			
			if(ball4_y + ball_r >= bound_down)
			begin
				dir4[0] <= 0;
				ball4_y <= ball4_y - 1;
			end
			
			if (ball4_x - ball_r <= bound_left)
			begin
				dir4[1] <= 1;
				ball4_x <= ball4_x + 1;
			end
			
			if(ball4_x + ball_r >= bound_right)
			begin
				dir4[1] <= 0;
				ball4_x <= ball4_x - 1;
			end

			
			// Ball 5
			if (dir5 == 2'b00) //left-up
			begin
				ball5_x <= ball5_x - 1;
				ball5_y <= ball5_y - 1;
			end
			else if (dir5 == 2'b01) //left-down
			begin
				ball5_x <= ball5_x - 1;
				ball5_y <= ball5_y + 1;
			end
			else if (dir5 == 2'b10) //right-up
			begin
				ball5_x <= ball5_x + 1;
				ball5_y <= ball5_y - 1;
			end 
			else //dir == 11, right-down
			begin
				ball5_x <= ball5_x + 1;
				ball5_y <= ball5_y + 1;
			end
			
			if(ball5_y - ball_r <= bound_up)
			begin
				dir5[0] <= 1;
				ball5_y <= ball5_y + 1;
			end
			
			if(ball5_y + ball_r >= bound_down)
			begin
				dir5[0] <= 0;
				ball5_y <= ball5_y - 1;
			end
			
			if (ball5_x - ball_r <= bound_left)
			begin
				dir5[1] <= 1;
				ball5_x <= ball5_x + 1;
			end
			
			if(ball5_x + ball_r >= bound_right)
			begin
				dir5[1] <= 0;
				ball5_x <= ball5_x - 1;
			end
				
		end
	end
	
	wire inPlayer;
	wire [5:1] inBall;
	inBall player(.ballX(player_x), .ballY(player_y), .posX(x), .posY(y), .rad(player_r), .ret(inPlayer));	
	inBall ball1(.ballX(ball1_x), .ballY(ball1_y), .posX(x), .posY(y), .rad(ball_r), .ret(inBall[1]));
	inBall ball2(.ballX(ball2_x), .ballY(ball2_y), .posX(x), .posY(y), .rad(ball_r), .ret(inBall[2]));
	inBall ball3(.ballX(ball3_x), .ballY(ball3_y), .posX(x), .posY(y), .rad(ball_r), .ret(inBall[3]));
	inBall ball4(.ballX(ball4_x), .ballY(ball4_y), .posX(x), .posY(y), .rad(ball_r), .ret(inBall[4]));
	inBall ball5(.ballX(ball5_x), .ballY(ball5_y), .posX(x), .posY(y), .rad(ball_r), .ret(inBall[5]));
	
	always @ (posedge clk_100mhz)
	begin
		if (x < 0 || x > 640 || y < 0 || y > 480)
			rgb <= null_color;
		else
		begin
			if (inPlayer)
				rgb <= player_color;
			else if (inBall[1])
				rgb <= ball_color;
			else if (inBall[2])
				rgb <= ball_color;
			else if (inBall[3])
				rgb <= ball_color;
			else if (inBall[4])
				rgb <= ball_color;
			else if (inBall[5])
				rgb <= ball_color;
			else
				rgb <= background_color;
		end
	end
	
endmodule


module inBall( ballX, ballY, posX, posY, rad, ret );
	input [11:0] ballX, ballY, posX, posY;
	input [11:0] rad;
	output reg ret;
	reg [11:0] x, y;

	
	always @ (*)
	begin
		x <= (posX > ballX)? (posX-ballX) : (ballX-posX);
		y <= (posY > ballY)? (posY-ballY) : (ballY-posY);
		if ((x*x + y*y <= rad*rad) && (posX > ballX - rad) && (posX < ballX + rad) && (posY > ballY - rad) && (posY < ballY + rad))
			ret <= 1;
		else
			ret <= 0;
	end
endmodule
