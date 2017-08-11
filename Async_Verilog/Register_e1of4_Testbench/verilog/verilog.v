module Register_e1of4_Testbench (Tx, Txe, Cx, Cxe, Rx, Rxe, RESET, VDD, GND);

inout  VDD, GND;
output RESET;
output [3:0] Tx;
output [2:0] Cx;
input  Txe, Cxe;
input  [3:0] Rx;
output Rxe;

////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////
parameter RST_HOLD=1000;
parameter NO_TOKENS=16;   // # Tokens to insert
parameter FINISH=0;

localparam DW=2;      // Data Bus Width [Binary]
localparam CW=2;   // Control Bus Width [Binary]

// Todo: Redo everything using VerilogCSP
////////////////////////////////////////////////
//  Registers, wires, integers
////////////////////////////////////////////////
reg RESET, goReg;
reg [DW-1:0] TxReg;
reg [CW-1:0] CxReg;
reg [DW-1:0] RxReg;

wire[DW-1:0] dataRx;
wire validRx;

integer TxTokenCount;
integer RxTokenCount;
integer i;

////////////////////////////////////////////////
// Sub-modules
////////////////////////////////////////////////
Bin2QDI_1of4     DataTransmit (Tx, TxReg, goReg, Txe,     RESET, VDD, GND);
Bin2QDI_1of3     CtrlTransmit (Cx, CxReg, goReg, Cxe,     RESET, VDD, GND);
QDI2Bin_1of4     DataReceive  (dataRx, validRx,  Rxe, Rx, RESET, VDD, GND);

////////////////////////////////////////////////
// Task Definitions
////////////////////////////////////////////////
task SendTokens;   
    input [(DW-1):0] data;   
    input [(CW-1):0] ctrl;
    begin
        wait(Cxe);
        CxReg <= ctrl;

        if (ctrl != 2'b00) begin
            wait(Txe); 
            TxReg <= data;
        end
       
        goReg <= 1'b1;
        TxTokenCount = TxTokenCount + 1;
        $display(" %M: Tx token data = 0x%h @ time %t ps", TxReg, $time);
		@(negedge goReg);
    end
endtask

task Init;
    begin
        RESET  <= 1'b1;
        goReg  <= 1'b0;
        TxReg  <= {DW{1'b0}};
        CxReg  <= {CW{1'b0}};
        RxReg  <= {DW{1'b0}};
        #1; // Allow initial and final conditions to be interchangable
        $display("%M: Asserting Reset @ time %t ps", $time); 
        RESET <= 1'b0;
    	#RST_HOLD;
        $display("%M: De-Asserting Reset @ time %t ps", $time); 
    	RESET <= 1'b1;
    	#RST_HOLD;  
        TxTokenCount = 0;
        RxTokenCount = 0;
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init;

   // for (i = 0; i < (NO_TOKENS/4); i = i + 1) begin
        SendTokens(2'b11, 2'b01);  // write data
        SendTokens(2'b10, 2'b01);  // write data    
        SendTokens(2'b00, 2'b01);  // write data  
        SendTokens(2'b01, 2'b01);  // write data    
  
        SendTokens(2'b00, 2'b00);  // read data
        SendTokens(2'b01, 2'b10);  // write + read data
        SendTokens(2'b00, 2'b00);  // read data
   // end
    
   // wait(RxTokenCount==TxTokenCount);

    if (FINISH) begin
        #RST_HOLD;
        $finish();
    end
end

always @(negedge |Cxe) begin
    if (CxReg != 2'b00) begin
        @(negedge |Txe);
    end
    goReg <= 1'b0;
end

always @(posedge validRx) begin
    RxReg <= dataRx;
    RxTokenCount = RxTokenCount + 1;
    $display(" %M: Rx token %d w/ data = 0x%h @ time %t ps", RxTokenCount, dataRx, $time);
end

endmodule
