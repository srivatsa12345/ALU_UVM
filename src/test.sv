class test extends uvm_test;
	`uvm_component_utils(test);
	environment env;
	sequences seq;

	function new (string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env=environment::type_id::create("env",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		my_transaction::type_id::set_type_override(cont_arith_op::get_type());
		run();
		my_transaction::type_id::set_type_override(cont_log_op::get_type());
		run();
		my_transaction::type_id::set_type_override(err_op::get_type());
		run();
		my_transaction::type_id::set_type_override(mult_op::get_type());
		run();
		my_transaction::type_id::set_type_override(mul_during_op::get_type());
		run();
		my_transaction::type_id::set_type_override(stop_ce_dur_op::get_type());
		run();
		my_transaction::type_id::set_type_override(wait_rand_cycles::get_type());
		run();
		my_transaction::type_id::set_type_override(wait_rand_cycles_w_mcmd::get_type());
		run();
		my_transaction::type_id::set_type_override(wait_rand_cycles_w_mcmd_16::get_type());
		run();
		my_transaction::type_id::set_type_override(wait_rand_cycles_w_more_16::get_type());
		run();
		phase.phase_done.set_drain_time(this,20);
		phase.drop_objection(this);
	endtask

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		env.sc.compare_results();
	endfunction

	task run();
		seq=sequences::type_id::create("seq");
		seq.start(env.a_ag.sqr);
	endtask
endclass


