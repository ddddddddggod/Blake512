module blake_gcomp 
(
    input  [63:0]  m0, m1, 
    input  [63:0]  k0, k1, //CB
    input  [63:0]    a_in,
    input  [63:0]    b_in,
    input  [63:0]    c_in,
    input  [63:0]    d_in,
    output [63:0]    a_out,
    output [63:0]    b_out,
    output [63:0]    c_out,
    output [63:0]    d_out
);

    wire [63:0] a1, b1, c1, d1;
    wire [63:0] a2, b2, c2, d2;

    // --- Step 1 ---
    assign a1 = a_in + b_in + (m0 ^ k1);
    assign d1 = ((d_in ^ a1) >> 32)  | ((d_in ^ a1) << 32); // ROTR 32
    assign c1 = c_in + d1;
    assign b1 = ((b_in ^ c1) >> 25)  | ((b_in ^ c1) << 39); // ROTR 25 

    // --- step 2 ---
    assign a2 = a1 + b1 + (m1 ^ k0);
    assign d2 = ((d1 ^ a2) >> 16) | ((d1 ^ a2) << 48); // ROTR 16
    assign c2 = c1 + d2;
    assign b2 = ((b1 ^ c2) >> 11) |((b1 ^ c2) << 53); // ROTR 11

    // Output assignment
    assign a_out = a2;
    assign b_out = b2;
    assign c_out = c2;
    assign d_out = d2; 

endmodule
