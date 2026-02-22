
`timescale 1ns/10ps

module tb_blake_64 ();


reg clk;
reg rstb;

reg ena;
reg [639:0] din;

wire rdy;
wire [511:0] dout;

wire [639:0] md [0:2];
wire [511:0] ref [0:2];


blake_64 dut (

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


// Data Input
initial begin
  din = 640'b0;
  ena = 1'b0;

  // First Input
  repeat(64) @(negedge clk);
  din = md[0];
  ena = 1'b1;
  repeat(1  ) @(negedge clk);
  ena = 1'b0;

  // Second Input
  repeat(64 ) @(negedge clk);
  din = md[1];
  ena = 1'b1;
  repeat(1  ) @(negedge clk);
  ena = 1'b0;

  // Third Input
  repeat(64 ) @(negedge clk);
  din = md[2];
  ena = 1'b1;
  repeat(1  ) @(negedge clk);
  ena = 1'b0;

end //

// -----------------------------------
// Cycle Counter Addeds
// -----------------------------------
reg [31:0] global_cycle;

always @(posedge clk) begin
    if (rstb == 1'b0) global_cycle <= 32'h0;
    else              global_cycle <= global_cycle + 1;
end

// Output Compare
initial begin
  @(posedge rdy);
  if (dout == ref[0]) $display ("Hash[0] Done.");
    else $display ("Hash[0] Fail.");

  @(posedge rdy);
  if (dout == ref[1]) $display ("Hash[1] Done.");
  else $display ("Hash[1] Fail.");

  @(posedge rdy);
  if (dout == ref[2]) $display ("Hash[2] Done.");
  else $display ("Hash[2] Fail.");

  #(10000) $stop;

end //

/*reg [31:0] start_time [0:2]; // 각 입력의 시작 시간을 저장할 배열
integer in_idx = 0;
integer out_idx = 0;

// 입력 시점 기록
always @(posedge clk) begin
    if (ena) begin
        start_time[in_idx] <= global_cycle;
        in_idx <= in_idx + 1;
    end
end
initial begin
    wait(rstb == 1'b1);
    
    for (out_idx = 0; out_idx < 3; out_idx = out_idx + 1) begin
        @(posedge rdy);
        $display("--------------------------------------");
        $display("Hash[%0d] Done!", out_idx);
        // Latency = 현재 전체 시간 - 해당 입력이 들어왔던 시간
        $display("  > Latency: %0d cycles", global_cycle - start_time[out_idx]);
        
        if (dout == ref[out_idx]) $display("  > Result : MATCH");
        else                      $display("  > Result : FAIL");
    end

    $display("--------------------------------------");
    #(1000) $stop;
end*/

assign md[0] = {
  8'h00,8'h00,8'h00,8'h02,8'h5b,8'h4a,8'hbb,8'h46,8'h95,8'h9d,
  8'h93,8'hd0,8'h49,8'h1a,8'h8c,8'h97,8'hb0,8'h02,8'h37,8'h29,
  8'h5d,8'h1e,8'hf8,8'hfd,8'he0,8'h74,8'h2c,8'hf7,8'h00,8'hdd,
  8'h5c,8'hb2,8'h00,8'h00,8'h00,8'h00,8'h39,8'h2d,8'h31,8'hbc,
  8'h20,8'hdb,8'h56,8'h16,8'hc6,8'hf0,8'h56,8'h28,8'h79,8'h15,
  8'h4d,8'hc4,8'h62,8'h1a,8'h46,8'h97,8'h4c,8'h25,8'hf0,8'h40,
  8'h0d,8'hbc,8'h8c,8'hea,8'h24,8'hd7,8'haf,8'h70,8'h53,8'h95,
  8'h89,8'had,8'h1c,8'h02,8'hac,8'h3d,8'h00,8'h09,8'he2,8'h2e
};

assign md[1] = {
  8'h00,8'h00,8'h00,8'h02,8'h5b,8'h4a,8'hbb,8'h46,8'h95,8'h9d,
  8'h93,8'hd0,8'h49,8'h1a,8'h8c,8'h97,8'hb0,8'h02,8'h37,8'h29,
  8'h5d,8'h1e,8'hf8,8'hfd,8'he0,8'h74,8'h2c,8'hf7,8'h00,8'hdd,
  8'h5c,8'hb2,8'h00,8'h00,8'h00,8'h00,8'ha4,8'h47,8'haa,8'hb6,
  8'h66,8'h41,8'h0a,8'h3c,8'hd3,8'h06,8'hcb,8'h6b,8'h52,8'h80,
  8'h47,8'hab,8'hea,8'h13,8'he6,8'h62,8'h65,8'h9a,8'h74,8'h14,
  8'h99,8'hca,8'h0b,8'hed,8'h35,8'h07,8'h6f,8'h4f,8'h53,8'h95,
  8'h89,8'had,8'h1c,8'h02,8'hac,8'h3d,8'h00,8'h01,8'h28,8'hcf
};

assign md[2] = {
  8'h00,8'h00,8'h00,8'h02,8'h5b,8'h4a,8'hbb,8'h46,8'h95,8'h9d,
  8'h93,8'hd0,8'h49,8'h1a,8'h8c,8'h97,8'hb0,8'h02,8'h37,8'h29,
  8'h5d,8'h1e,8'hf8,8'hfd,8'he0,8'h74,8'h2c,8'hf7,8'h00,8'hdd,
  8'h5c,8'hb2,8'h00,8'h00,8'h00,8'h00,8'h56,8'hc0,8'h2f,8'h12,
  8'h82,8'h24,8'hd3,8'hb8,8'he9,8'h37,8'h67,8'h9f,8'h9d,8'h00,
  8'h10,8'h00,8'h2e,8'h32,8'h02,8'h6b,8'hf2,8'h9d,8'h22,8'hd5,
  8'h30,8'h68,8'hcb,8'h13,8'hc0,8'h14,8'h4d,8'ha5,8'h53,8'h95,
  8'h89,8'had,8'h1c,8'h02,8'hac,8'h3d,8'h00,8'h0a,8'h1e,8'hf1
};

assign ref[0] = 512'hD11A7038CC6784847E4F07BA92E0A4431F7D0225FE5FFDA873E7962790FA484F74D1DF11E82C47B4043A98FF68D8A7CA4B16E99EB501FF4E33E60A14BE825679;
assign ref[1] = 512'h66A6414A7DA863D0ABBC990295A739E8B28A4BE0BE2466643CC269590A48A53379591B7E7629C35AA8FC7FAEFDBADCAC632B845099A27BE003815C1F544A0724;
assign ref[2] = 512'hE4BD939F1CC5F6DEFF9520113E9A7D52524843800946F77BE02B383CC1E03CDFF02786605DD24431D543EB9EB7265927E97A38B0114D2BAD9ECD0C72CB1AD9CE;


endmodule
