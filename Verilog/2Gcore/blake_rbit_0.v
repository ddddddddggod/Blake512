`timescale 1ns / 10ps

module blake_rbit_0 #(  parameter N = 8 )
(
  input          clk  ,
  input          rstb ,
  input  [N-1:0] din  ,
  output reg [N-1:0] dout
);

always @(posedge clk or negedge rstb)
begin
  if (~rstb) dout <= {N{1'b0}};
  else dout <= din;
end // always

endmodule
