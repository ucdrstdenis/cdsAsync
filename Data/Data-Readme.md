# Data Readme
Example data was generated using the [sweep_template.ocn](../Ocean/sweep_template.ocn), 
which performs a process, voltage, and temperature sweep of the Buffer_Test
located in the [Async_Tests](../Async_Tests) library. PSF results from each 
sweep point were processed using the [analyzeQDI.il](../Skill/analyzeQDI.il) SKILL 
script to automatically produce the [.dat files](TT), which can be easily plotted using the
[plotdat.m](plotdat.m) Matlab file.
