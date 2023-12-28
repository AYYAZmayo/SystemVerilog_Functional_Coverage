module tb;
	logic [7:0] y;
	logic [2:0] a;
	
	
	penc DUT (y,a);
	
	covergroup cvr_penc;
		option.per_instance = 1;
		
		coverpoint y{
					 bins zero  ={8'b0000_0001};
			wildcard bins one   ={8'b0000_001?};
			wildcard bins two   ={8'b0000_01??};
			wildcard bins three ={8'b0000_1???};
			wildcard bins four  ={8'b0001_????};
			wildcard bins five  ={8'b001?_????};
			wildcard bins six   ={8'b01??_????};
			wildcard bins seven ={8'b1???_????};		
		}
		
		coverpoint a;
	endgroup
	
	cvr_penc c1;
	
	initial begin
		c1 = new();
		for (int i=0; i<500 ; i++)begin
			y=$urandom();
			c1.sample();
			#10;
		end
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
		#1200;
		$finish;
	end
endmodule		



