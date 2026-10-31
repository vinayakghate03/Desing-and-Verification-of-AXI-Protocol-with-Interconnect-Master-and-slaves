class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)

    axi_sequencer sequencer;
    axi_driver driver;
    axi_monitor monitor;
    int unsigned master_id;

    function new(string name = "axi_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(int unsigned)::get(this, "", "master_id", master_id))
            `uvm_fatal("NOID", "axi_agent did not receive a master id")

        sequencer = axi_sequencer::type_id::create("sequencer", this);
        driver = axi_driver::type_id::create("driver", this);
        monitor = axi_monitor::type_id::create("monitor", this);

        uvm_config_db#(int unsigned)::set(this, "driver", "master_id", master_id);
        uvm_config_db#(int unsigned)::set(this, "monitor", "master_id", master_id);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
