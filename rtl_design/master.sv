`include "define.sv"

module axi_master (
		   input logic			      ACLK, ARESETn,
		   input logic			      wr_req,
		   input logic [`AXI_ADDR_WIDTH-1:0]  wr_addr,
		   input logic [`AXI_DATA_WIDTH-1:0]  wr_data,
		   input logic [`AXI_STRB_WIDTH-1:0]  wr_strb,
		   output logic			      wr_done,
		   output logic [`AXI_RESP_WIDTH-1:0] wr_resp,

		   input logic			      rd_req,
		   input logic [`AXI_ADDR_WIDTH-1:0]  rd_addr,
		   output logic			      rd_done,
		   output logic [`AXI_DATA_WIDTH-1:0] rd_data,
		   output logic [`AXI_RESP_WIDTH-1:0] rd_resp,

		   output logic [`AXI_ADDR_WIDTH-1:0] AWADDR,
		   output logic			      AWVALID,
		   input logic			      AWREADY,

		   output logic [`AXI_DATA_WIDTH-1:0] WDATA,
		   output logic [`AXI_STRB_WIDTH-1:0] WSTRB,
		   output logic			      WVALID,
		   input logic			      WREADY,

		   input logic [`AXI_RESP_WIDTH-1:0]  BRESP,
		   input logic			      BVALID,
		   output logic			      BREADY,

		   output logic [`AXI_ADDR_WIDTH-1:0] ARADDR,
		   output logic			      ARVALID,
		   input logic			      ARREADY,

		   input logic [`AXI_DATA_WIDTH-1:0]  RDATA,
		   input logic [`AXI_RESP_WIDTH-1:0]  RRESP,
		   input logic			      RVALID,
		   output logic			      RREADY
		   );
   typedef enum					      logic [1:0] {WR_IDLE, WR_SEND, WR_RESP} wr_state_t;
   typedef enum					      logic [1:0] {RD_IDLE, RD_SEND, RD_RESP} rd_state_t;
   
   wr_state_t wr_state;
   rd_state_t rd_state;
   
   logic					      aw_accepted, w_accepted;
   logic [`AXI_ADDR_WIDTH-1:0]			      wr_addr_reg, rd_addr_reg;
   logic [`AXI_DATA_WIDTH-1:0]			      wr_data_reg;
   logic [`AXI_STRB_WIDTH-1:0]			      wr_strb_reg;

   always_ff @(posedge ACLK or negedge ARESETn) begin
      
      if (!ARESETn) begin
	 
         wr_state    <= WR_IDLE;
         rd_state    <= RD_IDLE;
         aw_accepted <= 1'b0;
         w_accepted  <= 1'b0;
         wr_addr_reg <= '0;
         rd_addr_reg <= '0;
         wr_data_reg <= '0;
         wr_strb_reg <= '0;
         wr_done     <= 1'b0;
         rd_done     <= 1'b0;
         wr_resp     <= `AXI_OKAY;
         rd_resp     <= `AXI_OKAY;
         rd_data     <= '0;
      end else begin
         wr_done <= 1'b0;
         rd_done <= 1'b0;
	 
         case (wr_state)
           WR_IDLE: begin
              if (wr_req) begin
                 wr_addr_reg <= wr_addr;
                 wr_data_reg <= wr_data;
                 wr_strb_reg <= wr_strb;
                 aw_accepted <= 1'b0;
                 w_accepted  <= 1'b0;
                 wr_state    <= WR_SEND;
              end
           end
	   
           WR_SEND: begin
              if (AWVALID && AWREADY) aw_accepted <= 1'b1;
              if (WVALID  && WREADY) w_accepted  <= 1'b1;
	      
                   if ((aw_accepted || (AWVALID && AWREADY)) && (w_accepted  || (WVALID  && WREADY))) begin
                      wr_state <= WR_RESP;
                   end
           end
	   
           WR_RESP: begin
                    if (BVALID && BREADY) begin
                       wr_resp <= BRESP;
                       wr_done <= 1'b1;
                       wr_state <= WR_IDLE;
                    end
              end
	   
           default: wr_state <= WR_IDLE;
         endcase
	 
         case (rd_state)
           RD_IDLE: begin
              if (rd_req) begin
                 rd_addr_reg <= rd_addr;
                 rd_state    <= RD_SEND;
              end
           end
	   
           RD_SEND: begin
              if (ARVALID && ARREADY) rd_state <= RD_RESP;
           end
	   
           RD_RESP: begin
              if (RVALID && RREADY) begin
                 rd_data <= RDATA;
                 rd_resp <= RRESP;
                 rd_done <= 1'b1;
                 rd_state <= RD_IDLE;
              end
           end
	   
           default: rd_state <= RD_IDLE;
         endcase
      end
   end
   
   always_comb begin
      
      AWADDR = wr_addr_reg;
      AWVALID = (wr_state == WR_SEND) && !aw_accepted;
      
      WDATA = wr_data_reg;
      WSTRB = wr_strb_reg;
      WVALID = (wr_state == WR_SEND) && !w_accepted;
      
      BREADY = (wr_state == WR_RESP);
      
      ARADDR = rd_addr_reg;
      ARVALID = (rd_state == RD_SEND);
      
      RREADY = (rd_state == RD_RESP);
      
   end
endmodule // axi_master

