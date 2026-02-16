module blake_msg_reg (
	input wire clk,
	input wire rstb,
	input wire [639:0] din_swapped,
    input wire init_round,
    input wire round_ing,
	output reg [639:0] msg_out
	);


    integer i;
    always @(posedge clk or negedge rstb)begin
        if (!rstb) begin
            msg_out <= 640'd0;
        end else if (init_round) begin
            msg_out <= din_swapped;
        end else if (round_ing) begin
            msg_out <= msg_out;
        end else begin
            msg_out <= 640'd0;
        end
    end

endmodule
