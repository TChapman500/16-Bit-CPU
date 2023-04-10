
module shifter_sig_proc(arith, rotate, in_data, out_data);
	input arith, rotate;
	input[15:0] in_data;
	output[14:0] out_data;
	reg[14:0] out_data;
	wire arith_out;
	
	assign arith_out = arith & in_data[15];
	
	always begin
		out_data[0] <= (in_data[0] & rotate) | arith_out;
		out_data[1] <= (in_data[1] & rotate) | arith_out;
		out_data[2] <= (in_data[2] & rotate) | arith_out;
		out_data[3] <= (in_data[3] & rotate) | arith_out;
		out_data[4] <= (in_data[4] & rotate) | arith_out;
		out_data[5] <= (in_data[5] & rotate) | arith_out;
		out_data[6] <= (in_data[6] & rotate) | arith_out;
		out_data[7] <= (in_data[7] & rotate) | arith_out;
		out_data[8] <= (in_data[8] & rotate) | arith_out;
		out_data[9] <= (in_data[9] & rotate) | arith_out;
		out_data[10] <= (in_data[10] & rotate) | arith_out;
		out_data[11] <= (in_data[11] & rotate) | arith_out;
		out_data[12] <= (in_data[12] & rotate) | arith_out;
		out_data[13] <= (in_data[13] & rotate) | arith_out;
		out_data[14] <= (in_data[14] & rotate) | arith_out;
	end
endmodule
