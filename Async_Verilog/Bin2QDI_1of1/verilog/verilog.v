// Bin2QDI_1of1.v
////////////////////////////////////////////////////////////
// Uses verilog binary input to drive DI-coded
// circuit interface.
////////////////////////////////////////////////////////////
module Bin2QDI_1of1(R, din, req, Re, RESET, VDD, GND);

output R;           // Right Output (e1of1) - to circuit
input Re;           // Right enable         - from circuit
input din;          // Data In  (binary);     comes from verilog
input req;          // Reqest                 comes from verilog
input RESET;        // comes from verilog
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg R;
parameter D1=0;  // Delay 1
parameter D2=0;  // Delay 2

////////////////////////////////////////////////////////////
//	Main Description
////////////////////////////////////////////////////////////
initial begin
    R <= 1'b0;
end

// Trigger on incoming request from verilog
always @(posedge req) begin	
    wait(Re);
    R  <= #D1 1'b1;            
end

always @(negedge Re) begin
    R  <= #D2 1'b0;
end

// To be removed ...
always @(posedge RESET or negedge RESET) begin
    R  <= #D2 1'b0; 
end

endmodule
