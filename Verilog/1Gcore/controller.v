//Moore FSM
module controller 
(
    input              clk,
    input              rstb,       
    input              ena, //enable신호

    output reg         ctrl_finalize, // finialize
    output reg         init_round,    // V initialize 
    output reg [6:0]   counter_idx, //counter index 
    output reg         round_ing,  // counter
    output reg          clr_all
);

    // state 
    localparam [1:0] st_idle  = 2'd0; //wait
    localparam [1:0] st_counter = 2'd1; //round
    localparam [1:0] st_fin = 2'd2; //finish
    localparam [1:0] st_clear = 2'd3; //register clear

    reg [1:0] state, state_n; 
    reg [6:0] counter, counter_n;

    // -------------------------------------------------------------------------
    // Next-state logic (combinational)
    // -------------------------------------------------------------------------
    always @(*) begin
        state_n = state;
        counter_n = counter;

        case (state)
            st_idle: begin
                if (ena) begin
                    state_n = st_counter;
                    counter_n = 7'd0;  
                end else begin
                    state_n = st_idle;
                    counter_n = 7'd0; 
                end
            end

            st_counter: begin
                if (counter < 7'd126) begin
                    counter_n = counter + 7'd1;
                    state_n = st_counter;
                end else begin
                    counter_n = 7'd127;
                    state_n = st_fin; 
                end
            end

            st_fin: begin
                state_n = st_clear; 
                counter_n = 7'd0;  
            end

            st_clear : begin
                state_n = st_idle;
                counter_n = 7'd0;
            end

            default: begin
                state_n = st_idle;
                counter_n = 7'd0;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // Current State Register (Sequential) 
    // ------------------------------------------------------------------------- 
    always @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin 
            state <= st_idle;
            counter <= 7'd0;
        end else begin
            state <= state_n;
            counter <= counter_n;
        end
    end
    // -------------------------------------------------------------------------
    // Output logic (Combinational)
    // -------------------------------------------------------------------------
    always @(*) begin
        init_round    = (state == st_idle && ena);
        round_ing = (state == st_counter);  
        ctrl_finalize = (state == st_fin); //rdy
        clr_all = (state == st_clear);
        counter_idx = counter;
    end


endmodule
