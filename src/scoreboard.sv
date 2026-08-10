class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	uvm_tlm_analysis_fifo #(my_transaction) in_fifo;
	uvm_tlm_analysis_fifo #(my_transaction) out_fifo;

	int MATCH,MISMATCH,TOTAL,counta,countb;
	bit[`DW-1:0]opa,opb;
     	bit[`CW-1:0]cmd;
     	bit signed [`DW*2-1:0]res,inter;
	bit cin,mode,cout,oflow,g,e,l,err,v,countmul,f,c;

	function new(string name, uvm_component parent);
		super.new(name,parent);
		in_fifo=new("in_fifo",this);
		out_fifo=new("out_fifo",this);
	endfunction
	
	task run_phase(uvm_phase phase);
		my_transaction inp_mon_xn,inp_mon_xn_hold;
		my_transaction out_mon_xn;
		forever begin
			fork 
				in_fifo.get(inp_mon_xn);
				out_fifo.get(out_mon_xn);
			join
			if (f==0) begin
				f=1;
				inp_mon_xn_hold=inp_mon_xn;
			end else begin
				ref_model(inp_mon_xn_hold);
				validate_outputs(inp_mon_xn_hold,out_mon_xn);
				inp_mon_xn_hold=inp_mon_xn;
			end
		end
	endtask
	function void compare_results();
		`uvm_info("SCOREBOARD",$sformatf("Total clock Cycles Checked:%0d\n Total cycles matched:%0d\n Total cycles failes:%0d",TOTAL,MATCH,MISMATCH),UVM_NONE);
	endfunction

	task ref_model(my_transaction inp);
	
		if(inp.rst) begin
			opa=0;
			opb=0;
			cin=0;
			cmd=0;
			res=0;
			mode=0;
			cout=0;
			oflow=0;
			g=0;
			e=0;
			l=0;
			err=0;
			v=0;
			counta=0;countb=0;
		end 

		inp.RES=res;
		inp.COUT=cout;
		inp.OFLOW=oflow;
		inp.G=g;
		inp.E=e;
		inp.L=l;
		inp.ERR=err;
		err=0;
		c=0;

		if((!inp.rst)&&(inp.CE)) begin
			if((cmd==inp.CMD)||(mode==inp.MODE)) c=0; else c=1;
			cmd=inp.CMD;
			mode=inp.MODE;
			if(inp.INP_VALID==2'b01) begin
				opa=inp.OPA;
				if (c==1) begin countb=1; c=0; v=0; end 
				else if((counta>0)&&(v==0)) begin counta=0;v=1; end else begin countb++; v=0; end
			end else if (inp.INP_VALID==2'b10) begin
				opb=inp.OPB;
				if (c==1) begin counta=1; c=0; v=0; end 
				else if ((countb>0)&&(v==0)) begin countb=0;v=1; end else begin counta++; v=0; end
			end else if (inp.INP_VALID==2'b11) begin
				opa=inp.OPA;
				opb=inp.OPB;
				if (c==1) begin c=0; end
				counta=0;countb=0;
				v=1;
			end else begin
				if(c==1) begin res=0; cout=0; oflow=0; g=0; e=0; l=0; err=0; counta=0;countb=0; end
				if(counta>0) counta++; else if(countb>0) countb++;
			end	
			if ((counta==17)||(countb==17)) begin
				counta=0;
				countb=0;
				opa=0;
				opb=0;
				cin=0;
				res=0;
				cout=0;
				oflow=0;
				g=0;
				e=0;
				l=0;
				err=1;
				v=0;
			end 
		end
		
		if((inp.CE)&&(!inp.rst)&&(v==1)&&(err!=1)) begin
			cin=inp.CIN;
			res=0;cout=0;oflow=0;g=0;e=0;l=0;err=0;
			if(mode) begin
				case(cmd)
					4'b0000:begin res=opa+opb; cout=res[`DW]; end
					4'b0001:begin res=opa-opb; oflow=opb>opa; end
					4'b0010:begin res=opa+opb+cin; cout=res[`DW]; end
					4'b0011:begin res=opa-opb-cin; oflow=((opb>opa)||((opa==opb)&&(cin==1))); end
					4'b0100:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opa+1));
					4'b0101:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opa-1));
					4'b0110:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opb+1));
					4'b0111:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opb-1));
					4'b1000:begin g=(opa>opb); e=(opa==opb); l=(opa<opb); end
					4'b1001:begin res=inter; inter=(opa+1)*(opb+1); end
					4'b1010:begin res=inter; inter=(opa<<1)*opb; end
					default:begin res=0;cout=0;oflow=0;g=0;e=0;l=0;err=1; end
				endcase
			end else begin
				case(cmd)
					4'b0000:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opa&opb));
					4'b0001:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(~(opa&opb)));
					4'b0010:res=(({{`DW{1'b0}},{`DW{1'b1}}})&((opa|opb)));
					4'b0011:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(~(opa|opb)));
					4'b0100:res=(({{`DW{1'b0}},{`DW{1'b1}}})&((opa^opb)));
					4'b0101:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(~(opa^opb)));
					4'b0110:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(~(opa)));
					4'b0111:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(~(opb)));
					4'b1000:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opa>>1));
					4'b1001:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opa<<1));
					4'b1010:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opb>>1));
					4'b1011:res=(({{`DW{1'b0}},{`DW{1'b1}}})&(opb<<1));
					4'b1100:begin
						if(opb[`DW-1:$clog2(`DW)+1]!=0) begin
							res=0;
							err=1;
						end else res=(({{`DW{1'b0}},{`DW{1'b1}}})&((opa<<opb[$clog2(`DW)-1:0])|(opa>>(`DW-opb[$clog2(`DW)-1:0]))));
					end
					4'b1101:begin
						if(opb[`DW-1:$clog2(`DW)+1]!=0) begin
							res=0;
							err=1;
						end else res=(({{`DW{1'b0}},{`DW{1'b1}}})&((opa>>opb[$clog2(`DW)-1:0])|(opa<<(`DW-opb[$clog2(`DW)-1:0]))));
					end
					default:begin res=0;cout=0;oflow=0;g=0;e=0;l=0;err=1; end
				endcase
			end
		end		
	endtask
	task validate_outputs(my_transaction inp, my_transaction out);
		++TOTAL;
		if(inp.rst==1'b1) begin
			if((out.RES!=0)||(out.COUT!=0)||(out.OFLOW!=0)||(out.G!=0)||(out.E!=0)||(out.L!=0)||(out.ERR!=0)) begin
				//`uvm_info("SCOREBOARD",$sformatf("Output from DUT:\n%s",out.sprint()),UVM_NONE)
				`uvm_info("SCOREBOARD",$sformatf("\nDUT: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\nREF: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\n_________________________________________________________________________________________________________________________________________",out.RES,out.COUT,out.OFLOW,out.G,out.E,out.L,out.ERR,inp.RES,inp.COUT,inp.OFLOW,inp.G,inp.E,inp.L,inp.ERR),UVM_NONE) 
				++MISMATCH;
			end else begin
				//`uvm_info("SCOREBOARD",$sformatf("Output from DUT:\n%s",out.sprint()),UVM_NONE)
				`uvm_info("SCOREBOARD",$sformatf("\nDUT: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\nREF: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h",out.RES,out.COUT,out.OFLOW,out.G,out.E,out.L,out.ERR,inp.RES,inp.COUT,inp.OFLOW,inp.G,inp.E,inp.L,inp.ERR),UVM_NONE) 
				++MATCH;
			end
		end else begin
			if ((inp.MODE==1)&&(countmul==0)&&((inp.CMD==4'b1001)||(inp.CMD==4'b1010))) begin
				countmul=1;
				`uvm_info("SCOREBOARD","Multipliaction second cycle ignored",UVM_NONE)
			end else begin
				if((inp.MODE!=1)&&(inp.CMD!=4'b1001)&&(inp.CMD!=4'b1010)) countmul=0;
				if((out.RES!=inp.RES)||(out.COUT!=inp.COUT)||(out.OFLOW!=inp.OFLOW)||(out.G!=inp.G)||(out.E!=inp.E)||(out.L!=inp.L)||(out.ERR!=inp.ERR)) begin
					//`uvm_info("SCOREBOARD",$sformatf("Output from DUT:\n%s\nOutput from REF:\n%s\n",out.sprint(),inp.sprint()),UVM_NONE)
					`uvm_info("SCOREBOARD",$sformatf("\nDUT: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\nREF: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\n_________________________________________________________________________________________________________________________________________",out.RES,out.COUT,out.OFLOW,out.G,out.E,out.L,out.ERR,inp.RES,inp.COUT,inp.OFLOW,inp.G,inp.E,inp.L,inp.ERR),UVM_NONE) 
					++MISMATCH;
				end else begin
					//`uvm_info("SCOREBOARD",$sformatf("Output from DUT:\n%s\nOutput from REF:\n%s\n",out.sprint(),inp.sprint()),UVM_NONE)
					`uvm_info("SCOREBOARD",$sformatf("\nDUT: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h\nREF: RES=%0h, COUT=%0h, OFLOW=%0h, G=%0h, E=%0h, L=%0h, ERR=%0h",out.RES,out.COUT,out.OFLOW,out.G,out.E,out.L,out.ERR,inp.RES,inp.COUT,inp.OFLOW,inp.G,inp.E,inp.L,inp.ERR),UVM_NONE) 
					++MATCH;
				end
			end
		end
	endtask
endclass
