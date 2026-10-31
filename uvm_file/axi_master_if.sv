`include "../rtl_design/define.sv"

interface axi_master_if (
    input logic ACLK,
    input logic ARESETn
);
    logic wr_req;
    logic [`AXI_ADDR_WIDTH-1:0] wr_addr;
    logic [`AXI_DATA_WIDTH-1:0] wr_data;
    logic [`AXI_STRB_WIDTH-1:0] wr_strb;
    logic wr_done;
    logic [`AXI_RESP_WIDTH-1:0] wr_resp;

    logic rd_req;
    logic [`AXI_ADDR_WIDTH-1:0] rd_addr;
    logic rd_done;
    logic [`AXI_DATA_WIDTH-1:0] rd_data;
    logic [`AXI_RESP_WIDTH-1:0] rd_resp;
endinterface
