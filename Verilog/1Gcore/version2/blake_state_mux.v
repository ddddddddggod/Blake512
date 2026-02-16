module blake_state_mux(
	input wire [1023:0] v_out,
	input wire [6:0]	counter_idx,
	output reg [63:0] a_in,
	output reg [63:0] b_in,
	output reg [63:0] c_in,
	output reg [63:0] d_in

);
    wire [2:0]  step = counter_idx[2:0];
    always @(*) begin 
         case (step)
         	// Column Step
            3'd0: begin a_in = v_out[1023:960]; b_in = v_out[767:704]; c_in = v_out[511:448];  d_in = v_out[255:192];  end // (V0, V4, V8, V12)
            3'd1: begin a_in = v_out[959:896];  b_in = v_out[703:640]; c_in = v_out[447:384];  d_in = v_out[191:128];  end // (V1, V5, V9, V13)
            3'd2: begin a_in = v_out[895:832];  b_in = v_out[639:576]; c_in = v_out[383:320];  d_in = v_out[127:64];   end // (V2, V6, V10, V14)
            3'd3: begin a_in = v_out[831:768];  b_in = v_out[575:512]; c_in = v_out[319:256];  d_in = v_out[63:0];    end // (V3, V7, V11, V15)
            //Diagonal
            3'd4: begin a_in = v_out[1023:960]; b_in = v_out[703:640]; c_in = v_out[383:320];  d_in = v_out[63:0]; end // (V0, V5, V10, V15)   
            3'd5: begin a_in = v_out[959:896];  b_in = v_out[639:576]; c_in = v_out[319:256];  d_in = v_out[255:192]; end // (V1, V6, V11, V12)
            3'd6: begin a_in = v_out[895:832];  b_in = v_out[575:512]; c_in = v_out[511:448];  d_in = v_out[191:128]; end // (V2, V7, V8, V13)
            3'd7: begin a_in = v_out[831:768];  b_in = v_out[767:704]; c_in = v_out[447:384];  d_in = v_out[127:64];  end // (V3, V4, V9, V14)
            default: begin a_in = 64'd0; b_in = 64'd0; c_in = 64'd0; d_in = 64'd0; end
        endcase
    end

endmodule
