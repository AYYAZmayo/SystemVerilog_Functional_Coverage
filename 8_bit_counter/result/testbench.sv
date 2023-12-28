interface counter_8_intf;
	logic clk,rst, up, load;
	logic [7:0] loadin;
	logic [7:0] y;
endinterface

class transaction;
	rand bit [7:0] loadin;
	bit load ;
	bit up;
	bit y;
  	bit rst;
	
endclass

class generator;
	transaction tr;
	mailbox #(transaction) mbx;
	event done;
	int count;
	
	function new(mailbox #(transaction) mbx);
		this.mbx=mbx;
		tr =new();
	endfunction
	
	task run();
		for (int i=0; i < count; i++)begin
			assert(tr.randomize) else $display("Randomization is failed");
			mbx.put(tr);
			$display("[GEN :] transaction %0d sent",i);
			@(done);
		end
	endtask
	
endclass

class driver;
	transaction trans;
	mailbox #(transaction) mbx;
	virtual counter_8_intf vif;
	event done;
	
	function new(mailbox #(transaction) mbx);
		this.mbx = mbx;
	endfunction
	
	task run();
		//trans= new();
		forever begin
          mbx.get(trans);
			vif.loadin <= trans.loadin;
			$display("[DRV] : Trigger Interface");
			@(posedge vif.clk);
			->done; 
		end
	endtask
endclass

////////////////////////////////////////////
 
class monitor;
	virtual counter_8_intf vif;
	mailbox #(transaction) mbx;
	transaction t;
  
 ///////////adding coverage
    covergroup c ;
    option.per_instance = 1;
    
    
      coverpoint t.loadin {
      bins lower = {[0:84]};
      bins mid = {[85:169]};
      bins high = {[170:255]};
    }
    
    
    
 
    coverpoint t.rst {
      bins rst_low = {0};
      bins rst_high = {1};
    }
    
    coverpoint t.load {
      bins ld_low = {0};
      bins ld_high = {1};
    }
    
 
    
      coverpoint t.y {
      bins lower = {[0:84]};
      bins mid = {[85:169]};
      bins high = {[170:255]};
    }
    
    
    cross_ld_loadin : cross t.load, t.loadin 
    {
      ignore_bins unused_ld = binsof(t.load) intersect {0}; 
    }
    
    
     cross_rst_up : cross t.rst, t.up
    {
      ignore_bins unused_rst = binsof(t.rst) intersect {1};
    }
 
    
    cross_rst_y : cross t.rst, t.y
    {
      ignore_bins unused_rst = binsof(t.rst) intersect {1};
    }
 
  endgroup
  
	function new(mailbox #(transaction)mbx);
		this.mbx = mbx;
		c = new();  
	endfunction
 
	task run();
		t = new();
		forever begin
			t.loadin = vif.loadin;
			t.y = vif.y;
			t.rst = vif.rst;
			t.up = vif.up;
			t.load = vif.load;
  
			c.sample();
			mbx.put(t);
			$display("[MON] : Data send to Scoreboard");
			@(posedge vif.clk);
		end
	endtask
endclass

class scoreboard;
  
	transaction t;
  	mailbox #(transaction) mbx;
	bit [7:0] temp; 
 
	function new(mailbox #(transaction) mbx);
		this.mbx = mbx;
	endfunction
 
	task run();
		t = new();
		forever begin
			mbx.get(t);
		end
	endtask
endclass  

class environment;
	generator gen;
	driver drv;
	monitor mon;
	scoreboard sco;
 
	virtual counter_8_intf vif;
 
	mailbox #(transaction) gdmbx;
	mailbox #(transaction) msmbx;
 
	event gddone;
 
	function new(virtual counter_8_intf vif);
		gdmbx = new();
		gen = new(gdmbx);
		drv = new(gdmbx);
 
		msmbx=new();
		mon = new(msmbx);
		sco = new(msmbx);
		
		gen.done = gddone;
		drv.done = gddone;
 
		this.vif = vif;
		drv.vif = this.vif;
		mon.vif = this.vif;
		
	endfunction
 
	task run();

 
		fork 
			gen.run();
			drv.run();
			mon.run();
			sco.run();
		join_any
 
	endtask
 
endclass
 
/////////////////////////////////////
 
module tb();
 
	environment env;
 
	counter_8_intf vif();
 
	counter_8 dut ( vif.clk, vif.rst, vif.up, vif.load,  vif.loadin, vif.y );
 
	always #5 vif.clk = ~vif.clk;
  
	initial begin
		vif.clk = 0;
		vif.rst = 1;
		#50; 
		vif.rst = 0;  
	end
 
	initial begin
		#50;
		repeat(20) begin
			vif.load = 1;
			#10;
			vif.load = 0;
			#100;
		end
	end
  
	initial begin
		#50;
		repeat(20) begin
			vif.up = 1;
			#70;
			vif.up = 0;
			#70;
		end
	end 
 
	initial begin
		env = new(vif);
        env.gen.count=20;
		env.run();
		#2000;
		$finish;
	end
  
	initial begin
		$dumpfile("dump.vcd"); 
		$dumpvars;  
	end
endmodule