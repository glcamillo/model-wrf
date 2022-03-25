#!/bin/bash -f
#  hash-bang (#!) http://aurelio.net/shell/
#  Encoding UTF-8
#  Last revision: 2022-03-07

#  generate_output_graphics.sh: this is the script that takes the output from ARWpost and
#           call GrADS scripts to plot the images.
#./generate_output_graphics.sh /home/cirrus/model-data-output/2022-02-19-00_dom_sao-paulo-sjcampos/wrf-a H 35 lambert 2022-02-19-00 2022-02-20-00
#./generate_output_graphics.sh $DIR_WRF_OUTPUT $CONFIG $_E_VERT $_MAP_PROJECTION ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR}  ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}


###################################################################

# Set debugging messages (variable tracking)
DEBUG=1 # debug ON
#DEBUG=0 # debug OFF


###################################################################
#
#                  General Functions
#
###################################################################

# Show debug messages for depuration
f_debug ()
{
    [ $DEBUG == 1 ] && echo -e "\033[33;1m --- (${1}):${2}=${3}\033[m \n"
}


###################################################################
#
#                  Verifying and copying the parameters
#
###################################################################



WRF_OUTPUT_DIR=$1
CONFIG=$2
NUM_LEVELS=$3
MAP_PROJECTION=$4

# Start date-time simulation
# Test for correct parameter
[ -z $5 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $5 > /dev/null
[[ $? -ne 0 ]] && exit 1

START_YEAR=$(cut -d- -f 1 <<<  $5)
START_MONTH=$(cut -d- -f 2 <<<  $5)
START_DAY=$(cut -d- -f 3 <<<  $5)
START_HOUR=$(cut -d- -f 4 <<<  $5)

## DEBUG
f_debug $0 START_DATE_TIME $START_YEAR$START_MONTH$START_DAY$START_HOUR

# Map projection for plotting in GrADS.
[[ $CONFIG =~ ^[ABCDEFGH]$ ]] && MAP_PROJECTION=lambert || MAP_PROJECTION=mercator  # I J K





###################################################################
###################################################################
#
#                  Execution
#
# grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
#  DIR_WRF_OUTPUT DOMAIN TYPE_OUTPUT_LEVEL INTERVAL MERCATOR_DEFS START_YEAR-START_MONTH-START_DAY-START_HOUR  END_YEAR-END_MONTH-END_DAY-END_HOUR
#  Parameter:
#    $1 : dir of output data to process: $DIR_WRF_OUTPUT/wrfout_d0*
#    $2 : domain to process: D1 | D2 | D3
#    $3 : type of output to INTERPOLATE: TYPE_OUTPUT_LEVEL=SIG|PRES|ALT
#    $4 : interval (in seconds) between plots
#    $5 : mercator_defs: .True. or .False.
#    $6 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $7 : date-time of ending of plotting (final date-time): 2021-12-02-00

###################################################################
###################################################################



cd $WRF_OUTPUT_DIR 2> /dev/null
[[ $? -ne 0 ]] && exit 1
#shutdown_execution "ERROR in processing this script ($0). Exiting ..." 1



# ========================================================
#  CONFIG A - conesul-RS-SC-PR-3d - RIO GRANDE DO SUL:  31,41 S / 53,435 W
# d1:100x140    18km
# d2:214x204     6km
# d3:366x306     2km
# ========================================================

# ========================================================
# CONFIG H - americasul-r_sudeste-SP-sjcampos-3d  - SÃO PAULO - São Jose dos Campos: 23,33 S / 44,80 W
# d1:166x188    31.208         36         0,2379x0,2379            10m
# d2:166x190    31.540         12        0,0793x0,07446             2m
# d3:163x190    30.970          4       0,02643x0,02482            30s
# ========================================================


# ========================================================
# CONFIG I - americasul-r_norte-MA-3d - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
# d1:166x188    31.208         27         0,1762x0,1698       10m
# d2:154x178    27.412          9       0,05876x0,05662        2m
# d3:142x166    23.572          3       0,01959x0,01887       30s
# ========================================================

# SM 29 42/053 41
# PK 31 42/052 19
# CX 29 11/051 11
# FI 25 36/054 29


if [ $CONFIG = 'A' ] ||  [ $CONFIG = 'H' ] ||  [ $CONFIG = 'I' ]; then

    if [ ! -d plotsd1 ] ; then
        mkdir plotsd1
    fi

    # wrfout_d01_PRES_2022-02-17_00.ctl
    # wrfout_d01_PRES_2022-02-17_00.dat
    WRF_OUTPUT_FILE=wrfout_d01_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    WRF_OUTPUT_FILE=wrfout_d01_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    #####################
    ###   Domain D2   ###
       
    if [ ! -d plotsd2 ] ; then
        mkdir plotsd2
    fi
    
    WRF_OUTPUT_FILE=wrfout_d02_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd2
    fi
    
    WRF_OUTPUT_FILE=wrfout_d02_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd2
    fi

    #####################
    ###   Domain D3   ###
    
    if [ ! -d plotsd3 ] ; then
        mkdir plotsd3
    fi

    WRF_OUTPUT_FILE=wrfout_d03_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then    
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd3
    fi

    WRF_OUTPUT_FILE=wrfout_d03_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd3
    fi
    
    # Return to the main function
    exit 0

fi



# ========================================================
# CONFIG B - r_sul-RS-SC-2d - RIO GRANDE DO SUL, SANTA CATARINA, PARANÁ: 30,477 S / 53,302 W
# 
# d1:150x160    24.000      10            0,0642x0,0639            2m
# d2:391x371   145.061       2           0,01284x0,0128           30s 
# ========================================================

# ========================================================
# CONFIG C - r_sul-SC-2d-high - SANTA CATARINA:  28,921 S / 53,524 W
# d1:298x277    82.546      5           0,032x0,032                        2m
# d2:751x516   387.516      1           0,00642x0,00642                   30s
# ========================================================

# ========================================================
# CONFIG G - r_sudeste-SP-MG-PR-MS-2d - SÃO PAULO (BAURU): 30,477 S / 53,302 W
# d1:150x160    24.000        10            0,0642x0,0639            2m
# d2:380x360   136.800         2           0,01284x0,0128           30s 
# ========================================================


# ========================================================
# CONFIG J r_norte-r_nordeste-MA-2d-low - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
# d1:100x80       8.000           36          0,2321x0,2293         10m
# d2:64x49        3.136           12        0,07739x0,07646         5m
# ========================================================


# ========================================================
# CONFIG K - r_norte-MA-2d-high  - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
# d1:100x80     8.000          18          0,1155x0,1152           5m
# d2:64x49      3.136           6         0,03852x0,0384           2m
# ========================================================


if [ $CONFIG = 'B' ] ||  [ $CONFIG = 'C' ] ||  [ $CONFIG = 'G' ] ||  [ $CONFIG = 'J' ] ||  [ $CONFIG = 'K' ]; then

    if [ ! -d plotsd1 ] ; then
        mkdir plotsd1
    fi

    # wrfout_d01_PRES_2022-02-17_00.ctl
    # wrfout_d01_PRES_2022-02-17_00.dat
    WRF_OUTPUT_FILE=wrfout_d01_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    WRF_OUTPUT_FILE=wrfout_d01_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    #####################
    ###   Domain D2   ###
       
    if [ ! -d plotsd2 ] ; then
        mkdir plotsd2
    fi
    
    WRF_OUTPUT_FILE=wrfout_d02_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd2
    fi
    
    WRF_OUTPUT_FILE=wrfout_d02_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd2
    fi

    # Return to the main function
    exit 0
fi



# ========================================================
# CONFIG B - r_sul-RS-SC-2d - RIO GRANDE DO SUL, SANTA CATARINA, PARANÁ: 30,477 S / 53,302 W
# 
# d1:150x160    24.000      10            0,0642x0,0639            2m
# d2:391x371   145.061       2           0,01284x0,0128           30s 
# ========================================================

# ========================================================
# CONFIG C - r_sul-SC-2d-high - SANTA CATARINA:  28,921 S / 53,524 W
# d1:298x277    82.546      5           0,032x0,032                        2m
# d2:751x516   387.516      1           0,00642x0,00642                   30s
# ========================================================

# ========================================================
# CONFIG G - r_sudeste-SP-MG-PR-MS-2d - SÃO PAULO (BAURU): 30,477 S / 53,302 W
# d1:150x160    24.000        10            0,0642x0,0639            2m
# d2:380x360   136.800         2           0,01284x0,0128           30s 
# ========================================================


# ========================================================
# CONFIG J r_norte-r_nordeste-MA-2d-low - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
# d1:100x80       8.000           36          0,2321x0,2293         10m
# d2:64x49        3.136           12        0,07739x0,07646         5m
# ========================================================


# ========================================================
# CONFIG K - r_norte-MA-2d-high  - MARANHÃO (ALCÂNTARA):  2,5 S / 44,5 W
# d1:100x80     8.000          18          0,1155x0,1152           5m
# d2:64x49      3.136           6         0,03852x0,0384           2m
# ========================================================


if [ $CONFIG == 'B' ] ||  [ $CONFIG == 'C' ] ||  [ $CONFIG == 'G' ] ||  [ $CONFIG == 'J' ] ||  [ $CONFIG == 'K' ]; then
    if [ ! -d plotsd1 ] ; then
        mkdir plotsd1
    fi

    # wrfout_d01_PRES_2022-02-17_00.ctl
    # wrfout_d01_PRES_2022-02-17_00.dat
    WRF_OUTPUT_FILE=wrfout_d01_SIG_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    WRF_OUTPUT_FILE=wrfout_d01_PRES_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}
    if [ -e $WRF_OUTPUT_FILE ]; then
        grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE.ctl $NUM_LEVELS $MAP_PROJECTION"
        mv *.png plotsd1
    fi

    # Return to the main function
    exit 0
fi








# if [ -e $WRF_OUTPUT_FILE.ctl ]; then
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 1 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 5 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 9 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 1 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 5 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 9 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 1 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 5 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 9 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 1 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 5 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 9 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 1 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 5 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 9 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 1 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 5 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 9 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 1 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 5 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 9 FL"
#     if [ $_TIMAX = 2160 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
#     fi
#     if [ $_TIMAX = 2880 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 17 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 17 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 17 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 17 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 17 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 17 FL"
#     fi
#     if [ $_TIMAX = 4320 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 PA"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 17 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 21 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -54 25 SM"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 17 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 21 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -32 -52 25 PK"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 17 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 21 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -29 -51 25 CX"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 17 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 21 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -26 -54 25 FI"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 17 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 21 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 25 CT"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 17 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 21 FL"
#     grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 25 FL"
#     fi
#     mv *.png plots
# fi

#####################
# DOMINIO DOIS  #####
#####################
# WRF_OUTPUT_FILE=wrfout_d02_SIG
# grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl 1 $NUM_LEVELS $MAP_PROJECTION"
# if [ ! -d plotsd2 ] ; then
#   mkdir plotsd2
# fi
# mv *.png plotsd2
# WRF_OUTPUT_FILE=wrfout_d02_PRES
# if [ -e $WRF_OUTPUT_FILE ]; then
#   grads -blc "run plot-pressao-wrf.gs $WRF_OUTPUT_FILE 1 $NUM_LEVELS $MAP_PROJECTION"
#   mv *.png plotsd2
# fi

#####################
# DOMINIO TRES  #####
#####################
# 
# WRF_OUTPUT_FILE=wrfout_d03_SIG
# grads -blc "run plot-sigma-wrf.gs $WRF_OUTPUT_FILE.ctl 1 $NUM_LEVELS $MAP_PROJECTION"
# if [ ! -d plotsd3 ] ; then
#   mkdir plotsd3
# fi
# mv *.png plotsd3
# 
# 
# WRF_OUTPUT_FILE=wrfout_d03_ALT
# if [ -e $WRF_OUTPUT_FILE ]; then
#   grads -blc "run plot-altura-wrf.gs $WRF_OUTPUT_FILE 1 $NUM_LEVELS $MAP_PROJECTION"
#   mv *.png plotsd3
# fi
# 
# Este ..fi.. é do if CONFIG.
# fi
# 


# 
# grads -blc "run plot.gs $WRF_OUTPUT_FILE.ctl"
# grads -blc "run plot-perfil-vertical-vento.gs $WRF_OUTPUT_FILE.ctl"
# grads -bpc "run plot-meteograma.gs $WRF_OUTPUT_FILE.ctl"
# 
# if [ $NUM_LEVELS -eq 41 ] ; then
#         grads -blc "run plot-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# else
#         grads -blc "run plot-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# fi
# 

# 
# fi
# 
# # =================================================================
# #   CONFIGURACAO CINCO, SEIS e NOVE  -  DOMÍNIO 1 e 2
# # =================================================================
# #  1  -   Para NIVES DE PRESSAO
# #  SP 23g37minS 46g39minW
# #  SJ 23g14minS 45g52minW
# #  
# #  
# if [ $CONFIG -eq 5 ] || [ $CONFIG -eq 6 ] || [ $CONFIG -eq 9 ] ; then
#         
#         cd $WRF_OUTPUT_DIR
#         
#         # Dominio UM
#         WRF_OUTPUT_FILE=wrfout_d01
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $WRF_OUTPUT_FILE.ctl"
# 
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         fi
# 
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 1 SP"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 5 SP"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 9 SP"
#         
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 1 SJ"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 5 SJ"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 9 SJ"
#         
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 13 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 17 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 13 SJ"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 17 SJ"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 13 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 17 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 21 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -24 -47 25 SP"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 13 SJ"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 17 SJ"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 21 SJ"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -23 -46 25 SJ"
#         fi      
#         mkdir -p plots
#         mv *.png plots
# 
#                 
#         # Dominio DOIS
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl"
#         grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO SETE  -  DOMÍNIO 1 e 2
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# #  RF 08g07minS 34g55minW
# #  NT 05g54minS 34g15minW
# #  FZ 03g46minS 38g32minW
# #  SV 12g54minS 38g19minW
# 
# if [ $CONFIG -eq 7 ]; then
#         
#         cd $WRF_OUTPUT_DIR
#         
#         # Dominio UM
#         WRF_OUTPUT_FILE=wrfout_d01
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $WRF_OUTPUT_FILE.ctl"
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         fi
# 
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -08 -35 1 RF"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -08 -35 5 RF"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -08 -35 9 RF"
#         
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -08 -35 13 RF"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -08 -35 17 RF"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 RF"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 RF"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 RF"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 RF"
#         fi      
#         mkdir -p plots
#         mv *.png plots
# 
#                 
#         # Dominio DOIS
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl"
#         grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO TRES  -  DOMÍNIO 1 e 2
# # ========================================================
# if [ $CONFIG -eq 3 ]; then
#         
#         cd $WRF_OUTPUT_DIR
#         
#         # Dominio UM
#         WRF_OUTPUT_FILE=wrfout_d01
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG1
# # Em 2010abr11: o tamanho da imagem e passado como parametro
# #               31: 1000x750
#         grads -blc "run plot.gs $WRF_OUTPUT_FILE.ctl 31"
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl 31"
#         else
#                 grads -blc "run plot-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl 31"
#         fi
#         mkdir -p plots
#         mv *.png plots
# 
#         # Dominio DOIS
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl 31"
#         grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl 31"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# 
# 
# # ========================================================
# #   CONFIGURACAO TRES e OITO  -  DOMÍNIO 1 e 2
# # ========================================================
# if [ $CONFIG -eq 3 ] || [ $CONFIG -eq 8 ]; then
#         
#         cd $WRF_OUTPUT_DIR
#         
#         # Dominio UM
#         WRF_OUTPUT_FILE=wrfout_d01
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $WRF_OUTPUT_FILE.ctl"
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         fi
#         mkdir -p plots
#         mv *.png plots
# 
#         # Dominio DOIS
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl"
#         grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO 1  -   DOMINIO 2
# # ========================================================
# #  GRADE METROPOLITANA POA.
# #  1  -   Para NIVES DE PRESSAO
# if [ $CONFIG -eq 1 ]; then
# 
#         cd $WRF_OUTPUT_DIR
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         # b=batch l=landscape c=command
#         # grads -blc "run plot-skew-wrf.gs MMOUT_DOMAINx.ctl x y t l"
#         grads -blc "run plot-conf1-d2.gs $WRF_OUTPUT_FILE.ctl"
# 
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-conf1-d2-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         else
#                 grads -blc "run plot-conf1-d2-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         fi      
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 1 PA"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 5 PA"
#         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 9 PA"
#         if [ $_TIMAX = 2160 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#         fi
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 PA"
#         fi
#         # Mover todos os arquivos de plotagem (png) para uma pasta 
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# # ========================================================
# #   CONFIGURACAO ZERO   -   DOMINIO 2 e 3
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# # if [ $CONFIG -eq 0 ]; then
# # 
# # # DOMINIO DOIS DOIS DOIS
# #         
# #         cd $WRF_OUTPUT_DIR
# #         WRF_OUTPUT_FILE=wrfout_d02
# #         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
# #         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl"
# #         if [ $NUM_LEVELS -eq 41 ] ; then
# #                 grads -blc "run plot-sigma-d2-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# #         else
# #                 grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# #         fi
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 1 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 5 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 9 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 1 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 5 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 9 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 1 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 5 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 9 FL"
# #         if [ $_TIMAX = 2160 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
# #         fi
# #         if [ $_TIMAX = 2880 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 17 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 17 FL"
# #         fi
# #         if [ $_TIMAX = 4320 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 PA"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 17 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 21 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -25.3 -49.1 25 CT"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 13 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 17 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 21 FL"
# #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -27.6 -48.5 25 FL"
# #         fi
# #         mkdir -p plotsd2
# #         mv *.png plotsd2
# # 
# # # DOMINIO TRES TRES TRES
# # 
# # #         cd $WRF_OUTPUT_DIR
# # #         WRF_OUTPUT_FILE=wrfout_d03
# # #         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG3
# # #         grads -blc "run plot-conf1-d2.gs $WRF_OUTPUT_FILE.ctl"
# # #         if [ $NUM_LEVELS -eq 41 ] ; then
# # #                 grads -blc "run plot-conf1-d3-sigma-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# # #         else
# #                 grads -blc "run plot-conf1-d3-sigma.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
# # #         fi
# # #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 1 PA"
# # #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 5 PA"
# # #         grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 9 PA"
# # #         if [ $_TIMAX = 2160 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# # #         fi
# # #         if [ $_TIMAX = 2880 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
# # #         fi
# # #         if [ $_TIMAX = 4320 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 PA"
# # #         fi
# # #         mkdir -p plotsd3
# # #         mv *.png plotsd3
# # fi
# 
# # ========================================================
# #   CONFIGURACAO DOIS e QUATRO  -  DOMINIO 2
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# if [ $CONFIG -eq 2 ] || [ $CONFIG -eq 4 ]; then
#         
#         cd $WRF_OUTPUT_DIR
#         WRF_OUTPUT_FILE=wrfout_d02
#         WRF_OUTPUT_FILE_SIGMA=MMOUT_DOMAIN_SIG2
#         # b=batch l=landscape c=command
#         # grads -blc "run plot-skew-wrf.gs MMOUT_DOMAINx.ctl x y t l"
#         grads -blc "run plot-d2.gs $WRF_OUTPUT_FILE.ctl"
#         grads -blc "run plot-perfil-vertical-vento.gs $WRF_OUTPUT_FILE.ctl"
#         if [ $NUM_LEVELS -eq 41 ] ; then
#                 grads -blc "run plot-sigma-d2-n41.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma-d2.gs $WRF_OUTPUT_FILE_SIGMA.ctl"
#         fi
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 1 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 5 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 9 PA"
# 
#         if [ $_TIMAX = 2160 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#         fi
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 17 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 21 PA"
#                 grads -blc "run plot-skew-wrf.gs $WRF_OUTPUT_FILE.ctl -30 -51 25 PA"
#         fi
#         # Mover todos os arquivos de plotagem (png) para uma pasta 
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi



exit 0

