`include "uvm_macros.svh"

package axi_pkg;
    import uvm_pkg::*;
    `include "../rtl_design/define.sv"
    `include "axi_transaction.sv"
    `include "axi_sequencer.sv"
    `include "axi_driver.sv"
    `include "axi_monitor.sv"
    `include "axi_agent.sv"
    `include "axi_scoreboard.sv"
    `include "axi_env.sv"
    `include "axi_sequence.sv"
    `include "axi_test.sv"
endpackage
