	
module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input				ready;
input 		[4:0] 	code_pos;
input 		[4:0] 	code_len;
input 		[7:0] 	chardata;

// reg			[4:0]   code_position;
// reg			[4:0]	code_length;
// reg			[7:0]	char_data;

output reg  			encode;
output reg 			finish;
output reg 	  [7:0] 	char_nxt;

reg			[4:0]	output_counter;
reg			[3:0]	search_buffer[29:0];
// reg			wtf;
// parameter  IN=1'b0, CAL=1'b1;
// reg			current_State, nextState;

// always @(*) begin
// 	case (current_State)
// 		IN:
// 			nextState<=CAL;
// 		CAL:
// 			nextState<= (output_counter == code_length) ?IN:CAL;
// 	endcase
// end

always @(posedge clk or posedge reset)
begin
	if(reset)
	begin
		// current_State<=IN;
		// wtf <=0;
		finish <= 0;
		output_counter <= 0;
		encode <= 0;
		char_nxt <= 0;
		// code_position <= 0 ;
		// code_length <= 0;
		// char_data <=0;
		search_buffer[29] <= 0;
		search_buffer[28] <= 0;
		search_buffer[27] <= 0;
		search_buffer[26] <= 0;
		search_buffer[25] <= 0;
		search_buffer[24] <= 0;
		search_buffer[23] <= 0;
		search_buffer[22] <= 0;
		search_buffer[21] <= 0;
		search_buffer[20] <= 0;
		search_buffer[19] <= 0;
		search_buffer[18] <= 0;
		search_buffer[17] <= 0;
		search_buffer[16] <= 0;
		search_buffer[15] <= 0;
		search_buffer[14] <= 0;
		search_buffer[13] <= 0;
		search_buffer[12] <= 0;
		search_buffer[11] <= 0;
		search_buffer[10] <= 0;
		search_buffer[9] <= 0;
		search_buffer[8] <= 0;
		search_buffer[7] <= 0;
		search_buffer[6] <= 0;
		search_buffer[5] <= 0;
		search_buffer[4] <= 0;
		search_buffer[3] <= 0;
		search_buffer[2] <= 0;
		search_buffer[1] <= 0;
		search_buffer[0] <= 0;

	end
	else begin
		if(ready)begin
		// current_State <= nextState;
		// code_position <= code_pos;
		// code_length <= code_len;
		// char_data <= chardata;

		// if(current_State==IN)begin
		// 	char_nxt <= (output_counter == code_length && code_length!=0) ? 0 : search_buffer[code_pos];
		// end
		// if (current_State==CAL)
		// begin
			
			search_buffer[29] <= search_buffer[28];
			search_buffer[28] <= search_buffer[27];
			search_buffer[27] <= search_buffer[26];
			search_buffer[26] <= search_buffer[25];
			search_buffer[25] <= search_buffer[24];
			search_buffer[24] <= search_buffer[23];
			search_buffer[23] <= search_buffer[22];
			search_buffer[22] <= search_buffer[21];
			search_buffer[21] <= search_buffer[20];
			search_buffer[20] <= search_buffer[19];
			search_buffer[19] <= search_buffer[18];
			search_buffer[18] <= search_buffer[17];
			search_buffer[17] <= search_buffer[16];
			search_buffer[16] <= search_buffer[15];
			search_buffer[15] <= search_buffer[14];
			search_buffer[14] <= search_buffer[13];
			search_buffer[13] <= search_buffer[12];
			search_buffer[12] <= search_buffer[11];
			search_buffer[11] <= search_buffer[10];
			search_buffer[10] <= search_buffer[9];
			search_buffer[9] <= search_buffer[8];
			search_buffer[8] <= search_buffer[7];
			search_buffer[7] <= search_buffer[6];
			search_buffer[6] <= search_buffer[5];
			search_buffer[5] <= search_buffer[4];
			search_buffer[4] <= search_buffer[3];
			search_buffer[3] <= search_buffer[2];
			search_buffer[2] <= search_buffer[1];
			search_buffer[1] <= search_buffer[0];
			search_buffer[0] <= (output_counter == code_len) ? chardata : search_buffer[code_pos];
			
			output_counter <= (output_counter == code_len) ? 0 : output_counter+1;
			finish <= (char_nxt==8'h24) ? 1 : 0;
			char_nxt <= (output_counter == code_len) ? chardata : search_buffer[code_pos];
			
		// end
		end	
end
	end

endmodule
	
	
	
