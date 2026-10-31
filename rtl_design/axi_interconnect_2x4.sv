`include "define.sv"

// 2-master/4-slave AXI4-Lite interconnect.
//
// Address map:
//   slave 0: 0x0000_0000 - 0x0000_03ff
//   slave 1: 0x0000_0400 - 0x0000_07ff
//   slave 2: 0x0000_0800 - 0x0000_0bff
//   slave 3: 0x0000_0c00 - 0x0000_0fff
//
// Each slave has independent round-robin arbitration for reads and writes.
// A grant remains locked to the selected master until the corresponding
// AXI4-Lite response is accepted.
module axi_interconnect_2x4 #(
			      parameter int SLAVE_ADDR_BITS = 10
			      ) (
				 input logic			      ACLK,
				 input logic			      ARESETn,
				 
				 input logic [`AXI_ADDR_WIDTH-1:0]    m0_AWADDR,
				 input logic			      m0_AWVALID,
				 output logic			      m0_AWREADY,
				 input logic [`AXI_DATA_WIDTH-1:0]    m0_WDATA,
				 input logic [`AXI_STRB_WIDTH-1:0]    m0_WSTRB,
				 input logic			      m0_WVALID,
				 output logic			      m0_WREADY,
				 output logic [`AXI_RESP_WIDTH-1:0]   m0_BRESP,
				 output logic			      m0_BVALID,
				 input logic			      m0_BREADY,
				 input logic [`AXI_ADDR_WIDTH-1:0]    m0_ARADDR,
				 input logic			      m0_ARVALID,
				 output logic			      m0_ARREADY,
				 output logic [`AXI_DATA_WIDTH-1:0]   m0_RDATA,
				 output logic [`AXI_RESP_WIDTH-1:0]   m0_RRESP,
				 output logic			      m0_RVALID,
				 input logic			      m0_RREADY,

				 input logic [`AXI_ADDR_WIDTH-1:0]    m1_AWADDR,
				 input logic			      m1_AWVALID,
				 output logic			      m1_AWREADY,
				 input logic [`AXI_DATA_WIDTH-1:0]    m1_WDATA,
				 input logic [`AXI_STRB_WIDTH-1:0]    m1_WSTRB,
				 input logic			      m1_WVALID,
				 output logic			      m1_WREADY,
				 output logic [`AXI_RESP_WIDTH-1:0]   m1_BRESP,
				 output logic			      m1_BVALID,
				 input logic			      m1_BREADY,
				 input logic [`AXI_ADDR_WIDTH-1:0]    m1_ARADDR,
				 input logic			      m1_ARVALID,
				 output logic			      m1_ARREADY,
				 output logic [`AXI_DATA_WIDTH-1:0]   m1_RDATA,
				 output logic [`AXI_RESP_WIDTH-1:0]   m1_RRESP,
				 output logic			      m1_RVALID,
				 input logic			      m1_RREADY,

				 output logic [4*`AXI_ADDR_WIDTH-1:0] s_AWADDR_flat,
				 output logic [3:0]		      s_AWVALID,
				 input logic [3:0]		      s_AWREADY,
				 output logic [4*`AXI_DATA_WIDTH-1:0] s_WDATA_flat,
				 output logic [4*`AXI_STRB_WIDTH-1:0] s_WSTRB_flat,
				 output logic [3:0]		      s_WVALID,
				 input logic [3:0]		      s_WREADY,
				 input logic [4*`AXI_RESP_WIDTH-1:0]  s_BRESP_flat,
				 input logic			      s_BVALID [0:3],
				 output logic [3:0]		      s_BREADY,
				 output logic [4*`AXI_ADDR_WIDTH-1:0] s_ARADDR_flat,
				 output logic [3:0]		      s_ARVALID,
				 input logic [3:0]		      s_ARREADY,
				 input logic [4*`AXI_DATA_WIDTH-1:0]  s_RDATA_flat,
				 input logic [4*`AXI_RESP_WIDTH-1:0]  s_RRESP_flat,
				 input logic			      s_RVALID [0:3],
				 output logic [3:0]		      s_RREADY
);
    localparam int SLAVE_BYTES = 1 << SLAVE_ADDR_BITS;

   logic	   write_active [0:3];
   logic	   write_owner [0:3];
   logic	   read_active [0:3];
   logic	   read_owner [0:3];
   logic	   write_rr [0:3];
   logic	   read_rr [0:3];
   logic	   write_grant [0:3];
   logic	   read_grant [0:3];
   logic [1:0]	   write_selected [0:3];
   logic [1:0]	   read_selected [0:3];
   logic [`AXI_ADDR_WIDTH-1:0] s_AWADDR [0:3];
   logic [`AXI_DATA_WIDTH-1:0] s_WDATA [0:3];
   logic [`AXI_STRB_WIDTH-1:0] s_WSTRB [0:3];
   logic [`AXI_RESP_WIDTH-1:0] s_BRESP [0:3];
   logic [`AXI_ADDR_WIDTH-1:0] s_ARADDR [0:3];
   logic [`AXI_DATA_WIDTH-1:0] s_RDATA [0:3];
   logic [`AXI_RESP_WIDTH-1:0] s_RRESP [0:3];
   
   genvar		       bus_index;
   generate
      for (bus_index = 0; bus_index < 4; bus_index = bus_index + 1) begin : g_bus
         assign s_AWADDR_flat[bus_index*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH] = s_AWADDR[bus_index];
         assign s_WDATA_flat[bus_index*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH] = s_WDATA[bus_index];
         assign s_WSTRB_flat[bus_index*`AXI_STRB_WIDTH +: `AXI_STRB_WIDTH] = s_WSTRB[bus_index];
         assign s_BRESP[bus_index] = s_BRESP_flat[bus_index*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH];
         assign s_ARADDR_flat[bus_index*`AXI_ADDR_WIDTH +: `AXI_ADDR_WIDTH] = s_ARADDR[bus_index];
         assign s_RDATA[bus_index] = s_RDATA_flat[bus_index*`AXI_DATA_WIDTH +: `AXI_DATA_WIDTH];
         assign s_RRESP[bus_index] = s_RRESP_flat[bus_index*`AXI_RESP_WIDTH +: `AXI_RESP_WIDTH];
      end
   endgenerate
   
   function automatic integer decode_slave(
					   input logic [`AXI_ADDR_WIDTH-1:0] address
					   );
      integer								     selected;
      begin
         selected = -1;
         if (address < (4 * SLAVE_BYTES))
           selected = address / SLAVE_BYTES;
         decode_slave = selected;
        end
   endfunction
   
   function automatic logic [`AXI_ADDR_WIDTH-1:0] local_address(
								
								input logic [`AXI_ADDR_WIDTH-1:0] address,
								input integer			  slave_index
								
								);
      
      local_address = address - (slave_index * SLAVE_BYTES);
      
   endfunction
   
   always @* begin
      m0_AWREADY = 1'b0;
      m1_AWREADY = 1'b0;
      m0_WREADY  = 1'b0;
      m1_WREADY  = 1'b0;
      m0_BVALID  = 1'b0;
      m1_BVALID  = 1'b0;
      m0_BRESP   = `AXI_OKAY;
      m1_BRESP   = `AXI_OKAY;
      m0_ARREADY = 1'b0;
      m1_ARREADY = 1'b0;
      m0_RVALID  = 1'b0;
      m1_RVALID  = 1'b0;
      m0_RDATA   = '0;
      m1_RDATA   = '0;
      m0_RRESP   = `AXI_OKAY;
      m1_RRESP   = `AXI_OKAY;
      
      for (int s = 0; s < 4; s++) begin
         write_grant[s] = 1'b0;
         read_grant[s] = 1'b0;
         write_selected[s] = 2'b00;
         read_selected[s] = 2'b00;
	 
         s_AWADDR[s] = '0;
         s_AWVALID[s] = 1'b0;
         s_WDATA[s] = '0;
         s_WSTRB[s] = '0;
         s_WVALID[s] = 1'b0;
         s_BREADY[s] = 1'b0;
         s_ARADDR[s] = '0;
         s_ARVALID[s] = 1'b0;
         s_RREADY[s] = 1'b0;
	 
         if (write_active[s]) begin
            write_selected[s] = write_owner[s] ? 2'b01 : 2'b00;
         end else if (write_rr[s] == 1'b0) begin
            if (m0_AWVALID && (decode_slave(m0_AWADDR) == s)) begin
               write_grant[s] = 1'b1;
               write_selected[s] = 2'b00;
            end else if (m1_AWVALID && (decode_slave(m1_AWADDR) == s)) begin
               write_grant[s] = 1'b1;
               write_selected[s] = 2'b01;
            end
         end else begin
            if (m1_AWVALID && (decode_slave(m1_AWADDR) == s)) begin
               write_grant[s] = 1'b1;
               write_selected[s] = 2'b01;
            end else if (m0_AWVALID && (decode_slave(m0_AWADDR) == s)) begin
               write_grant[s] = 1'b1;
               write_selected[s] = 2'b00;
            end
         end
	 
         if (read_active[s]) begin
            read_selected[s] = read_owner[s] ? 2'b01 : 2'b00;
         end else if (read_rr[s] == 1'b0) begin
            if (m0_ARVALID && (decode_slave(m0_ARADDR) == s)) begin
               read_grant[s] = 1'b1;
               read_selected[s] = 2'b00;
            end else if (m1_ARVALID && (decode_slave(m1_ARADDR) == s)) begin
               read_grant[s] = 1'b1;
               read_selected[s] = 2'b01;
            end
         end else begin
            if (m1_ARVALID && (decode_slave(m1_ARADDR) == s)) begin
               read_grant[s] = 1'b1;
               read_selected[s] = 2'b01;
            end else if (m0_ARVALID && (decode_slave(m0_ARADDR) == s)) begin
               read_grant[s] = 1'b1;
               read_selected[s] = 2'b00;
            end
         end
	 
         if (write_active[s] || write_grant[s]) begin
            s_AWADDR[s] = (write_selected[s] == 2'b00) ?
                          local_address(m0_AWADDR, s) :
                          local_address(m1_AWADDR, s);
            s_AWVALID[s] = (write_selected[s] == 2'b00) ?
                           m0_AWVALID : m1_AWVALID;
            s_WDATA[s] = (write_selected[s] == 2'b00) ? m0_WDATA : m1_WDATA;
            s_WSTRB[s] = (write_selected[s] == 2'b00) ? m0_WSTRB : m1_WSTRB;
            s_WVALID[s] = (write_selected[s] == 2'b00) ? m0_WVALID : m1_WVALID;
            s_BREADY[s] = (write_selected[s] == 2'b00) ? m0_BREADY : m1_BREADY;
	    
            if (write_selected[s] == 2'b00) begin
               m0_AWREADY = s_AWREADY[s];
               m0_WREADY = s_WREADY[s];
               m0_BVALID = s_BVALID[s];
               m0_BRESP = s_BRESP[s];
            end else begin
               m1_AWREADY = s_AWREADY[s];
               m1_WREADY = s_WREADY[s];
               m1_BVALID = s_BVALID[s];
               m1_BRESP = s_BRESP[s];
            end
         end
	 
         if (read_active[s] || read_grant[s]) begin
            s_ARADDR[s] = (read_selected[s] == 2'b00) ?
                          local_address(m0_ARADDR, s) :
                          local_address(m1_ARADDR, s);
            s_ARVALID[s] = (read_selected[s] == 2'b00) ?
                           m0_ARVALID : m1_ARVALID;
            s_RREADY[s] = (read_selected[s] == 2'b00) ? m0_RREADY : m1_RREADY;
	    
            if (read_selected[s] == 2'b00) begin
               m0_ARREADY = s_ARREADY[s];
               m0_RVALID = s_RVALID[s];
               m0_RDATA = s_RDATA[s];
               m0_RRESP = s_RRESP[s];
            end else begin
               m1_ARREADY = s_ARREADY[s];
               m1_RVALID = s_RVALID[s];
               m1_RDATA = s_RDATA[s];
               m1_RRESP = s_RRESP[s];
            end
         end
      end
   end
   
   always_ff @(posedge ACLK or negedge ARESETn) begin
      if (!ARESETn) begin
         for (int s = 0; s < 4; s++) begin
            write_active[s] <= 1'b0;
            write_owner[s] <= 1'b0;
            read_active[s] <= 1'b0;
            read_owner[s] <= 1'b0;
            write_rr[s] <= 1'b0;
            read_rr[s] <= 1'b0;
         end
      end else begin
         for (int s = 0; s < 4; s++) begin
            if (!write_active[s]) begin
               if (write_grant[s] && s_AWVALID[s] && s_AWREADY[s]) begin
                  write_active[s] <= 1'b1;
                  write_owner[s] <= write_selected[s][0];
               end
            end else if (s_BVALID[s] && s_BREADY[s]) begin
               write_active[s] <= 1'b0;
               write_rr[s] <= ~write_owner[s];
            end
	    
            if (!read_active[s]) begin
               if (read_grant[s] && s_ARVALID[s] && s_ARREADY[s]) begin
                  read_active[s] <= 1'b1;
                  read_owner[s] <= read_selected[s][0];
               end
            end else if (s_RVALID[s] && s_RREADY[s]) begin
               read_active[s] <= 1'b0;
               read_rr[s] <= ~read_owner[s];
            end
         end
      end
   end
endmodule // axi_interconnect_2x4

