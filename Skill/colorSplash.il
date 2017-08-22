/*************************************************************************
* RSD - Used to quickly set default wire colors. Can be placed in a loop *
* to add color to an entire library. To use, open a schematic view, and  * 
* press F9. Or type colorSplash() in the CIW                             *
*                                                                        *
* Original source: CCSsetWireColorAndStyle.il                            *
*************************************************************************/

procedure(CCSsetWireColorAndStyle(net @key (color nil) (style nil) "tgg") 
let((cv)
cv=geGetEditCellView()
net=dbFindNetByName(cv net)
foreach(fig net~>figs 
	when(fig~>objType=="line"
		when(color
		schSetWireColor(fig color)
			)
		when(style
		schSetWireLineStyle(fig style)
			)
		)
	)
))

procedure(CCSsetMultiNetCS(nets @key (color nil) (style nil) "lgg") 
let(()
foreach(net nets
CCSsetWireColorAndStyle(net ?color color ?style style)
	)
t
))

procedure( colorSplash() 
    CCSsetWireColorAndStyle("VDD"   ?color "magenta")
    CCSsetWireColorAndStyle("VDDT!" ?color "magenta")
    CCSsetWireColorAndStyle("vdd!"  ?color "magenta")
    CCSsetWireColorAndStyle("GND"   ?color "violet")
    CCSsetWireColorAndStyle("gnd!"  ?color "violet")
    CCSsetWireColorAndStyle("RST"   ?color "cyan")
    CCSsetWireColorAndStyle("_RST"  ?color "lime")
)

hiSetBindKey("Schematics" "<Key>F9" "colorSplash()")


