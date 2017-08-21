// Bin2QDI_1of4.v
////////////////////////////////////////////////////////////
// Uses verilog binary input to drive DI-coded
// circuit interface.
////////////////////////////////////////////////////////////
module Bin2QDI_1of4(R, din, req, Re, RESET, VDD, GND);

output[3:0] R;      // Right Output (e1of4) - to circuit
input Re;           // Right enable         - from circuit
input [1:0] din;    // Data In  (binary) - comes from verilog
input req;          // Request Enable    - comes from verilog
input RESET;        // comes from verilog
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg[3:0] R;
parameter D1=0;  // Delay 1
parameter D2=0;  // Delay 2


////////////////////////////////////////////////////////////
//	Main Description
////////////////////////////////////////////////////////////
initial begin
    R <= 4'h0;
end

// Trigger on incoming request from verilog
always @(posedge req) begin	
    wait(Re);
    R[0] <= #D1 ~din[0] & ~din[1];   // 00->0001
    R[1] <= #D1  din[0] & ~din[1];   // 01->0010
    R[2] <= #D1 ~din[0] &  din[1];   // 10->0100
    R[3] <= #D1  din[0] &  din[1];   // 11->1000
end

always @(negedge Re) begin
    R <= #D2 4'h0;
end

// To be removed ...
always @(posedge RESET or negedge RESET) begin
    R <= #D2 4'h0; 
end

endmodule
