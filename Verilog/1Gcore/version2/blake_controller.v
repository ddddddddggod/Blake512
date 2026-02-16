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
            st_idle: begin
                if (ena) begin 
                    state_n = st_counter; 
                end else begin 
                    state_n = st_idle; 
                end
            end
            st_counter: begin
                if (count_done) begin
                    state_n = st_idle;
                end else begin         
                    state_n = st_counter;
                end
            end
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
