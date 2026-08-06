class my_transaction extends uvm_sequence_item;
	rand bit [`DW-1:0] OPA, OPB; 
	rand bit CE, MODE, CIN;
	rand bit [`CW-1:0] CMD;
	rand bit [1:0] INP_VALID;
	bit signed [`DW*2-1:0] RES;
	bit COUT, OFLOW, G, E, L, ERR;
	
	logic rst;

	static bit [5:0] count,delay_hold;
	static bit [1:0] Inv_hold;
	static bit m;
	static bit [`CW-1:0] cmd_h;

	rand bit [5:0] delay;

	function new (string name="trans");
		super.new(name);
	endfunction

	constraint opa{ OPA dist{ 0:=100, [1:(2**`DW)-2]:=1, ((2**`DW)-1):=100};}
	constraint opb{ OPB dist{ 0:=100, [1:(2**`DW)-2]:=1, ((2**`DW)-1):=100};}
	constraint mode{ MODE inside {0,1};}
	constraint cmd{ CMD inside {0,(2**`CW)-1};}
	constraint in_v{ INP_VALID inside {0,3};}
	constraint ce{ CE inside {0,1};}
	constraint cin{ CIN inside {0,1};}
	constraint wait_cyc{ delay inside {[0:15]};}

	`uvm_object_utils_begin(my_transaction)
		`uvm_field_int(OPA, UVM_ALL_ON)
		`uvm_field_int(OPB, UVM_ALL_ON)
		`uvm_field_int(rst, UVM_ALL_ON)
		`uvm_field_int(CE, UVM_ALL_ON)
		`uvm_field_int(MODE, UVM_ALL_ON)
		`uvm_field_int(CIN, UVM_ALL_ON)
		`uvm_field_int(CMD, UVM_ALL_ON)
		`uvm_field_int(INP_VALID, UVM_ALL_ON)
		`uvm_field_int(RES, UVM_ALL_ON)
		`uvm_field_int(COUT, UVM_ALL_ON)
		`uvm_field_int(OFLOW, UVM_ALL_ON)
		`uvm_field_int(G, UVM_ALL_ON)
		`uvm_field_int(E, UVM_ALL_ON)
		`uvm_field_int(L, UVM_ALL_ON)
		`uvm_field_int(ERR, UVM_ALL_ON)
	`uvm_object_utils_end
endclass

class cont_arith_op extends my_transaction;
	`uvm_object_utils(cont_arith_op)

	function new (string name="con_arith_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==1;}
	constraint cmd{ CMD inside {[0:8]};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class cont_log_op extends my_transaction;
	`uvm_object_utils(cont_log_op)

	function new (string name="con_log_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==0;}
	constraint cmd{ CMD inside {[0:13]};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class err_op extends my_transaction;
	`uvm_object_utils(err_op)

	function new (string name="err_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE inside {0,1};}
	constraint n1{solve MODE before CMD;}
	constraint cmd{ if(MODE==0) CMD>13; else CMD>10;}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class mult_op extends my_transaction;
	`uvm_object_utils(mult_op)

	function new (string name="mult_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==1;}
	constraint cmd{ CMD inside {9,10};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class mul_during_op extends my_transaction;
	`uvm_object_utils(mul_during_op)

	function new (string name="mul_during_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==1;}
	constraint cmd{ CMD dist{[9:10]:=100, [0:8]:/50, [11:15]:/50};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class stop_ce_dur_op extends my_transaction;
	`uvm_object_utils(stop_ce_dur_op)

	function new (string name="stop_ce_dur_op");
		super.new(name);
	endfunction
		
	constraint ce{ CE dist{1:=1, 0:=4};}
endclass

class wait_rand_cycles extends my_transaction;
	`uvm_object_utils(wait_rand_cycles)

	function new (string name="wait_rand_cycles");
		super.new(name);
	endfunction

	constraint wait_cyc{ delay inside {[0:14]};}
	constraint in_v{ INP_VALID inside {[0:2]};}

	function void post_randomize();
		if ((m!=MODE)&&(cmd_h!=CMD)) begin
			delay_hold=delay;
			count=1;
			Inv_hold=INP_VALID;	
			m=MODE;
			cmd_h=CMD;
		end else if ((INP_VALID!=0)&&(count==0)) begin
			delay_hold=delay;
			count++;
			Inv_hold=INP_VALID;
			m=MODE;
			cmd_h=CMD;
		end else if (count==delay_hold) begin
			count=0;
			INP_VALID=~(Inv_hold);
		end else if (count!=0) begin
			count++;
			INP_VALID=Inv_hold;
		end
	endfunction	
endclass

class wait_rand_cycles_w_mcmd extends my_transaction;
	`uvm_object_utils(wait_rand_cycles_w_mcmd)

	function new (string name="wait_rand_cycles_w_mcmd");
		super.new(name);
	endfunction

	constraint wait_cyc{ delay inside {[0:14]};}
	constraint in_v{ INP_VALID inside {[0:2]};}

	function void post_randomize();
		if ((INP_VALID!=0)&&(count==0)) begin
			delay_hold=delay;
			count++;
			Inv_hold=INP_VALID;
			m=MODE;
			cmd_h=CMD;
		end else if (count==delay_hold) begin
			count=0;
			INP_VALID=~(Inv_hold);
			MODE=m;
			CMD=cmd_h;
		end else if (count!=0) begin
			count++;
			INP_VALID=Inv_hold;
			MODE=m;
			CMD=cmd_h;
		end
	endfunction	
endclass

class wait_rand_cycles_w_mcmd_16 extends my_transaction;
	`uvm_object_utils(wait_rand_cycles_w_mcmd_16)

	function new (string name="wait_rand_cycles_w_mcmd_16");
		super.new(name);
	endfunction

	constraint wait_cyc{ delay==15;}
	constraint in_v{ INP_VALID inside {[0:2]};}

	function void post_randomize();
		if ((INP_VALID!=0)&&(count==0)) begin
			delay_hold=delay;
			count++;
			Inv_hold=INP_VALID;
			m=MODE;
			cmd_h=CMD;
		end else if (count==delay_hold) begin
			count=0;
			INP_VALID=~(Inv_hold);
			MODE=m;
			CMD=cmd_h;
		end else if (count!=0) begin
			count++;
			INP_VALID=Inv_hold;
			MODE=m;
			CMD=cmd_h;
		end
	endfunction	
endclass

class wait_rand_cycles_w_more_16 extends my_transaction;
	`uvm_object_utils(wait_rand_cycles_w_more_16)

	function new (string name="wait_rand_cycles_w_more_16");
		super.new(name);
	endfunction

	constraint wait_cyc{ delay>16;}
	constraint in_v{ INP_VALID inside {[0:2]};}

	function void post_randomize();
		if ((INP_VALID!=0)&&(count==0)) begin
			delay_hold=delay;
			count++;
			Inv_hold=INP_VALID;
			m=MODE;
			cmd_h=CMD;
		end else if (count==delay_hold) begin
			count=0;
			INP_VALID=~(Inv_hold);
			MODE=m;
			CMD=cmd_h;
		end else if (count!=0) begin
			count++;
			INP_VALID=Inv_hold;
			MODE=m;
			CMD=cmd_h;
		end
	endfunction	
endclass

