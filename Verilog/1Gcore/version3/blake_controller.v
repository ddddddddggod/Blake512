module blake_controller (
    input  wire        clk,
    input  wire        rstb,       
    input  wire        ena,
    input wire         count_done,
    output wire        init_round,
    output wire        round_ing
);
    localparam  st_idle  = 1'b0; //initialization
    localparam  st_counter = 1'b1; //rounding

    reg state;
    wire state_n = state; 

    //----- Current State (Sequential) -----
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= st_idle; 
        end
        else begin    
            state <= (ena ^ count_done) ? ~state_n : state_n; 
        end
    end

    //------ Output Logic (One-line) ------
    assign init_round = ~state && ena;
    assign round_ing = state;

endmodule
