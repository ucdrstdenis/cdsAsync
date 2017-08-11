module CDC_A2S_Testbench (Tx, Txe, Din, Si, So, CLK, RESET, VDD, GND);
 // Transfer 1 word / 4 cycles

inout  VDD, GND;
output RESET;
output CLK;
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
reg goReg;
reg CLK;
reg So;

integer TxTokenCount;
integer RxTokenCount;
integer i;
////////////////////////////////////////////////
// Sub-modules
////////////////////////////////////////////////
Bin2QDI_1of4  TxEncoder [(DW/2)-1:0]  (Tx, TxReg,  goReg,  Txe, RESET, VDD, GND); 

////////////////////////////////////////////////
// Task Definitions
////////////////////////////////////////////////

task SendTokens;   
    input [(DW-1):0] data;   
    begin
        wait(&Txe);  // Todo: Redo everything using VerilogCSP
        TxReg <= data;
        goReg <= 1'b1;
        TxTokenCount = TxTokenCount + 1;
        $display(" %M: %t ps - Sent token w/ data = 0x%h.", $time, TxReg);
		@(negedge goReg);
    end
endtask

task Init;
    begin
        RESET  <= 1'b1;
        goReg  <= 1'b0;
        TxReg  <= {DW{1'b0}};
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

    for (i = 0; i < NO_TOKENS; i = i + 1) begin
        SendTokens({DW{1'b0}});
    end
    
    wait(RxTokenCount==TxTokenCount);
    #RST_HOLD;
    $finish();
end

always @(negedge |Txe) begin
    goReg <= 1'b0;
end


///////////////////////////////////////////////
// Synchronous
///////////////////////////////////////////////
initial begin
    CLK    <= 1'b0;
    So     <= 1'b0;
    forever begin
        #(CLK_PERIOD/2) CLK = !CLK;
    end
end

always @(posedge CLK) begin
    if (Si == 1'b1 && So == 1'b0) begin
        @(negedge CLK) So <= 1'b1;
    end else if (Si == 1'b1 && So == 1'b1) begin
        RxReg <= Din;
        RxTokenCount = RxTokenCount + 1;
    end else if (Si == 1'b0 && So == 1'b1) begin
       @(negedge CLK) So <= 1'b0;
    end
end
endmodule
