module quad_inverter(in_data, out_data);
	input[3:0] in_data;
	output[3:0] out_data;
	reg[3:0] out_data;
	
	always begin
		out_data[0] <= ~in_data[0];
		out_data[1] <= ~in_data[1];
		out_data[2] <= ~in_data[2];
		out_data[3] <= ~in_data[3];
	end
endmodule