`timescale 1ns / 10ps

module blake_rbit_2 #(  parameter N = 8 )(
  input          clk  ,
  input          rstb ,
  input          init ,
  input  [N-1:0] iv   ,
  input          ena  ,
  input  [N-1:0] din  ,
  output reg [N-1:0] dout
);

wire ld = init | ena;
wire [N-1:0] d = init? iv: din;

always @(posedge clk or negedge rstb)
begin
  if (~rstb) dout <= {N{1'b0}};
  else if (ld) dout <= d;
end // always

endmodule
