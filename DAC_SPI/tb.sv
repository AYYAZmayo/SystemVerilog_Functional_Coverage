module tb;
	logic clk=0;
	logic [11:0] din;
	logic start;
	logic mosi, cs;
	
	dac dut (clk,din,start,mosi,cs);
	
	always #5 clk = ~clk;
	
	initial begin
		start =0;
		#20;
		start=1;
		#2000;
        start=0;
        #20;
		end


	initial begin
      for(int i = 0; i< 200; i++) begin
			@(posedge clk);
			din = $urandom();
		end
	end
	
  
  // Coverage of state transitions
	covergroup cvr_dac1 @(posedge clk);
		
		option.per_instance = 1;
		coverpoint dut.state {
		
			bins out_of_idle = (dut.idle => dut.init); // coming out of idle state bins
		  
			bins init_to_data_gen = (dut.idle => dut.init[*33] => dut.data_gen); // setup to send user data
		  
			bins user_data_send = (dut.data_gen => dut.send[*33] => dut.cont); // sending user data
		  
			bins user_data_cont_to_send = (dut.cont => dut.data_gen); // continue to send user data
		  
			bins stay_in_send_33 = (dut.send[*33]); // stay in send state for 33 clock ticks (32 ticks for data and 1 for acknowledge tick)
		  
			bins stay_in_init_33 = (dut.init[*33]); // stay in init state for 33 clock ticks (32 ticks for dac unique code of 32 bits and 1 for acknowledge tick)
          
			bins back_to_idle =(dut.cont => dut.idle); //start is de-asserted go back to idle state
		}
		
	endgroup
	
	covergroup cvr_dac2 @(posedge clk);
		option.per_instance =1;
		coverpoint mosi{
			bins mosi_low ={0};
			bins mosi_high ={1};
		}
		
		coverpoint cs{
			bins cs_low ={0};
			bins cs_high ={1};
		}
	
	endgroup 
	
	cvr_dac1 ci;
	cvr_dac2 ci2;
	
	initial begin
    	ci = new();
		ci2 = new();
    	$dumpfile("dump.vcd"); 
    	$dumpvars;
    	#2500;
    	$finish();
  end
endmodule