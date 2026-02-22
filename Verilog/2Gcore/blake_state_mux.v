module blake_state_mux(
	input wire [1023:0] v_out,
	input wire [5:0]	counter_idx,
	output reg [63:0]   a1_in,
	output reg [63:0]   b1_in,
	output reg [63:0]   c1_in,
	output reg [63:0]   d1_in,

    output reg [63:0]   a2_in,
    output reg [63:0]   b2_in,
    output reg [63:0]   c2_in,
    output reg [63:0]   d2_in
);

    wire [1:0]  step = counter_idx[1:0];

    always @(*) begin 
        case (step)
            2'd0: begin a1_in = v_out[1023:960]; end // v0 (Col 0)
            2'd1: begin a1_in = v_out[895:832];  end // v2 (Col 2)
            2'd2: begin a1_in = v_out[1023:960]; end // v0 (Diag 0)
            2'd3: begin a1_in = v_out[895:832];  end // v2 (Diag 2)
            default: begin a1_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin a2_in = v_out[959:896];  end // v1 (Col 1)
            2'd1: begin a2_in = v_out[831:768];  end // v3 (Col 3)
            2'd2: begin a2_in = v_out[959:896];  end // v1 (Diag 1)
            2'd3: begin a2_in = v_out[831:768];  end // v3 (Diag 3)
            default: begin a2_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin b1_in = v_out[767:704]; end // v4 (Col 0)
            2'd1: begin b1_in = v_out[639:576]; end // v6 (Col 2)
            2'd2: begin b1_in = v_out[703:640]; end // v5 (Diag 0)
            2'd3: begin b1_in = v_out[575:512]; end // v7 (Diag 2)
            default: begin b1_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin b2_in = v_out[703:640]; end // v5 (Col 1)
            2'd1: begin b2_in = v_out[575:512]; end // v7 (Col 3)
            2'd2: begin b2_in = v_out[639:576]; end // v6 (Diag 1)
            2'd3: begin b2_in = v_out[767:704]; end // v4 (Diag 3)
            default: begin b2_in = 64'd0;end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin c1_in = v_out[511:448]; end // v8 (Col 0)
            2'd1: begin c1_in = v_out[383:320]; end // v10 (Col 2)
            2'd2: begin c1_in = v_out[383:320]; end // v10 (Diag 0)
            2'd3: begin c1_in = v_out[511:448]; end // v8 (Diag 2)
            default: begin c1_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin c2_in = v_out[447:384]; end // v9 (Col 1)
            2'd1: begin c2_in = v_out[319:256]; end // v11 (Col 3)
            2'd2: begin c2_in = v_out[319:256]; end // v11 (Diag 1)
            2'd3: begin c2_in = v_out[447:384]; end // v9 (Diag 3)
            default: begin c2_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin d1_in = v_out[255:192];end // v12 (Col 0)
            2'd1: begin d1_in = v_out[127:64]; end // v14 (Col 2)
            2'd2: begin d1_in = v_out[63:0];   end // v15 (Diag 0)
            2'd3: begin d1_in = v_out[191:128];end // v13 (Diag 2)
            default: begin d1_in = 64'd0; end
        endcase
    end

    always @(*) begin 
        case (step)
            2'd0: begin d2_in = v_out[191:128]; end// v13 (Col 1)
            2'd1: begin d2_in = v_out[63:0];    end// v15 (Col 3)
            2'd2: begin d2_in = v_out[255:192]; end// v12 (Diag 1)
            2'd3: begin d2_in = v_out[127:64];  end// v14 (Diag 3)
            default: begin d2_in = 64'd0; end
        endcase
    end

endmodule
