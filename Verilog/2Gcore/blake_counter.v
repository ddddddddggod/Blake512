module blake_counter (
    input  wire       clk,
    input  wire       rstb,         
    input  wire       round_ing,    
    output reg [5:0]  counter_idx,
    output wire       count_done,
    output wire       rdy_from_counter       
);
    //counter
    assign count_done = (counter_idx == 6'd63);
    always @(posedge clk or negedge rstb) begin 
        if (!rstb) begin
            counter_idx <= 6'd0;
        end 
        else if (round_ing) begin
            if (count_done) counter_idx <= 6'd0;
            else            counter_idx <= counter_idx + 6'd1;
        end
    end

    //rdy signal
    reg [63:0] rdy_pipe;

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            rdy_pipe <= 64'b0;
        end else begin
            rdy_pipe <= {rdy_pipe[62:0], count_done};
        end
    end
    assign rdy_from_counter = rdy_pipe[63]; 

endmodule
