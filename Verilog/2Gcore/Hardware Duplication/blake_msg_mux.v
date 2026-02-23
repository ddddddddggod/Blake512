module blake_msg_mux(
    input wire [5:0] counter_idx,
    input wire [639:0]   msg_out,
    output reg [63:0] m0_1, m1_1, k0_1 ,k1_1,
    output reg [63:0] m0_2, m1_2, k0_2 ,k1_2
);

    //CB
    wire [63:0] cb [0:15];
    assign cb[0] = 64'h243F6A8885A308D3;
    assign cb[1] = 64'h13198A2E03707344;
    assign cb[2] = 64'hA4093822299F31D0; 
    assign cb[3] = 64'h082EFA98EC4E6C89;
    assign cb[4] = 64'h452821E638D01377; 
    assign cb[5] = 64'hBE5466CF34E90C6C;
    assign cb[6] = 64'hC0AC29B7C97C50DD; 
    assign cb[7] = 64'h3F84D5B5B5470917;
    assign cb[8] = 64'h9216D5D98979FB1B; 
    assign cb[9] = 64'hD1310BA698DFB5AC;
    assign cb[10] = 64'h2FFD72DBD01ADFB7; 
    assign cb[11] = 64'hB8E1AFED6A267E96;
    assign cb[12] = 64'hBA7C9045F12C7F99; 
    assign cb[13] = 64'h24A19947B3916CF7;
    assign cb[14] = 64'h0801F2E2858EFC16; 
    assign cb[15] = 64'h636920D871574E69;

    //sigma MUX
    reg  [63:0] sigma_row;
    always @(*) begin
        case (counter_idx[5:2]) 
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

    //Padding
    wire [63:0] msg_words [0:15];
    assign msg_words[0] = msg_out[639:576];
    assign msg_words[1] = msg_out[575:512];
    assign msg_words[2] = msg_out[511:448];
    assign msg_words[3] = msg_out[447:384];
    assign msg_words[4] = msg_out[383:320];
    assign msg_words[5] = msg_out[319:256];
    assign msg_words[6] = msg_out[255:192];
    assign msg_words[7] = msg_out[191:128];
    assign msg_words[8] = msg_out[127:64];
    assign msg_words[9] = msg_out[63:0];
    assign msg_words[10] = {8'h80, 56'h0};                
    assign msg_words[11] = 64'h0;                          
    assign msg_words[12] = 64'h0;                          
    assign msg_words[13] = {56'h0, 8'h01};                 
    assign msg_words[14] = 64'h0;                          
    assign msg_words[15] = 64'h0000_0000_0000_0280;
    
//---------msg_Mux--------------------
    wire [1:0]  step = counter_idx[1:0];
    reg [3:0] idx0_1, idx1_1, idx0_2, idx1_2;

//G1,3,5,7
    always @(*) begin
        case (step)
            2'd0: begin idx0_1 = sigma_row[63:60]; end //column
            2'd1: begin idx0_1 = sigma_row[47:44]; end //column
            2'd2: begin idx0_1 = sigma_row[31:28]; end //diagonal
            2'd3: begin idx0_1 = sigma_row[15:12]; end //diagonal
            default: begin idx0_1 = 4'd0; end
        endcase
    end

    always @(*) begin
        case (step)
            2'd0: begin idx1_1 = sigma_row[59:56]; end 
            2'd1: begin idx1_1 = sigma_row[43:40]; end 
            2'd2: begin idx1_1 = sigma_row[27:24]; end 
            2'd3: begin idx1_1 = sigma_row[11:8];  end 
            default: begin idx1_1 = 4'd0; end
        endcase
    end

//G2,4,6,8
    always @(*) begin
        case (step)
            2'd0: begin idx0_2 = sigma_row[55:52]; end 
            2'd1: begin idx0_2 = sigma_row[39:36]; end 
            2'd2: begin idx0_2 = sigma_row[23:20]; end 
            2'd3: begin idx0_2 = sigma_row[7:4];   end 
            default: begin idx0_2 = 4'd0; end
        endcase
    end
    always @(*) begin
        case (step)
            2'd0: begin idx1_2 = sigma_row[51:48]; end 
            2'd1: begin idx1_2 = sigma_row[35:32]; end 
            2'd2: begin idx1_2 = sigma_row[19:16]; end 
            2'd3: begin idx1_2 = sigma_row[3:0];   end 
            default: begin idx1_2 = 4'd0; end
        endcase
    end


   assign m0_1 = msg_words[idx0_1];
   assign m1_1 = msg_words[idx1_1];
   assign k0_1 = cb[idx0_1];       
   assign k1_1 = cb[idx1_1];

   assign m0_2 = msg_words[idx0_2];
   assign m1_2 = msg_words[idx1_2];
   assign k0_2 = cb[idx0_2];
   assign k1_2 = cb[idx1_2];


endmodule
