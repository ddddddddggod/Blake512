module blake_state_update (
    input  wire [1023:0] v_out,  
    input  wire [5:0]    counter_idx,       
    input  wire [63:0]   a1_out,      
    input  wire [63:0]   b1_out,      
    input  wire [63:0]   c1_out,      
    input  wire [63:0]   d1_out,
    input  wire [63:0]   a2_out,      
    input  wire [63:0]   b2_out,      
    input  wire [63:0]   c2_out,      
    input  wire [63:0]   d2_out,
    output reg  [1023:0] v_state_next      
);

    wire [1:0]  step = counter_idx[1:0];

    reg [255:0] vn_a;
    always @(*) begin
        vn_a = v_out[1023:768];
        case (step)
            2'd0: begin vn_a[255:192] = a1_out; vn_a[191:128] = a2_out; end
            2'd1: begin vn_a[127:64]  = a1_out; vn_a[63:0]   = a2_out; end
            2'd2: begin vn_a[255:192] = a1_out; vn_a[191:128] = a2_out; end
            2'd3: begin vn_a[127:64]  = a1_out; vn_a[63:0]   = a2_out; end
        endcase
    end

    reg [255:0] vn_b;
    always @(*) begin
        vn_b = v_out[767:512]; 
        case (step)
            2'd0: begin vn_b[255:192] = b1_out; vn_b[191:128] = b2_out; end
            2'd1: begin vn_b[127:64]  = b1_out; vn_b[63:0]   = b2_out;  end
            2'd2: begin vn_b[191:128] = b1_out; vn_b[127:64]  = b2_out; end
            2'd3: begin vn_b[63:0]    = b1_out; vn_b[255:192] = b2_out; end
        endcase
    end

    reg [255:0] vn_c;
    always @(*) begin
        vn_c = v_out[511:256]; 
        case (step)
            2'd0: begin vn_c[255:192] = c1_out; vn_c[191:128] = c2_out; end
            2'd1: begin vn_c[127:64]  = c1_out; vn_c[63:0]   = c2_out; end
            2'd2: begin vn_c[127:64]  = c1_out; vn_c[63:0]   = c2_out; end
            2'd3: begin vn_c[255:192] = c1_out; vn_c[191:128] = c2_out; end
        endcase
    end

    reg [255:0] vn_d;
    always @(*) begin
        vn_d = v_out[255:0]; 
        case (step)
            2'd0: begin vn_d[255:192] = d1_out; vn_d[191:128] = d2_out;  end
            2'd1: begin vn_d[127:64]  = d1_out; vn_d[63:0]   = d2_out; end
            2'd2: begin vn_d[63:0]    = d1_out; vn_d[255:192] = d2_out; end
            2'd3: begin vn_d[191:128] = d1_out; vn_d[127:64]  = d2_out; end
        endcase
    end

    assign v_state_next = {vn_a, vn_b, vn_c, vn_d};

endmodule
