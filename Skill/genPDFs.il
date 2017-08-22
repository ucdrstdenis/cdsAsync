/*************************************************************************
* RSD - Generates a high-res PDF for each schematic in the Async library *
* All PDF files are placed into a folder "pdf/"                          *
* Edit the script to change resolution, filetype, or resulting filenames *
* To use, just type load("genPDFs.il") into the CIW                      *
*                                                                        *
* Original source: printtopdf.il                                         *
*************************************************************************/

/*

Group           Custom IC, Cadence Design Systems
Language        SKILL
Revision No.    1.0
Date Created    22nd Apr 2014
Last Modified   23rd Apr 2014
Tested in       IC616-500-5
Lint score      100/100
Author          hcquek
COS article	20257839
Description     This program will print specified views in a library to pdf format

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

CCSprintToPdf("myLib" "myOutputDir")
CCSprintToPdf("myLib" "myOutputDir" list("schematic" "layout"))

*/

procedure( CCSprintToPdf(lib outputDir @optional (viewList list("schematic")))
   let( (pngFiles name cmd)
      unless( ddGetObj(lib) error("Library %s cannot be found" lib))

      foreach( view viewList
         hiGenerateThumbnails(
           ?lib lib
           ?view view
           ?sizes list(2048 2048) ;; RSD resolution edit
           ?filePath strcat(outputDir "/%C_%V.png") ;; RSD filename edit
         ) ;hiGenerateThumbnails
      ) ;foreach

      printf("Converting png files to pdf format\n")
      pngFiles=setof(x getDirFiles(outputDir) pcreMatchp("png$" x))
      foreach( file pngFiles
         pcreMatchp("(\\w+).png" file)
         name=pcreSubstitute("\\1")
         ; "convert" is a linux utility to convert graphics file to pdf format
         cmd=sprintf(nil "convert %s/%s %s/%s.pdf" outputDir file outputDir name)
         system(cmd)
         system(strcat("rm -f " outputDir "/" file))
      ) ;foreach
      printf("Generated %d pdf files\n" length(pngFiles))
   ) ;let
) ;procedure

/* ******************************** */
/*   Called on load("genPDFs.il")   */
/* ******************************** */
printf("Saving Async schematic PDFs to directory...\n")
CCSprintToPdf("Async" "pdf")

