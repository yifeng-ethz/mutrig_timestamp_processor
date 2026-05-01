(* black_box *) module dual_port_rom
#(
    parameter DATA_WIDTH = 15,
    parameter ADDR_WIDTH = 15
)
(
    input  [(ADDR_WIDTH - 1):0] addr_a,
    input  [(ADDR_WIDTH - 1):0] addr_b,
    input                       clk,
    output [(DATA_WIDTH - 1):0] q_a,
    output [(DATA_WIDTH - 1):0] q_b
);
endmodule
