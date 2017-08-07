// Driver to send / receive tokens into an e1of2 FIFO

module Throughput_1of2(Tx, Txe, Rx, Rxe,  // Circuit Tx/Rx signals
                       RESET, VDD, GND);
inout VDD, GND;
output RESET;
output [1:0] Tx;
input Txe;
input [1:0] Rx;
output Rxe;
////////////////////////////////////////////////
parameter RST_HOLD=1000;
parameter NO_TOKENS=10; // # Tokens to insert
parameter FINISH=0;

integer TxTokenCount;
integer RxTokenCount;
integer i;
////////////////////////////////////////////////
reg resetReg;
reg goReg;
reg TxReg;

reg RxReg;
wire dataRx;
wire validRx;

reg allTokensRxd;
////////////////////////////////////////////////
Bin2QDI_1of2          Transmit (Tx,     TxReg,   goReg, Txe, resetReg, VDD, GND);
QDI2Bin_1of2          Receive  (dataRx, validRx, Rxe,   Rx,  resetReg, VDD, GND);
assign RESET = resetReg;
////////////////////////////////////////////////
task Init;
    begin
        i = 0;
        RxTokenCount = 0;
        TxTokenCount = 0;

        resetReg <= 1'b1;     // Reset not asserted yet
        goReg <= 1'b0;        // Nothing being sent yet
        TxReg <= 1'b1;        // Clear Tx Data Register
        RxReg <= 1'b0;        // Clear Rx Data Register
        allTokensRxd <= 1'b0; 
 
        #1; // Allow initial and final conditions to be interchangable
        $display(" %M: %t ps - Asserting Reset...", $time); 
        resetReg <= 1'b0;     // Assert Reset
        #RST_HOLD;         
        $display(" %M: %t ps - De-Asserting Reset...", $time); 
        resetReg <= 1'b1;     // Stop Asserting Reset
        #RST_HOLD;
    end
endtask

task SendTokens;              // Task to send tokens
    input data;              
    begin
        wait(Txe);
        TxReg <= data;
        goReg <= 1'b1;
        TxTokenCount = TxTokenCount + 1;
        $display(" %M: %t ps - Sent token w/ data = %b.", $time, TxReg);
		@(negedge goReg);
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init; // Init and reset

    for (i = 0; i < NO_TOKENS; i = i + 1) begin
        SendTokens(1'b1);
    end
    
    wait(RxTokenCount==TxTokenCount);
    wait(~validRx);
    if (FINISH) begin
        #RST_HOLD;
        $finish();
    end
end

always @(posedge validRx) begin
    RxTokenCount=RxTokenCount+1;
    RxReg <= dataRx;
    $display(" %M: %t - Received token %d, data = %b", $time, RxTokenCount, dataRx);
end

always @(negedge Txe) begin
    goReg <= 1'b0;
end

endmodule

