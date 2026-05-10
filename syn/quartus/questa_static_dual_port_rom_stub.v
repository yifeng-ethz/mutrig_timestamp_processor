module dual_port_rom
#(
    parameter DATA_WIDTH = 15,
    parameter ADDR_WIDTH = 15
)
(
    input  [(ADDR_WIDTH - 1):0] addr_a,
    input  [(ADDR_WIDTH - 1):0] addr_b,
    input                       clk,
    output reg [(DATA_WIDTH - 1):0] q_a,
    output reg [(DATA_WIDTH - 1):0] q_b
);
    always @(posedge clk) begin
        q_a <= addr_a[DATA_WIDTH - 1:0];
        q_b <= addr_b[DATA_WIDTH - 1:0];
    end
endmodule
