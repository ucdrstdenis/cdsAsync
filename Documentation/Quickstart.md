# Quickstart #

```shell
git clone git@github.com:ucdrstdenis/cdsAsync.git
cd cdsAsync
virtuoso &
```

## PDK Integration
* For use with the [ASAP 7nm PDK](http://asap.asu.edu/asap/), please see download the original PDK from ASU and see the [usage instructions](../Documentation/Usage.md).
* For use with an alternative PDK, run the [CCSinstReplace.il](../Skill/CCSinstReplace.il) skill script to find and replace all transistors with those from the desired PDK library.

### Data Generation \& Automation of Analysis
See the example data generation [README](../Data/Data-Readme.md) file.


## Software Pre-requisites ##
Versions listings are recommended, but not required.

#### Minimum Prerequisites ####
Red Hat Enterprise Linux OS v7.5  
Cadence IC 6.17 or ICADV 12.3 

#### Simulation Prerequisites ####
Cadence MMSIM 15.1    or SPECTRE 16.1  
Cadence INCISIVE 15.2 or XCELIUM 17.04

#### Layout Prerequisites ####
PDK Dependent
