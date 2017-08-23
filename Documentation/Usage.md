# Usage Examples #

## How to integerate cdsAsync with ASAP7 PDK ##
1. Download the ASAP 7nm PDK, follow the setup instructions. 
2. Run the cdsAsync integration script ...    
   
```shell
#!/bin/sh

#########################################################
# RSD - cdsAsync + ASAP 7nm Free PDK integration script #
# Created: Aug 21, 2017                                 #
# Acceptable version reached: Not yet                   #
#########################################################

# 1. Ensure environment variables are set correctly
export PDK_DIR=/path/to/asap7
export ASYNC_DIR=/path/to/cdsAsync

# 2. Sync cdsAsync Spectre views with existing asap7_TechLib views 
cd "$PDK_DIR/cdslib/asap7_TechLib"
rsync -avuhP "$ASYNC_DIR/TechLib/" . --exclude=*data.dm*

# 3. Sync updated asap7_TechLib with cdsAsync
cd "$ASYNC_DIR/TechLib/";
rsync -avuhP "PDK_DIR/cdslib/asap7_TechLib/" .

# 4. Merge the model files, cds.lib, .cdsinit, and .cdsenv files
## Upcoming ...
```

### [Download, install + proper shell environment setup for Cadence]()  

### [Distributed Processing Setup Guide + Useful Tools]()  

### [AMS/IE APS Simulation Setup Guide]()  

### [Additional Tutorials]()  


