# AXI4-Lite UVM environment

This directory contains a standalone UVM testbench for the two-master/four-slave
AXI4-Lite RTL in `../rtl_design`.

Each UVM component and sequence item is in its own SystemVerilog file:

- `axi_transaction.sv`: sequence item
- `axi_sequence.sv`: write/read stimulus
- `axi_sequencer.sv`, `axi_driver.sv`, `axi_monitor.sv`, `axi_agent.sv`
- `axi_scoreboard.sv`, `axi_env.sv`, `axi_test.sv`
- `axi_master_if.sv`: virtual-interface definition
- `uvm_tb_top.sv`: clock, reset, DUT, interconnect, and slave instances

From the repository root, compile with `filelist.ff` and select `uvm_tb_top` as
the simulation top using a simulator that provides UVM. For example, with a
simulator-specific UVM installation:

```sh
<simulator> -f filelist.ff -top uvm_tb_top
```

The test drives both masters concurrently, exercises all four address regions,
and checks responses and read data against a reference memory model. Transaction
fields are randomized in `axi_sequence.sv`; address alignment, legal address
range, nonzero write data, and valid byte strobes are constrained in
`axi_transaction.sv`.
