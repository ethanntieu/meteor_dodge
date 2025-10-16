module score_display (
	input logic [15:0] score,
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3
);
	// Decimal digits
	logic [3:0] ones, tens, hundreds, thousands;
	
	// Convert binary score to decimal digits
	binary_to_decimal_converter converter (
		.binary_in(score),
		.thousands(thousands),
		.hundreds(hundreds),
		.tens(tens),
		.ones(ones)
	);
	
	// Seven segment decoders for each decimal digit
	seven_seg_decoder hex0_dec (.hex_digit(ones), .segments(HEX0));
	seven_seg_decoder hex1_dec (.hex_digit(tens), .segments(HEX1));
	seven_seg_decoder hex2_dec (.hex_digit(hundreds), .segments(HEX2));
	seven_seg_decoder hex3_dec (.hex_digit(thousands), .segments(HEX3));
endmodule