module blake_datapath (
    input  wire clk,
    input  wire rstb,
    input  wire [1023:0] padded_block, 
    
    // Controller에서 받은 신호
    input  wire init_round,   
    input  wire [3:0] round_idx,
    input  wire ctrl_finalize,     

    output wire [511:0] dout
);
    //-----입력 데이터 유지 (tb에선 입력을 한 클락만 줌)---
    reg [1023:0] block_reg;

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            block_reg <= 1024'b0;
        end else begin
            // 해시가 시작될 때(init_round) 입력을 캡처해서 끝날 때까지 유지
            if (init_round) begin
                block_reg <= padded_block;
            end
        end
    end

    // --- IV512----------------
    wire [63:0] IV [0:7]; //64bit 8개

    assign IV[0] = 64'h6A09E667F3BCC908; assign IV[1] = 64'hBB67AE8584CAA73B;
    assign IV[2] = 64'h3C6EF372FE94F82B; assign IV[3] = 64'hA54FF53A5F1D36F1;
    assign IV[4] = 64'h510E527FADE682D1; assign IV[5] = 64'h9B05688C2B3E6C1F;
    assign IV[6] = 64'h1F83D9ABFB41BD6B; assign IV[7] = 64'h5BE0CD19137E2179;

    //------CB-----------------

    wire [63:0] CB [0:7]; // 64bit 8개

    assign CB[0] = 64'h243F6A8885A308D3; assign CB[1] = 64'h13198A2E03707344;
    assign CB[2] = 64'hA4093822299F31D0; assign CB[3] = 64'h082EFA98EC4E6C89;
    assign CB[4] = 64'h452821E638D01377; assign CB[5] = 64'hBE5466CF34E90C6C;
    assign CB[6] = 64'hC0AC29B7C97C50DD; assign CB[7] = 64'h3F84D5B5B5470917;

    // --- H Registers ---
    reg [63:0] h [0:7];

    // --- V값 (initial, current) ----
    //roundreg Interface
    reg  [1023:0] v_init_val; // V 초기값 (Combined)
    wire [1023:0] v_current;  // roundreg의 출력 (VxDO)

    // --- V 초기값 생성 로직 ---
    always @(*) begin
        // V[0..7] = H[0..7]
        v_init_val[1023:960] = h[0]; 
        v_init_val[959:896]  = h[1]; 
        v_init_val[895:832]  = h[2]; 
        v_init_val[831:768]  = h[3]; 
        v_init_val[767:704]  = h[4]; 
        v_init_val[703:640]  = h[5]; 
        v_init_val[639:576]  = h[6]; 
        v_init_val[575:512]  = h[7];
        // V[8..11] = CB
        v_init_val[511:448] = CB[0];
        v_init_val[447:384] = CB[1];
        v_init_val[383:320] = CB[2];
        v_init_val[319:256] = CB[3];
        v_init_val[255:192] = 64'h452821E638D011F7; // T0(640) ^ CB4
        v_init_val[191:128] = 64'hBE5466CF34E90EEC; // T0(640) ^ CB5
        v_init_val[127:64]  = CB[6];
        v_init_val[63:0]    = CB[7];
    end

    // --- 반복 loop 계산 ---
    roundreg #( .WWIDTH(64) ) u_roundreg (
        .clk   (clk),
        .rstb  (rstb),
        .init_round   (init_round), 
        .round_idx (round_idx),
        .v_init_val     (v_init_val),
        .block_reg     (block_reg),
        .v_current     (v_current)
    );

    // --- H와 XOR을 위한 V값 pack과정-----
    wire [63:0] v_final [0:15];
    
    genvar i;
    generate
        for(i=0; i<16; i=i+1) begin : unpack_v
            assign v_final[i] = v_current[(15-i)*64 +: 64];
        end
    endgenerate

    //---------H값 update-------------------
    integer x;
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            // Reset H to IV512
            for(x=0; x<8; x=x+1) h[x] <= IV[x];
        end else begin
            if (ctrl_finalize) begin
                for(x=0; x<8; x=x+1) begin
                    h[x] <= h[x] ^ v_final[x] ^ v_final[x+8]; // Final XOR: H[i] = H[i] ^ V[i] ^ V[i+8]
                end
            end
        end
    end

    // Output
    assign dout = {h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]};

endmodule
