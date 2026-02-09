module padding (
    input  [639:0]  din,       // 80 Bytes Input
    output [1023:0] State_buf  // 128 Bytes Padded Block
);

    // ----------------------------------------------------------------------
    // bswap32동작 
    // ----------------------------------------------------------------------
    wire [639:0] din_swapped;
    
    //640bit를 32bit로 나눔
    genvar i;
    generate
        for (i = 0; i < 20; i = i + 1) begin 
            assign din_swapped[ (19-i)*32 +: 32 ] = {
                //32bit를 8bit씩 묶어 순선를 뒤집음.
                 din[ (19-i)*32 + 0  +: 8 ],  // 원래의 LSB (4번째 바이트) -> MSB 자리로
                 din[ (19-i)*32 + 8  +: 8 ],  // 3번째 바이트
                 din[ (19-i)*32 + 16 +: 8 ],  // 2번째 바이트
                 din[ (19-i)*32 + 24 +: 8 ]   // 원래의 MSB (1번째 바이트) -> LSB 자리로
            };
        end
    endgenerate

    // ----------------------------------------------------------------------
    // 기존 패딩 로직 (din 대신 din_swapped 사용)
    // ----------------------------------------------------------------------
    assign State_buf = {
        // byte[0..79] : input
        din_swapped,

        // byte[80]: 0x80 (Padding Start)
        8'h80,

        // byte[81..110]: Zeros
        240'h0,

        // byte[111]: 0x01 (BLAKE special bit)
        8'h01,

        // byte[112..119]: T1
        64'h0000_0000_0000_0000,

        // byte[120..127]: T0
        64'h0000_0000_0000_0280
    };

endmodule
