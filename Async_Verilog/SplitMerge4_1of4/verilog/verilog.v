//Verilog HDL for "Async_Verilog", "Split_test" "verilog"
module SplitMerge4_1of4 (Tx, Txe, Cx, Cxe, Rx, Rxe, RESET, VDD, GND);

inout VDD, GND;
output RESET;
output [3:0] Tx;
output [3:0] Cx;
input Txe, Cxe;
input [3:0] Rx;
output Rxe;

////////////////////////////////////////////////
parameter RST_HOLD=1000; // 1000 ps
parameter NO_TOKENS=10;  // # Tokens to insert
parameter FINISH=0;

integer i;
////////////////////////////////////////////////
reg resetReg, goReg;
reg [1:0] TxReg;
reg [1:0] CxReg;

reg [1:0] RxReg;
wire[1:0] dataRx;
wire validRx;
////////////////////////////////////////////////
Bin2QDI_1of4     DataTransmit (Tx, TxReg, goReg, Txe, resetReg, VDD, GND);
Bin2QDI_1of4     CtrlTransmit (Cx, CxReg, goReg, Cxe, resetReg, VDD, GND);
QDI2Bin_1of4     DataReceive  (dataRx, validRx,  Rxe, Rx, resetReg, VDD, GND);
assign RESET = resetReg;
////////////////////////////////////////////////

task Init;
    begin
        resetReg <= 1'b1;  // Reset not asserted yet
        goReg <= 1'b0;  // Nothing being sent yet
        TxReg <= 2'b11; // Clear Tx Data Register
        CxReg <= 2'b11;
        RxReg <= 2'b0;  // Clear Rx Data Register

        #1; // Allow initial and final conditions to be interchangable
        $display("%M:  %t ps - Asserting Reset...", $time); 
        resetReg <= 1'b0;  // Assert Reset
        #RST_HOLD;         
        $display("%M:  %t ps - De-Asserting Reset...", $time); 
        resetReg <= 1'b1;  // Stop Asserting Reset
        #RST_HOLD;
    end
endtask

task SendTokens;
    input [1:0] data;
    input [1:0] ctrl;   
    begin
        wait(Txe);
        wait(Cxe);
        TxReg <= data;
        CxReg <= ctrl;
        goReg <= 1'b1;
        $display("%M:  %t ps - Sent token w/ data = %b.", $time, TxReg);
		@(negedge goReg);
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init;
    for (i = 0; i < NO_TOKENS; i = i + 1) begin
        SendTokens(2'b11, 2'b11);
    end  

    if (FINISH) begin
        #RST_HOLD;
        #RST_HOLD;
        $finish();
    end
end

always @(posedge validRx) begin
    RxReg <= dataRx;
    $display("%M:  %t ps - Rx data = %b", $time, dataRx);
end

always @(negedge (Txe|Cxe)) begin
    goReg <= 1'b0;
end

endmodule
