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

    reg [255:0] vn_a;
    always @(*) begin
        vn_a = v_out[1023:768]; 
        case (step)
            3'd0: vn_a[255:192] = a_out; 
            3'd1: vn_a[191:128] = a_out; 
            3'd2: vn_a[127:64]  = a_out; 
            3'd3: vn_a[63:0]    = a_out;
            3'd4: vn_a[255:192] = a_out; 
            3'd5: vn_a[191:128] = a_out; 
            3'd6: vn_a[127:64]  = a_out; 
            3'd7: vn_a[63:0]    = a_out;  
        endcase
    end

    reg [255:0] vn_b;
    always @(*) begin
        vn_b = v_out[767:512]; 
        case (step)
            3'd0: vn_b[255:192] = b_out; 
            3'd1: vn_b[191:128] = b_out; 
            3'd2: vn_b[127:64]  = b_out; 
            3'd3: vn_b[63:0]    = b_out;
            3'd4: vn_b[191:128] = b_out; 
            3'd5: vn_b[127:64]  = b_out; 
            3'd6: vn_b[63:0]    = b_out; 
            3'd7: vn_b[255:192] = b_out;  
        endcase
    end

    reg [255:0] vn_c;
    always @(*) begin
        vn_c = v_out[511:256]; 
        case (step)
            3'd0: vn_c[255:192] = c_out; 
            3'd1: vn_c[191:128] = c_out; 
            3'd2: vn_c[127:64]  = c_out; 
            3'd3: vn_c[63:0]    = c_out;
            3'd4: vn_c[127:64]  = c_out; 
            3'd5: vn_c[63:0]    = c_out; 
            3'd6: vn_c[255:192] = c_out; 
            3'd7: vn_c[191:128] = c_out; 
        endcase
    end

    reg [255:0] vn_d;
    always @(*) begin
        vn_d = v_out[255:0]; 
        case (step)
            3'd0: vn_d[255:192] = d_out; 
            3'd1: vn_d[191:128] = d_out; 
            3'd2: vn_d[127:64]  = d_out; 
            3'd3: vn_d[63:0]    = d_out;
            3'd4: vn_d[63:0]    = d_out; 
            3'd5: vn_d[255:192] = d_out; 
            3'd6: vn_d[191:128] = d_out; 
            3'd7: vn_d[127:64]  = d_out; 
        endcase
    end

    assign v_state_next = {vn_a, vn_b, vn_c, vn_d};

endmodule
