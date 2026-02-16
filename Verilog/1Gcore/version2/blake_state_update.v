module blake_state_update (
    input  wire [1023:0] v_out,  
    input  wire [6:0]    counter_idx,       
    input  wire [63:0]   a_out,      
    input  wire [63:0]   b_out,      
    input  wire [63:0]   c_out,      
    input  wire [63:0]   d_out,      

    output reg  [1023:0] v_state_next      
);

wire [2:0]  step = counter_idx[2:0];
    always @(*) begin
        v_state_next = v_out;
        case (step)
            // Column Step (
            3'd0: begin v_state_next[1023:960]=a_out; v_state_next[767:704]=b_out; v_state_next[511:448]=c_out; v_state_next[255:192]=d_out; end
            3'd1: begin v_state_next[959:896]=a_out;  v_state_next[703:640]=b_out; v_state_next[447:384]=c_out; v_state_next[191:128]=d_out; end
            3'd2: begin v_state_next[895:832]=a_out;  v_state_next[639:576]=b_out; v_state_next[383:320]=c_out; v_state_next[127:64]=d_out;  end
            3'd3: begin v_state_next[831:768]=a_out;  v_state_next[575:512]=b_out; v_state_next[319:256]=c_out; v_state_next[63:0]=d_out;   end
            // Diagonal Step
            3'd4: begin v_state_next[1023:960]=a_out; v_state_next[703:640]=b_out; v_state_next[383:320]=c_out; v_state_next[63:0]=d_out;   end
            3'd5: begin v_state_next[959:896]=a_out;  v_state_next[639:576]=b_out; v_state_next[319:256]=c_out; v_state_next[255:192]=d_out; end
            3'd6: begin v_state_next[895:832]=a_out;  v_state_next[575:512]=b_out; v_state_next[511:448]=c_out; v_state_next[191:128]=d_out; end
            3'd7: begin v_state_next[831:768]=a_out;  v_state_next[767:704]=b_out; v_state_next[447:384]=c_out; v_state_next[127:64]=d_out;  end
        endcase
    end

endmodule
