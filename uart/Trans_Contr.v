`include "Data_Reg.v"
`include "Shift_Reg.v"

module Trans_Contr(Serial_out, Clk, Reset, Byte_ready, T_byte, Data_in);
	output Serial_out;
	input Clk, Reset;
	input Byte_ready, T_byte; // Byte_ready for signalling loading the shift reg
								// T_byte used to actually signal a transmit operation

	input [7:0] Data_in;							
	// status registers
	reg Start, Load_shift_register, Load_XMT_register;
	reg [3:0] Counter;

	// module hookup wires
	wire Start_w, Load_shift_register_w, Load_XMT_register_w;
	wire [9:0] Byte_pckg_out_Data_reg_in;



	parameter [1:0]	Idle = 2'b00;
	parameter [1:0]	Loading = 2'b01;
	parameter [1:0]	Transmitting = 2'b10;
	parameter [1:0]	Clearing = 2'b11;
	//, Loading = 2'b01, Transmitting = 2'b10; Clearing = 2'b11; 
	
	reg[1:0] ps, ns;

	Data_Reg data_reg(.Byte_pckg_out(Byte_pckg_out_Data_reg_in), .Data_bus(Data_in), .Clk(Clk), .Reset(Reset), .Load_XMT_register(Load_XMT_register_w));
	Shift_Reg shift_reg(.Serial_out(Serial_out), .Data_reg_in(Byte_pckg_out_Data_reg_in), .Load_shift_register(Load_shift_register_w), .Start(Start_w), .Clk(Clk), .Reset(Reset));


	assign Start_w = Start;
	assign Load_shift_register_w = Load_shift_register;
	assign Load_XMT_register_w = Load_XMT_register;



	always @(posedge Clk) begin
		if (Reset) begin
			ps <= Idle;
			ns <= Idle;
			Counter <= 4'b0;
		end else begin
			case (ps)
				Idle: //----------------------------------------------------------------IDLE----------------------------------
					if (Byte_ready) begin
						ns <= Loading;
						Load_XMT_register <= 1;
						Load_shift_register <= 1;
					end else begin
						ns = Idle;
						Load_shift_register <= 0;
						Load_XMT_register <= 0;
						Start <= 0;		
					end 
				Loading: //------------------------------------------------------------LOADING--------------------------------
					if (T_byte) begin
						ns <= Transmitting;
						Counter <= 4'b0; 
					end else begin 
						if (Load_shift_register == 1'b0) begin
							ns <= 2'b00;
							Load_XMT_register <= 0;
							Start <= 0;
						end else begin
							ns <= Loading;
							Load_XMT_register <= 1;
							Start <= 0;	
						end
					end
				Transmitting: //-------------------------------------------------------TRANSMITTING----------------------------
					if (Counter == 4'b1100) begin // unsure about when to set counter rn
						ns <= Clearing;
						Load_shift_register <= 0; // these two loads were moved from Clearing stage to hit it a cycle before
						Load_XMT_register <= 0;
						Start <= 0;		
					end else begin
						ns <= Transmitting;
						Counter <= Counter + 1'b1;
						Load_shift_register <= 0;
						Load_XMT_register <= 1;
						Start <= 1;
					end
				Clearing: // ---------------------------------------------------------CLEARING-----------------------------------
					begin
						ns <= Idle;
						Load_XMT_register <= 0;
						Start <= 0;
					end
			endcase
		end
	end

	always @(posedge Clk) begin
		if (Reset) begin
			ps <= Idle;
			ns <= Idle;
		end else begin
			ps <= ns;
		end
	end

endmodule

module Trans_Contr_tb();
	
	parameter PERIOD = 10;

	reg Clk, Reset, Byte_ready, T_byte;
	wire Clk_w, Reset_w, Byte_ready_w, T_byte_w;
	
	reg [7:0] Data_bus;
	wire[7:0] Data_bus_w;

	wire Serial_out;

	assign Clk_w = Clk;
	assign Reset_w = Reset;
	assign Byte_ready_w = Byte_ready;
	assign T_byte_w = T_byte;

	assign Data_bus_w = Data_bus; 


	Trans_Contr dut(.Serial_out(Serial_out), .Clk(Clk_w), .Reset(Reset_w), .Byte_ready(Byte_ready_w), .T_byte(T_byte_w), .Data_in(Data_bus_w));


	always #PERIOD Clk=~Clk;

	initial begin
		$dumpfile("Trans_Contr.vcd");
		$dumpvars(0, dut);
		#(200*PERIOD);
		$finish;
	end

	initial begin
		Reset = 1; Byte_ready = 0; T_byte = 0; Clk = 0; Data_bus = 8'b11111111; #(2*PERIOD);
		#(2*PERIOD); 
		#(2*PERIOD);
		Reset = 0;
		#(2*PERIOD);
		#(2*PERIOD);
		Byte_ready = 1;
		#(2*PERIOD);
		#(2*PERIOD);
		T_byte = 1;
		#(14*2*PERIOD);
		T_byte = 0; Byte_ready = 0; Data_bus = 8'b10101010;
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD); 
		Byte_ready = 1;
		#(2*PERIOD);
		#(2*PERIOD);
		T_byte = 1;
		#(14*2*PERIOD);
		T_byte = 0; Byte_ready = 0;
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		#(2*PERIOD);
		// #(2*PERIOD);
		// #(2*PERIOD);
		// #(2*PERIOD);
		// #(2*PERIOD);
		// #(2*PERIOD);
		 #(20*PERIOD);
		$finish;
	end
endmodule