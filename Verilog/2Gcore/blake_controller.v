module blake_controller (
    input  wire        clk,
    input  wire        rstb,       
    input  wire        ena,
    input wire         count_done,
    output wire        init_round,
    output wire        round_ing
);
    localparam  st_idle  = 1'b0; //initialization
    localparam  st_running = 1'b1; //rounding

    reg state,state_n;

    //----- Next State (Combinational) ----
    always @(*) begin
        state_n = state; 
        case (state)
            st_idle: begin
                if (ena) begin
                    state_n = st_running;
                end
                else begin
                    state_n = st_idle;
                end
            end
            st_running: begin
                if (count_done && !ena) begin
                    state_n = st_idle;
                end
                else begin
                    state_n = st_running;
                end
            end
        endcase
    end

    //----- Current State (Sequential) -----
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            state <= st_idle;
        end
        else begin
            state <= state_n;
        end
    end

    //------ Output Logic ------
    assign init_round = ena;
    assign round_ing = (state == st_running); 

endmodule
