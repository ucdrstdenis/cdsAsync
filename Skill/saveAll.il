/*************************************************************************
* RSD - Use this to re-save the schematic libraries when a change is    *
* made that propagates throughout all cells; avoids blinking-yellow     *
* boxes and simulation "re-save required" error messages.               *
*************************************************************************/

load("Skill/CCScheckAllSch.il")

printf("Saving Async Lib...\n")
CCScheckAllSch("Async")

printf("Saving Async FIFOs Lib...\n")
CCScheckAllSch("Async_FIFOs")

printf("Saving Async Tests Lib...\n")
CCScheckAllSch("Async_Tests")

printf("Saving Async Verilog Wrappers...\n")
CCScheckAllSch("Async_Verilog_Wrappers")

