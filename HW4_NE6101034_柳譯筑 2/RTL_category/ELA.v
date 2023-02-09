`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input clk;
	input rst;
	input [7:0] in_data;
	input [7:0] data_rd;
	output req;
	output wen;
	output [9:0] addr;
	output [7:0] data_wr;
	output done;

	//reg [7:0] in_data2;
	reg [9:0] cnt , n_cnt;
	reg [9:0] i,j;
	reg done, n_done;
	reg wen, n_wen;
	reg [9:0] addr;
	reg req, n_req;

	reg [7:0] data_wr;
	reg [7:0] img [991:0];
	reg [8:0] n_img[991:0];
	reg [7:0] D1, D2, D3;


	parameter IDLE = 2'b00, IN = 2'b01, CALC = 2'b10, OUT = 2'b11;
	reg [1:0] State, NextState;

	// State register
	always @(posedge clk or posedge rst)begin
		if (rst) begin
			State <= IDLE;
			cnt <= 10'd0;
			done <= 1'b0;
			//wen <= 1'b0;
			req <= 1'b0;
			addr <= 10'd0;
			for (j = 10'd0; j<10'd992; j=j+10'd1)begin
				img[j] <= 8'd0; 
			end

		end else begin
			State <= NextState;
			cnt <= n_cnt;
			done <= n_done;
			//wen <= n_wen;
			req <= n_req;
			addr <= n_cnt;
			for (j = 10'd0; j<10'd992; j=j+10'd1)begin
				img[j] <= n_img[j][7:0]; 
			end
		end
	end
	// Next State logic
	// n_cnt & State & req & done
	always @(*)begin
		NextState = State;
		n_cnt = cnt;
		n_req = req;
		n_done = done;
		case(State)

			IDLE:begin
				NextState = IN;
				n_cnt = 10'd0;
				n_req = 1'b1;
				n_done = 1'b0;
			end
			// 0 ~ 991
			IN:begin
				if (cnt == 10'd991)begin
					NextState = CALC;
					n_cnt = 10'd32;
					n_req = 1'b0;
					n_done = 1'b0;
				end else begin
					NextState = IN;
					n_req = 1'b1;
					n_done = 1'b0;
					if (cnt[5:0]==6'd31)begin
						n_cnt = cnt + 10'd33;
					end else begin
						n_cnt = cnt + 10'd1;
					end
				end
			end
			// 32 -63,  ~ 959
			CALC:begin
				n_req = 1'b0;
				n_done = 1'b0;
				if (cnt == 10'd959)begin
					NextState = OUT;
					n_cnt = 10'd0;
				end else begin
					NextState = CALC;
					if (cnt[5:0]==6'd63)begin
						n_cnt = cnt + 10'd33;
					end else begin
						n_cnt = cnt + 10'd1;
					end
				end
			end

			OUT:begin
				n_req = 1'b0;
				NextState = OUT;
				if (cnt == 10'd992)begin 
					n_done = 1'b1;
				end else begin
					n_done = 1'b0;
					// if (cnt[5:0]==6'd63)begin
					// 	n_cnt <= cnt + 10'd33;
					// end else begin
					// 	n_cnt <= cnt + 10'd1;
					// end
					n_cnt = cnt + 10'd1;
				end
			end
		endcase
	end
	// n_img
	always @(*)begin
	for (i = 10'd0; i<=10'd991; i=i+10'd1)begin
		n_img[i] = {1'b0,img[i]};
	end	
	D1 = 8'hff;
	D2 = 8'hff;
	D3 = 8'hff;
	case (State)
	
		IDLE:begin
			for (i = 10'd0; i<10'd992; i=i+10'd1)begin
				n_img[i] = 9'b111111111;
			end
		end
		IN:begin
			n_img[cnt] = {1'b0,in_data};
		end
		CALC:begin
			// WALL
			if (cnt[4:0]==5'd0)begin
				n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;
				
			end else if (cnt[5:0]==6'd63)begin
				n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;

			end else begin
				// SAFE
				
				if(img[cnt-10'd33]>img[cnt+10'd33])begin
					D1 = img[cnt-10'd33]-img[cnt+10'd33];
				end else begin
					D1 = img[cnt+10'd33]-img[cnt-10'd33];
				end
				if(img[cnt-10'd32]>img[cnt+10'd32])begin
					D2 = img[cnt-10'd32]-img[cnt+10'd32];
				end else begin
					D2 = img[cnt+10'd32]-img[cnt-10'd32];
				end
				if(img[cnt-10'd31]>img[cnt+10'd31])begin
					D3 = img[cnt-10'd31]-img[cnt+10'd31];
				end else begin
					D3 = img[cnt+10'd31]-img[cnt-10'd31];
				end
				// D1 min
				if (D1<D2 && D1<D3)begin
					n_img[cnt] = ({1'b0,img[cnt-10'd33]}+{1'b0,img[cnt+10'd33]})>>1;
					
					//n_img[cnt] = (img[cnt-10'd33]+img[cnt+10'd33])/2;
				// D2 min
				end else if(D2<D1 && D2<D3)begin
					n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;
	
					//n_img[cnt] = (img[cnt-10'd32]+img[cnt+10'd32])/2;
				// D3 min
				end else if (D3<D1 && D3<D2)begin
					n_img[cnt] = ({1'b0,img[cnt-10'd31]}+{1'b0,img[cnt+10'd31]})>>1;
					
					//n_img[cnt] = (img[cnt-10'd31]+img[cnt+10'd31])/2;
				// D1=D2 min
				end else if (D1==D2 && D1 < D3) begin
					n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;
			
				// D2=D3 min	
				end else if (D3==D2 && D3 < D1)begin
					n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;
				// D1 = D3 min
				end else if(D1 == D3 && D1<D2)begin
					n_img[cnt] = ({1'b0,img[cnt-10'd33]}+{1'b0,img[cnt+10'd33]})>>1;
					
				// D1=D2=D3 min
				end else begin
					n_img[cnt] = ({1'b0,img[cnt-10'd32]}+{1'b0,img[cnt+10'd32]})>>1;
				end

			end
		end
		

	endcase
	end

	// OUTPUT LOGIC
	// wen, data_wr, addr
	always @(*)begin
		case(State)
			OUT:begin
				if (cnt == 10'd992)begin
					wen <= 1'b0;
					data_wr <= 8'hff;

				end else begin
					wen <= 1'b1;
					data_wr <= img[addr];
				end
			end
			default:begin
				wen = 1'b0;
				data_wr <= 8'hff;
			end
		endcase
	end

endmodule