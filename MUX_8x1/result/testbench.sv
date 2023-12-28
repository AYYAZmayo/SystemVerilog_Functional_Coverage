`timescale 1ns/1ns 

module tb;
	logic a,b,c,d,e,f,g,h;
	logic [2:0] sel;
	logic y;
	
  mux DUT (a,b,c,d,e,f,g,h,sel,y);
	
	covergroup cvr_mux;
		option.per_instance = 1;
		
		coverpoint a {
			bins a_low = {0};
			bins a_high = {1};
		}
		
		coverpoint b {
			bins b_low = {0};
			bins b_high = {1};
		}
		
		coverpoint c {
			bins c_low = {0};
			bins c_high = {1};
		}
		
		coverpoint d {
			bins d_low = {0};
			bins d_high = {1};
		}
		
		coverpoint e {
			bins e_low = {0};
			bins e_high = {1};
		}
		
		coverpoint f {
			bins f_low = {0};
			bins f_high = {1};
		}
		
		coverpoint g {
			bins g_low = {0};
			bins g_high = {1};
		}
		
		coverpoint h {
			bins h_low = {0};
			bins h_high = {1};
		}

		cross sel,a {
			ignore_bins other_bins = binsof (sel) intersect {[1:7]}; // a occurs when sel=0, other values if sel are useless
		}
		
		cross sel,b {
			ignore_bins other_bins = binsof (sel) intersect {0,[2:7]}; // b occurs when sel=1, other values if sel are useless
		}
		
		cross sel,c {
			ignore_bins other_bins = binsof (sel) intersect {[0:1],[3:7]}; // c occurs when sel=2, other values if sel are useless
		}
		
		cross sel,d {
			ignore_bins other_bins = binsof (sel) intersect {[0:2],[4:7]}; // d occurs when sel=3, other values if sel are useless
		}
		
		cross sel,e {
			ignore_bins other_bins = binsof (sel) intersect {[0:3],[5:7]}; // e occurs when sel=4, other values if sel are useless
		}
		
		cross sel,f {
			ignore_bins other_bins = binsof (sel) intersect {[0:4],[6:7]}; // f occurs when sel=5, other values if sel are useless
		}
		
		cross sel,g {
			ignore_bins other_bins = binsof (sel) intersect {[0:5],7}; // g occurs when sel=6, other values if sel are useless
		}
		
		cross sel,h {
			ignore_bins other_bins = binsof (sel) intersect {[0:6]}; // h occurs when sel=7, other values if sel are useless
		}
		
		coverpoint sel;
		coverpoint y;
		
	endgroup
	
	
	cvr_mux c1;
	
	initial begin
		c1 = new();
		for (int i=0; i<100 ;i++) begin
		sel = $urandom();
		{a,b,c,d,e,f,g,h} = $urandom();
		c1.sample();
		#10;
		end
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
		#1500;
		$finish();
	
	end
endmodule
