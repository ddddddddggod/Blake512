module controller #(
    parameter integer NROUND = 16
)
(
    input              clk,
    input              rstb,       
    input              ena, //enable신호

    output reg         ctrl_finalize, 
    output reg    [3:0]   round_idx,  //round index 0~15
    output reg         init_round       // V값을 초기값으로 세팅하는 것
);

    // state 
    localparam [1:0] ST_IDLE  = 2'd0; //입력대기
    localparam [1:0] ST_ROUND = 2'd1; //round계산
    localparam [1:0] ST_FIN = 2'd2; //완료

    //현재, 다음 상태
    reg [1:0] state, state_n; 
    reg [3:0] round, round_n;


    // -------------------------------------------------------------------------
    // Next-state / output logic (combinational)
    // -------------------------------------------------------------------------
    always @(*) begin
    
        state_n = state;
        round_n = round;
        ctrl_finalize = 1'b0;
        init_round     = 1'b0;

        case (state)
            // ---------------------------------------------------------------
            ST_IDLE: begin
                round_n = 4'd0;
                if (ena) begin
                    init_round = 1'b1; //초기화 신호
                    state_n = ST_ROUND;
                end
            end

            // ---------------------------------------------------------------

            ST_ROUND: begin
                if (round < (NROUND-1)) begin
                    round_n = round + 4'd1;
                    state_n = ST_ROUND;
                end else begin
                    state_n = ST_FIN; // 16번 끝나면 FIN로
                end
            end

            // ---------------------------------------------------------------
            ST_FIN: begin
                ctrl_finalize = 1'b1;  //done신호 high
                state_n = ST_IDLE; //다음 사이클에 IDLE로 복귀
                round_n = 4'd0;  //다시 초기화
            end

            // ---------------------------------------------------------------
            default: begin
                state_n = ST_IDLE; //신호가 없을 때 초기화로 지정
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // State / counter registers (sequential)
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin 
            state <= ST_IDLE;
            round <= 4'd0;
        end else begin
            state <= state_n;
            round <= round_n;
        end
    end

    //outputs
    always @(*) begin
        round_idx = round;
    end


endmodule
