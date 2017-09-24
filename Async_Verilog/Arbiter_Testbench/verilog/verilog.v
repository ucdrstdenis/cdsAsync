module Arbiter_Testbench(Tx, Txe, Rx, Rxe, RESET, VDD, GND);

inout VDD, GND;
output RESET;
output [1:0] Tx;
input [1:0] Txe;
input [1:0] Rx;
output Rxe;
////////////////////////////////////////////////
parameter RST_HOLD=1000;
parameter NO_TOKENS=10; // # Tokens to insert
parameter FINISH=1;

integer TxTokenCount;
integer RxTokenCount;
integer i;
////////////////////////////////////////////////
reg resetReg;
reg [1:0] goReg;
reg [1:0] TxReg;

reg RxReg;
wire dataRx;
wire validRx;

reg allTokensRxd;
reg RESET;
////////////////////////////////////////////////
Bin2QDI_1of1          Transmit [1:0] (Tx,     TxReg,   goReg, Txe, RESET, VDD, GND);
QDI2Bin_1of2          Receive        (dataRx, validRx, Rxe,   Rx,  RESET, VDD, GND);
////////////////////////////////////////////////
task Init;
    begin
        i = 0;

        RESET <= 1'b1;       // Reset not asserted yet
        goReg <= 2'b0;       // Nothing being sent yet
        TxReg <= 2'b0;       // Clear Tx Data Register
        RxReg <= 1'b0;       // Clear Rx Data Register
 
        #1; // Allow initial and final conditions to be interchangable
        $display("%M: Asserting Reset @ time %t ps ...", $time); 
        RESET <= 1'b0;     // Assert Reset
        #RST_HOLD;         
        $display("%M: De-Asserting Reset @ time %t ps ...", $time); 
        RESET <= 1'b1;     // Stop Asserting Reset
        #RST_HOLD;
    end
endtask

task SendTokens;           // Task to send tokens
    input [1:0] data;              
    begin
        if(data == 2'b00) begin
            TxReg <= 2'b01;
        end 
        else begin
            TxReg <= data;
        end
        $display(" %M: %t ps - Sent token w/ data = 2b%b.", $time, TxReg);
        case(data)
            2'b01: begin 
                       goReg[0] <= 1'b1;
                       @(negedge Txe[0]);
                       goReg[0] <= 1'b0;
                   end
            2'b10: begin
                       goReg[1] <= 1'b1;
                       @(negedge Txe[1]);
                       goReg[1] <= 1'b0;
                   end
            2'b11: begin
                       goReg <= 2'b11;
                       @(negedge goReg);
                   end
        endcase
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init; // Init and reset

    for (i = 0; i < NO_TOKENS; i = i + 1) begin
        SendTokens($urandom());
    end
    
    if (FINISH) begin
        #RST_HOLD;
        $finish();
    end
end

always @(posedge validRx) begin
    RxReg <= dataRx;
    $display(" %M: %t - Received token %d, data = %b", $time, RxTokenCount, dataRx);
end

always @(negedge Txe[0]) begin
    goReg[0] <= 1'b0;
end

always @(negedge Txe[1]) begin
    goReg[1] <= 1'b0;
end

endmodule

