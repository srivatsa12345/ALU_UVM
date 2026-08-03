interface my_if(input logic clk, input logic rst);

	logic [`DW-1:0] OPA, OPB; 
	logic CE, MODE, CIN;
	logic [`CW-1:0] CMD;
	logic [1:0] INP_VALID;
	logic signed [`DW*2-1:0] RES;
	logic COUT, OFLOW, G, E, L, ERR;

	clocking cb_drv@(posedge clk);
		default input #1 output #1;
		output OPA,OPB,CE,MODE,CIN,CMD,INP_VALID;
		input rst;
	endclocking
	clocking cb_in_mon@(posedge clk);
		default input #1 output #1;
		input OPA,OPB,CE,MODE,CIN,CMD,INP_VALID;
		input rst;
	endclocking
	clocking cb_out_mon@(posedge clk);
		default input #1 output #1;
		input RES,COUT,OFLOW,G,E,L,ERR;
	endclocking

	modport DRV(clocking cb_drv);
	modport IN_MON(clocking cb_in_mon);
	modport OUT_MON(clocking cb_out_mon);

endinterface
