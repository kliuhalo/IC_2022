module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[8-1:0] chardata;
output  			valid;
output  			encode;
output  			finish;
output reg	[4-1:0] offset;
output reg	[3-1:0] match_len;
output reg	[8-1:0] char_nxt;

reg	[4-1:0] n_offset;
reg [3-1:0] n_match_len;
reg [8-1:0] n_char_nxt;

parameter 	IDLE = 2'b00, 
			INPUT = 2'b01, 
			CALC = 2'b10, 
			OUT = 2'b11;
integer i, j, k, p;
reg [12-1:0]		cnt, n_cnt;
reg [2-1:0]			state, n_state;

reg [8-1:0]			img[2057-1:0], n_img[2057-1:0];

reg [8-1:0]			lookahead[18-1:0], n_lookahead[18-1:0];
reg [8-1:0]			search[9-1:0], n_search[9-1:0];

reg [4-1:0]			max_len, max_index;
reg break_j, break_k;

assign encode = 1'b1;
/*
	Write Your Design Here ~
*/
always @(posedge clk or posedge reset) begin
	if(reset)begin
		state <= IDLE;
		cnt <= 12'd0;
		for(p=0; p<2057; p=p+1)begin
			img[p] <= 8'd0;
		end
		for(p=0; p<18; p=p+1)begin
			lookahead[p] <= 8'hff;
		end
		for(p=0; p<9; p=p+1)begin
			search[p] <= 8'hff;
		end

		offset <= 4'd0;
		match_len <= 3'd0;
		char_nxt <= 8'd0;


	end else begin
		state <= n_state;
		cnt <= n_cnt;
		for(p=0; p<2057; p=p+1)begin
			img[p] <= n_img[p];
		end
		for(p=0; p<18; p=p+1)begin
			lookahead[p] <= n_lookahead[p];
		end
		for(p=0; p<9; p=p+1)begin
			search[p] <= n_search[p];
		end

		offset <= n_offset;
		match_len <= n_match_len;
		char_nxt <= n_char_nxt;
	end
end


always @(*) begin
	for(i = 0; i<2057; i = i+1)begin
		n_img[i] = img[i];
	end
	case(state)
		IDLE:begin
			for(i = 0; i<2057; i = i+1)begin
				n_img[i] = 8'd0;
			end
			n_img[cnt] = chardata;
		end
		INPUT:begin
			n_img[cnt] = chardata;
		end
	endcase
	
end

assign finish = (state==OUT & cnt==12'd2056) ? 1'b1 : 1'b0;
assign valid = (state == OUT) ? 1'b1 : 1'b0;

always @(*) begin
	case(state)
		IDLE:
			n_cnt = cnt+12'd1;
		INPUT:begin
			n_cnt = cnt+12'd1;
			if(cnt==12'd2048)begin
				n_cnt = 12'd7;
			end
		end
		OUT:
			if(match_len==3'd0)begin
				n_cnt = cnt+12'd1;
			end else begin
				n_cnt = cnt+{9'd0, match_len}+12'd1;
			end
		default:begin
			n_cnt = cnt;
		end
	endcase
end




always@(*)begin
	case(state)
		IDLE:begin
			n_state = INPUT;
		end
		INPUT:begin
			if(cnt == 12'd2048)begin
				n_state = CALC;
			end else begin
				n_state = INPUT;
			end
		end
		CALC:begin
			n_state = OUT;
		end
		OUT:begin
			n_state = CALC;
		end
		default:begin
			n_state = IDLE;
		end
	endcase

end


always @(*) begin
	k = 0;
	for(j = 0; j<18; j = j+1)begin
		n_lookahead[j] = lookahead[j];
	end
	for(j = 0; j<9; j = j+1)begin
		n_search[j] = search[j];
	end
	n_match_len = 3'd0;
	n_offset = 3'd0;
	n_char_nxt = lookahead[0];
	max_len = 4'd0;
	max_index = 4'd8;
	break_j = 1'b0;
	break_k = 1'b0;
	case(state)
		IDLE:begin
			for(j = 0; j<18; j = j+1)begin
				n_lookahead[j] = 8'hff;
			end
			for(j = 0; j<9; j = j+1)begin
				n_search[j] = 8'hff;
			end
		end

		INPUT:begin
			if(cnt==12'd2048)begin
				for(j=0; j<18; j=j+1)begin
					n_lookahead[j] = img[j];
				end
			end
		end	

		CALC:begin
			for(j=0; j<9; j = j+1)begin
				if(search[j] == lookahead[0] && break_j == 1'b0)begin
					break_k = 1'b0;
					for(k = 1; k+j<17; k=k+1)begin
						if(break_k == 1'b0)begin
							if(k==8)begin
								max_index = j[3:0];
								max_len = 4'd7;
								n_char_nxt = lookahead[7];
								break_k = 1'b1;
								break_j = 1'b1;
							end else if((j+k)<9)begin
								if(search[j+k] != lookahead[k])begin
									if(max_len<k[3:0])begin
										max_len = k[3:0];
										max_index = j[3:0];
										n_char_nxt = lookahead[k];
									end
								break_k = 1'b1;
								end
							end else begin
								if(lookahead[j+k-9]!=lookahead[k])begin
									if(max_len<k[3:0])begin
										max_len = k[2:0];
										max_index = j[3:0];
										n_char_nxt = lookahead[k];
									end
									break_k = 1'b1;
								end
							end
						end
					end
				end
			end
			n_match_len = max_len[2:0];
			n_offset = 4'd8-max_index;
		end

		OUT:begin
			for(j = 0; j<9; j = j+1)begin
				if(j+match_len<8)begin
					n_search[j] = search[match_len+j+1];
				end else begin
					n_search[j] = lookahead[j+match_len-8];
				end
			end
			for(j = 0; j<8; j = j+1)begin
				if(j+match_len<7)begin
					n_lookahead[j] = lookahead[match_len+j+1];
				end else begin
					n_lookahead[j] = img[cnt+(j+match_len-6)];
				end
			end
		end
	endcase
	
end
endmodule
