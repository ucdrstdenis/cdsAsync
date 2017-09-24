module CSA_Testbench (Ax, Bx, Cx, ABCe, Sx, Sxe, Co, Coe, RESET, VDD, GND);

inout  VDD, GND;
output RESET;
output [3:0] Ax, Bx;
output [1:0] Cx;
input  ABCe;
input  [3:0] Sx;
input  [1:0] Co;
output Sxe, Coe;

////////////////////////////////////////////////
parameter RST_HOLD=1000; // 1000 ps
parameter FINISH=0;

integer i;
////////////////////////////////////////////////
reg RESET, goReg;
reg [1:0] AxReg, BxReg;
reg CxReg;
reg [2:0] RxReg, exReg;
reg [4:0] TxReg;

wire [1:0] sumRx;
wire coRx;
wire sumValid, coValid;

////////////////////////////////////////////////
// Sub-modules
////////////////////////////////////////////////
Bin2QDI_1of4  AxEncoder (Ax, AxReg,  goReg,  ABCe, RESET, VDD, GND); 
Bin2QDI_1of4  BxEncoder (Bx, BxReg,  goReg,  ABCe, RESET, VDD, GND); 
Bin2QDI_1of2  CxEncoder (Cx, CxReg,  goReg,  ABCe, RESET, VDD, GND);

QDI2Bin_1of4 SumDecoder (sumRx, sumValid, Sxe, Sx, RESET, VDD, GND);
QDI2Bin_1of2 CoDecoder  (coRx,  coValid,  Coe, Co, RESET, VDD, GND);

////////////////////////////////////////////////
// Task Definitions
////////////////////////////////////////////////

task Init;
    begin
        RESET <= 1'b1;
        goReg <= 1'b0;
        AxReg <= 2'b0;   
        BxReg <= 2'b0;
        CxReg <= 1'b0;
        RxReg <= 3'b0;
        exReg <= 3'b0;
        TxReg <= 5'b0;

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
    input [4:0] data;   
    begin
        wait(ABCe);
        AxReg <= data[1:0];
        BxReg <= data[3:2];
        CxReg <= data[4];
        exReg <= data[1:0] + data[3:2] + data[4];
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
        $finish();
    end
end

always @(posedge &{sumValid,coValid}) begin
    RxReg[1:0] <= sumRx;
    RxReg[2] <= coRx;
    //$display("%M: Expected 0b%b, Rx'd 0b%b", exReg, {coRx,sumRx});
    $display(" %M: CS Rx'd 0b%b", sumRx);
    $display(" %M: Co Rx'd 0b%b", coRx);
end

always @(negedge ABCe) begin
    goReg <= 1'b0;
end

endmodule
