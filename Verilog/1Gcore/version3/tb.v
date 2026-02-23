
`timescale 1ns/10ps

module tb ();


reg clk;
reg rstb;

reg ena;
reg [639:0] din;

wire rdy;
wire [511:0] dout;

wire [639:0] vec;
wire [511:0] ref;
//added
integer cycle_cnt;
reg count_en;

blake dut (

  .clk  (clk ),
  .rstb (rstb),

  .din  (din ),
  .ena  (ena ),

  .rdy  (rdy ),
  .dout (dout)
);

// -----------------------------------
// Reset & Clock
// -----------------------------------

initial clk = 1'b0;
always #(5) clk = ~clk;

initial begin
  rstb = 1'b0;
  repeat(10) @(negedge clk);
  rstb = 1'b1;
end // initial

//added
always @(posedge clk) begin
    if (count_en) cycle_cnt = cycle_cnt + 1;
end

// -------------------------------------------------------------------------------------
// Timing diagram
// -------------------------------------------------------------------------------------
//           ______        _______             ______        _______        _______
// clk _____|      |______|       |______ ... |      |______|       |______|        .....
//                  ______________
// din          0  |    vec       | 0
//                  ______________
// ena ____________|              |__________________________________________
//                                                            _____________
// rdy ______________________________________________________|             |________
//                                                            _____________
// dout______________________________________________________| ref         |________


// Data Input
initial begin
  din = 640'b0;
  ena = 1'b0;
  //added
  count_en = 1'b0;
  cycle_cnt = 0;

  repeat(30) @(negedge clk);
  din = vec;

  ena = 1'b1;
  //added
  count_en = 1'b1;

  repeat(1 ) @(negedge clk);
  din = 640'b0;
  ena = 1'b0;
end //

// Output Compare
initial begin
  @(posedge rdy);

  if (dout == ref) begin $display ("Hash Done.");

  //added

  count_en = 1'b0; // rdy가 뜨면 카운트 중지

  $display("Measured Latency : %0d cycles", cycle_cnt); // 사이클 출력

end

  else $display ("Hash Fail.");

  #(10000) $stop;



end //

assign vec = {
  8'h00,8'h00,8'h00,8'h02,8'h5b,8'h4a,8'hbb,8'h46,8'h95,8'h9d,
  8'h93,8'hd0,8'h49,8'h1a,8'h8c,8'h97,8'hb0,8'h02,8'h37,8'h29,
  8'h5d,8'h1e,8'hf8,8'hfd,8'he0,8'h74,8'h2c,8'hf7,8'h00,8'hdd,
  8'h5c,8'hb2,8'h00,8'h00,8'h00,8'h00,8'h39,8'h2d,8'h31,8'hbc,
  8'h20,8'hdb,8'h56,8'h16,8'hc6,8'hf0,8'h56,8'h28,8'h79,8'h15,
  8'h4d,8'hc4,8'h62,8'h1a,8'h46,8'h97,8'h4c,8'h25,8'hf0,8'h40,
  8'h0d,8'hbc,8'h8c,8'hea,8'h24,8'hd7,8'haf,8'h70,8'h53,8'h95,
  8'h89,8'had,8'h1c,8'h02,8'hac,8'h3d,8'h00,8'h09,8'he2,8'h2e
};

assign ref = 512'hD11A7038CC6784847E4F07BA92E0A4431F7D0225FE5FFDA873E7962790FA484F74D1DF11E82C47B4043A98FF68D8A7CA4B16E99EB501FF4E33E60A14BE825679;



endmodule
