module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode; 
output reg 			finish;
output 	 	[7:0] 	char_nxt;

// State
parameter	Idle =2'b00, Calc = 2'b01;
reg  		[1:0]	State, NextState;
reg			[3:0]	pos, n_pos;
reg			[2:0]	len, n_len;
reg			[7:0]	char, n_char;

wire n_finish;
reg			[2:0]	cnt, n_cnt;

parameter EndToken = 8'h24;

reg [7:0] search_buf[8:0], next_search_buf[8:0];
reg	[7:0]	char_nxt;
reg	[4:0] i,k;

assign encode = 1'd0;
assign n_finish = (char_nxt == EndToken) ? 1'b1 : 1'b0;

always  @(posedge clk or posedge reset)begin
  if (reset)begin
    State <= Idle;
    cnt <= 3'd0;
	pos <= 4'd0;
	len <= 3'd0;
	char <= 7'd0;
	finish <= 1'b0;
  end else begin 
	finish <= n_finish;

	pos <= n_pos;
	len <= n_len;
	char <= n_char;

    State <= NextState;
    cnt <= n_cnt;
	
	for (k=5'd0;k<=5'd8;k=k+5'd1)begin
		search_buf[k] <= next_search_buf[k];
	end
  end
end

always @(*) begin
	n_pos = code_pos;
	n_len = code_len;
	n_char = chardata;
end

always @(*)begin
  case(State)
  	Idle:begin
      NextState = Calc;
      n_cnt = 3'd0;
    end
    Calc:begin
          if (cnt == len)begin
            NextState = Calc;
            n_cnt = 3'd0;
          end else if(cnt == len && char==EndToken)begin
            NextState = Idle;
            n_cnt = 3'd0;
          end else begin
            NextState = Calc;
            n_cnt = cnt + 3'd1;
          end
      end
    default:begin
        NextState = State;
		n_cnt = cnt;
    end
  endcase
end

always @(*)begin
	char_nxt = 8'd0;
    case(State)
      Idle:begin
        for (i=5'd0; i<5'd9;i=i+5'd1)begin
          next_search_buf[i] = 8'hff;
        end
      end
      Calc:begin
        if(cnt!=len)begin
            for(i=4'd8; i>=4'd1;i=i-4'd1)begin
                next_search_buf[i] = search_buf[i-4'd1];
            end
            next_search_buf[0] = search_buf[pos];
            char_nxt = search_buf[pos];
        
        end else begin
            next_search_buf[0] = char;
            char_nxt = char;
            for(i=4'd8; i>=4'd1;i=i-4'd1)begin
                next_search_buf[i] = search_buf[i-4'd1];
            end
        end
            
      end

      default:begin
        for (i=4'd0;i<=4'd8;i=i+4'd1)begin
          next_search_buf[i] = search_buf[i]; 
        end
      end
    endcase
end


endmodule

