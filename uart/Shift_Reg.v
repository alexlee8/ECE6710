module Shift_Reg(Serial_out, Data_reg_in, Load_shift_register, Start, Clk, Reset);
	output Serial_out;

	input [9:0] Data_reg_in;
	input Load_shift_register, Start, Clk, Reset;

	reg[3:0] Counter;
	reg[9:0] Shift_reg_data;

	
	assign Serial_out = Shift_reg_data[9];

	// Counter 
	always @(posedge Clk) begin
		if (Reset || Counter == 4'b1010 || Load_shift_register || !Start) begin 
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
				Shift_reg_data <= Data_reg_in;
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


endmodule

// module Shift_Reg_tb();
	
// 	parameter PERIOD = 10;

// 	reg Clk, Reset;
// 	wire Clk_w, Reset_w; 
	
// 	wire Serial_out;

// 	reg Load_shift_register, Start;
// 	wire Load_shift_register_w, Start_w;

// 	reg [9:0] Data_reg_in;
// 	wire[9:0] Data_reg_in_w;


// 	assign Clk_w = Clk;
// 	assign Reset_w = Reset;
// 	assign Load_shift_register_w = Load_shift_register;
// 	assign Data_reg_in_w = Data_reg_in;
// 	assign Start_w = Start; 

// 	Shift_Reg dut(.Serial_out(Serial_out), .Data_reg_in(Data_reg_in_w), .Load_shift_register(Load_shift_register_w), .Start(Start_w), .Clk(Clk), .Reset(Reset));


// 	always #PERIOD Clk=~Clk;

// 	initial begin
// 		$dumpfile("Shift_Reg.vcd");
// 		$dumpvars(0, dut);
// 	end

// 	initial begin

// 		#(2*PERIOD);

// 		Reset = 1; Load_shift_register = 0; Data_reg_in = 10'b0111111111; Start = 0; Clk = 0; #(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD); 
// 		Reset = 0;
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		Load_shift_register = 1;
// 		#(2*PERIOD);
// 		Start = 1; Load_shift_register = 0; // new data at least 10 cycles after start
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		Data_reg_in = 10'b1010101010; 
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		Start = 0; Load_shift_register = 1; // always make sure Start and Load_shift_register are not equal
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		Start = 1; Load_shift_register = 0;
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		#(2*PERIOD);
// 		$finish;
// 	end
// endmodule