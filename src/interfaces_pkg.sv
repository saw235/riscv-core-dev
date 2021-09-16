
interface mem_intf #(
    parameter integer BUSWIDTH = 32,
    parameter integer ADDRWIDTH = 32 
)(
    input logic clk
);
    logic [ADDRWIDTH-1:0] rd_addr;
    logic [ADDRWIDTH-1:0] wr_addr;
    logic [BUSWIDTH-1:0] wr_data;
    logic wren;

    logic [BUSWIDTH-1:0] rd_data;

    modport slave(
        input rd_addr, wr_addr, wr_data, wren, clk,
        output rd_data
    );

    modport master(
        output rd_addr, wr_addr, wr_data, wren,
        input rd_data
    );
endinterface