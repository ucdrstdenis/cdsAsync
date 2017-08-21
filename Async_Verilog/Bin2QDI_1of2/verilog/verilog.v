// Bin2QDI_1of2.v
////////////////////////////////////////////////////////////
// Uses verilog binary input to drive DI-coded
// circuit interface.
////////////////////////////////////////////////////////////
module Bin2QDI_1of2(R, din, req, Re, RESET, VDD, GND);

output[1:0] R;      // Right Output (e1of2) - to circuit
input Re;           // Right enable         - from circuit
input din;          // Data In  (binary);     comes from verilog
input req;          // Reqest                 comes from verilog
input RESET;        // comes from verilog
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg[1:0] R;
parameter D1=0;  // Delay 1
parameter D2=0;  // Delay 2

////////////////////////////////////////////////////////////
//	Main Description
////////////////////////////////////////////////////////////
initial begin
    R <= 2'b00;
end

always @(posedge req) begin	
    wait(Re);
    R  <= #D1 {din,~din};    // 0 -> 01, 1-> 10
end

always @(negedge Re) begin
    R  <= #D2 2'b00;
end

// To be removed ...
always @(posedge RESET or negedge RESET) begin
    R  <= #D2 2'b00; 
end

endmodule
