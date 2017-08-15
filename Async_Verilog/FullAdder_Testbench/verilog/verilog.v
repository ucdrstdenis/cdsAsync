module FullAdder_Testbench (Ax, Bx, Cx, ABCe, Sx, Sxe, Co, Coe, RESET, VDD, GND);

inout  VDD, GND;
output RESET;
output [1:0] Ax, Bx, Cx;
input  ABCe;
input  [1:0] Sx, Co;
output Sxe, Coe;

////////////////////////////////////////////////
parameter RST_HOLD=1000; // 1000 ps
parameter FINISH=0;

integer i;
////////////////////////////////////////////////
reg RESET, goReg;
reg AxReg, BxReg, CxReg;
reg [1:0] RxReg, exReg;
reg [2:0] TxReg;

wire sumRx, coRx;
wire sumValid, coValid;

////////////////////////////////////////////////
// Sub-modules
////////////////////////////////////////////////
Bin2QDI_1of2  AxEncoder (Ax, AxReg,  goReg,  ABCe, RESET, VDD, GND); 
Bin2QDI_1of2  BxEncoder (Bx, BxReg,  goReg,  ABCe, RESET, VDD, GND); 
Bin2QDI_1of2  CxEncoder (Cx, CxReg,  goReg,  ABCe, RESET, VDD, GND);

QDI2Bin_1of2 SumDecoder (sumRx, sumValid, Sxe, Sx, RESET, VDD, GND);
QDI2Bin_1of2 CoDecoder  (coRx,  coValid,  Coe, Co, RESET, VDD, GND);

////////////////////////////////////////////////
// Task Definitions
////////////////////////////////////////////////

task Init;
    begin
        RESET <= 1'b1;
        goReg <= 1'b0;
        AxReg <= 1'b0;   
        BxReg <= 1'b0;
        CxReg <= 1'b0;
        RxReg <= 2'b0;
        exReg <= 2'b0;
        TxReg <= 3'b0;

        #1; // Allow initial and final conditions to be interchangable
        $display("%M: Asserting Reset @ time %t ps ...", $time); 
        RESET <= 1'b0;  
        #RST_HOLD;         
        $display("%M: De-Asserting Reset @ time %t ps ...", $time); 
        RESET <= 1'b1;
        #RST_HOLD;
    end
endtask

task SendTokens;
    input [2:0] data;   
    begin
        wait(ABCe);
        AxReg <= data[0];
        BxReg <= data[1];
        CxReg <= data[2];
        exReg <= data[0] + data[1] + data[2];
        goReg <= 1'b1;
        @(negedge goReg);
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init;
    for (i = 0; i < 10; i = i + 1) begin
        SendTokens(TxReg);
        TxReg <= TxReg + 1;
    end  

    if (FINISH) begin
        #RST_HOLD;
        #RST_HOLD;
        $finish();
    end
end

always @(posedge &{sumValid,coValid}) begin
    RxReg[0] <= sumRx;
    RxReg[1] <= coRx;
    $display("%M: Expected 2b%b, Rx'd 2b%b", exReg, {coRx,sumRx});
   // $display("%M: Rx'd data 0x%h @ time %t ps", {coRx,sumRx}, $time);
end

always @(negedge ABCe) begin
    goReg <= 1'b0;
end

endmodule
