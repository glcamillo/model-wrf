## README for package `model-wrf`
This Readme explains the basic use of scripts in Bash Shell to automate most of the routines of executon of the WRF package. It can be used for operational purposes, but the initial purpose is to carry out studies and simulations.


## Documentation and references
What is WRF (Weather Research and Forecasting Model): in short, is a set of programs that extrapolates the state of atmosphere to some time in future (days, months) through physical equations. 

The model is available at NCAR with a lot of documentation, data, and links to the source code: [WRF Users' page.](https://www2.mmm.ucar.edu/wrf/users/)

The code is available in public domain: [WRF Public Domain Notice](https://www2.mmm.ucar.edu/wrf/users/public_domain_notice.html)

Reference: Skamarock, W. C., J. B. Klemp, J. Dudhia, D. O. Gill, Z. Liu, J. Berner, W. Wang, J. G. Powers, M. G. Duda, D. M. Barker, and X.-Y. Huang, 2019: A Description of the Advanced Research WRF Version 4. NCAR Tech. Note NCAR/TN-556+STR, 145 pp. doi:10.5065/1dfh-6p97



## General aspects

Autor: G Camillo
Last revision: 24 mar. 2022

***This Readme and the scripts are in update***

The main scripts:
* runwrf.sh
* fetch_global_data.sh

* post_processing/generate_output_graphics.sh

* wps/link_grib.csh
* wps/link_grib-data.csh
* wps/namelist.wps.sh
* wps/process_ungrib.sh
* wps/ungrib.sh

* wrf/namelist.input.wrf.sh

Auxiliary files and programs
* wrf/ncdump
* post_processing/grads

* modelo-dataset-CFS.sh
* modelo-regcm-config.in.sh

* config-domains/


## **WRF** : some restrictions of this package
   a) The `model-wrf` only supports domains with up to three levels of nesting;
   b) Nested domains must all start at the same time;
   c) Maximum integration time of 3 days (72 hours);
   d) The script tracks the execution (and success/failure) of modules so it is possible to continue execution in case of failure. The restriction is that the script must be re-executed immediately afterwards. 
  
***Obs: the scripts expect that the WRF/WPS system is installed and working.***
***These scripts were tested with WRF 4.2.1 (with MPICH).***
***The namelist (WPS and WRF) options were updated to WRF v. 4.3.***

   
### The prerequisites for running the model are::

1. ***Directories***: WRF binaries, input and output data, and script files are located (referenced) in the user's home directory.
Obs.: the variable `USER_PATH` contains the directory of home (`$HOME`).

These variables are defined and used in the script `runwrf.sh`

`CURRENT_DIR=/home/$(id -un)/model-wrf`
- What it contains: all the scripts to execute the WRF model
- Where is defined: `model-wrf/runwrf.sh`
- Where is used: global use in `runwrf.sh`

`BIN_PATH=$USER_PATH/bin`
- What it contains: directories for the binaries: libs (NetCDF, MPI, etc), WPS, WRF
- Where is defined: `model-wrf/runwrf.sh`
- Where is used: global use (exported) in `runwrf.sh` and `wps/namelist.wps.sh`


`GEODATA_PATH=$USER_PATH/bin/WPS_GEOG`
- What it contains: geographical data sets (soil categories, land use category, terrain height, annual mean deep soil temperature, monthly vegetation fraction, monthly albedo, maximum snow albedo, and slope category)
- Where is defined: `model-wrf/runwrf.sh`
- Where is used: passed to the script `namelist.wps.sh`

`WPS_PATH=$USER_PATH/bin/WPS`
- What it contains: binaries, data (`WPS/data`) and `namelist.wps` for the programs: geogrid.exe, ungrib.exe and metgrid.exe
- Where is defined: `model-wrf/runwrf.sh`
- Where is used: global use (exported) in: `runwrf.sh`, `wps/namelist.wps.sh`, `wps/executes_ungrib.sh`

2.  ***Directories*** for INPUT and OUTPUT data. The higher level of these directories can be modified by users in the script `model-wrf/runwrf.sh`

* Directory for global INPUT data: `DIR_DATA_INPUT=$USER_PATH/model-data-input-global`

* Directory for the OUTPUT data from the model: `DIR_DATA_OUTPUT=$USER_PATH/model-data-output`

3. ***Variable definitions*** some variables need to be defined in the script before run it.

String that contains the letters of all domains configured. If new domain settings are added, they will be defined by letters.

***CONFIG_VALUES="ABCDEFGHIJK"***
- Where is defined: `model-wrf/runwrf.sh`
- Where is used: these scripts use `CONFIG_VALUES`:
`model-wrf/post_processing/process_ARWpost.sh`
`model-wrf/post_processing/generate_output_graphics.sh`



## How to execute

Here the basic execution options will be presented (according to the help of the runwrf.sh script). Details of each option will be presented later.

```sh
$ cd $HOME/model-wrf
```

# How to call help for command line parameters
```sh
$ ./runwrf.sh --help
```

Use: `$ ./runwrf.sh parameters options`

* MANDATORY parameters *
 -conf A | B | ... Z : domain configuration
 -ts 2021-06-01-12   : (yyyy-mm-dd-HH) date-time of start data/hora inicial da integração
 -ti 24 | 48 | 72    : (HH) integration time in hours (run time forecast) (default:24h)

* OPTIONAL parameters *
 -tiout 3 | 6        : (H) time interval of output (default:3h)
 -gd gfs1p00 | gfs0p50 | gfs0p25 | cptec_wrf_5km :global data NCEP-GFS (1|0.5|0.25 degree - default:gfs1p00) OR WRF from CPTEC (5km)
 -gti 1 | 3 | 6      : (H) time interval (hours) of global input data (time resolution): 1 for cptec_wrf_5km and 3/6 for gfs (defaults are: 1h for cptec_wrf_5km and 3h for gfs)

 -np 1              :  number of processes to be use: (default=1)
 --wrf-time-step 20 :  value (in s) of WRF time step (default:each configuration has been defined with some default time step)

* OPTIONS *
 [--use-hwthread-cpus ]     : use hardware threads as independent cpus
         Default: empty (no use)
 [--use-generated-geogrid ] : use file(s) geo_em.d01,2,3 to the program WPS geogrid.exe. They must be generated previously and available in this directory: `model-wrf/config-domains/'NAME_OF_DOMAIN'/`
For each domain/nest there is a file: domain 1 (geo_em.d01), domain 2 (geo_em.d02), domain 3 (geo_em.d03). In the end, depends on how many nests are configured in each domain configuration.
         **Important** The default is the program `bin/WPS/geogrid.exe` generate the model terrestrial domains (geo_em).
 [--use-static-config ]     : the script will use the namelist files in their directories. Only need provide the mandatory parameters to verify DIR and INPUT DATA
         Default: use dynamic generation of the namelist files.
 
 
Observations:
  a) The parameter `tiout` is for the coarse domain (domain 1). The domain 2 and 3 (if configured) will output data in time interval of 1 hour
  b) There are no guarantee that using virtual processors (hyperthreading) will upgrade performance. Recommendation is one process per core.

* EXAMPLE *
`./runwrf.sh -conf G -ts 2022-01-01-12 -ti 24 -gti 3 -np 4 -gd gfs0p50 --use-generated-geogrid`
Configuration G: r_sudeste-SP-MG-PR-MS-2d
Start of simulation: 2022, 1st january at 12 UTC
Time of forecast: 24 hours
Time step of global data: 3 hours
Type and resolution of global data: GFS from NCEP - 0.5 degrees
Use domain configuration (physical) from geogrid.exe

   
-------------------------------------------------------------------------------
                              Other information



##  CHANGELOG

2009      : v. 0.1: Initial version. This version was based on the scripts used
                    to run the MM5 model.

2010-06/07  : v. 1.0: Scripts have been improved to run comparison experiments
                    between MM5 and WRF for forecasting winds at low levels.

2011-04/05: v. 2.0: Modifications to make the code cleaner and with some
                    improvements. Inclusion of the multi-configuration system.

2021-05   : v. 3.0: Option to choose the resolution of GFS global data:1p00,0p50,0p25
                    Some options can be passed as command line parameters (this
                    feature was implemented in the RegCM4 script)


2021-10-12 : v. 4.0: (starting) This is the biggest and the main code review. All
                    scripts were reviewed.
                    a) Some alterations come from RegCM4 scripts
                    b) New and revised domain configurations
                    c) Review of the namelist parameters (WPS and WRF) to follow
                    the last revision of the WRF (v. 4.3, 21/May/10) (https://github.com/wrf-model/WRF/releases)
                    d) Change of DIRs: model (scripts location), input, and output data
                    e) Expansion of the parameter processing (via input from command line)
                    f) Parameterize more physical options in the namelist.input
                    g) Option to download global data from CPTEC (WRF output
                    resolution in 5km)
                    h)Review the scripts to improve readability and resilience (more tests and debug info): this is a permanent TODO
2022-02-10 : v. 4.1 (finished) The model is running now, but there is still more development and testing to go

 
##  Execution details

Dependencies for domain configuration:
- runwrf.sh
- post_processing/process_arwpost.h
- post_processing/generate_output_graphics.sh



All execution configurations have a set of parameters defined in the the next two files:
WPS: `bin/WPS/namelist.wps`  (WPS-n)
>>>> `WRF: bin/WRF/namelist.input` (WRF-n)

The next two scripts will generate the output namelist files above:
WPS: `model-wrf/wps/namelist.wps.sh`  (WPS-s)
WRF: `model-wrf/wrf/namelist.input.wrf.sh` (WRF-s)

Then, if you need alter some parameter to specify an execution, there are two options:
a) You can alter the configuration file that contains some parametrized variables to adjust the namelist. This is a text file that allow you to modify the `Microphysics parametrization` (MP_PHYSICS), for example.
b) If you need modify other parameters, then I sugest include the modifications in the scripts files (WPS-s and WRF-s)
  
 



## Global Data

Global meteorological data is required for initialization and to ateral and boundary conditions (LBC). The LBC data available by global models have a temporal resolution, that is, the time interval between predictions.

So the time interval setting for WPS (ungrib.exe) will depend on:
a) availability of the temporal resolution of a given global model (can be 1, 3 or 6 hours); and
b) the configuration and simulation needs. 

[Meteorological Data for WRF](https://www2.mmm.ucar.edu/wrf/users/download/free_data.html)


# NCEP: GFS model
Obs.: some changes occured at March, 22 (2021).

[GFS information] (https://www.nco.ncep.noaa.gov/pmb/products/gfs/)
CC is the model cycle runtime (i.e. 00, 06, 12, 18)
FFF is the forecast hour of product from 000 - 384
YYYYMMDD is the Year, Month and Day
    
The GFS model provides three spatial resolutions:

0p25: 0.25 degree resolution gfs.tCCz.pgrb2.0p25.fFFF 	ANL FH000 FH001-384
0p50: 0.5 degree resolution gfs.tCCz.pgrb2.0p50.fFFF 	ANL FH000 FH003-384
1p00: 1.0 degree resolution      gfs.tCCz.pgrb2.1p00.fFFF ANL FH000 FH003-384

Time interval of forecasts:
0p25: FH001-120 (1 hour)  FH120-384 (3 hours)
0p50: FH003-384 (3 hours)
1p00: FH003-384 (3 hours)
   
Data available on this site (example for this initialization date-time: 2022-03-15 12UTC):
[NOMADS] (https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20220315/12/atmos/)

Directory default name for GFS data from NCEP: `DIR_WPS_INPUT=$DIR_DATA_INPUT/yyyy-mm-dd-HH-gfs`

# CPTEC: WRF model

There is the possibility of use Initial and LBC (Lateral and Boundary Conditions) from [CPTEC] (https://www.cptec.inpe.br/) that run some met and climate models.
One of that is the output from WRF that is available to input in our model. 

Directory default name for WRF data from CPTEC: `DIR_WPS_INPUT=$DIR_DATA_INPUT/yyyy-mm-dd-HH-cptec-wrf`



## TODO
  a) Continuous review this script and the others for readability, security, and resilience (where possible).

  b) Check disk available space before running.

  c) Check lenght of files that need be downloaded (GLOBAL data for input: GFS and WRF from CPTEC).
  
  d) Check the parameters (all needed) supplied from user
  
  e) The domain configurations (A, B, ...) need to be bring out from the main script. The aim is to be put in a configuration text file.
  
  f) Upgrade and improve the graphics plots.
  
  g) Take out the data (options) of the configuration domains in a text file. This will be the configuration file that USER can EDIT and MODIFY.
  
  
  
## CONFIGURATIONS: some domain configurations available to be used


***A*** conesul-RS-SC-PR-3d - RIO GRANDE DO SUL:  31,41 S / 53,435 W
d1:100x140    18km
d2:214x204     6km
d3:366x306     2km

***B*** r_sul-RS-SC-2d - RIO GRANDE DO SUL, SANTA CATARINA, PARANÁ: 30,477 S / 53,302 W
d1:150x160    10km
d2:391x371     2km

***C*** r_sul-SC-2d-high - SANTA CATARINA:  28,921 S / 53,524 W
d1:298x277     5km
d2:751x516     1km

***D*** santa-catarina-1d-high - SANTA CATARINA:  27,322 S / 51,746 W
d1:751x516     1km

***E*** santa-catarina-1d-high-small - SANTA CATARINA:  27,322 S / 51,2 W
d1:560x420     1km

***F*** santa-catarina-1d-low-small - SANTA CATARINA:  27,322 S / 51,746 W
d1:370x250     2km

***G*** r_sudeste-SP-MG-PR-MS-2d - SÃO PAULO (BAURU): 30,477 S / 53,302 W
d1:150x160    10km
d2:380x360     2km

***H*** americasul-r_sudeste-SP-sjcampos-3d  - SÃO PAULO - São Jose dos Campos: 23,33 S / 44,80 W
d1:166x188    36km
d2:166x190    12km
d3:163x190     4km

***I*** americasul-r_norte-MA-3d - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
d1:166x188    27km
d2:154x178     9km
d3:142x166     3km

***J*** r_norte-r_nordeste-MA-2d-low - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
d1:100x80     36km
d2:64x49      12km

***K*** r_norte-MA-2d-high  - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
d1:100x80     18km
d2:64x49       6km



# Meta
I need to express my gratitude for those who embraced the idea of open source and voluntarily shared their knowledge. For this work, especially:
- People who are involved in the world of the WRF model; and,
- Aurélio[1] and Julio Cezar[2]: for their contribution to making Scripting Bash accessible (books: [3][4]). I know I need to improve my codes, but with your help, that's going to be possible.

[1] [Aurélio Marinho Jargas](http://aurelio.net/about.html)
[2] [Julio Cezar Neves](https://www.linkedin.com/in/juliocezarneves/)
[3](https://www.shellscript.com.br/)
[4](https://novatec.com.br/livros/programacao-shell-linux-12ed/)


https://help.github.com/articles/creating-and-highlighting-code-blocks/
