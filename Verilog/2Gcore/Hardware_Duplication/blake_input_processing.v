module blake_input_processing (
	input wire [639:0] din,
	output wire [639:0] din_swapped
	);

	assign din_swapped[31:0]   = {din[7:0],   din[15:8],  din[23:16], din[31:24]};
	assign din_swapped[63:32]    = {din[39:32],  din[47:40], din[55:48], din[63:56]};
	assign din_swapped[95:64]    = {din[71:64],  din[79:72], din[87:80], din[95:88]};
	assign din_swapped[127:96]   = {din[103:96], din[111:104], din[119:112], din[127:120]};
	assign din_swapped[159:128]  = {din[135:128], din[143:136], din[151:144], din[159:152]};
	assign din_swapped[191:160]  = {din[167:160], din[175:168], din[183:176], din[191:184]};
	assign din_swapped[223:192]  = {din[199:192], din[207:200], din[215:208], din[223:216]};
	assign din_swapped[255:224]  = {din[231:224], din[239:232], din[247:240], din[255:248]};
	assign din_swapped[287:256]  = {din[263:256], din[271:264], din[279:272], din[287:280]};
	assign din_swapped[319:288]  = {din[295:288], din[303:296], din[311:304], din[319:312]};
	assign din_swapped[351:320]  = {din[327:320], din[335:328], din[343:336], din[351:344]};
	assign din_swapped[383:352]  = {din[359:352], din[367:360], din[375:368], din[383:376]};
	assign din_swapped[415:384]  = {din[391:384], din[399:392], din[407:400], din[415:408]};
	assign din_swapped[447:416]  = {din[423:416], din[431:424], din[439:432], din[447:440]};
	assign din_swapped[479:448]  = {din[455:448], din[463:456], din[471:464], din[479:472]};
	assign din_swapped[511:480]  = {din[487:480], din[495:488], din[503:496], din[511:504]};
	assign din_swapped[543:512]  = {din[519:512], din[527:520], din[535:528], din[543:536]};
	assign din_swapped[575:544]  = {din[551:544], din[559:552], din[567:560], din[575:568]};
	assign din_swapped[607:576]  = {din[583:576], din[591:584], din[599:592], din[607:600]};
	assign din_swapped[639:608]  = {din[615:608], din[623:616], din[631:624], din[639:632]};

endmodule