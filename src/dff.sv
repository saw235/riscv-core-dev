module dff_async #(parameter integer NBIT = 1)(
    input logic [NBIT-1:0] d,
    output logic [NBIT-1:0] q,
    input logic clk,
    input logic rstn
);

    always_ff @(posedge clk or negedge rstn) begin :
        if (!rstn) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule

module dffe_async(
    input logic [NBIT-1:0] d,
    output logic [NBIT-1:0] q,
    input logic clk,
    input logic rstn,
    input logic en
);

    logic [NBIT-1:0] d_internal;
    logic [NBIT-1:0] q_internal;

    assign d_internal = en ? d : q_internal;
    assign q = q_internal;

    dff ff_internal(.d(d_internal), .q(q_internal), .clk(clk), .rstn(rstn));

endmodule