module blake_msg_mux(
	input wire [6:0] counter_idx,
	input wire [639:0]   msg_out,
	output reg [63:0] m0, m1, k0 ,k1 
);

	//CB
	wire [63:0] cb [0:15];
	assign cb[0] = 64'h243F6A8885A308D3; assign cb[1] = 64'h13198A2E03707344;
	assign cb[2] = 64'hA4093822299F31D0; assign cb[3] = 64'h082EFA98EC4E6C89;
    assign cb[4] = 64'h452821E638D01377; assign cb[5] = 64'hBE5466CF34E90C6C;
    assign cb[6] = 64'hC0AC29B7C97C50DD; assign cb[7] = 64'h3F84D5B5B5470917;
    assign cb[8] = 64'h9216D5D98979FB1B; assign cb[9] = 64'hD1310BA698DFB5AC;
    assign cb[10] = 64'h2FFD72DBD01ADFB7; assign cb[11] = 64'hB8E1AFED6A267E96;
    assign cb[12] = 64'hBA7C9045F12C7F99; assign cb[13] = 64'h24A19947B3916CF7;
    assign cb[14] = 64'h0801F2E2858EFC16; assign cb[15] = 64'h636920D871574E69;

    //sigma MUX
	reg  [63:0] sigma_row;
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

	//padding
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
    wire [2:0]  step = counter_idx[2:0];
	always @(*) begin
	    case (step)
	        3'd0: begin m0 = msg_words[sigma_row[63:60]]; m1 = msg_words[sigma_row[59:56]]; k0 = cb[sigma_row[63:60]];  k1 = cb[sigma_row[59:56]]; end
	        3'd1: begin m0 = msg_words[sigma_row[55:52]]; m1 = msg_words[sigma_row[51:48]]; k0 = cb[sigma_row[55:52]];  k1 = cb[sigma_row[51:48]]; end
	        3'd2: begin m0 = msg_words[sigma_row[47:44]]; m1 = msg_words[sigma_row[43:40]]; k0 = cb[sigma_row[47:44]];  k1 = cb[sigma_row[43:40]]; end
	        3'd3: begin m0 = msg_words[sigma_row[39:36]]; m1 = msg_words[sigma_row[35:32]]; k0 = cb[sigma_row[39:36]];  k1 = cb[sigma_row[35:32]]; end
	        3'd4: begin m0 = msg_words[sigma_row[31:28]]; m1 = msg_words[sigma_row[27:24]]; k0 = cb[sigma_row[31:28]];  k1 = cb[sigma_row[27:24]]; end
	        3'd5: begin m0 = msg_words[sigma_row[23:20]]; m1 = msg_words[sigma_row[19:16]]; k0 = cb[sigma_row[23:20]];  k1 = cb[sigma_row[19:16]]; end
	        3'd6: begin m0 = msg_words[sigma_row[15:12]]; m1 = msg_words[sigma_row[11:8]]; k0 = cb[sigma_row[15:12]];  k1 = cb[sigma_row[11:8]]; end
	        3'd7: begin m0 = msg_words[sigma_row[7:4]];   m1 = msg_words[sigma_row[3:0]]; k0 = cb[sigma_row[7:4]];    k1 = cb[sigma_row[3:0]]; end
	        default: begin m0 = 64'd0; m1 = 64'd0; k0 = 64'd0; k1 = 64'd0; end
	    endcase
	 end 

endmodule
