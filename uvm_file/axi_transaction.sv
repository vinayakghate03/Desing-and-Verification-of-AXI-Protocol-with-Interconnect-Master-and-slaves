class axi_transaction extends uvm_sequence_item;
    rand bit is_write;
    rand bit [`AXI_ADDR_WIDTH-1:0] addr;
    rand bit [`AXI_DATA_WIDTH-1:0] data;
    rand bit [`AXI_STRB_WIDTH-1:0] strb;

    bit [`AXI_DATA_WIDTH-1:0] read_data;
    bit [`AXI_RESP_WIDTH-1:0] resp;
    int unsigned master_id;

    constraint c_aligned_address {
        addr[1:0] == 2'b00;
        addr inside {[32'h0000_0000:32'h0000_0ffc]};
    }

    constraint c_write_data {
        data != '0;
    }

    constraint c_valid_strobe {
        strb != '0;
    }

    `uvm_object_utils_begin(axi_transaction)
        `uvm_field_int(is_write, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_HEX)
        `uvm_field_int(data, UVM_HEX)
        `uvm_field_int(strb, UVM_HEX)
        `uvm_field_int(read_data, UVM_HEX)
        `uvm_field_int(resp, UVM_BIN)
        `uvm_field_int(master_id, UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_transaction");
        super.new(name);
    endfunction
endclass
