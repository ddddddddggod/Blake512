module blake (
    input  wire          clk,
    input  wire          rstb,
    input  wire          ena,   // 1일 때 해시 시작 (1클럭 펄스)
    input  wire [639:0]  din, // 80 Bytes 입력 데이터 (MSB가 첫 바이트)
    
    output wire [511:0]  dout, // 최종 해시값
    output reg          rdy      // 1일 때 rdy 유효 (완료 신호)
);

    // --- 내부 연결 와이어 ---
    wire [1023:0] padded_block; // 패딩된 128바이트 데이터
    wire          init_round;   // Controller -> Datapath (초기화 지시)
    wire [3:0]    round_idx;    // Controller -> Datapath (라운드 인덱스)
    wire          ctrl_finalize;// Controller -> Datapath (최종 XOR 지시)
    
    // -------------------------------------------------------------------------
    // 1. Padding Module 
    //    80바이트 입력을 받아 BLAKE 규격에 맞게 128바이트로 변환
    // -------------------------------------------------------------------------
    padding u_padding (
        .din       (din),
        .State_buf (padded_block)
    );

    // -------------------------------------------------------------------------
    // 2. Controller Module
    //    전체 흐름(Init -> Round 0~15 -> Finalize) 제어
    // -------------------------------------------------------------------------
    controller #(
        .NROUND(16)
    ) u_controller (
        .clk      (clk),
        .rstb     (rstb),
        .ena  (ena),
        
        .ctrl_finalize (ctrl_finalize), // 계산이 끝나면 Finalize 신호 발생
        .round_idx    (round_idx),     // 현재 라운드 번호
        .init_round   (init_round)     // 초기화 신호
    );

    // -------------------------------------------------------------------------
    // 3. Datapath Module
    //    실제 해시 연산 및 레지스터 관리 (roundreg 내장)
    // -------------------------------------------------------------------------
    blake_datapath u_datapath (
        .clk         (clk),
        .rstb       (rstb),
        .padded_block    (padded_block),
        
        // Control Signals
        .init_round  (init_round),
        .round_idx   (round_idx),
        .ctrl_finalize    (ctrl_finalize),
        
        // Output
        .dout    (dout)
    );

    // -------------------------------------------------------------------------
    // 4. Output Timing Alignment
    //    Datapath가 ctrl_finalize 신호를 받고 XOR하여 레지스터에 쓰는 데 1클럭이 소요되므로, done 신호를 1클럭 지연시켜 출력
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rstb) begin
        if (!rstb) begin
            rdy <= 1'b0;
        end else begin
            rdy <= ctrl_finalize;
        end
    end

endmodule
