class axi_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_sequence)

    int unsigned master_id;

    function new(string name = "axi_sequence");
        super.new(name);
    endfunction

    task automatic send_random_read(
        int unsigned slave_index,
        bit [`AXI_ADDR_WIDTH-1:0] expected_addr
    );
        axi_transaction item;
        bit [`AXI_ADDR_WIDTH-1:0] slave_base;

        slave_base = slave_index * 32'h0000_0400;
        item = axi_transaction::type_id::create("random_read");
        start_item(item);
        if (!item.randomize() with {
            is_write == 1'b0;
            addr == expected_addr;
            addr inside {[slave_base : slave_base + 32'h0000_03fc]};
        })
            `uvm_fatal("RANDFAIL", "Unable to randomize AXI read transaction")
        finish_item(item);
    endtask

    task body();
        axi_transaction write_item;
        bit [`AXI_ADDR_WIDTH-1:0] write_addr;

        // One randomized write/read pair per slave region. Both agents run
        // this loop concurrently, exercising contention and independent routes.
        for (int unsigned slave_index = 0; slave_index < 4; slave_index++) begin
            write_item = axi_transaction::type_id::create("random_write");
            start_item(write_item);
            if (!write_item.randomize() with {
                is_write == 1'b1;
                addr inside {[slave_index * 32'h0000_0400 :
                              (slave_index * 32'h0000_0400) + 32'h0000_03fc]};
            })
                `uvm_fatal("RANDFAIL", "Unable to randomize AXI write transaction")
            write_addr = write_item.addr;
            finish_item(write_item);
            send_random_read(slave_index, write_addr);
        end

        // Additional unconstrained randomized traffic remains inside the
        // legal AXI address map and increases data/strobe variation.
        repeat (5) begin
            write_item = axi_transaction::type_id::create("random_access");
            start_item(write_item);
            if (!write_item.randomize())
                `uvm_fatal("RANDFAIL", "Unable to randomize AXI transaction")
            finish_item(write_item);
        end
    endtask
endclass
