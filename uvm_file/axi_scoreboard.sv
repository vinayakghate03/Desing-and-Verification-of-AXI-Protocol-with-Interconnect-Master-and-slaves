class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    uvm_analysis_imp #(axi_transaction, axi_scoreboard) analysis_export;
    bit [7:0] model_mem [longint unsigned];
    int unsigned checked;
    int unsigned errors;

    function new(string name = "axi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function bit valid_address(bit [`AXI_ADDR_WIDTH-1:0] addr);
        return ((addr[1:0] == 2'b00) && (addr < 32'h0000_1000) &&
                ((addr & 32'h0000_03ff) <= 32'h0000_03fc));
    endfunction

    function void write(axi_transaction item);
        bit [`AXI_DATA_WIDTH-1:0] expected;
        bit [`AXI_RESP_WIDTH-1:0] expected_resp;
        longint unsigned byte_addr;

        checked++;
        expected_resp = valid_address(item.addr) ? `AXI_OKAY : 2'b10;

        if (item.resp !== expected_resp) begin
            errors++;
            `uvm_error("RESP", $sformatf(
                "M%0d %s addr=%08h response=%b expected=%b",
                item.master_id, item.is_write ? "write" : "read",
                item.addr, item.resp, expected_resp))
            return;
        end

        if (item.is_write) begin
            if (valid_address(item.addr)) begin
                for (int i = 0; i < `AXI_STRB_WIDTH; i++) begin
                    if (item.strb[i])
                        model_mem[item.addr + i] = item.data[i*8 +: 8];
                end
            end
        end else if (valid_address(item.addr)) begin
            expected = '0;
            for (int i = 0; i < `AXI_STRB_WIDTH; i++) begin
                byte_addr = item.addr + i;
                expected[i*8 +: 8] = model_mem.exists(byte_addr) ?
                                      model_mem[byte_addr] : 8'h00;
            end
            if (item.read_data !== expected) begin
                errors++;
                `uvm_error("DATA", $sformatf(
                    "M%0d read addr=%08h data=%08h expected=%08h",
                    item.master_id, item.addr, item.read_data, expected))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        if (errors == 0)
            `uvm_info("SCOREBOARD", $sformatf(
                "Checked %0d completed transactions with no errors", checked), UVM_NONE)
        else
            `uvm_error("SCOREBOARD", $sformatf(
                "Found %0d errors in %0d completed transactions", errors, checked))
    endfunction
endclass
