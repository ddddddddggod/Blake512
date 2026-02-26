module blake_msg_reg (
    input wire clk,
    input wire rstb,
    input wire [639:0] din_swapped,
    input wire init_round,
    input wire round_ing,
    output wire [639:0] msg_out
    );

    blake_rbit_1 #(.N(640)) u_msg_buffer (
        .clk  (clk),
        .rstb (rstb),
        .ena  (init_round),         
        .din  (din_swapped),
        .dout (msg_out)      
    );

endmodule
