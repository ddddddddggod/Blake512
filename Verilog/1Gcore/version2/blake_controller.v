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

    reg state, state_n;

    //-----Next State(Combinational)------
    always @(*) begin
        state_n = st_idle;
        case (state)
            st_idle: state_n = (ena) ? st_counter : st_idle;
            st_counter: state_n = (count_done) ? st_idle : st_counter;
        endcase
    end

    //-----Current State (Sequential)-----
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= st_idle;
        end
        else begin    
           state <= state_n;
        end
    end

    //------Output Logic(Combinational)------
    assign init_round = (state == st_idle && ena); // enable signal => pulse
    assign round_ing = (state == st_counter);

endmodule
