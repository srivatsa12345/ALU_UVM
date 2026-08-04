class test extends uvm_test;
	`uvm_component_utils(test);
	environment env;

	function new (string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		my_transaction::type_id::set_type_override(cont_log_op::get_type());
		env=environment::type_id::create("env",this);
	endfunction

	task run_phase(uvm_phase phase);
		sequences seq;
		phase.raise_objection(this);
		seq=sequences::type_id::create("seq");
		seq.start(env.a_ag.sqr);
		#20;
		env.sc.compare_results();
		phase.drop_objection(this);
	endtask
endclass


