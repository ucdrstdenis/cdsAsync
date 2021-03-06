// QDI2Bin_1of3.v
////////////////////////////////////////////////////////////
// Uses e1of3 DI input from a QDI circuit
// to communicate with verilog in binary
////////////////////////////////////////////////////////////
module QDI2Bin_1of3(dout, valid, Le, L, RESET, VDD, GND);

output [1:0] dout;   // signal to verilog, 2-bit binary encoded output
output       valid;  // signal to verilog, when input is valid
output       Le;     // Left enable to circuit  - falls low when valid data present
input  [2:0] L;      // Left input from circuit - e1of3 DI encoded 

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
    valid  <= 1'b0;
    Le     <= #D1 1'b1;
end

always @(posedge |L) begin
    valid <= 1'b1;
    case (L)
        3'b001: dout <= 2'b00;
        3'b010: dout <= 2'b01;
        3'b100: dout <= 2'b10;
        3'b00x: begin   // Avoid error message @ STV's
                   wait( L == 3'b001);
                   dout <= 2'b00;
                end
        3'b0x0: begin   // Avoid error message @ STV's
                   wait( L == 3'b010);
                   dout <= 2'b01;
                end
        3'bx00: begin   // Avoid error message @ STV's
                    wait( L == 3'b100); 
                    dout <= 2'b10; 
                end
        default begin
            $display(" %M: Received invalid DI code from circuit: %b. Check for errors @time %t ps.", L, $time);
            dout <= 2'bx;
        end
    endcase
    Le     <= #D2 1'b0;
end

endmodule
////////////////////////////////////////////////////////////
