module tb;
	logic clk, rst, wr, rd;
	logic [7:0] din;
	logic [7:0] dout;
	logic empty, full;
	
	FIFO DUT(clk,rst,wr,rd,din,dout,empty,full);
	
	//Clock 
	always #5 clk = ~clk;
	
	//FIFO Reset condition
	initial begin
		clk =0;
		rst = 1;
		wr=0;
		rd=0;
		repeat (5) @(posedge clk);
		rst = 0;
		write();
		read();
	end
	
	// write task
	task write();
		for (int i=0; i<20; i++)begin
			rst = 0;
			wr = 1;
			rd = 0;
			din = $urandom;
			@(posedge clk);
			$display("wr: %0d, addr : %0d, din : %0d full:%0d", wr, i, din, full);
			wr=0;
			@(posedge clk);
		end
	endtask
	
	// Read task
	
	task read();
		for (int i=0; i<20; i++)begin
			rst = 0;
			wr = 0;
			rd = 1;
			@(posedge clk);
			rd=0;
			@(posedge clk);
          			$display("rd: %0d, addr : %0d, dout : %0d empty : %0d", rd, i, dout,empty);
          
		end
	endtask
	
	
	covergroup cvr_fifo @(posedge clk);
		option.per_instance = 1;
		
		coverpoint rst{
			bins rst_low ={0};
			bins rst_hgih = {1};
		}
		
		coverpoint wr{
			bins wr_low ={0};
			bins wr_hgih = {1};
		}
		
		coverpoint rd{
			bins rd_low ={0};
			bins rd_hgih = {1};
		}
		
		coverpoint empty{
			bins empty_low ={0};
			bins empty_hgih = {1};
		}
		
		coverpoint full{
			bins full_low ={0};
			bins full_hgih = {1};
		}
		
		coverpoint din{
			bins din_lower = {[0:84]};
			bins din_medium = {[85:169]};
			bins din_higher = {[170:255]};
		}
		
		coverpoint dout{
			bins dout_lower = {[0:84]};
			bins dout_medium = {[85:169]};
			bins dout_higher = {[170:255]};
		}
		
		//cross coverage b/w rst and wr
		cross_rst_wr: cross rst,wr{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_wr = binsof (wr) intersect {0};
		}
		
		cross_rst_rd: cross rst,rd{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_rd = binsof (rd) intersect {0};
		}
		
		cross_wr_din: cross rst,wr,din{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_wr = binsof (wr) intersect {0};
		}
		
		cross_rd_dout: cross rst,rd,dout{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_rd = binsof (rd) intersect {0};
		}
		
		cross_wr_full: cross rst,wr,full{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_wr = binsof (wr) intersect {0};
			ignore_bins others_full = binsof (full) intersect {0};
		}
		
	    cross_rd_empty: cross rst,rd,empty{
			ignore_bins others_rst = binsof (rst) intersect {1};
			ignore_bins others_rd = binsof (rd) intersect {0};
			ignore_bins others_empty = binsof (empty) intersect {0};
		}
		
	endgroup
	
	cvr_fifo c1;
	
	initial begin
		c1 = new();
		$dumpfile("dump.vcd");
		$dumpvars;
		repeat (1200) @(posedge clk);
		$finish();
	end
	
endmodule 
