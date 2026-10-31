class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_agent agents[2];
    axi_scoreboard scoreboard;

    function new(string name = "axi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        for (int i = 0; i < 2; i++) begin
            uvm_config_db#(int unsigned)::set(this, $sformatf("agent%0d", i),
                                              "master_id", i);
            agents[i] = axi_agent::type_id::create($sformatf("agent%0d", i), this);
        end
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        for (int i = 0; i < 2; i++)
            agents[i].monitor.analysis_port.connect(scoreboard.analysis_export);
    endfunction
endclass
