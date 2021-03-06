////////////////////////////////////////////////////////////
// Uses e1of4 DI encoded input from a QDI circuit
// to communicate with verilog parent module.
//
// Uses extra ExEnable for Throughput_vs_Tokens module.
////////////////////////////////////////////////////////////
module QDI2Bin_RxEnable_1of4(dout, valid, rxe, Le, L, RESET, VDD, GND);

output [1:0] dout;   // signal to verilog, 2-bit binary encoded output
output       valid;  // signal to verilog, when input is valid
input        rxe;    // Rx Enabled from verilog - must be high for Le to fall low
output       Le;     // Left enable to circuit  - falls low when valid data present
input  [3:0] L;      // Left input from circuit - e1of4 DI encoded 

input RESET;
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg valid, Le;
reg [1:0] dout;
parameter D1 = 0; // Delay 1 - Backward latency up
parameter D2 = 0; // Delay 2 - Backward latency down

////////////////////////////////////////////////////////////
//	Main Description
////////////////////////////////////////////////////////////
initial begin
    dout   <= 2'bz;
    valid  <= 1'b0;
    Le     <= 1'b1;
end

always @(negedge RESET) begin
    Le    <= #D2 1'b0;
    valid <= 1'b0;
    dout  <= 2'bz;
end

always @(posedge RESET) begin
    Le    <= #D1 1'b1;
    valid <= 1'b0;
    dout  <= 2'bz;
end

always @(negedge |L) begin
    valid  <= 1'b0;
    Le     <= #D1 1'b1;
end

always @(posedge |L) begin
    valid <= 1'b1;
    wait(rxe);
    case (L)
        4'b0001: dout <= 2'b00;
        4'b0010: dout <= 2'b01;
        4'b0100: dout <= 2'b10;
        4'b1000: dout <= 2'b11;
		4'b000x: dout <= 2'b00;   // Avoid error message @ STV's
        4'b00x0: dout <= 2'b01;   // Avoid error message @ STV's
        4'b0x00: dout <= 2'b10;   // Avoid error message @ STV's
        4'bx000: dout <= 2'b11;   // Avoid error message @ STV's
		default begin
            $display("DI2Bin_1of4:Received invalid DI code from circuit: %b. Check for errors @time %t ps.", L, $time);
	   		dout <= 2'bx;
		end
    endcase
    Le   <= #D2 1'b0;
end

endmodule
////////////////////////////////////////////////////////////