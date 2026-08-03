class environment extends uvm_env;
	`uvm_component_utils(environment)
	act_agent a_ag;
	pass_agent p_ag;
	scoreboard sc;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		a_ag=act_agent::type_id::create("a_ag",this);
		p_ag=pass_agent::type_id::create("p_ag",this);
		sc=scoreboard::type_id::create("sc",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		a_ag.in_mon.ap.connect(sc.in_fifo.analysis_export);
		p_ag.out_mon.ap.connect(sc.out_fifo.analysis_export);
	endfunction

endclass
