/************************************************************************
* RSD - Script used to re-save the schematic libraries when a change is *
* made that propagates throughout all cells; avoids blinking-yellow     *
* boxes and simulation "schematic unbound. Do check + save"  errors.    *
* To use, type load("saveAll.il") into the CIW.                         *
*                                                                       *
* Original Source: CCScheckAllSch.il                                    *
*********************************************************************** */

/* CCScheckAllSch.il

Group		Custom IC, Cadence Design Systems
Language	SKILL
Revision No.	1.2
Date Created	Nov 05, 2002 
Last Modified	June 27, 2016
Tested in	IC6.1.7.500.4
Lint score	100

Description:

  Checks and saves all schematics that need it in the library that
  is passed in. An optional argument can be supplied to indicate
  that any error or warning markers should be removed after the
  check and save operation.

Usage:
  ;; to check & save all schematics in "testlib"
  CCScheckAllSch("testlib")
  
  ;; to check & save all schematics in "testlib" and remove markers
  CCScheckAllSch("testlib" t)

***************************************************

SCCS Info: @(#) CCScheckAllSch.il 11/07/02.11:13:54 1.1

********************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any           *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                             *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
********************************************************************

*/
procedure(CCScheckAllSch(libName @optional (deleteMarkers nil) "tg")
let(((libId ddGetObj(libName)) cv markers)

  printf("Processing library %L\n" libName)
  ;; when the library exists
  
  when(libId
  
    ;; iterate over all the schematics in the library
    foreach(cell setof(sch libId~>cells   member("schematic" sch~>views~>name))
    
      ;; open the schematic in read mode
      cv = dbOpenCellViewByType(libId cell~>name "schematic" "" "a")
      dbSave(cv)
      schSetEnv("saveAction" t)
      dbSave(cv)
      ;; if the schematic needs extracting, either because it has
      ;; not yet been extracted, or has been modified since the last
      ;; extraction, or symbols updated since last schematic save condition,
      ;; reopen it in append mode and extract/check it
      when(or(!dbIsConnCurrent(cv) member(schExtractStatus(cv) list("dirty"
"obselete")))
        printf("\tCell \"%s\" \"%s\" \"schematic\" needs extracting\n" libName
cell~>name)
        dbReopen(cv "a")
	;; check the schematic: when there are warnings or errors
	;; and if they are to be deleted, remove them afterwards
	;; (the schematic will be checked because it comes first in
	;; the "and" statement, markers will only be deleted after
	;; the schematic check has run)
        when(and(schCheck(cv) deleteMarkers)
		if(dbGetDatabaseType()=="CDBA" then
	  	markers = setof(lpp cv~>lpps and(lpp~>layerName=="marker"
	     	member(lpp~>purpose '("error" "warning"))))
	  	
		foreach(type markers
	   	 foreach(shape type~>shapes
	      		dbDeleteObject(shape)
	    		);; foreach marker shape
	  	);; foreach error or warning marker type
			t
		else
		 markers=setof(marker cv~>markers member(marker~>severity list("error"
"warning")))
    		
		foreach(type markers
      			;; delete marker of that marker type
      			dbDeleteObject(type)
    		); foreach marker type (error or warning)
		
    		t
		) ;if CDBA/OA
	);; when there were warnings or errors
	dbSave(cv)
	schSetEnv("saveAction" t)
        dbClose(cv)
       printf("\tCell \"%s\" \"%s\" \"schematic\" Extracted\n\n" libName cell~>name)
      ); when schematic needs extracting
    );; foreach schematic in the library
  );; when the library exists
  t
);; let
);; procedure CCScheckAllSch

/* **************************** */
/* Called on load("saveAll.il") */
/* **************************** */
printf("Saving Async Lib...\n")
CCScheckAllSch("Async")

printf("Saving Async FIFOs Lib...\n")
CCScheckAllSch("Async_FIFOs")

printf("Saving Async Tests Lib...\n")
CCScheckAllSch("Async_Tests")

printf("Saving Async Verilog Wrappers...\n")
CCScheckAllSch("Async_Verilog_Wrappers")

