module blake_finalize (
    input  wire          clk,
    input  wire          rstb,
    input  wire          init_round,
    input wire           count_done, 
    input wire           rdy,   
    input  wire [1023:0] v_state_next,                    
    output reg  [511:0]  dout           
);

    // IV512
    wire [63:0] IV [0:7];
    assign IV[0] = 64'h6A09E667F3BCC908; 
    assign IV[1] = 64'hBB67AE8584CAA73B;
    assign IV[2] = 64'h3C6EF372FE94F82B; 
    assign IV[3] = 64'hA54FF53A5F1D36F1;
    assign IV[4] = 64'h510E527FADE682D1; 
    assign IV[5] = 64'h9B05688C2B3E6C1F;
    assign IV[6] = 64'h1F83D9ABFB41BD6B; 
    assign IV[7] = 64'h5BE0CD19137E2179;

    //bit slicing
    wire [63:0] v [0:15];
    assign v[0]  = v_state_next[1023:960]; assign v[1]  = v_state_next[959:896];
    assign v[2]  = v_state_next[895:832];  assign v[3]  = v_state_next[831:768];
    assign v[4]  = v_state_next[767:704];  assign v[5]  = v_state_next[703:640];
    assign v[6]  = v_state_next[639:576];  assign v[7]  = v_state_next[575:512];
    assign v[8]  = v_state_next[511:448];  assign v[9]  = v_state_next[447:384];
    assign v[10] = v_state_next[383:320];  assign v[11] = v_state_next[319:256];
    assign v[12] = v_state_next[255:192];  assign v[13] = v_state_next[191:128];
    assign v[14] = v_state_next[127:64];   assign v[15] = v_state_next[63:0];

    // ---------------------------------------------------------
    // 1. Sequential_129cycle
    // ---------------------------------------------------------

    reg [63:0] h [0:7];
    wire [1023:0] init_value = { 
    h[0] ^ v[0] ^ v[8],
    h[1] ^ v[1] ^ v[9],
    h[2] ^ v[2] ^ v[10],
    h[3] ^ v[3] ^ v[11],
    h[4] ^ v[4] ^ v[12],
    h[5] ^ v[5] ^ v[13],
    h[6] ^ v[6] ^ v[14],
    h[7] ^ v[7] ^ v[15] 
    };

    //initialize
    genvar i;
    generate 
    for (i = 0; i < 16; i = i+1 ) begin
        always @(posedge clk or negedge rstb) begin
            if (!rstb) begin
                h[i] <= IV[i];
            end 
            else if (init_round) begin
                h[i] <= IV[i];
            end
        end
    end
    endgenerate

    //output
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            dout <= 512'd0;
        end 
        else if (count_done) begin
            dout <= init_value;
        end 
        else if (init_round) begin
            dout <= 512'd0;
        end
    end 

endmodule
