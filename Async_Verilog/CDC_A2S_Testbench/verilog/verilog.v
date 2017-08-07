module CDC_A2S_Testbench (Tx, Txe, Din, Si, So, CLK, RESET, VDD, GND);

inout VDD, GND;
output  RESET;
output  CLK;
output [127:0] Tx;
input  [31:0] Txe;
input  [63:0] Din;
input Si;
output So;

// Todo
endmodule
