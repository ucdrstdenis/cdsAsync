/* ****************************************************************
*  RSD - Use this script to find and replace all transistors      *
*  for use with an alternative PDK                                *
***************************************************************** */

/* CCSInstReplace.il
Group           Custom IC, Cadence Design Systems
Language        SKILL
Revision No.    1.0
Date Created    5th December 2007
Last Modified   6th June 2016
Tested in       IC5141, IC616
Lint score      100
Description:    This program will perform instance replacement

***************************************************
SCCS Info: %Z% %M% %G%.%U% %I%
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

Key in the following in the CIW input panel :
1. load("./CCSinstReplace.il")
2. Fill in the fields in the GUI that appears
*******************************************************************/


procedure( CCSinstReplace()
  let((newRefLib targetLib oldCellName newCellName view updateForm)
        newRefLib = hiCreateStringField(
                ?name           'newRefLib
                ?prompt         "Name of new Reference library"
                ?callback       ""
                ?editable       t
        ) ;newRefLib

    targetLib = hiCreateStringField(
                ?name           'targetLib
                ?prompt         "Name of the Target library"
                ?callback       ""
                ?editable       t
        ) ;targetLib

    oldCellName = hiCreateStringField(
                ?name           'oldCellName
                ?prompt         "Name of cell to be replaced"
                ?callback       ""
                ?editable       t
        ) ;oldCellName

    newCellName = hiCreateStringField(
                ?name           'newCellName
                ?prompt         "Name of new cell"
                ?callback       ""
                ?editable       t
        ) ;newCellName

    view = hiCreateRadioField(
                ?name           `view
                ?prompt         "Choose view"
                ?choices        list("schematic" "layout")
        ) ;view

    updateForm = hiCreateAppForm(
                ?name           'updateForm
                ?formTitle      "Instance Replacement Helper"
                ?callback       'CCSreplace(hiGetCurrentForm() )
                ?fields         list(targetLib oldCellName newRefLib newCellName view)
                ?help           ""
                ?unmapAfterCB   nil
        ) ;updateForm

        hiDisplayForm( updateForm )
  );let
) ;procedure CCSinstReplace

procedure(CCSreplace(theForm)
let((cv libId cellList newRlib viewName libName oldCell newCell)
;extract parameters from the form
newRlib = theForm->newRefLib->value       ;; Name of the new Reference Library
viewName = theForm->view->value           ;; Choose the view ("Schematic/Layout")
libName = theForm->targetLib->value       ;; Target Library
oldCell = theForm->oldCellName->value     ;; Name of the cell to be replaced
newCell = theForm->newCellName->value     ;; Name of the new cell

libId = ddGetObj(libName)
cellList = libId~>cells

foreach(cell cellList
foreach(view cell~>views        ;using views matching viewName variable.

 if(view~>name == viewName && (cv=dbOpenCellViewByType(libName  cell~>name view~>name "" "a")) then
   printf("\nReplacing instances in cellview %L of library %L\n" cv~>cellName cv~>libName)
             foreach( instId cv~>instances
                        if( instId~>cellName == oldCell then
                                     leReplaceAnyInstMaster(instId newRlib newCell nil)
                        ) ;if
              ) ;foreach
             
            dbCheck(cv)
            dbSave(cv)
            dbClose(cv)
  ) ;if viewName
) ;foreach view
);foreach cell
ddReleaseObj(libId)
);let
printf("\nJob Done... :-)  \n")
);procedure CCSreplace

CCSinstReplace()  ;; This Command Opens the GUI Form
