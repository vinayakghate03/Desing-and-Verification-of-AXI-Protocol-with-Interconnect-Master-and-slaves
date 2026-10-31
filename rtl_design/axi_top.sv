`timescale 1ns/1ps
`include "define.sv"

module tb_top;
    logic ACLK = 1'b0;
    logic ARESETn = 1'b0;
    always #5 ACLK = ~ACLK;

    initial begin
        $dumpfile("axi.vcd");
        $dumpvars(0, tb_top);
    end

    logic wr_req [0:1];
    logic rd_req [0:1];
    logic [`AXI_ADDR_WIDTH-1:0] wr_addr [0:1];
    logic [`AXI_ADDR_WIDTH-1:0] rd_addr [0:1];
    logic [`AXI_DATA_WIDTH-1:0] wr_data [0:1];
    logic [`AXI_DATA_WIDTH-1:0] rd_data [0:1];
    logic [`AXI_STRB_WIDTH-1:0] wr_strb [0:1];
    logic wr_done [0:1];
    logic rd_done [0:1];
    logic [`AXI_RESP_WIDTH-1:0] wr_resp [0:1];
    logic [`AXI_RESP_WIDTH-1:0] rd_resp [0:1];

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

    axi_master u_master_0 (
        .ACLK, .ARESETn,
        .wr_req(wr_req[0]), .wr_addr(wr_addr[0]), .wr_data(wr_data[0]),
        .wr_strb(wr_strb[0]), .wr_done(wr_done[0]), .wr_resp(wr_resp[0]),
        .rd_req(rd_req[0]), .rd_addr(rd_addr[0]), .rd_done(rd_done[0]),
        .rd_data(rd_data[0]), .rd_resp(rd_resp[0]),
        .AWADDR(m_awaddr[0]), .AWVALID(m_awvalid[0]), .AWREADY(m_awready[0]),
        .WDATA(m_wdata[0]), .WSTRB(m_wstrb[0]), .WVALID(m_wvalid[0]), .WREADY(m_wready[0]),
        .BRESP(m_bresp[0]), .BVALID(m_bvalid[0]), .BREADY(m_bready[0]),
        .ARADDR(m_araddr[0]), .ARVALID(m_arvalid[0]), .ARREADY(m_arready[0]),
        .RDATA(m_rdata[0]), .RRESP(m_rresp[0]), .RVALID(m_rvalid[0]), .RREADY(m_rready[0])
    );

   axi_master u_master_1 (
			  .ACLK, .ARESETn,
			  .wr_req(wr_req[1]), .wr_addr(wr_addr[1]), .wr_data(wr_data[1]),
			  .wr_strb(wr_strb[1]), .wr_done(wr_done[1]), .wr_resp(wr_resp[1]),
			  .rd_req(rd_req[1]), .rd_addr(rd_addr[1]), .rd_done(rd_done[1]),
			  .rd_data(rd_data[1]), .rd_resp(rd_resp[1]),
			  .AWADDR(m_awaddr[1]), .AWVALID(m_awvalid[1]), .AWREADY(m_awready[1]),
			  .WDATA(m_wdata[1]), .WSTRB(m_wstrb[1]), .WVALID(m_wvalid[1]), .WREADY(m_wready[1]),
			  .BRESP(m_bresp[1]), .BVALID(m_bvalid[1]), .BREADY(m_bready[1]),
			  .ARADDR(m_araddr[1]), .ARVALID(m_arvalid[1]), .ARREADY(m_arready[1]),
			  .RDATA(m_rdata[1]), .RRESP(m_rresp[1]), .RVALID(m_rvalid[1]), .RREADY(m_rready[1])
			  );
   
   axi_interconnect_2x4 u_interconnect (
					.ACLK, .ARESETn,
					.m0_AWADDR(m_awaddr[0]), .m0_AWVALID(m_awvalid[0]), .m0_AWREADY(m_awready[0]),
					.m0_WDATA(m_wdata[0]), .m0_WSTRB(m_wstrb[0]), .m0_WVALID(m_wvalid[0]), .m0_WREADY(m_wready[0]),
					.m0_BRESP(m_bresp[0]), .m0_BVALID(m_bvalid[0]), .m0_BREADY(m_bready[0]),
					.m0_ARADDR(m_araddr[0]), .m0_ARVALID(m_arvalid[0]), .m0_ARREADY(m_arready[0]),
					.m0_RDATA(m_rdata[0]), .m0_RRESP(m_rresp[0]), .m0_RVALID(m_rvalid[0]), .m0_RREADY(m_rready[0]),
					.m1_AWADDR(m_awaddr[1]), .m1_AWVALID(m_awvalid[1]), .m1_AWREADY(m_awready[1]),
					.m1_WDATA(m_wdata[1]), .m1_WSTRB(m_wstrb[1]), .m1_WVALID(m_wvalid[1]), .m1_WREADY(m_wready[1]),
					.m1_BRESP(m_bresp[1]), .m1_BVALID(m_bvalid[1]), .m1_BREADY(m_bready[1]),
					.m1_ARADDR(m_araddr[1]), .m1_ARVALID(m_arvalid[1]), .m1_ARREADY(m_arready[1]),
					.m1_RDATA(m_rdata[1]), .m1_RRESP(m_rresp[1]), .m1_RVALID(m_rvalid[1]), .m1_RREADY(m_rready[1]),
					.s_AWADDR_flat(s_awaddr_flat), .s_AWVALID(s_awvalid), .s_AWREADY(s_awready),
					.s_WDATA_flat(s_wdata_flat), .s_WSTRB_flat(s_wstrb_flat),
					.s_WVALID(s_wvalid), .s_WREADY(s_wready),
					.s_BRESP_flat(s_bresp_flat), .s_BVALID(s_bvalid), .s_BREADY(s_bready),
					.s_ARADDR_flat(s_araddr_flat), .s_ARVALID(s_arvalid), .s_ARREADY(s_arready),
					.s_RDATA_flat(s_rdata_flat), .s_RRESP_flat(s_rresp_flat),
					.s_RVALID(s_rvalid), .s_RREADY(s_rready)
					);
   
   genvar	slave_index;
   generate
      for (slave_index = 0; slave_index < 4; slave_index = slave_index + 1) begin : g_slave
         axi_slave u_slave (
			    .ACLK, .ARESETn,
			    .AWADDR(s_awaddr_flat[slave_index*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH]),
			    .AWVALID(s_awvalid[slave_index]),
			    .AWREADY(s_awready[slave_index]),
			    .WDATA(s_wdata_flat[slave_index*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH]),
			    .WSTRB(s_wstrb_flat[slave_index*`AXI_STRB_WIDTH +: `AXI_STRB_WIDTH]),
			    .WVALID(s_wvalid[slave_index]), .WREADY(s_wready[slave_index]),
			    .BRESP(s_bresp_flat[slave_index*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH]),
			    .BVALID(s_bvalid[slave_index]),
			    .BREADY(s_bready[slave_index]),
			    .ARADDR(s_araddr_flat[slave_index*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH]),
			    .ARVALID(s_arvalid[slave_index]),
			    .ARREADY(s_arready[slave_index]),
			    .RDATA(s_rdata_flat[slave_index*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH]),
			    .RRESP(s_rresp_flat[slave_index*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH]),
			    .RVALID(s_rvalid[slave_index]), .RREADY(s_rready[slave_index])
			    );
      end
   endgenerate
   
   task automatic write_word(
			     input integer		       master_index,
			     input logic [`AXI_ADDR_WIDTH-1:0] address,
			     input logic [`AXI_DATA_WIDTH-1:0] data
			     );
      begin
         @(posedge ACLK);
         wr_addr[master_index] <= address;
         wr_data[master_index] <= data;
         wr_strb[master_index] <= {`AXI_STRB_WIDTH{1'b1}};
         wr_req[master_index] <= 1'b1;
         @(posedge ACLK);
         wr_req[master_index] <= 1'b0;
         wait (wr_done[master_index]);
         #1;
         if (wr_resp[master_index] !== `AXI_OKAY)
           $fatal(1, "M%0d write failed at %08h response=%b",
                  master_index, address, wr_resp[master_index]);
         $display("M%0d WRITE PASS address=%08h data=%08h",
                  master_index, address, data);
      end
   endtask
   
   task automatic read_word(
			    input integer		      master_index,
			    input logic [`AXI_ADDR_WIDTH-1:0] address,
			    input logic [`AXI_DATA_WIDTH-1:0] expected
			    );
      begin
         @(posedge ACLK);
         rd_addr[master_index] <= address;
         rd_req[master_index] <= 1'b1;
         @(posedge ACLK);
         rd_req[master_index] <= 1'b0;
         wait (rd_done[master_index]);
         #1;
         if (rd_resp[master_index] !== `AXI_OKAY ||
             rd_data[master_index] !== expected)
           $fatal(1, "M%0d read failed at %08h got=%08h expected=%08h response=%b",
                  master_index, address, rd_data[master_index], expected,
                  rd_resp[master_index]);
         $display("M%0d READ  PASS address=%08h data=%08h",
                  master_index, address, rd_data[master_index]);
      end
   endtask
   
   initial begin
      // Create an explicit reset edge so every sequential block is reset
      // consistently across simulators.
      ARESETn = 1'b1;
      #1 ARESETn = 1'b0;
      
      for (int m = 0; m < 2; m++) begin
         wr_req[m] = 1'b0;
         rd_req[m] = 1'b0;
         wr_addr[m] = '0;
         rd_addr[m] = '0;
         wr_data[m] = '0;
         wr_strb[m] = '0;
      end
      
      repeat (3) @(posedge ACLK);
      ARESETn = 1'b1;
      
      // Both masters target slave 0. Round-robin arbitration serializes them.
      fork
         write_word(0, 32'h0000_0010, 32'hAAAA_0000);
         write_word(1, 32'h0000_0020, 32'hBBBB_0001);
      join
      fork
         read_word(0, 32'h0000_0010, 32'hAAAA_0000);
         read_word(1, 32'h0000_0020, 32'hBBBB_0001);
      join
      $display("SAME-SLAVE CONTENTION PASS");
      
      // Different address regions select different slaves and can proceed together.
      fork
         write_word(0, 32'h0000_0410, 32'hCCCC_0002);
         write_word(1, 32'h0000_0810, 32'hDDDD_0003);
      join
      fork
         read_word(0, 32'h0000_0410, 32'hCCCC_0002);
         read_word(1, 32'h0000_0810, 32'hDDDD_0003);
      join
      $display("MULTIPLE-SLAVE SELECTION PASS");
      
      $display("ALL 2-MASTER/4-SLAVE AXI4-LITE TESTS PASSED");
      $finish;
   end
endmodule
