class in_monitor extends uvm_monitor;
       `uvm_component_utils(in_monitor)
	virtual my_if.IN_MON vif;	
	uvm_analysis_port #(my_transaction) ap;

	my_transaction tr;
	
	function new(string name,uvm_component parent);
		super.new(name,parent);
		ap=new("ap",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
			`uvm_fatal("NOVIF","vif is not set for monitor");
	endfunction

	task run_phase(uvm_phase phase);
		@(vif.cb_in_mon);
		forever
			collect_input();
	endtask

	task collect_input();
		begin
			tr=my_transaction::type_id::create("tr");
			@(vif.cb_in_mon);
			tr.OPA=vif.cb_in_mon.OPA; 
			tr.OPB=vif.cb_in_mon.OPB; 
			tr.CE=vif.cb_in_mon.CE; 
			tr.MODE=vif.cb_in_mon.MODE; 
			tr.CIN=vif.cb_in_mon.CIN; 
			tr.CMD=vif.cb_in_mon.CMD; 
			tr.INP_VALID=vif.cb_in_mon.INP_VALID;
			tr.rst=vif.cb_in_mon.rst;
			//`uvm_info("INPUT_MONITOR",$sformatf("Input MONITOR\n%s",tr.sprint()),UVM_NONE)
			`uvm_info("INPUT_MONITOR",$sformatf("\nI_M: OPA=%0h, OPB=%0h, CE=%0h, MODE=%0h, CIN=%0h, CMD=%0h, INP_VALID=%0h RST=%0h",tr.OPA,tr.OPB,tr.CE,tr.MODE,tr.CIN,tr.CMD,tr.INP_VALID,tr.rst),UVM_NONE) 
			ap.write(tr);
		end
	endtask

endclass

