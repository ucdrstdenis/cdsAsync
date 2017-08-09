module CDC_A2S_Testbench (Tx, Txe, Din, Si, So, CLK, RESET, VDD, GND);
 // Still in progress ...

inout VDD, GND;
output  RESET;
output  CLK;
output [127:0] Tx;
input  [31:0] Txe;
input  [63:0] Din;
input Si;
output So;

////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////
parameter RST_HOLD=1000;
parameter CLK_PERIOD=1000;
parameter NO_TOKENS=16;   // # Tokens to insert

localparam DW=64;     // Data Bus Width [Binary]
////////////////////////////////////////////////
//  Registers
////////////////////////////////////////////////
reg RESET;
reg [DW-1:0] TxReg;
reg [DW-1:0] RxReg;
wire [DW-1:0] dataRx;
wire [(DW/2)-1:0] readDataValid;
reg goReg;

integer TxTokenCount;
integer RxTokenCount;
integer i;
////////////////////////////////////////////////
// Sub-modules
////////////////////////////////////////////////
Bin2QDI_1of4      TxEncoder [(DW/2)-1:0]  (Tx, TxReg,  goReg,  Txe, RESET, VDD, GND); 

////////////////////////////////////////////////
// Task Definitions
////////////////////////////////////////////////

task SendTokens;   
    input [(DW-1):0] data;   
    begin
        wait(&Txe);
        TxReg <= data;
        goReg <= 1'b1;
        TxTokenCount = TxTokenCount + 1;
        $display(" %M: %t ps - Sent token w/ data = %b.", $time, TxReg);
		@(negedge goReg);
    end
endtask

task Init;
    begin
        RESET    <= 1'b1;
        goReg    <= 1'b0;
        TxReg    <= {DW{1'b0}};
        RxReg    <= {DW{1'b0}};

        #1; // Allow initial and final conditions to be interchangable
        $display("%M:  %t ps - Asserting Reset...", $time); 
        RESET <= 1'b0;
    	#RST_HOLD;
        $display("%M: %t ps - De-Asserting Reset...", $time); 
    	RESET <= 1'b1;
    	#RST_HOLD;  
    end
endtask

////////////////////////////////////////////////
// Main Description 
////////////////////////////////////////////////
initial begin
    Init;

    for (i = 0; i < NO_TOKENS; i = i + 1) begin
        SendTokens(2'b11);
    end
    
    wait(RxTokenCount==TxTokenCount);
    wait(~validRx);
    #RST_HOLD;
    $finish();
end


always @(negedge |Txe) begin
    goReg <= 1'b0;
end


endmodule