class axi_test extends uvm_test;
    `uvm_component_utils(axi_test)

    axi_env env;

    function new(string name = "axi_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        axi_sequence seq0;
        axi_sequence seq1;

        phase.raise_objection(this);
        wait (env.agents[0].driver.vif.ARESETn &&
              env.agents[1].driver.vif.ARESETn);

        seq0 = axi_sequence::type_id::create("seq0");
        seq1 = axi_sequence::type_id::create("seq1");
        seq0.master_id = 0;
        seq1.master_id = 1;

        fork
            seq0.start(env.agents[0].sequencer);
            seq1.start(env.agents[1].sequencer);
        join
        repeat (5) @(env.agents[0].driver.vif.ACLK);
        phase.drop_objection(this);
    endtask
endclass
