module blake_datapath (
    input  wire clk,
    input  wire rstb,
    input  wire [1023:0] state_buf, 
    
    // Controller -> datapath
    input  wire init_round,   
    input  wire [6:0] counter_idx,
    input  wire ctrl_finalize,
    input  wire round_ing,
    output reg rdy,           
    output reg [511:0] dout     
);

    wire [63:0] IV [0:7];
    wire [63:0] cb [0:15];
    reg  [1023:0] v_init_val;
    reg  [63:0] sigma_row;
    
    reg  [63:0] msg [0:15];
    reg  [1023:0] state;
    reg  [1023:0] v_state;

    // MUX constant
    reg  [63:0] a_in, b_in, c_in, d_in;
    reg  [63:0] m0, m1, k0, k1;
    wire [2:0]  step = counter_idx[2:0];
    
    // G-Function output
    wire [63:0] a_out, b_out, c_out, d_out;

    // -------------------------------------------------------------------------
    // 1. Constant
    // -------------------------------------------------------------------------
    // IV512
    assign IV[0] = 64'h6A09E667F3BCC908; assign IV[1] = 64'hBB67AE8584CAA73B;
    assign IV[2] = 64'h3C6EF372FE94F82B; assign IV[3] = 64'hA54FF53A5F1D36F1;
    assign IV[4] = 64'h510E527FADE682D1; assign IV[5] = 64'h9B05688C2B3E6C1F;
    assign IV[6] = 64'h1F83D9ABFB41BD6B; assign IV[7] = 64'h5BE0CD19137E2179;
    //CB
    assign cb[0] = 64'h243F6A8885A308D3; assign cb[1] = 64'h13198A2E03707344;
    assign cb[2] = 64'hA4093822299F31D0; assign cb[3] = 64'h082EFA98EC4E6C89;
    assign cb[4] = 64'h452821E638D01377; assign cb[5] = 64'hBE5466CF34E90C6C;
    assign cb[6] = 64'hC0AC29B7C97C50DD; assign cb[7] = 64'h3F84D5B5B5470917;
    assign cb[8] = 64'h9216D5D98979FB1B; assign cb[9] = 64'hD1310BA698DFB5AC;
    assign cb[10] = 64'h2FFD72DBD01ADFB7; assign cb[11] = 64'hB8E1AFED6A267E96;
    assign cb[12] = 64'hBA7C9045F12C7F99; assign cb[13] = 64'h24A19947B3916CF7;
    assign cb[14] = 64'h0801F2E2858EFC16; assign cb[15] = 64'h636920D871574E69;


    // V0 (IV512 + CB) 
    always @(*) begin
        // V[0..7] = H[0..7]
        v_init_val[1023:960] = IV[0];
        v_init_val[959:896]  = IV[1];
        v_init_val[895:832]  = IV[2];
        v_init_val[831:768]  = IV[3];
        v_init_val[767:704]  = IV[4];
        v_init_val[703:640]  = IV[5];
        v_init_val[639:576]  = IV[6];
        v_init_val[575:512]  = IV[7];
        // V[8..11] = cb
        v_init_val[511:448] = cb[0];
        v_init_val[447:384] = cb[1];
        v_init_val[383:320] = cb[2];
        v_init_val[319:256] = cb[3];
        v_init_val[255:192] = 64'h452821E638D011F7; // T0(640) ^ cb4
        v_init_val[191:128] = 64'hBE5466CF34E90EEC; // T0(640) ^ cb5
        v_init_val[127:64]  = cb[6];
        v_init_val[63:0]    = cb[7];
    end

    // sigma table (MUX)
    always @(*) begin
        case (counter_idx[6:3]) 
            4'd0, 4'd10: sigma_row = 64'h0123456789ABCDEF;
            4'd1, 4'd11: sigma_row = 64'hEA489FD61C02B753;
            4'd2, 4'd12: sigma_row = 64'hB8C052FDAE367194;
            4'd3, 4'd13: sigma_row = 64'h7931DCBE265A40F8;
            4'd4, 4'd14: sigma_row = 64'h905724AFE1BC683D;
            4'd5, 4'd15: sigma_row = 64'h2C6A0B834D75FE19;
            4'd6:        sigma_row = 64'hC51FED4A0763928B;
            4'd7:        sigma_row = 64'hDB7EC13950F4862A;
            4'd8:        sigma_row = 64'h6FE9B308C2D714A5;
            4'd9:        sigma_row = 64'hA2847615FB9E3CD0;
            default:     sigma_row = 64'h0;
        endcase
    end


    // -------------------------------------------------------------------------
    // 2. Register
    // -------------------------------------------------------------------------
    //msg register
    integer i;
    always @(posedge clk or negedge rstb)begin
        if (!rstb) begin
            for (i =0; i<16; i = i+1) begin
                msg[i] <= 64'd0;
            end
        end
        else if (ctrl_finalize) begin
            for (i =0; i<16; i = i+1) begin
                msg[i] <= 64'd0;
            end
        end else if (init_round) begin
            msg[0]  <= state_buf[1023:960];
            msg[1]  <= state_buf[959:896];
            msg[2]  <= state_buf[895:832];
            msg[3]  <= state_buf[831:768];
            msg[4]  <= state_buf[767:704];
            msg[5]  <= state_buf[703:640];
            msg[6]  <= state_buf[639:576];
            msg[7]  <= state_buf[575:512];
            msg[8]  <= state_buf[511:448];
            msg[9]  <= state_buf[447:384];
            msg[10] <= state_buf[383:320];
            msg[11] <= state_buf[319:256];
            msg[12] <= state_buf[255:192];
            msg[13] <= state_buf[191:128];
            msg[14] <= state_buf[127:64];
            msg[15] <= state_buf[63:0];
        end 
    end


    //state register
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= 1024'd0;
        end
        else if (init_round) begin   //initial
            state <= v_init_val;
        end
        else if (round_ing) begin    //update
            state <= v_state;
        end
        else if (ctrl_finalize) begin
            state <= state;
        end

    end

    // -------------------------------------------------------------------------
    // 3. MUX
    // -------------------------------------------------------------------------
    //msg_mux
    always @(*) begin
        case (step)
            3'd0: begin m0 = msg[sigma_row[63:60]]; m1 = msg[sigma_row[59:56]]; k0 = cb[sigma_row[63:60]];  k1 = cb[sigma_row[59:56]]; end
            3'd1: begin m0 = msg[sigma_row[55:52]]; m1 = msg[sigma_row[51:48]]; k0 = cb[sigma_row[55:52]];  k1 = cb[sigma_row[51:48]]; end
            3'd2: begin m0 = msg[sigma_row[47:44]]; m1 = msg[sigma_row[43:40]]; k0 = cb[sigma_row[47:44]];  k1 = cb[sigma_row[43:40]]; end
            3'd3: begin m0 = msg[sigma_row[39:36]]; m1 = msg[sigma_row[35:32]]; k0 = cb[sigma_row[39:36]];  k1 = cb[sigma_row[35:32]]; end
            3'd4: begin m0 = msg[sigma_row[31:28]]; m1 = msg[sigma_row[27:24]]; k0 = cb[sigma_row[31:28]];  k1 = cb[sigma_row[27:24]]; end
            3'd5: begin m0 = msg[sigma_row[23:20]]; m1 = msg[sigma_row[19:16]]; k0 = cb[sigma_row[23:20]];  k1 = cb[sigma_row[19:16]]; end
            3'd6: begin m0 = msg[sigma_row[15:12]]; m1 = msg[sigma_row[11:8]]; k0 = cb[sigma_row[15:12]];  k1 = cb[sigma_row[11:8]]; end
            3'd7: begin m0 = msg[sigma_row[7:4]];   m1 = msg[sigma_row[3:0]]; k0 = cb[sigma_row[7:4]];    k1 = cb[sigma_row[3:0]]; end
            default: begin m0 = 64'd0; m1 = 64'd0; k0 = 64'd0; k1 = 64'd0; end
        endcase
    end 
        //state mux
       always @(*) begin
        // Column Step 
         case (step)
            3'd0: begin a_in = state[1023:960]; b_in = state[767:704]; c_in = state[511:448];  d_in = state[255:192];  end // (V0, V4, V8, V12)
            3'd1: begin a_in = state[959:896];  b_in = state[703:640]; c_in = state[447:384];  d_in = state[191:128];  end // (V1, V5, V9, V13)
            3'd2: begin a_in = state[895:832];  b_in = state[639:576]; c_in = state[383:320];  d_in = state[127:64];   end // (V2, V6, V10, V14)
            3'd3: begin a_in = state[831:768];  b_in = state[575:512]; c_in = state[319:256];  d_in = state[63:0];    end // (V3, V7, V11, V15)
            //Diagonal
            3'd4: begin a_in = state[1023:960]; b_in = state[703:640]; c_in = state[383:320];  d_in = state[63:0]; end // (V0, V5, V10, V15)   
            3'd5: begin a_in = state[959:896];  b_in = state[639:576]; c_in = state[319:256];  d_in = state[255:192]; end // (V1, V6, V11, V12)
            3'd6: begin a_in = state[895:832];  b_in = state[575:512]; c_in = state[511:448];  d_in = state[191:128]; end // (V2, V7, V8, V13)
            3'd7: begin a_in = state[831:768];  b_in = state[767:704]; c_in = state[447:384];  d_in = state[127:64];  end // (V3, V4, V9, V14)
            default: begin a_in = 64'd0; b_in = 64'd0; c_in = 64'd0; d_in = 64'd0; end
        endcase
    end
    

    // -------------------------------------------------------------------------
    // 4. G-Function & Feedback
    // -------------------------------------------------------------------------
    gcomp u_gcomp0 (
        .a_in(a_in), .b_in(b_in), .c_in(c_in), .d_in(d_in), .m0(m0), .m1(m1), .k0(k0), .k1(k1),
        .a_out(a_out), .b_out(b_out), .c_out(c_out), .d_out(d_out)
    );

    always @(*) begin
        v_state = state; 
        case (step)
            3'd0: begin v_state[1023:960]=a_out; v_state[767:704]=b_out; v_state[511:448]=c_out; v_state[255:192]=d_out; end
            3'd1: begin v_state[959:896]=a_out;  v_state[703:640]=b_out; v_state[447:384]=c_out; v_state[191:128]=d_out; end
            3'd2: begin v_state[895:832]=a_out;  v_state[639:576]=b_out; v_state[383:320]=c_out; v_state[127:64]=d_out;  end
            3'd3: begin v_state[831:768]=a_out;  v_state[575:512]=b_out; v_state[319:256]=c_out; v_state[63:0]=d_out;   end
            3'd4: begin v_state[1023:960]=a_out; v_state[703:640]=b_out; v_state[383:320]=c_out; v_state[63:0]=d_out;   end
            3'd5: begin v_state[959:896]=a_out;  v_state[639:576]=b_out; v_state[319:256]=c_out; v_state[255:192]=d_out; end
            3'd6: begin v_state[895:832]=a_out;  v_state[575:512]=b_out; v_state[511:448]=c_out; v_state[191:128]=d_out; end
            3'd7: begin v_state[831:768]=a_out;  v_state[767:704]=b_out; v_state[447:384]=c_out; v_state[127:64]=d_out;  end
            default : v_state = state;
        endcase
    end
    

    // -------------------------------------------------------------------------
    // 5. output_comb
    // -------------------------------------------------------------------------
    //v pack
    wire [63:0] v_final [0:15];

    genvar k;
    generate
        for(k=0; k<16; k=k+1) begin 
            assign v_final[k] = v_state[((15-k) << 6) +: 64]; 
        end
    endgenerate

    
    // h finalize
    reg [63:0] h [0:7];

    // 1) Sequential Logic
    integer j;
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            for(j=0; j<8; j=j+1) h[j] <= IV[j];
            rdy  <= 1'b0;
            dout <= 512'd0;
        end 
        else if (init_round) begin
            for(j=0; j<8; j=j+1) 
            h[j] <= IV[j];
            rdy  <= 1'b0;
            dout <= 512'd0;
        end
        else if (round_ing) begin
            for(j=0; j<8; j=j+1) h[j] <= IV[j];
            rdy  <= 1'b0;
            dout <= 512'd0;
        end
        else if (ctrl_finalize) begin
            rdy  <= 1'b1;
            dout <= {       
                h[0] ^ v_final[0] ^ v_final[8],
                h[1] ^ v_final[1] ^ v_final[9],
                h[2] ^ v_final[2] ^ v_final[10],
                h[3] ^ v_final[3] ^ v_final[11],
                h[4] ^ v_final[4] ^ v_final[12],
                h[5] ^ v_final[5] ^ v_final[13],
                h[6] ^ v_final[6] ^ v_final[14],
                h[7] ^ v_final[7] ^ v_final[15] };
        end
        else begin
            rdy <= 1'b0;
        end
    end 

    // 2) combinational logic
    /*integer j;
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            for(j=0; j<8; j=j+1) h[j] <= IV[j];
        end 
        //else if (clr_all) begin
        //    for(j=0; j<8; j=j+1) h[j] <= 64'd0; 
        //end
        else if (init_round) begin
            for(j=0; j<8; j=j+1) h[j] <= IV[j]; 
        end
        else if (round_ing) begin
            for(j=0; j<8; j=j+1) h[j] <= h[j];
        end
        else if (ctrl_finalize) begin
            h[0] <= h[0] ^ v_final[0] ^ v_final[8];
            h[1] <= h[1] ^ v_final[1] ^ v_final[9];
            h[2] <= h[2] ^ v_final[2] ^ v_final[10];
            h[3] <= h[3] ^ v_final[3] ^ v_final[11];
            h[4] <= h[4] ^ v_final[4] ^ v_final[12];
            h[5] <= h[5] ^ v_final[5] ^ v_final[13];
            h[6] <= h[6] ^ v_final[6] ^ v_final[14];
            h[7] <= h[7] ^ v_final[7] ^ v_final[15];
        end
    end

    //assign rdy = (counter_idx == 7'd127) ?  1'b1 : 1'b0;
    assign rdy = (ctrl_finalize);
    assign dout = (rdy) ? {
        h[0] ^ v_final[0] ^ v_final[8],
        h[1] ^ v_final[1] ^ v_final[9],
        h[2] ^ v_final[2] ^ v_final[10],
        h[3] ^ v_final[3] ^ v_final[11],
        h[4] ^ v_final[4] ^ v_final[12],
        h[5] ^ v_final[5] ^ v_final[13],
        h[6] ^ v_final[6] ^ v_final[14],
        h[7] ^ v_final[7] ^ v_final[15] 
    } : 512'd0; */

    
endmodule
