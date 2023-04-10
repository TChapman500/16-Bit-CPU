module mux_16to1(sel, isel, in_data, out_data);
	input [3:0] sel;
	input [3:0] isel;
	input [15:0] in_data;
	output out_data;
	reg out_data;
	
	wire[15:0] gate;
	assign gate[0]  = isel[0] & isel[1] & isel[2] & isel[3] & in_data[0];
	assign gate[1]  =  sel[0] & isel[1] & isel[2] & isel[3] & in_data[1];
	assign gate[2]  = isel[0] &  sel[1] & isel[2] & isel[3] & in_data[2];
	assign gate[3]  =  sel[0] &  sel[1] & isel[2] & isel[3] & in_data[3];
	assign gate[4]  = isel[0] & isel[1] &  sel[2] & isel[3] & in_data[4];
	assign gate[5]  =  sel[0] & isel[1] &  sel[2] & isel[3] & in_data[5];
	assign gate[6]  = isel[0] &  sel[1] &  sel[2] & isel[3] & in_data[6];
	assign gate[7]  =  sel[0] &  sel[1] &  sel[2] & isel[3] & in_data[7];
	assign gate[8]  = isel[0] & isel[1] & isel[2] &  sel[3] & in_data[8];
	assign gate[9]  =  sel[0] & isel[1] & isel[2] &  sel[3] & in_data[9];
	assign gate[10] = isel[0] &  sel[1] & isel[2] &  sel[3] & in_data[10];
	assign gate[11] =  sel[0] &  sel[1] & isel[2] &  sel[3] & in_data[11];
	assign gate[12] = isel[0] & isel[1] &  sel[2] &  sel[3] & in_data[12];
	assign gate[13] =  sel[0] & isel[1] &  sel[2] &  sel[3] & in_data[13];
	assign gate[14] = isel[0] &  sel[1] &  sel[2] &  sel[3] & in_data[14];
	assign gate[15] =  sel[0] &  sel[1] &  sel[2] &  sel[3] & in_data[15];
	
	always begin
		out_data <= gate[0] | gate[1] | gate[2] | gate[3] | gate[4] | gate[5] | gate[6] | gate[7] | gate[8] | gate[9] | gate[10] | gate[11] | gate[12] | gate[13] | gate[14] | gate[15];
	end
endmodule
