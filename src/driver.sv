class driver extends uvm_driver#(my_transaction);
	`uvm_component_utils(driver)
	virtual my_if.DRV vif;

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
			`uvm_fatal("NOVIF", "vif not found in driver")
	endfunction
	
	task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end
	endtask
	task drive(my_transaction tr);
		begin
			//`uvm_info("DRIVER",$sformatf("DRV:\n%s",tr.sprint()),UVM_NONE)
			`uvm_info("DRIVER",$sformatf("\nDRV: OPA=%0h, OPB=%0h, CE=%0h, MODE=%0h, CIN=%0h, CMD=%0h, INP_VALID=%0h\n",tr.OPA,tr.OPB,tr.CE,tr.MODE,tr.CIN,tr.CMD,tr.INP_VALID),UVM_NONE) 
			@(vif.cb_drv);
			vif.cb_drv.OPA<=tr.OPA; 
			vif.cb_drv.OPB<=tr.OPB; 
			vif.cb_drv.CE<=tr.CE; 
			vif.cb_drv.MODE<=tr.MODE; 
			vif.cb_drv.CIN<=tr.CIN; 
			vif.cb_drv.CMD<=tr.CMD; 
			vif.cb_drv.INP_VALID<=tr.INP_VALID;
		end
	endtask
endclass

