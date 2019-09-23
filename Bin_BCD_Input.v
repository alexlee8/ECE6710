module Bin_BCD_Input();
	parameter PERIOD = 10;

	reg[7:0] currIn;
	reg clk, reset;

	wire[7:0] currIn_w;
	wire[11:0] decOut;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

	integer i;



	assign currIn_w = currIn;

	initial begin
		$dumpfile("Bin_BCD.vcd");
    	$dumpvars(0, Bin_BCD_Input);
	end
	
	always #PERIOD clk=~clk;
	
	BinToBCD dut(.decOut(decOut), .binIn(currIn_w), .clk(clk), .reset(reset));

	initial begin
		clk = 0;
		currIn = 8'b1100100;
		reset = 1; #40;
		reset = 0; #150;
		for (i=0; i < 255-100+1; i++) begin
			currIn = currIn + 1; #180;
		end
		$finish;
	end

endmodule



module BinToBCD(decOut, binIn, clk, reset);
	parameter BINSIZE = 8;

	output [11:0] decOut;
	input [BINSIZE-1:0] binIn;
	input clk, reset;

	reg [12+BINSIZE-1:0] dec_and_bin;
	reg [3:0] counter;
	reg [12+BINSIZE-1:0] bcdOut;

	assign decOut = bcdOut[19:8];

	always @(posedge clk) begin
		if (reset) begin 
			dec_and_bin <= {12'b0, binIn}; // initialized at 000... | input
			counter <= 4'b1;
			bcdOut = 12'b0;	
		end else begin
			dec_and_bin = dec_and_bin << 1;
			
			if (counter == 4'b1001) begin
				counter = 4'b0;
				dec_and_bin = {12'b0, binIn};	
			end else begin

			// double dabble logic
				if (dec_and_bin[11:8] > 4'b0100 && counter < 4'b1000) 
				 		dec_and_bin[11:8] = dec_and_bin[11:8] + 4'b0011;

				if (dec_and_bin[15:12] > 4'b0100 && counter < 4'b1000) 
				 		dec_and_bin[15:12] = dec_and_bin[15:12] + 4'b0011;

				if (dec_and_bin[19:16] > 4'b0100 && counter < 4'b1000) 
				 		dec_and_bin[19:16] = dec_and_bin[19:16] + 4'b0011;
			end

			if (counter == 4'b1000) //set bcdOut in the cycle before the last
			 	bcdOut = dec_and_bin;

			counter = counter + 1'b1;
		end
	end
endmodule
