`include "define.sv"

// Byte-addressed AXI4-Lite memory slave, with one outstanding read and write.
module axi_slave #(
    parameter int MEM_ADDR_WIDTH = 10
) (
    input logic ACLK, ARESETn,

    input logic [`AXI_ADDR_WIDTH-1:0] AWADDR,
    input logic AWVALID,
    output logic AWREADY,

    input logic [`AXI_DATA_WIDTH-1:0] WDATA,
    input logic [`AXI_STRB_WIDTH-1:0] WSTRB,
    input logic WVALID,
    output logic WREADY,

    output logic [`AXI_RESP_WIDTH-1:0] BRESP,
    output logic BVALID,
    input logic BREADY,

    input logic [`AXI_ADDR_WIDTH-1:0] ARADDR,
    input logic ARVALID,
    output logic ARREADY,

    output logic [`AXI_DATA_WIDTH-1:0] RDATA,
    output logic [`AXI_RESP_WIDTH-1:0] RRESP,
    output logic RVALID,
    input logic RREADY
);
    localparam int MEM_BYTES  = 1 << MEM_ADDR_WIDTH;
    localparam int DATA_BYTES = `AXI_STRB_WIDTH;

    logic [7:0] data_mem [0:MEM_BYTES-1];

    logic [`AXI_ADDR_WIDTH-1:0] saved_awaddr;
    logic [`AXI_DATA_WIDTH-1:0] saved_wdata;
    logic [`AXI_STRB_WIDTH-1:0] saved_wstrb;
    logic have_awaddr, have_wdata;
    logic bvalid_reg, rvalid_reg;
    logic [`AXI_RESP_WIDTH-1:0] bresp_reg, rresp_reg;
    logic [`AXI_DATA_WIDTH-1:0] rdata_reg;
    logic write_complete;

    function automatic logic address_valid(input logic [`AXI_ADDR_WIDTH-1:0] address);
        address_valid = (address[1:0] == 2'b00) && (address <= (MEM_BYTES - DATA_BYTES));
    endfunction

    always_comb begin
        // AXI allows AW and W to arrive in either order, so we hold each payload separately.
        AWREADY = !have_awaddr && !bvalid_reg;
        WREADY  = !have_wdata && !bvalid_reg;

        write_complete = !bvalid_reg &&
                         ((have_awaddr || (AWVALID && AWREADY)) &&
                          (have_wdata  || (WVALID  && WREADY)));

        BVALID = bvalid_reg;
        BRESP  = bresp_reg;

        ARREADY = !rvalid_reg;
        RVALID  = rvalid_reg;
        RRESP   = rresp_reg;
        RDATA   = rdata_reg;
    end

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            saved_awaddr <= '0;
            saved_wdata  <= '0;
            saved_wstrb  <= '0;
            have_awaddr  <= 1'b0;
            have_wdata   <= 1'b0;
            bvalid_reg   <= 1'b0;
            bresp_reg    <= `AXI_OKAY;
            rvalid_reg   <= 1'b0;
            rresp_reg    <= `AXI_OKAY;
            rdata_reg    <= '0;
        end else begin
            if (AWVALID && AWREADY) begin
                saved_awaddr <= AWADDR;
                have_awaddr  <= 1'b1;
            end

            if (WVALID && WREADY) begin
                saved_wdata <= WDATA;
                saved_wstrb <= WSTRB;
                have_wdata  <= 1'b1;
            end

            if (bvalid_reg && BREADY)
                bvalid_reg <= 1'b0;

            if (write_complete) begin
                if (address_valid(have_awaddr ? saved_awaddr : AWADDR)) begin
                    for (int i = 0; i < DATA_BYTES; i++) begin
                        if (have_wdata ? saved_wstrb[i] : WSTRB[i]) begin
                            data_mem[(have_awaddr ? saved_awaddr : AWADDR) + i] <=
                                have_wdata ? saved_wdata[i*8 +: 8] : WDATA[i*8 +: 8];
                        end
                    end
                    bresp_reg <= `AXI_OKAY;
                end else begin
                    bresp_reg <= 2'b10; // SLVERR: unaligned or out-of-range address
                end

                have_awaddr <= 1'b0;
                have_wdata  <= 1'b0;
                bvalid_reg  <= 1'b1;
            end

            if (ARVALID && ARREADY) begin
                if (address_valid(ARADDR)) begin
                    rdata_reg <= {data_mem[ARADDR + 3], data_mem[ARADDR + 2],
                                  data_mem[ARADDR + 1], data_mem[ARADDR]};
                    rresp_reg <= `AXI_OKAY;
                end else begin
                    rdata_reg <= '0;
                    rresp_reg <= 2'b10; // SLVERR
                end
                rvalid_reg <= 1'b1;
            end else if (rvalid_reg && RREADY) begin
                rvalid_reg <= 1'b0;
            end
        end
    end
endmodule
