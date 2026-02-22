module blake_state_reg (
	input wire clk,
	input wire rstb,
	input wire round_ing,
    input wire init_round,
    input wire count_done,
	input wire [1023:0] v_state_next,
	output wire [1023:0] v_out
);

	//V0 (IV + CB )
	wire  [1023:0] v_init_val;
    assign v_init_val[1023:960] = 64'h6A09E667F3BCC908; //IV[0];
    assign v_init_val[959:896]  = 64'hBB67AE8584CAA73B; //IV[1];
    assign v_init_val[895:832]  = 64'h3C6EF372FE94F82B; //IV[2];
    assign v_init_val[831:768]  = 64'hA54FF53A5F1D36F1; //IV[3];
    assign v_init_val[767:704]  = 64'h510E527FADE682D1; //IV[4];
    assign v_init_val[703:640]  = 64'h9B05688C2B3E6C1F; //IV[5];
    assign v_init_val[639:576]  = 64'h1F83D9ABFB41BD6B; //IV[6];
    assign v_init_val[575:512]  = 64'h5BE0CD19137E2179; //IV[7];
    assign v_init_val[511:448] = 64'h243F6A8885A308D3;
    assign v_init_val[447:384] = 64'h13198A2E03707344;
    assign v_init_val[383:320] = 64'hA4093822299F31D0; 
    assign v_init_val[319:256] = 64'h082EFA98EC4E6C89;
    assign v_init_val[255:192] = 64'h452821E638D011F7; // T0(640) ^ cb4
    assign v_init_val[191:128] = 64'hBE5466CF34E90EEC; // T0(640) ^ cb5
    assign v_init_val[127:64]  = 64'hC0AC29B7C97C50DD;
    assign v_init_val[63:0]    = 64'h3F84D5B5B5470917;

    blake_rbit_2 #(.N(1024)) u_v_state_mem (
        .clk  (clk),
        .rstb (rstb),
        .init (init_round),   
        .iv   (v_init_val),   
        .ena  (round_ing),   
        .din  (v_state_next), 
        .dout (v_out)
    );

endmodule
