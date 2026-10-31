class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_master_if vif;
    uvm_analysis_port #(axi_transaction) analysis_port;
    int unsigned master_id;

    axi_transaction pending_writes[$];
    axi_transaction pending_reads[$];

    function new(string name = "axi_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_master_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "axi_monitor did not receive a virtual interface")
        if (!uvm_config_db#(int unsigned)::get(this, "", "master_id", master_id))
            `uvm_fatal("NOID", "axi_monitor did not receive a master id")
    endfunction

    task run_phase(uvm_phase phase);
        axi_transaction item;

        forever begin
            @(posedge vif.ACLK);

            if (vif.wr_req) begin
                item = axi_transaction::type_id::create("pending_write");
                item.is_write = 1'b1;
                item.addr = vif.wr_addr;
                item.data = vif.wr_data;
                item.strb = vif.wr_strb;
                item.master_id = master_id;
                pending_writes.push_back(item);
            end

            if (vif.rd_req) begin
                item = axi_transaction::type_id::create("pending_read");
                item.is_write = 1'b0;
                item.addr = vif.rd_addr;
                item.master_id = master_id;
                pending_reads.push_back(item);
            end

            if (vif.wr_done && (pending_writes.size() != 0)) begin
                item = pending_writes.pop_front();
                item.resp = vif.wr_resp;
                analysis_port.write(item);
            end

            if (vif.rd_done && (pending_reads.size() != 0)) begin
                item = pending_reads.pop_front();
                item.read_data = vif.rd_data;
                item.resp = vif.rd_resp;
                analysis_port.write(item);
            end
        end
    endtask
endclass
