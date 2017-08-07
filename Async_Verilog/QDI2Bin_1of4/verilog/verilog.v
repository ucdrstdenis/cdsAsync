// QDI2Bin_1of4.v
////////////////////////////////////////////////////////////
// Uses e1of4 DI input from a QDI circuit
// to communicate with verilog in binary
////////////////////////////////////////////////////////////
module QDI2Bin_1of4(dout, valid, Le, L, RESET, VDD, GND);

output [1:0] dout;   // signal to verilog, 2-bit binary encoded output
output       valid;  // signal to verilog, when input is valid
output       Le;     // Left enable to circuit  - falls low when valid data present
input  [3:0] L;      // Left input from circuit - e1of4 DI encoded 

input RESET;
inout VDD, GND;

////////////////////////////////////////////////////////////
//     Registers Driving Output
////////////////////////////////////////////////////////////
reg valid, Le;
reg [1:0] dout;
parameter D1 = 0; // Delay 1
parameter D2 = 0; // Delay 2

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
    if( |L == 1'bx) begin
        wait(|L == 1'b0);
    end
    valid  <= 1'b0;
    Le     <= #D1 1'b1;
end

always @(posedge |L) begin
    if( |L == 1'bx) begin
        wait(|L == 1'b1);
    end
    valid <= 1'b1;
    case (L)
        4'b0001: dout <= 2'b00;
        4'b0010: dout <= 2'b01;
        4'b0100: dout <= 2'b10;
        4'b1000: dout <= 2'b11;
		4'b000x: begin      // Avoid error message @ STV's
                     wait( L == 4'b0001 );
                     dout <= 2'b00;
                 end
        4'b00x0: begin      // Avoid error message @ STV's
                     wait( L == 4'b0010);
                     dout <= 2'b01;
                 end
        4'b0x00: begin     // Avoid error message @ STV's
                     wait( L == 4'b0100);
                     dout <= 2'b10; 
                 end
        4'bx000: begin     // Avoid error message @ STV's
                     wait( L == 4'b1000);
                     dout <= 2'b11;  
                 end
		default begin
	   		$display("DI2Bin_1of4:Received invalid DI code from circuit: %b. Check for errors @time %t ps.", L, $time);
	   		dout <= 2'bx;
		end
    endcase
    Le     <= #D2 1'b0;
end

endmodule
////////////////////////////////////////////////////////////
