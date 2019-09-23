module Shift_Reg(Serial_out, Data_reg_in, Load_shift_register, Start, Clk, Reset);
	output Serial_out;

	input [9:0] Data_reg_in;
	input Load_shift_register, Start, Clk, Reset;

	reg[3:0] Counter;
	reg[9:0] Shift_reg_data;

	

	// Counter 
	always @(posedge Clk) begin
		if (Reset || Start) begin // or might give error?
			Counter <= 4'b0;
		end else begin
			Counter <= Counter + 1'b1;
		end
	end

	// shift register loading logic
	always @(posedge Clk) begin
		if (Reset) begin
			Shift_reg_data <= 10'bxxxxxxxxxx;
		end else begin
			if (Load_shift_register) // Start will never be on at the same time 
				Shift_reg_data = Data_reg_in;	
		end	
	end

	// shift/output logic
	always @(posedge Clk) begin
		if (!Reset) begin
			if (Start) begin
				if (Counter != 4'b0000 || Counter >= 4'b1010) //don't shift on first clk cycle since i want original MSB, and stop shifting when byte is finished
					Shift_reg_data = Shift_reg_data << 1;
			end
		end 
	end

	assign Serial_out = Shift_reg_data[10];




endmodule