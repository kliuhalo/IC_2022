module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;

reg       [3:0] Gnum, Ynum, Rnum, Cnt;
reg       [3:0] NextCnt;

output          Gout;
output          Yout;
output          Rout;
reg             Gout,Yout,Rout;
reg       [1:0] State, NextState;

parameter Idle=2'b00, Green=2'b01,
          Yellow=2'b10, Red=2'b11;

// state register

always @(posedge clk or posedge reset)
begin 
  if(reset)begin
    State <= Idle;
    Cnt <= 4'd0;
  end
    
  else begin
    State <= NextState;
    Cnt <= NextCnt;
  end
end


always @(posedge Set)
begin
    Gnum <= Gin;
    Rnum <= Rin;
    Ynum <= Yin; 
end

// Next state logic
always @(*)begin
  if(Set)begin
    NextState <= Green;
    NextCnt <= 4'd0;
  end
  else if (Jump)begin
    NextState <= Red;
    NextCnt <= 4'd0;
    end   
  else if (Stop) begin
    NextState <= State;
    NextCnt <= Cnt;
    end
    
else begin
  case(State)
    Green:begin
            if (Cnt == Gnum-4'd1) begin
              NextState <= Yellow;
              NextCnt <= 4'd0;
            end else begin
              NextState <= Green;
              NextCnt <= Cnt+4'd1; 
            end
          end   
   
    Yellow:begin
              if (Cnt == Ynum-4'd1) begin
                NextState <= Red;
                NextCnt <= 4'd0;
              end else begin
                NextState <= Yellow;
                NextCnt <= Cnt+4'd1; 
              end
            end
    Red:begin
          if (Cnt == Rnum-4'd1) begin
              NextState <= Green;
              NextCnt <= 4'd0;
          end else begin
            NextState <= Red;
            NextCnt <= Cnt+4'd1; 
          end
        end
    default:
      begin
        NextState <= Idle;
        NextCnt <= Cnt;
      end
    endcase
    end
end

// output logic
always @(State)begin
  case(State)
    Green:begin
          Gout = 1'b1;
          Rout = 1'b0;
          Yout = 1'b0;
          end
    Yellow:begin
          Gout = 1'b0;
          Rout = 1'b0;
          Yout = 1'b1;
        end
    Red:begin
          Gout = 1'b0;
          Rout = 1'b1;
          Yout = 1'b0;
        end
    Idle:begin
          Gout = 1'b0;
          Rout = 1'b0;
          Yout = 1'b0;
        end
    default:
    begin
      Gout = 1'b0;
      Rout = 1'b0;
      Yout = 1'b0;
      end
    endcase
end


endmodule