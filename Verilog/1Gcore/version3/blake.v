module blake (
    input  wire          clk,
    input  wire          rstb,
    input  wire [639:0] din,   
    input  wire          ena,   
    output wire          rdy,   
    output wire [511:0]  dout   
); 
    

    // ---------------------------------------------------------
    //  FSM 
    // ---------------------------------------------------------
    wire [6:0]  counter_idx;
    wire        count_done;
    wire        round_ing;
    wire        init_round;

    blake_counter u_counter (
        .clk          (clk),
        .rstb         (rstb),
        .round_ing    (round_ing),
        .counter_idx  (counter_idx),
        .count_done   (count_done),
        .rdy          (rdy)
    );

    blake_controller u_controller (
        .clk          (clk),
        .rstb         (rstb),
        .ena          (ena),
        .count_done   (count_done),
        .init_round   (init_round),
        .round_ing    (round_ing)
    );

    // ---------------------------------------------------------
    // 1. input_processing
    // ---------------------------------------------------------
    wire [639:0] din_swapped; 
    blake_input_processing u_input_processing(
        .din         (din),
        .din_swapped (din_swapped)
        );

    // ---------------------------------------------------------
    // 2. Message Register 
    // ---------------------------------------------------------
    wire [639:0] msg_out;  
    blake_msg_reg u_msg_reg (
        .clk         (clk),
        .rstb        (rstb),
        .din_swapped (din_swapped),
        .init_round  (init_round),
        .round_ing   (round_ing),
        .msg_out     (msg_out)
    );


    // ---------------------------------------------------------
    // 3. V State Register
    // ---------------------------------------------------------
    wire [1023:0] v_out;
    wire [1023:0] v_state_next;       
    blake_state_reg u_state_reg (
        .clk          (clk),
        .rstb         (rstb),
        .round_ing    (round_ing),
        .init_round   (init_round),
        .v_state_next (v_state_next),
        .v_out        (v_out)
    );

    // ---------------------------------------------------------
    // 4. State Mux 
    // ---------------------------------------------------------
    wire [63:0] a_in, b_in, c_in, d_in;   // State Mux -> GB
    blake_state_mux u_state_mux (
        .v_out        (v_out),
        .counter_idx  (counter_idx),
        .a_in         (a_in),
        .b_in         (b_in),
        .c_in         (c_in),
        .d_in         (d_in)
    );

    // ---------------------------------------------------------
    // 5. Message Mux 
    // ---------------------------------------------------------
    wire [63:0] m0, m1, k0, k1;           // Msg Mux -> GB
    blake_msg_mux u_msg_mux (
        .msg_out      (msg_out),
        .counter_idx  (counter_idx),
        .m0           (m0),
        .m1           (m1),
        .k0           (k0),
        .k1           (k1)
    );

    // ---------------------------------------------------------
    // 6. G-Function Block 
    // ---------------------------------------------------------
    wire [63:0] a_out, b_out, c_out, d_out; 
    blake_gcomp u_gcomp (
        .a_in         (a_in),
        .b_in         (b_in),
        .c_in         (c_in),
        .d_in         (d_in),
        .m0           (m0),
        .m1           (m1),
        .k0           (k0),
        .k1           (k1),
        .a_out        (a_out),
        .b_out        (b_out),
        .c_out        (c_out),
        .d_out        (d_out)
    );

    // ---------------------------------------------------------
    // 7. State Update Logic 
    // ---------------------------------------------------------
    blake_state_update u_state_update (
        .v_out        (v_out),
        .counter_idx  (counter_idx),
        .a_out        (a_out),
        .b_out        (b_out),
        .c_out        (c_out),
        .d_out        (d_out),
        .v_state_next (v_state_next)
    );

    // ---------------------------------------------------------
    // 8. Finalization 
    // ---------------------------------------------------------
    blake_finalize u_finalize (
        .clk          (clk),
        .rstb         (rstb),
        .init_round   (init_round),
        .count_done   (count_done),
        .rdy          (rdy),
        .v_state_next (v_state_next),
        .rdy_out      (rdy_out),
        .dout         (dout)
    );


endmodule
