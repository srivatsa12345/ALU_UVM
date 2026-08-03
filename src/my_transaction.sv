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

	`uvm_object_utils_begin(my_transaction)
		`uvm_field_int(OPA, UVM_ALL_ON)
		`uvm_field_int(OPB, UVM_ALL_ON)
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

