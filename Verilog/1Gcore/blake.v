module blake (
    input  wire          clk,
    input  wire          rstb,
    input  wire          ena,   
    input  wire [639:0]  din, 
    
    output wire [511:0]  dout, 
    output wire           rdy      
);

    wire          init_round;
    wire [6:0]    counter_idx;
    wire          ctrl_finalize;
    wire          round_ing;
    wire [1023:0] state_buf;
    wire          clr_all;   

    // --- 1. input processing (capture & bswap32) ---
    wire [639:0] din_swapped;
    genvar i;
    generate
        for (i = 0; i < 20; i = i + 1) begin 
        assign din_swapped[(i << 5) + 24 +: 8] = din[(i << 5) + 0  +: 8];
        assign din_swapped[(i << 5) + 16 +: 8] = din[(i << 5) + 8  +: 8];
        assign din_swapped[(i << 5) + 8  +: 8] = din[(i << 5) + 16 +: 8];
        assign din_swapped[(i << 5) + 0  +: 8] = din[(i << 5) + 24 +: 8];
        end
    endgenerate

    assign state_buf = {din_swapped, 8'h80, 240'h0, 8'h01, 64'h0, 64'h0000_0000_0000_0280};


    // --- 2. FSM ---
    controller  u_controller (
        .clk           (clk),
        .rstb          (rstb),
        .ena           (ena),
        .ctrl_finalize (ctrl_finalize),
        .counter_idx     (counter_idx),
        .init_round    (init_round),
        .round_ing     (round_ing),
        .clr_all        (clr_all)
    );

    // --- 3. Datapath Module ---
    blake_datapath u_blake_datapath (
        .clk           (clk),
        .rstb          (rstb),
        .state_buf     (state_buf),
        .init_round    (init_round),
        .counter_idx     (counter_idx),
        .ctrl_finalize (ctrl_finalize),
        .round_ing     (round_ing),
        .clr_all       (clr_all),
        .rdy            (rdy),
        .dout          (dout)
    );


endmodule
