module binary_to_decimal_converter (
	input logic [15:0] binary_in,
	output logic [3:0] thousands,
	output logic [3:0] hundreds,
	output logic [3:0] tens,
	output logic [3:0] ones
);

	logic [15:0] value;
	logic [15:0] temp1, temp2, temp3;
	
	always_comb begin
		// Clamp to 9999 if input is larger (since we only have 4 digits)
		if (binary_in > 16'd9999) begin
			value = 16'd9999;
		end else begin
			value = binary_in;
		end
		
		// Extract thousands (0-9)
		if (value >= 16'd9000) thousands = 4'd9;
		else if (value >= 16'd8000) thousands = 4'd8;
		else if (value >= 16'd7000) thousands = 4'd7;
		else if (value >= 16'd6000) thousands = 4'd6;
		else if (value >= 16'd5000) thousands = 4'd5;
		else if (value >= 16'd4000) thousands = 4'd4;
		else if (value >= 16'd3000) thousands = 4'd3;
		else if (value >= 16'd2000) thousands = 4'd2;
		else if (value >= 16'd1000) thousands = 4'd1;
		else thousands = 4'd0;
		
		// Subtract thousands to get remainder
		temp1 = value - (thousands * 16'd1000);
		
		// Extract hundreds (0-9)
		if (temp1 >= 16'd900) hundreds = 4'd9;
		else if (temp1 >= 16'd800) hundreds = 4'd8;
		else if (temp1 >= 16'd700) hundreds = 4'd7;
		else if (temp1 >= 16'd600) hundreds = 4'd6;
		else if (temp1 >= 16'd500) hundreds = 4'd5;
		else if (temp1 >= 16'd400) hundreds = 4'd4;
		else if (temp1 >= 16'd300) hundreds = 4'd3;
		else if (temp1 >= 16'd200) hundreds = 4'd2;
		else if (temp1 >= 16'd100) hundreds = 4'd1;
		else hundreds = 4'd0;
		
		// Subtract hundreds to get remainder
		temp2 = temp1 - (hundreds * 16'd100);
		
		// Extract tens (0-9)
		if (temp2 >= 16'd90) tens = 4'd9;
		else if (temp2 >= 16'd80) tens = 4'd8;
		else if (temp2 >= 16'd70) tens = 4'd7;
		else if (temp2 >= 16'd60) tens = 4'd6;
		else if (temp2 >= 16'd50) tens = 4'd5;
		else if (temp2 >= 16'd40) tens = 4'd4;
		else if (temp2 >= 16'd30) tens = 4'd3;
		else if (temp2 >= 16'd20) tens = 4'd2;
		else if (temp2 >= 16'd10) tens = 4'd1;
		else tens = 4'd0;
		
		// Extract ones (0-9)
		temp3 = temp2 - (tens * 16'd10);
		ones = temp3[3:0]; // Since temp3 will be 0-9, only need bottom 4 bits
	end
endmodule