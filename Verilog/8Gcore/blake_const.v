module blake_const#(
    parameter WWIDTH = 64
)
(
    input      [3:0] round_idx,   // round값 = k , sigma배열의 행
    input      [3:0] sigma_idx,    // sigma배열의 열 (m0,m1)
    input      [3:0] c_idx,       // sigma배열의 열 (c0,c1)

    output reg [3:0] sigma_o,   // sigma값 (0..15)
    output reg [WWIDTH-1:0] c_o // CB값
);

    // -------------------------------------------------------------------------
    // SIGMA ROM
    // -------------------------------------------------------------------------
    always @(*) begin
        case (round_idx)
            0, 10: case (sigma_idx)
                0:sigma_o=0; 1:sigma_o=1; 2:sigma_o=2; 3:sigma_o=3;
                4:sigma_o=4; 5:sigma_o=5; 6:sigma_o=6; 7:sigma_o=7;
                8:sigma_o=8; 9:sigma_o=9; 10:sigma_o=10; 11:sigma_o=11;
                12:sigma_o=12; 13:sigma_o=13; 14:sigma_o=14; 15:sigma_o=15;
                default: sigma_o=0;
            endcase
            1, 11: case (sigma_idx)
                0:sigma_o=14;1:sigma_o=10;2:sigma_o=4; 3:sigma_o=8;
                4:sigma_o=9; 5:sigma_o=15;6:sigma_o=13;7:sigma_o=6;
                8:sigma_o=1; 9:sigma_o=12;10:sigma_o=0;11:sigma_o=2;
                12:sigma_o=11;13:sigma_o=7;14:sigma_o=5;15:sigma_o=3;
                default: sigma_o=0;
            endcase
            2, 12: case (sigma_idx)
                0:sigma_o=11;1:sigma_o=8;2:sigma_o=12;3:sigma_o=0;
                4:sigma_o=5; 5:sigma_o=2;6:sigma_o=15;7:sigma_o=13;
                8:sigma_o=10;9:sigma_o=14;10:sigma_o=3;11:sigma_o=6;
                12:sigma_o=7;13:sigma_o=1;14:sigma_o=9;15:sigma_o=4;
                default: sigma_o=0;
            endcase
            3, 13: case (sigma_idx)
                0:sigma_o=7;1:sigma_o=9;2:sigma_o=3;3:sigma_o=1;
                4:sigma_o=13;5:sigma_o=12;6:sigma_o=11;7:sigma_o=14;
                8:sigma_o=2;9:sigma_o=6;10:sigma_o=5;11:sigma_o=10;
                12:sigma_o=4;13:sigma_o=0;14:sigma_o=15;15:sigma_o=8;
                default: sigma_o=0;
            endcase
            4, 14: case (sigma_idx)
                0:sigma_o=9;1:sigma_o=0;2:sigma_o=5;3:sigma_o=7;
                4:sigma_o=2;5:sigma_o=4;6:sigma_o=10;7:sigma_o=15;
                8:sigma_o=14;9:sigma_o=1;10:sigma_o=11;11:sigma_o=12;
                12:sigma_o=6;13:sigma_o=8;14:sigma_o=3;15:sigma_o=13;
                default: sigma_o=0;
            endcase
            5, 15: case (sigma_idx)
                0:sigma_o=2;1:sigma_o=12;2:sigma_o=6;3:sigma_o=10;
                4:sigma_o=0;5:sigma_o=11;6:sigma_o=8;7:sigma_o=3;
                8:sigma_o=4;9:sigma_o=13;10:sigma_o=7;11:sigma_o=5;
                12:sigma_o=15;13:sigma_o=14;14:sigma_o=1;15:sigma_o=9;
                default: sigma_o=0;
            endcase
            6: case (sigma_idx)
                0:sigma_o=12;1:sigma_o=5;2:sigma_o=1;3:sigma_o=15;
                4:sigma_o=14;5:sigma_o=13;6:sigma_o=4;7:sigma_o=10;
                8:sigma_o=0;9:sigma_o=7;10:sigma_o=6;11:sigma_o=3;
                12:sigma_o=9;13:sigma_o=2;14:sigma_o=8;15:sigma_o=11;
                default: sigma_o=0;
            endcase
            7: case (sigma_idx)
                0:sigma_o=13;1:sigma_o=11;2:sigma_o=7;3:sigma_o=14;
                4:sigma_o=12;5:sigma_o=1;6:sigma_o=3;7:sigma_o=9;
                8:sigma_o=5;9:sigma_o=0;10:sigma_o=15;11:sigma_o=4;
                12:sigma_o=8;13:sigma_o=6;14:sigma_o=2;15:sigma_o=10;
                default: sigma_o=0;
            endcase
            8: case (sigma_idx)
                0:sigma_o=6;1:sigma_o=15;2:sigma_o=14;3:sigma_o=9;
                4:sigma_o=11;5:sigma_o=3;6:sigma_o=0;7:sigma_o=8;
                8:sigma_o=12;9:sigma_o=2;10:sigma_o=13;11:sigma_o=7;
                12:sigma_o=1;13:sigma_o=4;14:sigma_o=10;15:sigma_o=5;
                default: sigma_o=0;
            endcase
            9: case (sigma_idx)
                0:sigma_o=10;1:sigma_o=2;2:sigma_o=8;3:sigma_o=4;
                4:sigma_o=7;5:sigma_o=6;6:sigma_o=1;7:sigma_o=5;
                8:sigma_o=15;9:sigma_o=11;10:sigma_o=9;11:sigma_o=14;
                12:sigma_o=3;13:sigma_o=12;14:sigma_o=13;15:sigma_o=0;
                default: sigma_o=0;
            endcase
            default: sigma_o = 0;
        endcase
    end

    // -------------------------------------------------------------------------
    // CB constant ROM
    // -------------------------------------------------------------------------
    always @(*) begin
        case (c_idx)
            0:  c_o = 64'h243F6A8885A308D3;
            1:  c_o = 64'h13198A2E03707344;
            2:  c_o = 64'hA4093822299F31D0;
            3:  c_o = 64'h082EFA98EC4E6C89;
            4:  c_o = 64'h452821E638D01377;
            5:  c_o = 64'hBE5466CF34E90C6C;
            6:  c_o = 64'hC0AC29B7C97C50DD;
            7:  c_o = 64'h3F84D5B5B5470917;
            8:  c_o = 64'h9216D5D98979FB1B;
            9:  c_o = 64'hD1310BA698DFB5AC;
            10: c_o = 64'h2FFD72DBD01ADFB7;
            11: c_o = 64'hB8E1AFED6A267E96;
            12: c_o = 64'hBA7C9045F12C7F99;
            13: c_o = 64'h24A19947B3916CF7;
            14: c_o = 64'h0801F2E2858EFC16;
            15: c_o = 64'h636920D871574E69;
            default: c_o = {WWIDTH{1'b0}};
        endcase
    end

endmodule
