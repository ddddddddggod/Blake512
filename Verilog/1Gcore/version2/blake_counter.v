module blake_counter (
    input  wire       clk,
    input  wire       rstb,         
    input  wire       round_ing,    
    output reg [6:0]  counter_idx,
    output wire       count_done
);

    assign count_done = (counter_idx == 7'd127);

    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            counter_idx <= 7'd0;
        end else if (round_ing) begin
            if (count_done) begin 
                counter_idx <= 7'd0;
            end else begin      
                counter_idx <= counter_idx + 7'd1;
            end
        end else begin
            counter_idx <= 7'd0;
        end
    end
endmodule
