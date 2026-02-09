module roundreg
#(
    parameter integer WWIDTH = 64
)
(
    input                       clk,
    input                       rstb,    // async reset, active-low
    input                       init_round,  // 초기화 신호 (controller)
    input       [3:0]           round_idx,  // round횟수 (controller)
    input       [WWIDTH*16-1:0] v_init_val, // v초기값 (datapath)
    input       [WWIDTH*16-1:0] block_reg,  // input data값 (datapath)

    output      [WWIDTH*16-1:0] v_current  // v현재값
);

    // -------------------------------------------------------------------------
    // GB함수를 위한 준비 (v_present, v_next, M배열)
    // -------------------------------------------------------------------------
    reg  [WWIDTH-1:0] v_present [0:15]; //현재 v값
    reg  [WWIDTH-1:0] v_next [0:15];    //다음 v값
    wire [WWIDTH-1:0] M [0:15];     //M배열

    // input을 M배열 형태로 (16개 * 64bit) 
    genvar gi;
    generate
        for (gi=0; gi<16; gi=gi+1) begin 
            assign M[gi] = block_reg[ (15-gi)*64 +: 64 ];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // GB input signals 
    // -------------------------------------------------------------------------
    //m0,m1,c0,c1값
    reg [WWIDTH-1:0] G0_m0, G0_m1, G0_k0, G0_k1; 
    reg [WWIDTH-1:0] G1_m0, G1_m1, G1_k0, G1_k1;
    reg [WWIDTH-1:0] G2_m0, G2_m1, G2_k0, G2_k1;
    reg [WWIDTH-1:0] G3_m0, G3_m1, G3_k0, G3_k1;
    reg [WWIDTH-1:0] G4_m0, G4_m1, G4_k0, G4_k1;
    reg [WWIDTH-1:0] G5_m0, G5_m1, G5_k0, G5_k1;
    reg [WWIDTH-1:0] G6_m0, G6_m1, G6_k0, G6_k1;
    reg [WWIDTH-1:0] G7_m0, G7_m1, G7_k0, G7_k1;

    // a,b,c,d값 output
    //Column
    wire [WWIDTH-1:0] G0AOxD, G0BOxD, G0COxD, G0DOxD;
    wire [WWIDTH-1:0] G1AOxD, G1BOxD, G1COxD, G1DOxD;
    wire [WWIDTH-1:0] G2AOxD, G2BOxD, G2COxD, G2DOxD;
    wire [WWIDTH-1:0] G3AOxD, G3BOxD, G3COxD, G3DOxD;
    //Diagonal
    wire [WWIDTH-1:0] G4AOxD, G4BOxD, G4COxD, G4DOxD;
    wire [WWIDTH-1:0] G5AOxD, G5BOxD, G5COxD, G5DOxD;
    wire [WWIDTH-1:0] G6AOxD, G6BOxD, G6COxD, G6DOxD;
    wire [WWIDTH-1:0] G7AOxD, G7BOxD, G7COxD, G7DOxD;

    // -------------------------------------------------------------------------
    // Sigma and CB constants via blake_const
    // -------------------------------------------------------------------------
    wire [3:0] sigma [0:15];      
    wire [WWIDTH-1:0] CB [0:15]; 

    genvar pj;
    generate
        //sigma값 가져오기
        for (pj=0; pj<16; pj=pj+1) begin 
            blake_const #(.WWIDTH(WWIDTH)) u_p (
                .round_idx (round_idx),
                .sigma_idx (pj[3:0]),
                .c_idx     (4'd0),
                .sigma_o   (sigma[pj]), 
                .c_o       () //필요없음
            );
        end
        //CB값 가져오기
        for (pj=0; pj<16; pj=pj+1) begin 
            blake_const #(.WWIDTH(WWIDTH)) u_c (
                .round_idx (4'd0),
                .sigma_idx (4'd0),
                .c_idx     (pj[3:0]),
                .sigma_o   (),  //필요없음
                .c_o       (CB[pj])    
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // v_next값 지정 (Mux 로직)
    // -------------------------------------------------------------------------
    integer j;
    always @(*) begin  
    // 1. 기본적으로 현재 값을 유지하도록 초기화
        for (j=0; j<16; j=j+1) begin
            v_next[j] = v_present[j];
        end

    // 2. 초기값 저장
        if (init_round == 1'b1) begin  //IV512
            for (j=0; j<16; j=j+1) begin
               v_next[j] = v_init_val[(15-j)*64 +: 64]; 
            end 
        end 
        else begin
    // 3. gcomp이후 값 저장 
        // gcomp diagonal step이후 연산 결과 v_next에 저장
            v_next[0]  = G4AOxD; v_next[5]  = G4BOxD; v_next[10] = G4COxD; v_next[15] = G4DOxD;
            v_next[1]  = G5AOxD; v_next[6]  = G5BOxD; v_next[11] = G5COxD; v_next[12] = G5DOxD;
            v_next[2]  = G6AOxD; v_next[7]  = G6BOxD; v_next[8]  = G6COxD; v_next[13] = G6DOxD;
            v_next[3]  = G7AOxD; v_next[4]  = G7BOxD; v_next[9]  = G7COxD; v_next[14] = G7DOxD;
        end 
    end 

    // -------------------------------------------------------------------------
    // GB input 선택 (Sigma 인덱스를 이용한 M, CB 선택)
    // -------------------------------------------------------------------------
    always @(*) begin
        G0_m0 = M[sigma[0]];  G0_m1 = M[sigma[1]];  G0_k0 = CB[sigma[1]]; G0_k1 = CB[sigma[0]]; 
        G1_m0 = M[sigma[2]];  G1_m1 = M[sigma[3]];  G1_k0 = CB[sigma[3]]; G1_k1 = CB[sigma[2]];
        G2_m0 = M[sigma[4]];  G2_m1 = M[sigma[5]];  G2_k0 = CB[sigma[5]]; G2_k1 = CB[sigma[4]];
        G3_m0 = M[sigma[6]];  G3_m1 = M[sigma[7]];  G3_k0 = CB[sigma[7]]; G3_k1 = CB[sigma[6]];
        
        G4_m0 = M[sigma[8]];  G4_m1 = M[sigma[9]];  G4_k0 = CB[sigma[9]]; G4_k1 = CB[sigma[8]];
        G5_m0 = M[sigma[10]]; G5_m1 = M[sigma[11]]; G5_k0 = CB[sigma[11]]; G5_k1 = CB[sigma[10]];
        G6_m0 = M[sigma[12]]; G6_m1 = M[sigma[13]]; G6_k0 = CB[sigma[13]]; G6_k1 = CB[sigma[12]];
        G7_m0 = M[sigma[14]]; G7_m1 = M[sigma[15]]; G7_k0 = CB[sigma[15]]; G7_k1 = CB[sigma[14]];
    end

    // -------------------------------------------------------------------------
    // G BLOCKS (8 instances)
    // -------------------------------------------------------------------------
    // Column Step (G0-G3)
    gcomp u_gcomp0 (.a_in(v_present[0]), .b_in(v_present[4]), .c_in(v_present[8]), .d_in(v_present[12]), .m0(G0_m0), .m1(G0_m1), .k0(G0_k0), .k1(G0_k1), .a_out(G0AOxD), .b_out(G0BOxD), .c_out(G0COxD), .d_out(G0DOxD));
    gcomp u_gcomp1 (.a_in(v_present[1]), .b_in(v_present[5]), .c_in(v_present[9]), .d_in(v_present[13]), .m0(G1_m0), .m1(G1_m1), .k0(G1_k0), .k1(G1_k1), .a_out(G1AOxD), .b_out(G1BOxD), .c_out(G1COxD), .d_out(G1DOxD));
    gcomp u_gcomp2 (.a_in(v_present[2]), .b_in(v_present[6]), .c_in(v_present[10]), .d_in(v_present[14]), .m0(G2_m0), .m1(G2_m1), .k0(G2_k0), .k1(G2_k1), .a_out(G2AOxD), .b_out(G2BOxD), .c_out(G2COxD), .d_out(G2DOxD));
    gcomp u_gcomp3 (.a_in(v_present[3]), .b_in(v_present[7]), .c_in(v_present[11]), .d_in(v_present[15]), .m0(G3_m0), .m1(G3_m1), .k0(G3_k0), .k1(G3_k1), .a_out(G3AOxD), .b_out(G3BOxD), .c_out(G3COxD), .d_out(G3DOxD));

    // Diagonal Step (G4-G7)
    gcomp u_gcomp4 (.a_in(G0AOxD), .b_in(G1BOxD), .c_in(G2COxD), .d_in(G3DOxD), .m0(G4_m0), .m1(G4_m1), .k0(G4_k0), .k1(G4_k1), .a_out(G4AOxD), .b_out(G4BOxD), .c_out(G4COxD), .d_out(G4DOxD));
    gcomp u_gcomp5 (.a_in(G1AOxD), .b_in(G2BOxD), .c_in(G3COxD), .d_in(G0DOxD), .m0(G5_m0), .m1(G5_m1), .k0(G5_k0), .k1(G5_k1), .a_out(G5AOxD), .b_out(G5BOxD), .c_out(G5COxD), .d_out(G5DOxD));
    gcomp u_gcomp6 (.a_in(G2AOxD), .b_in(G3BOxD), .c_in(G0COxD), .d_in(G1DOxD), .m0(G6_m0), .m1(G6_m1), .k0(G6_k0), .k1(G6_k1), .a_out(G6AOxD), .b_out(G6BOxD), .c_out(G6COxD), .d_out(G6DOxD));
    gcomp u_gcomp7 (.a_in(G3AOxD), .b_in(G0BOxD), .c_in(G1COxD), .d_in(G2DOxD), .m0(G7_m0), .m1(G7_m1), .k0(G7_k0), .k1(G7_k1), .a_out(G7AOxD), .b_out(G7BOxD), .c_out(G7COxD), .d_out(G7DOxD));

    // -------------------------------------------------------------------------
    // V memory registers 
    // -------------------------------------------------------------------------
    integer i;
    always @(posedge clk or negedge rstb) begin
        if (rstb == 1'b0) begin
            for (i=0; i<16; i=i+1)
                v_present[i] <= {WWIDTH{1'b0}};
        end else begin
            for (i=0; i<16; i=i+1)
                v_present[i] <= v_next[i];
        end
    end

    // Pack v_present -> v_current (외부 출력용)
    assign v_current = { v_present[0],  v_present[1],  v_present[2],  v_present[3],
                        v_present[4],  v_present[5],  v_present[6],  v_present[7],
                        v_present[8],  v_present[9],  v_present[10], v_present[11],
                        v_present[12], v_present[13], v_present[14], v_present[15] };


endmodule
