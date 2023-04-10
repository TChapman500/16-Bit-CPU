
module bit_shifter(arith, rotate, shift, in_data, out_data);
	input arith, rotate;
	input[3:0] shift;
	input[15:0] in_data;
	output[15:0] out_data;
	reg [15:0] out_data;
	
	wire[3:0] invShift;
	wire[14:0] in_shift;
	wire[15:0] shift_result;
	
	// Invert the shift bits
	quad_inverter qInverter(
		.in_data(shift[3:0]),
		.out_data(invShift[3:0])
	);
	
	shifter_sig_proc sig_proc(
		.arith(arith),
		.rotate(rotate),
		.in_data(in_data[15:0]),
		.out_data(in_shift[14:0])
	);
	
	mux_16to1 Bit0(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(in_data[15:0]),
		.out_data(shift_result[0])
	);
	
	wire[15:0] shift_data1;
	assign shift_data1[14:0] = in_data[15:1];
	assign shift_data1[15] = in_shift[0];
	mux_16to1 Bit1(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data1[15:0]),
		.out_data(shift_result[1])
	);
	
	wire[15:0] shift_data2;
	assign shift_data2[13:0] = in_data[15:2];
	assign shift_data2[15:14] = in_shift[1:0];
	mux_16to1 Bit2(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data2[15:0]),
		.out_data(shift_result[2])
	);
	
	wire[15:0] shift_data3;
	assign shift_data3[12:0] = in_data[15:3];
	assign shift_data3[15:13] = in_shift[2:0];
	mux_16to1 Bit3(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data3[15:0]),
		.out_data(shift_result[3])
	);
	
	wire[15:0] shift_data4;
	assign shift_data4[11:0] = in_data[15:4];
	assign shift_data4[15:12] = in_shift[3:0];
	mux_16to1 Bit4(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data4[15:0]),
		.out_data(shift_result[4])
	);
	
	wire[15:0] shift_data5;
	assign shift_data5[10:0] = in_data[15:5];
	assign shift_data5[15:11] = in_shift[4:0];
	mux_16to1 Bit5(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data5[15:0]),
		.out_data(shift_result[5])
	);
	
	wire[15:0] shift_data6;
	assign shift_data6[9:0] = in_data[15:6];
	assign shift_data6[15:10] = in_shift[5:0];
	mux_16to1 Bit6(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data6[15:0]),
		.out_data(shift_result[6])
	);
	
	wire[15:0] shift_data7;
	assign shift_data7[8:0] = in_data[15:7];
	assign shift_data7[15:9] = in_shift[6:0];
	mux_16to1 Bit7(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data7[15:0]),
		.out_data(shift_result[7])
	);
	
	wire[15:0] shift_data8;
	assign shift_data8[7:0] = in_data[15:8];
	assign shift_data8[15:8] = in_shift[7:0];
	mux_16to1 Bit8(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data8[15:0]),
		.out_data(shift_result[8])
	);
	
	wire[15:0] shift_data9;
	assign shift_data9[6:0] = in_data[15:9];
	assign shift_data9[15:7] = in_shift[8:0];
	mux_16to1 Bit9(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data9[15:0]),
		.out_data(shift_result[9])
	);
	
	wire[15:0] shift_data10;
	assign shift_data10[5:0] = in_data[15:10];
	assign shift_data10[15:6] = in_shift[9:0];
	mux_16to1 Bit10(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data10[15:0]),
		.out_data(shift_result[10])
	);
	
	wire[15:0] shift_data11;
	assign shift_data11[4:0] = in_data[15:11];
	assign shift_data11[15:5] = in_shift[10:0];
	mux_16to1 Bit11(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data11[15:0]),
		.out_data(shift_result[11])
	);
	
	wire[15:0] shift_data12;
	assign shift_data12[3:0] = in_data[15:12];
	assign shift_data12[15:4] = in_shift[11:0];
	mux_16to1 Bit12(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data12[15:0]),
		.out_data(shift_result[12])
	);
	
	wire[15:0] shift_data13;
	assign shift_data13[2:0] = in_data[15:13];
	assign shift_data13[15:3] = in_shift[12:0];
	mux_16to1 Bit13(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data13[15:0]),
		.out_data(shift_result[13])
	);
	
	wire[15:0] shift_data14;
	assign shift_data14[1:0] = in_data[15:14];
	assign shift_data14[15:2] = in_shift[13:0];
	mux_16to1 Bit14(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data14[15:0]),
		.out_data(shift_result[14])
	);
	
	wire[15:0] shift_data15;
	assign shift_data15[0] = in_data[15];
	assign shift_data15[15:1] = in_shift[14:0];
	mux_16to1 Bit15(
		.sel(shift[3:0]),
		.isel(invShift[3:0]),
		.in_data(shift_data15[15:0]),
		.out_data(shift_result[15])
	);
	
	always begin
		out_data[15:0] <= shift_result[15:0];
	end
	
endmodule
