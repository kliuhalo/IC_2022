`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output 				req;
	output 				wen;
	output 		[12:0]	addr;
	output 		[7:0]	data_wr;
	output 				done;
	reg  wen;
	reg  req;
	reg  done;
	reg [7:0]  data_wr;
	reg [12:0]  addr;

	reg [2:0]  curt_state;
	reg [2:0]  next_state;

	// two buffer to store the data
	reg [7:0]  data_line_1 [127:0];
	reg [7:0]  data_line_2 [127:0];
	reg [7:0]  counter_128;

	reg [9:0]  d1,d2,d3,weight1, weight2, weight3;
	reg unsigned [9:0] call;
	reg			[9:0]ans;
	// State Machine
	always @( * ) begin
		//if (ready) begin
			case ( curt_state )
				// initial			
				0 : 
				begin 
					if(ready)
					next_state = 1;
					else
					next_state = 0;
				end
				// read first row
				1 : 
				begin            
					if ( counter_128 == 128 && addr!=8191 )          
						next_state = 2;
					else
						next_state = 1;
				end
				// read next row
				2 : 
				begin
					if( addr >= 8063 )
						next_state = 6;
					else if ( counter_128== 128 && addr[7:0] == 127)          
						next_state = 5;
					else if ( counter_128 == 128)          
						next_state = 3;
					else
						next_state = 2;
				end
				// not boundary
				3 :
				begin
					next_state = 4;				
				end
				// write out data 
				4 :
				begin
					if( addr >= 8063 )
						next_state = 6;
					else if( addr[7:0] == 127 || addr[7:0] == 253 )
						next_state = 5;
					else
						next_state = 3;
				end
				// boundary
				5 :
				begin				
					if( addr[7:0] == 254)
						next_state = 7;
					else
						next_state = 3;
				end
				// finish
				6 :
				begin
					next_state = 6;
				end
				//read next row
				7 :
				begin
					if ( counter_128 == 128 )          
						next_state = 2;
					else
						next_state = 7;
				end	
			endcase
		
	end
	// Reset Signal
	always @(posedge clk or posedge rst ) begin
		if ( rst )
			curt_state <= 0;
		else
			curt_state <= next_state;  
	end
	// Datapath & Controlpath
	always @(posedge clk or posedge rst ) begin
		if ( rst )
		begin
			counter_128 <= 128;
			req <= 0;
			addr <= -1;
			done <= 0;
			wen  <= 0;
		end
		else
		begin
			if(ready)begin
			case ( curt_state )
			// read first row
				0:
				begin
					
					data_line_1[counter_128] <= in_data;					
					data_wr <= in_data;
					if ( counter_128 == 128 )
					begin
						counter_128 <= 0;
						wen <= 0; 
						req <= 1;
					end
					else
					begin
						counter_128 <= counter_128 + 1;
						wen <= 1; 
						req <= 0; 
					end					
					if ( counter_128 < 128 )
						addr <= addr + 1;
				end
				1 : 
				begin
					data_line_1[counter_128] <= in_data;					
					data_wr <= in_data;
					if ( counter_128 == 128 )
					begin
						counter_128 <= 0;
						wen <= 0; 
						req <= 1;
					end
					else
					begin
						counter_128 <= counter_128 + 1;
						wen <= 1; 
						req <= 0; 
					end					
					if ( counter_128 < 128 )
						addr <= addr + 1;
				end
				// read next row			
				2 : 
				begin
					req <= 0;  
					data_line_2[counter_128] <= in_data;
					
					if ( counter_128 == 128 )
						counter_128 <= 0;
					else
						counter_128 <= counter_128 + 1;
				end
				// not boundary,calculate diff
				3 : 
				begin
                    // d1 <= (data_line_1[addr[7:0]-128]+data_line_1[addr[7:0]-127]+data_line_1[addr[7:0]-126]+data_line_2[addr[7:0]-128]+data_line_2[addr[7:0]-127]+data_line_2[addr[7:0]-126])/6;
					
					d1 <= data_line_1[addr[7:0] - 128] >= data_line_2[addr[7:0] - 126] ? data_line_1[addr[7:0] - 128] - data_line_2[addr[7:0] - 126] : data_line_2[addr[7:0] - 126] - data_line_1[addr[7:0] - 128];
					d2 <= data_line_1[addr[7:0] - 127] >= data_line_2[addr[7:0] - 127] ? data_line_1[addr[7:0] - 127] - data_line_2[addr[7:0] - 127] : data_line_2[addr[7:0] - 127] - data_line_1[addr[7:0] - 127];
					d3 <= data_line_1[addr[7:0] - 126] >= data_line_2[addr[7:0] - 128] ? data_line_1[addr[7:0] - 126] - data_line_2[addr[7:0] - 128] : data_line_2[addr[7:0] - 128] - data_line_1[addr[7:0] - 126];
		
					// call = (( {2'b0,data_line_1[addr[7:0] - 127]} + {2'b0,data_line_2[addr[7:0] - 127]} ) >> 1)+(( {2'b0,data_line_1[addr[7:0] - 128]} + {2'b0,data_line_2[addr[7:0] - 126]} ) >> 1)+( {2'b0,data_line_1[addr[7:0] - 126]} + ({2'b0,data_line_2[addr[7:0] - 128]} ) >> 1);	
					// ans = call/3;
				end
				// write out data 
				4 : 
				begin
					wen <= 1; 
					addr <= addr + 1;
					// the condition has priority，D2 > D1 > D3
					if ( ( d2 <= d1 ) & ( d2 <= d3 ) )
					begin
						//data_wr  <= (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1);
						if(d1<=d3)begin
							call = (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 128]} + {1'b0,data_line_2[addr[7:0] - 126]} ) >> 1)>>1;
							data_wr  <= call[7:0];
							
						end else begin
							call = (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)>>1;
							data_wr  <= call[7:0];
						end
					end
					else if ( ( d1 <= d2 ) & ( d1 <= d3 ) )
					begin
						//data_wr  <= (( {1'b0,data_line_1[addr[7:0] - 128]} + {1'b0,data_line_2[addr[7:0] - 126]} ) >> 1);
						if(d2<=d3)begin
							call = (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 128]} + {1'b0,data_line_2[addr[7:0] - 126]} ) >> 1)>>1;
							data_wr  <= call[7:0];
							
						end else begin
							call = (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)>>1;
							data_wr  <= call[7:0];
						end
					end					
					else
					// else if ( ( d3 <= d2 ) & ( d3 <= d1 ) )
					begin
						//data_wr  <= (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1);			
						if(d2<=d1)begin
							call = (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)>>1;
							data_wr  <= call[7:0];
							
						end else begin
							call = (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)+ (( {1'b0,data_line_1[addr[7:0] - 126]} + {1'b0,data_line_2[addr[7:0] - 128]} ) >> 1)>>1;
							data_wr  <= call[7:0];
						end		
					end	
                    data_wr<=ans[7:0];
				end
				// boundary
				5 :
				begin
					wen <= 1; 
					addr <= addr + 1;
					data_wr <= (( {1'b0,data_line_1[addr[7:0] - 127]} + {1'b0,data_line_2[addr[7:0] - 127]} ) >> 1 );
				end	
				// finish	
				6 :
				begin
					wen <= 0;					
					done <= 1;
				end
				//read next row
				7 : 
				begin
					data_line_1[counter_128] <= data_line_2[counter_128];
					data_wr <= data_line_2[counter_128];
					if ( counter_128 == 128 )
					begin
						counter_128 <= 0;
						wen <= 0; 
						req <= 1;
					end
					else
					begin
						req <= 0;  
						wen <= 1; 
						counter_128 <= counter_128 + 1;
					end
					
					if ( counter_128 < 128 )
						addr <= addr + 1;
				end	
			endcase
			end
		end
	end
endmodule