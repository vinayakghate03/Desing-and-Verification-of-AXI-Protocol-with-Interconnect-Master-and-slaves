class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver)

    virtual axi_master_if vif;
    int unsigned master_id;

    function new(string name = "axi_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_master_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "axi_driver did not receive a virtual interface")
        if (!uvm_config_db#(int unsigned)::get(this, "", "master_id", master_id))
            `uvm_fatal("NOID", "axi_driver did not receive a master id")
    endfunction

    task run_phase(uvm_phase phase);
        axi_transaction req;

        vif.wr_req = 1'b0;
        vif.rd_req = 1'b0;
        vif.wr_addr = '0;
        vif.wr_data = '0;
        vif.wr_strb = '0;
        vif.rd_addr = '0;

        forever begin
            seq_item_port.get_next_item(req);
            req.master_id = master_id;

            if (req.is_write) begin
                @(negedge vif.ACLK);
                vif.wr_addr = req.addr;
                vif.wr_data = req.data;
                vif.wr_strb = req.strb;
                vif.wr_req = 1'b1;
                @(negedge vif.ACLK);
                vif.wr_req = 1'b0;
                do @(posedge vif.ACLK); while (!vif.wr_done);
            end else begin
                @(negedge vif.ACLK);
                vif.rd_addr = req.addr;
                vif.rd_req = 1'b1;
                @(negedge vif.ACLK);
                vif.rd_req = 1'b0;
                do @(posedge vif.ACLK); while (!vif.rd_done);
            end

            seq_item_port.item_done();
        end
    endtask
endclass
