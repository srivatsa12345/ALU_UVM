package pkg;
	`define DW 8
	`define CW 4
	`define n 100
  	import uvm_pkg::*;
  	`include "uvm_macros.svh"
  	`include "my_transaction.sv"
  	`include "sequencer.sv"
  	`include "sequences.sv"
  	`include "driver.sv"
  	`include "in_monitor.sv"
  	`include "out_monitor.sv"
  	`include "act_agent.sv"
  	`include "pass_agent.sv"
  	`include "scoreboard.sv"
  	`include "environment.sv"
  	`include "test.sv"
endpackage

