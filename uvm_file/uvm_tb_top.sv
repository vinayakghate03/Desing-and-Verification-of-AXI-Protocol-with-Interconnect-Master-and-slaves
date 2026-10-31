`timescale 1ns/1ps
`include "../rtl_design/define.sv"

module uvm_tb_top;
    import uvm_pkg::*;
    import axi_pkg::*;

    logic ACLK;
    logic ARESETn;
    axi_master_if master_if[2](ACLK, ARESETn);

    logic [`AXI_ADDR_WIDTH-1:0] m_awaddr [0:1];
    logic m_awvalid [0:1];
    logic m_awready [0:1];
    logic [`AXI_DATA_WIDTH-1:0] m_wdata [0:1];
    logic [`AXI_STRB_WIDTH-1:0] m_wstrb [0:1];
    logic m_wvalid [0:1];
    logic m_wready [0:1];
    logic [`AXI_RESP_WIDTH-1:0] m_bresp [0:1];
    logic m_bvalid [0:1];
    logic m_bready [0:1];
    logic [`AXI_ADDR_WIDTH-1:0] m_araddr [0:1];
    logic m_arvalid [0:1];
    logic m_arready [0:1];
    logic [`AXI_DATA_WIDTH-1:0] m_rdata [0:1];
    logic [`AXI_RESP_WIDTH-1:0] m_rresp [0:1];
    logic m_rvalid [0:1];
    logic m_rready [0:1];

    logic [4*`AXI_ADDR_WIDTH-1:0] s_awaddr_flat;
    logic [3:0] s_awvalid;
    logic [3:0] s_awready;
    logic [4*`AXI_DATA_WIDTH-1:0] s_wdata_flat;
    logic [4*`AXI_STRB_WIDTH-1:0] s_wstrb_flat;
    logic [3:0] s_wvalid;
    logic [3:0] s_wready;
    logic [4*`AXI_RESP_WIDTH-1:0] s_bresp_flat;
    logic s_bvalid [0:3];
    logic [3:0] s_bready;
    logic [4*`AXI_ADDR_WIDTH-1:0] s_araddr_flat;
    logic [3:0] s_arvalid;
    logic [3:0] s_arready;
    logic [4*`AXI_DATA_WIDTH-1:0] s_rdata_flat;
    logic [4*`AXI_RESP_WIDTH-1:0] s_rresp_flat;
    logic s_rvalid [0:3];
    logic [3:0] s_rready;

    initial ACLK = 1'b0;
    always #5 ACLK = ~ACLK;

    initial begin
        ARESETn = 1'b0;
        repeat (3) @(posedge ACLK);
        ARESETn = 1'b1;
    end

    genvar m;
    generate
        for (m = 0; m < 2; m++) begin : g_master
            axi_master u_master (
                .ACLK(ACLK), .ARESETn(ARESETn),
                .wr_req(master_if[m].wr_req), .wr_addr(master_if[m].wr_addr),
                .wr_data(master_if[m].wr_data), .wr_strb(master_if[m].wr_strb),
                .wr_done(master_if[m].wr_done), .wr_resp(master_if[m].wr_resp),
                .rd_req(master_if[m].rd_req), .rd_addr(master_if[m].rd_addr),
                .rd_done(master_if[m].rd_done), .rd_data(master_if[m].rd_data),
                .rd_resp(master_if[m].rd_resp),
                .AWADDR(m_awaddr[m]), .AWVALID(m_awvalid[m]), .AWREADY(m_awready[m]),
                .WDATA(m_wdata[m]), .WSTRB(m_wstrb[m]), .WVALID(m_wvalid[m]),
                .WREADY(m_wready[m]), .BRESP(m_bresp[m]), .BVALID(m_bvalid[m]),
                .BREADY(m_bready[m]), .ARADDR(m_araddr[m]), .ARVALID(m_arvalid[m]),
                .ARREADY(m_arready[m]), .RDATA(m_rdata[m]), .RRESP(m_rresp[m]),
                .RVALID(m_rvalid[m]), .RREADY(m_rready[m])
            );
        end
    endgenerate

    axi_interconnect_2x4 u_interconnect (
        .ACLK(ACLK), .ARESETn(ARESETn),
        .m0_AWADDR(m_awaddr[0]), .m0_AWVALID(m_awvalid[0]), .m0_AWREADY(m_awready[0]),
        .m0_WDATA(m_wdata[0]), .m0_WSTRB(m_wstrb[0]), .m0_WVALID(m_wvalid[0]),
        .m0_WREADY(m_wready[0]), .m0_BRESP(m_bresp[0]), .m0_BVALID(m_bvalid[0]),
        .m0_BREADY(m_bready[0]), .m0_ARADDR(m_araddr[0]), .m0_ARVALID(m_arvalid[0]),
        .m0_ARREADY(m_arready[0]), .m0_RDATA(m_rdata[0]), .m0_RRESP(m_rresp[0]),
        .m0_RVALID(m_rvalid[0]), .m0_RREADY(m_rready[0]),
        .m1_AWADDR(m_awaddr[1]), .m1_AWVALID(m_awvalid[1]), .m1_AWREADY(m_awready[1]),
        .m1_WDATA(m_wdata[1]), .m1_WSTRB(m_wstrb[1]), .m1_WVALID(m_wvalid[1]),
        .m1_WREADY(m_wready[1]), .m1_BRESP(m_bresp[1]), .m1_BVALID(m_bvalid[1]),
        .m1_BREADY(m_bready[1]), .m1_ARADDR(m_araddr[1]), .m1_ARVALID(m_arvalid[1]),
        .m1_ARREADY(m_arready[1]), .m1_RDATA(m_rdata[1]), .m1_RRESP(m_rresp[1]),
        .m1_RVALID(m_rvalid[1]), .m1_RREADY(m_rready[1]),
        .s_AWADDR_flat(s_awaddr_flat), .s_AWVALID(s_awvalid), .s_AWREADY(s_awready),
        .s_WDATA_flat(s_wdata_flat), .s_WSTRB_flat(s_wstrb_flat), .s_WVALID(s_wvalid),
        .s_WREADY(s_wready), .s_BRESP_flat(s_bresp_flat), .s_BVALID(s_bvalid),
        .s_BREADY(s_bready), .s_ARADDR_flat(s_araddr_flat), .s_ARVALID(s_arvalid),
        .s_ARREADY(s_arready), .s_RDATA_flat(s_rdata_flat), .s_RRESP_flat(s_rresp_flat),
        .s_RVALID(s_rvalid), .s_RREADY(s_rready)
    );

    genvar s;
    generate
        for (s = 0; s < 4; s++) begin : g_slave
            axi_slave u_slave (
                .ACLK(ACLK), .ARESETn(ARESETn),
                .AWADDR(s_awaddr_flat[s*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH]),
                .AWVALID(s_awvalid[s]), .AWREADY(s_awready[s]),
                .WDATA(s_wdata_flat[s*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH]),
                .WSTRB(s_wstrb_flat[s*`AXI_STRB_WIDTH +: `AXI_STRB_WIDTH]),
                .WVALID(s_wvalid[s]), .WREADY(s_wready[s]),
                .BRESP(s_bresp_flat[s*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH]),
                .BVALID(s_bvalid[s]), .BREADY(s_bready[s]),
                .ARADDR(s_araddr_flat[s*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH]),
                .ARVALID(s_arvalid[s]), .ARREADY(s_arready[s]),
                .RDATA(s_rdata_flat[s*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH]),
                .RRESP(s_rresp_flat[s*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH]),
                .RVALID(s_rvalid[s]), .RREADY(s_rready[s])
            );
        end
    endgenerate

    initial begin
        uvm_config_db#(virtual axi_master_if)::set(null, "uvm_test_top.env.agent0.*",
                                                    "vif", master_if[0]);
        uvm_config_db#(virtual axi_master_if)::set(null, "uvm_test_top.env.agent1.*",
                                                    "vif", master_if[1]);
        run_test("axi_test");
    end
endmodule
