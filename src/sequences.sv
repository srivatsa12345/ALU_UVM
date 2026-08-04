class sequences extends uvm_sequence #(my_transaction);
	
	`uvm_object_utils(sequences)

	function new (string name="seq");
		super.new(name);
	endfunction

	task body();
		repeat(`n) begin
			req=my_transaction::type_id::create("req");
			start_item(req);
			if(req.randomize())
				`uvm_info("SEQ",$sformatf("\nSEQ: OPA=%0h, OPB=%0h, CE=%0h, MODE=%0h, CIN=%0h, CMD=%0h, INP_VALID=%0h", req.OPA, req.OPB, req.CE, req.MODE, req.CIN, req.CMD, req.INP_VALID),UVM_MEDIUM)
			else 
				`uvm_error("SEQ","SEQ failed");
			finish_item(req);
		end	
	endtask
endclass

		
