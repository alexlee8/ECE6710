module Data_Reg(Byte_pckg_out, Data_bus, Clk, Reset, Load_XMT_register);
	output [9:0] Byte_pckg_out;

	input [7:0] Data_bus;
	input Clk, Reset, Load_XMT_register;

	assign Byte_pckg_out = Byte_pckg;

	reg [9:0] Byte_pckg;

	always @(posedge Clk) begin
		if (Reset) begin
			Byte_pckg <= 10'b0000000001;
		end	else begin
			if (Load_XMT_register) 
				Byte_pckg[8:1] = Data_bus;
			else
				Byte_pckg[8:1] = 8'b0;
		end
	end

endmodule 