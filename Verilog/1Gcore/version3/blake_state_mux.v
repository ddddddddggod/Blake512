module blake_state_mux(
	input wire [1023:0] v_out,
	input wire [6:0]	counter_idx,
	output reg [63:0]   a_in,
	output reg [63:0]   b_in,
	output reg [63:0]   c_in,
	output reg [63:0]   d_in
);

    wire [2:0]  step = counter_idx[2:0];
    always @(*) begin 
         case (step)
            3'd0: begin a_in = v_out[1023:960]; end
            3'd1: begin a_in = v_out[959:896]; end
            3'd2: begin a_in = v_out[895:832]; end
            3'd3: begin a_in = v_out[831:768]; end
            3'd4: begin a_in = v_out[1023:960]; end
            3'd5: begin a_in = v_out[959:896]; end
            3'd6: begin a_in = v_out[895:832]; end
            3'd7: begin a_in = v_out[831:768]; end
            default: begin a_in = 64'd0; end
        endcase
    end

    always @(*) begin 
         case (step)
            3'd0: begin b_in = v_out[767:704]; end 
            3'd1: begin b_in = v_out[703:640]; end 
            3'd2: begin b_in = v_out[639:576]; end 
            3'd3: begin b_in = v_out[575:512]; end 
            3'd4: begin b_in = v_out[703:640]; end    
            3'd5: begin b_in = v_out[639:576]; end 
            3'd6: begin b_in = v_out[575:512]; end 
            3'd7: begin b_in = v_out[767:704]; end 
            default: begin b_in = 64'd0; end
        endcase
    end

    always @(*) begin 
         case (step)
            3'd0: begin c_in = v_out[511:448]; end 
            3'd1: begin c_in = v_out[447:384]; end 
            3'd2: begin c_in = v_out[383:320]; end 
            3'd3: begin c_in = v_out[319:256]; end 
            3'd4: begin c_in = v_out[383:320]; end    
            3'd5: begin c_in = v_out[319:256]; end 
            3'd6: begin c_in = v_out[511:448]; end 
            3'd7: begin c_in = v_out[447:384]; end 
            default: begin c_in = 64'd0; end
        endcase
    end

    always @(*) begin 
         case (step)
            3'd0: begin d_in = v_out[255:192];  end
            3'd1: begin d_in = v_out[191:128];  end
            3'd2: begin d_in = v_out[127:64];   end
            3'd3: begin d_in = v_out[63:0];    end 
            3'd4: begin d_in = v_out[63:0]; end  
            3'd5: begin d_in = v_out[255:192]; end 
            3'd6: begin d_in = v_out[191:128]; end 
            3'd7: begin d_in = v_out[127:64];  end 
            default: begin d_in = 64'd0; end
        endcase
    end
endmodule
