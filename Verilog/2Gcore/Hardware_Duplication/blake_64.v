`timescale 1ns/10ps

module blake_64 (

input          clk,
input          rstb,

input          ena,
input  [639:0] din,

output         rdy,
output [511:0] dout
);

   // ---------------------------------------------------------
    //  FSM 
    // ---------------------------------------------------------
    wire [5:0]  counter_idx;
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
        .count_done   (count_done),
        .v_state_next (v_state_next),
        .v_out        (v_out)
    );

    // ---------------------------------------------------------
    // 4. State Mux 
    // ---------------------------------------------------------
    wire [63:0] a1_in, b1_in, c1_in, d1_in;      //State mux -> GB
    wire [63:0] a2_in, b2_in, c2_in, d2_in;
    blake_state_mux u_state_mux (
        .v_out        (v_out),
        .counter_idx  (counter_idx),
        .a1_in         (a1_in),
        .b1_in         (b1_in),
        .c1_in         (c1_in),
        .d1_in         (d1_in),
        .a2_in         (a2_in),
        .b2_in         (b2_in),
        .c2_in         (c2_in),
        .d2_in         (d2_in)
    );

    // ---------------------------------------------------------
    // 5. Message Mux 
    // ---------------------------------------------------------
    wire [63:0] m0_1, m1_1, k0_1, k1_1;
    wire [63:0] m0_2, m1_2, k0_2, k1_2;          // Msg Mux -> GB
    blake_msg_mux u_msg_mux (
        .msg_out      (msg_out),
        .counter_idx  (counter_idx),
        .m0_1          (m0_1),
        .m1_1          (m1_1),
        .k0_1          (k0_1),
        .k1_1          (k1_1),
        .m0_2          (m0_2),
        .m1_2          (m1_2),
        .k0_2          (k0_2),
        .k1_2          (k1_2)
    );

    // ---------------------------------------------------------
    // 6. G-Function Block 
    // ---------------------------------------------------------
    wire [63:0] a1_out, b1_out, c1_out, d1_out; 
    wire [63:0] a2_out, b2_out, c2_out, d2_out;
    blake_gcomp u_gcomp1 (
        .a_in         (a1_in),
        .b_in         (b1_in),
        .c_in         (c1_in),
        .d_in         (d1_in),
        .m0           (m0_1),
        .m1           (m1_1),
        .k0           (k0_1),
        .k1           (k1_1),
        .a_out        (a1_out),
        .b_out        (b1_out),
        .c_out        (c1_out),
        .d_out        (d1_out)
    );

    blake_gcomp u_gcomp2 (
        .a_in         (a2_in),
        .b_in         (b2_in),
        .c_in         (c2_in),
        .d_in         (d2_in),
        .m0           (m0_2),
        .m1           (m1_2),
        .k0           (k0_2),
        .k1           (k1_2),
        .a_out        (a2_out),
        .b_out        (b2_out),
        .c_out        (c2_out),
        .d_out        (d2_out)
    );

    // ---------------------------------------------------------
    // 7. State Update Logic 
    // ---------------------------------------------------------
    blake_state_update u_state_update (
        .v_out        (v_out),
        .counter_idx  (counter_idx),
        .a1_out        (a1_out),
        .b1_out        (b1_out),
        .c1_out        (c1_out),
        .d1_out        (d1_out),
        .a2_out        (a2_out),
        .b2_out        (b2_out),
        .c2_out        (c2_out),
        .d2_out        (d2_out),
        .v_state_next (v_state_next)
    );

    // ---------------------------------------------------------
    // 8. Finalization 
    // ---------------------------------------------------------
    blake_finalize u_finalize (
        .clk              (clk),
        .rstb             (rstb),
        .init_round       (init_round),
        .count_done       (count_done),
        .v_state_next     (v_state_next),
        .dout             (dout)
    );

endmodule
