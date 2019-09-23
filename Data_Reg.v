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


module Data_Reg_tb();
	
	parameter PERIOD = 10;

	reg Clk, Reset, Load_XMT_register;
	wire Clk_w, Reset_w, Load_XMT_register_w;
	
	reg [7:0] Data_bus;
	wire[7:0] Data_bus_w;

	wire[9:0] Byte_pckg_out;

	assign Clk_w = Clk;
	assign Reset_w = Reset;
	assign Load_XMT_register_w = Load_XMT_register;
	assign Data_bus_w = Data_bus; 


	Data_Reg dut(.Byte_pckg_out(Byte_pckg_out), .Data_bus(Data_bus_w), .Clk(Clk_w), .Reset(Reset_w), .Load_XMT_register(Load_XMT_register_w));


	always #PERIOD Clk=~Clk;

	initial begin
		$dumpfile("Data_Reg.vcd");
		$dumpvars(0, dut);
	end

	initial begin
		Reset = 1; Load_XMT_register = 0; Data_bus = 8'b11111111; Clk = 0; #(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD); 
		Reset = 0;
		#(2*PERIOD);
		#(2*PERIOD);
		Load_XMT_register = 1;
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		Load_XMT_register = 0;
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		$finish;
	end
endmodule