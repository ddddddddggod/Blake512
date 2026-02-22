
module blake_finalize (
    input  wire          clk,
    input  wire          rstb,
    input  wire          init_round,
    input  wire          count_done, 
    input  wire          rdy_from_counter,             
    input  wire [1023:0] v_state_next, 
    output wire          rdy,          
    output wire [511:0]  dout           
);

    // ---------------------------------------------------------
    // 1. IV512 정의 (기본값)
    // ---------------------------------------------------------
    wire [63:0] IV [0:7];
    assign IV[0] = 64'h6A09E667F3BCC908; assign IV[1] = 64'hBB67AE8584CAA73B;
    assign IV[2] = 64'h3C6EF372FE94F82B; assign IV[3] = 64'hA54FF53A5F1D36F1;
    assign IV[4] = 64'h510E527FADE682D1; assign IV[5] = 64'h9B05688C2B3E6C1F;
    assign IV[6] = 64'h1F83D9ABFB41BD6B; assign IV[7] = 64'h5BE0CD19137E2179;
    wire [511:0] iv_512 = {IV[0], IV[1], IV[2], IV[3], IV[4], IV[5], IV[6], IV[7]};

    // ---------------------------------------------------------
    // 2. Chaining Value (h) 관리
    // ---------------------------------------------------------
    wire [511:0] h_out;
    wire [511:0] compress_val;

    blake_rbit_2 #(.N(512)) u_h_reg (
        .clk  (clk),
        .rstb (rstb),
        .init (init_round),   
        .iv   (iv_512),
        .ena  (count_done),   
        .din  (compress_val), 
        .dout (h_out)
    );

    // ---------------------------------------------------------
    // 3. Final XOR 연산 (Combinational)
    // ---------------------------------------------------------
    assign compress_val = {
        h_out[511:448] ^ v_state_next[1023:960] ^ v_state_next[511:448], 
        h_out[447:384] ^ v_state_next[959:896]  ^ v_state_next[447:384], 
        h_out[383:320] ^ v_state_next[895:832]  ^ v_state_next[383:320], 
        h_out[319:256] ^ v_state_next[831:768]  ^ v_state_next[319:256], 
        h_out[255:192] ^ v_state_next[767:704]  ^ v_state_next[255:192], 
        h_out[191:128] ^ v_state_next[703:640]  ^ v_state_next[191:128], 
        h_out[127:64]  ^ v_state_next[639:576]  ^ v_state_next[127:64],  
        h_out[63:0]    ^ v_state_next[575:512]  ^ v_state_next[63:0]     
    };

    // ---------------------------------------------------------
    // 4. Pipeline Stages & Output Sync 
    // ---------------------------------------------------------
    
    // Stage 1: T=64 result capture
    wire [511:0] hash_stage1;
    blake_rbit_1 #(.N(512)) u_stage1_reg (
        .clk(clk), 
        .rstb(rstb), 
        .ena(count_done),
        .din(compress_val), 
        .dout(hash_stage1)
    );

    // Stage 2: T=128 result
    blake_rbit_1 #(.N(512)) u_dout_reg (
        .clk(clk), 
        .rstb(rstb), 
        .ena(rdy_from_counter), 
        .din(hash_stage1), 
        .dout(dout)
    );

    blake_rbit_0 #(.N(1)) u_rdy_final_sync (
        .clk(clk),
        .rstb(rstb),
        .din(rdy_from_counter),
        .dout(rdy)
    );

endmodule
