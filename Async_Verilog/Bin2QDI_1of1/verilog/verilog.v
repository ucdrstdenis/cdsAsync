// Bin2QDI_1of1.v
////////////////////////////////////////////////////////////
// Uses verilog binary input to drive DI-coded
// circuit interface.
////////////////////////////////////////////////////////////
module Bin2QDI_1of1(R, din, req, Re, RESET, VDD, GND);

output R;   	    // Right Output (e1of1) - to circuit
input Re;		    // Right enable         - from circuit
input din;		    // Data In  (binary);     comes from verilog
input req;		    // Reqest                 comes from verilog
input RESET;        // comes from verilog
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg R;
parameter D1=0;  // Delay 1
parameter D2=0;  // Delay 2

////////////////////////////////////////////////////////////
//     Timing Error Check Variables
////////////////////////////////////////////////////////////
integer state;
parameter idle=0, requesting=1, resetting=2;

////////////////////////////////////////////////////////////
//    Ensure correct output behavior if poorly driven
////////////////////////////////////////////////////////////
task CheckRequest;
begin
    if (state==requesting) begin
	    $display(" %M: Waiting on re. Possible driving error @time %t", $time);
    end  else if (state==resetting) begin
	    wait (Re);  
    end
end
endtask

task CheckReset;
begin
    if (state==requesting) begin
        $display(" %M: Early reset. Possible driving error @time %t", $time);
        // wait(~Re);
	    R <= #D2 1'b0;
	    state = resetting;
    end else if (state==resetting) begin
    	wait (Re);  
    end
end
endtask

////////////////////////////////////////////////////////////
//	Main Description
////////////////////////////////////////////////////////////
initial begin
	R <= 1'b0;
	state = idle;
end

always @(posedge RESET or negedge RESET) begin
    R  <= #D2 1'b0; 
	state = idle;
end

// Trigger on incoming request from verilog
always @(posedge req) begin	
	CheckRequest;               // Check for driver timing errors
    R  <= #D1 1'b1;            
    state  = requesting;        // Track state for debugging
end

always @(negedge req) begin
    CheckReset;
    state = idle;
end

always @(negedge Re) begin
	state  = resetting;
    R  <= #D2 1'b0;
end

always @(posedge Re) begin
    state = idle;
end

endmodule
