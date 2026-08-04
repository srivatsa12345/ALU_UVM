class my_transaction extends uvm_sequence_item;
	rand bit [`DW-1:0] OPA, OPB; 
	rand bit CE, MODE, CIN;
	rand bit [`CW-1:0] CMD;
	rand bit [1:0] INP_VALID;
	bit signed [`DW*2-1:0] RES;
	bit COUT, OFLOW, G, E, L, ERR;
	
	logic rst;

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

	function new (string name="con_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==1;}
	constraint cmd{ CMD inside {[0:8]};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class cont_log_op extends my_transaction;
	`uvm_object_utils(cont_log_op)

	function new (string name="con_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==0;}
	constraint cmd{ CMD inside {[0:13]};}
	constraint in_v{ INP_VALID==3;}
	constraint ce{ CE==1;}
endclass

class mul_op extends my_transaction;
	`uvm_object_utils(mul_op)

	function new (string name="mul_op");
		super.new(name);
	endfunction
		
	constraint mode{ MODE==1;}
	constraint cmd{ CMD inside {9,10};}
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




