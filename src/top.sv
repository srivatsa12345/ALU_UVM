`include "package.sv"
`include "interface.sv"
`include "DUT.sv"
module top;
	import pkg::*;
  	import uvm_pkg::*;
	bit clk,rst;
	always #5 clk=~clk;
	initial begin
		rst=0;
		#2 rst=1;
		repeat(3) @(posedge clk);
		#2 rst=0;
	end
/*	initial begin
		rst=0;
		repeat(6) begin
			repeat(25) @(posedge clk);
			#2 rst=1;
			repeat(3) @(posedge clk);
			#2 rst=0;
		end
	end*/
	my_if vif(.clk(clk),.rst(rst));
	ALU_DESIGN  #(.DW(`DW),.CW(`CW)) m1(.INP_VALID(vif.INP_VALID),.OPA(vif.OPA),.OPB(vif.OPB),.CIN(vif.CIN),.CLK(clk),.RST(rst),.CMD(vif.CMD),.CE(vif.CE),.MODE(vif.MODE),.COUT(vif.COUT),.OFLOW(vif.OFLOW),.RES(vif.RES),.G(vif.G),.E(vif.E),.L(vif.L),.ERR(vif.ERR));
	
	initial begin
		uvm_config_db#(virtual my_if)::set(null,"*","vif",vif);
		run_test("test");
	end
endmodule
