class subscriber extends uvm_subscriber#(my_transaction);
  	`uvm_component_utils(subscriber)    
 
  	my_transaction in_mon_xn;   
	localparam MAX=((2**`DW)-1);

	covergroup input_cg;   
		OPA:coverpoint in_mon_xn.OPA{ bins MIN={0}; bins LOW={[1:25]}; bins MED={[26:MAX-26]}; bins HIGH={[MAX-25:MAX-1]}; bins MAX={MAX};}
		OPB:coverpoint in_mon_xn.OPB{ bins MIN={0}; bins LOW={[1:25]}; bins MED={[26:MAX-26]}; bins HIGH={[MAX-25:MAX-1]}; bins MAX={MAX};}
		CE:coverpoint in_mon_xn.CE{ bins ON={1}; bins OFF={0};}
		MODE:coverpoint in_mon_xn.MODE{ bins ARITH={1}; bins LOGIC={0};}
		CIN:coverpoint in_mon_xn.CIN{ bins WITH_CIN={1};bins WITHOUT_CIN={0};}
		CMD:coverpoint in_mon_xn.CMD;
		INP_VALID:coverpoint in_mon_xn.INP_VALID{ bins INV={0}; bins V_A={1}; bins V_B={2}; bins VAB={3};}
		MxC:cross MODE,CMD;
		MxCxAxB:cross OPA,OPB,MODE,CMD{ ignore_bins b1=binsof(MODE.ARITH)&&binsof(CMD) intersect {[11:$]}; ignore_bins b2=binsof(MODE.LOGIC)&&binsof(CMD) intersect {[14:$]};} 
		CinwhileADDSUB:cross CIN,OPA,OPB iff((in_mon_xn.MODE==1)&&((in_mon_xn.CMD==2)||(in_mon_xn.CMD==3)));
	endgroup

	function new(string name, uvm_component parent);
    		super.new(name,parent);
    		input_cg = new();
  	endfunction:new
 
  	function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
  	endfunction
 
  	virtual function void write(my_transaction t);     
    		$cast(in_mon_xn,t);
   		input_cg.sample();
    		`uvm_info(get_name,"[SUB]:INPUT RECIEVED",UVM_HIGH)
  	endfunction
 
  	function void report_phase(uvm_phase phase);
    		super.report_phase(phase);
    		`uvm_info(get_name,$sformatf("INPUT COVERAGE = %0f\n",input_cg.get_coverage()),UVM_NONE);
  	endfunction
endclass
