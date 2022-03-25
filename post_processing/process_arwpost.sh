#!/bin/bash
#
#  Encoding UTF-8
#  Last revision: 2022-03-07
#
#  process_arwpost : build the Namelist (namelist.wps) for the Post-Processing.
#          Namelist used by the ARWpost/ARWpost.exe to generate GrADS files (dat,ctl)
#  
#  *** Important Obs: there are repetitive code (the original wasn't), but we need
#          to considerer that in future, we will different output processing for
#          different domain configurations.
#
#   20220212: creation of this script; original code was in the main script (runwrf.sh)
#
#  Input Parameters:
#    $1 : domain configuration: A | B | C ...
#    $2 : path for ARWpost binary (default: $HOME/bin/ARWpost
#    $3 : path for the output of the dat and ctl files (DIR_WRF_OUTPUT)
#    $4 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $5 : date-time of ending of simulation (final date-time): 2021-12-02-00
#  Output:
#    bin/ARWpost/namelist.ARWpost


# Valores passados como parâmetros:
# 1: Caminho dos dados  2:Número do domínio 3:Tipo de nível de saída
# Para o terceiro parâmetro:
# 0:níveis do modelo (sigma) 1:níveis de pressão  2:níveis em altura
# MERCATOR_DEFS=.False.    .True. (for large domains)


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


shutdown_execution () {
      echo -e "\n\n $1 \n\n" ; exit $2
}

mensagem () {
      echo -e "\n\n $1 \n\n" ;
}

###################################################################
###################################################################
#
#                  Verifying the parameters
#
###################################################################
###################################################################


# $1: domain configuration: test for correct parameter
    # Obs: use of regex in Bash
f_debug $0 "\$1 (CONFIG)" $1    
if [[ ${1} =~ [:alfa:]* ]] && [[ ${#1} -eq 1 ]]; then
    CONFIG=$1
        if [[ ${CONFIG} =~ ${CONFIG_VALUES} ]] && [ $? -ne 0 ] ; then
            mensagem "ERROR in the parameter conf:${1} The value is out of the config domains available:$CONFIG_VALUES "
            exit 1
        fi
else
    mensagem "ERROR in the parameter \$1:${1} The value is INCORRECT."
    exit 1
fi

# $2 path for ARWpost binary (default: $HOME/bin/ARWpost
f_debug $0 " Path of ARWpost bin and namelist" $2    
if [ ! -x "${2}/ARWpost.exe" ]; then
    mensagem "ERROR in the parameter ${2}. No binary (${2}/ARWpost.exe) found"
    exit 1
fi

# Start date-time simulation
# Test for correct parameter
[ -z $4 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $4 > /dev/null
[[ $? -ne 0 ]] && exit 1

START_YEAR=$(cut -d- -f 1 <<<  $4)
START_MONTH=$(cut -d- -f 2 <<<  $4)
START_DAY=$(cut -d- -f 3 <<<  $4)
START_HOUR=$(cut -d- -f 4 <<<  $4)

## DEBUG
f_debug $0 START_DATE_TIME $START_YEAR$START_MONTH$START_DAY$START_HOUR

# Ending date-time simulation
# Test for correct parameter
[ -z $5 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $5 > /dev/null
[[ $? -ne 0 ]] && exit 1

END_YEAR=$(cut -d- -f 1 <<<  $5)
END_MONTH=$(cut -d- -f 2 <<<  $5)
END_DAY=$(cut -d- -f 3 <<<  $5)
END_HOUR=$(cut -d- -f 4 <<<  $5)

## DEBUG
f_debug $0 END_DATE_TIME $END_YEAR$END_MONTH$END_DAY$END_HOUR


# $3 path for DIR_WRF_OUTPUT
# IMPORTANT: only tested for the first domain. Some configurations have domains 2 and/or 3.
#            These will be tested in the specific sections below.
f_debug $0 " Path of DIR_WRF_OUTPUT"  $3
ls $3/wrfout_d01_"$START_YEAR"-"$START_MONTH"-"$START_DAY"_"$START_HOUR":00:00  1> /dev/null 2>&1
if [ $? -ne 0 ]; then
    mensagem "ERROR in the parameter ${3}"
    mensagem "No WRF output files ${3}/wrfout_d0[1|3]_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00 found"
    exit 1
fi
DIR_WRF_OUTPUT=$3


# 0: padrão do modelo (sigma)
# 1: níveis em pressão
# 2: níveis em altura
# Valores do INTERP_METHOD :0 - sigma levels,  -1 - code defined "nice" height levels,  1 - user defined height or pressure levels
# INTERP_METHOD=0 (valor padrão)
# Em 26set13: foi acrescido o INTERP_LEVELS=$NUM_NIVEIS_ETA_SIGMA, sendo o NUM_NIVEIS_ETA_SIGMA setado no script run principal.



################################################################################
################################################################################
#
#                  Execution
# Obs:
#  The function will return:
#  0: sucess
#  1: ERROR: neither domain could generate GrADS output
#  2: ERROR: some domain resulted in error

# ./namelist.ARWpost.sh DIR_WRF_OUTPUT DOMAIN TYPE_OUTPUT_LEVEL INTERVAL MERCATOR_DEFS START_YEAR-START_MONTH-START_DAY-START_HOUR  END_YEAR-END_MONTH-END_DAY-END_HOUR
#  Parameter:
#    $1 : dir of output data to process: $DIR_WRF_OUTPUT/wrfout_d0*
#    $2 : domain to process: D1 | D2 | D3
#    $3 : type of output to INTERPOLATE: TYPE_OUTPUT_LEVEL=SIG|PRES|ALT
#    $4 : interval (in seconds) between plots
#    $5 : mercator_defs: .True. or .False.
#    $6 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $7 : date-time of ending of plotting (final date-time): 2021-12-02-00

################################################################################
################################################################################


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

if [ $CONFIG = 'I' ]; then
    MERCATOR_DEFS=.True.
else
    MERCATOR_DEFS=.False.
fi
INTERVAL_PLOT_IN_SECONDS=10800  #  3 hours

cd ${BIN_PATH}/ARWpost 2> /dev/null
[[ $? -ne 0 ]] && shutdown_execution "ERROR in processing this script ($0). Exiting ..." 1


if [ $CONFIG = 'A' ] ||  [ $CONFIG = 'H' ] ||  [ $CONFIG = 'I' ]; then
    
    mensagem ">>>>>>> Program arwpost.exe (STARTING) for config:$CONFIG"    

    #####################
    ###   Domain D1   ###
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    echo -e ">> SIGMA output <<\n"
         
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh $DIR_WRF_OUTPUT 1 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_SIG_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        # shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
    
        cp ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        #shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
        # shutdown_execution  "ERROR: problem in execution of ${BIN_PATH}/ARWpost/namelist.ARWpost.sh. Exiting."  1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh $DIR_WRF_OUTPUT 1 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_PRES_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1
    
        cp ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1        
    fi
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"
    
    
    
    #####################
    ###   Domain D2   ###
    mensagem ">>>>>>> D2:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    
    ls $3/wrfout_d02_"$START_YEAR"-"$START_MONTH"-"$START_DAY"_"$START_HOUR":00:00  1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        mensagem " No WRF output file: $3/wrfout_d02_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00"
        exit 1
    fi
    
    echo -e ">> SIGMA output <<\n"
         
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh $DIR_WRF_OUTPUT 2 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D2=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D2  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_SIG_D2} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D2=1        
    
        cp ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D2=1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 2 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D2=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D2  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_PRES_D2} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D2=1
    
        cp ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D2=1
    fi
    mensagem ">>>>>>> D2:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"        

    
    #####################
    ###   Domain D3   ###
    mensagem ">>>>>>> D3:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    echo -e ">> SIGMA output <<\n"

    ls $3/wrfout_d03_"$START_YEAR"-"$START_MONTH"-"$START_DAY"_"$START_HOUR":00:00  1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        mensagem " No WRF output file: $3/wrfout_d02_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00"
        exit 1
    fi
    
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 3 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D3=$?

    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D3  2>/dev/null
    
    if [ ${STATUS_SIG_D3} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D3=1        
    
        cp ARWpost-SIG-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D3=1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 3 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D3=$?

    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D3  2>/dev/null
    
    if [ ${STATUS_PRES_D3} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D3=1
    
        cp ARWpost-PRES-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D3-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D3=1
    fi
    mensagem ">>>>>>> D3:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"        
    
    if [ $STATUS_SIG_D1 -eq 0 ] && [ $STATUS_SIG_D2 -eq 0 ] && [ $STATUS_SIG_D3 -eq 0 ] && [ $STATUS_PRES_D1 -eq 0 ] && [ $STATUS_PRES_D2 -eq 0 ] && [ $STATUS_PRES_D3 -eq 0 ]; then
        exit 0
    else
        exit 2
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


if [ $CONFIG == 'J' ] || [ $CONFIG == 'K' ]; then
    MERCATOR_DEFS=.True.
else
    MERCATOR_DEFS=.False.
fi
INTERVAL_PLOT_IN_SECONDS=10800  #  3 hours

cd ${BIN_PATH}/ARWpost 2> /dev/null
[[ $? -ne 0 ]] && shutdown_execution "ERROR in processing this script ($0). Exiting ..." 1


if [ $CONFIG = 'B' ] ||  [ $CONFIG = 'C' ] ||  [ $CONFIG = 'G' ] ||  [ $CONFIG = 'J' ] ||  [ $CONFIG = 'K' ]; then
    
    mensagem ">>>>>>> Program arwpost.exe (STARTING) for config:$CONFIG"    

    #####################
    ###   Domain D1   ###
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    echo -e ">> SIGMA output <<\n"

    # DEBUG
    f_debug $0 '$DIR_WRF_OUTPUT' $DIR_WRF_OUTPUT

    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh $DIR_WRF_OUTPUT 1 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_SIG_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        # shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
    
        cp ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        #shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
        # shutdown_execution  "ERROR: problem in execution of ${BIN_PATH}/ARWpost/namelist.ARWpost.sh. Exiting."  1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 1 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_PRES_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1
    
        cp ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1        
    fi
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"
    
    
    
    #####################
    ###   Domain D2   ###
    mensagem ">>>>>>> D2:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    echo -e ">> SIGMA output <<\n"

    ls $3/wrfout_d02_"$START_YEAR"-"$START_MONTH"-"$START_DAY"_"$START_HOUR":00:00  1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        mensagem " No WRF output file: $3/wrfout_d02_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00"
        exit 1
    fi   
    
    # DEBUG
    f_debug $0 '$DIR_WRF_OUTPUT' $DIR_WRF_OUTPUT
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh $DIR_WRF_OUTPUT 2 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D2=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D2  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_SIG_D2} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D2=1        
    
        cp ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D2=1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 2 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D2=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D2  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_PRES_D2} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D2=1
    
        cp ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D2-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D2=1
    fi
    mensagem ">>>>>>> D2:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"        

    
    if [ $STATUS_SIG_D1 -eq 0 ] && [ $STATUS_SIG_D2 -eq 0 ] && [ $STATUS_PRES_D1 -eq 0 ] && [ $STATUS_PRES_D2 -eq 0 ]; then
        exit 0
    else
        exit 2
    fi
        
    # Return to the main function
    exit 0
    
    
fi



# ========================================================
# CONFIG D - santa-catarina-1d-high - SANTA CATARINA:  27,322 S / 51,746 W
# d1:751x516   383.761          1         0,0064x0,0064            30s
# ========================================================

# ========================================================
# CONFIG E - santa-catarina-1d-high-small - SANTA CATARINA:  27,322 S / 51,2 W
# d1:560x420   235.200          1         0,0064x0,0064            30s
# ========================================================

# ========================================================
# CONFIG F - santa-catarina-1d-low-small - SANTA CATARINA:  27,322 S / 51,746 W
# d1:370x250    92.500          2         0,0128x0,0128            30s
# ========================================================


MERCATOR_DEFS=.False.
INTERVAL_PLOT_IN_SECONDS=10800  #  3 hours

cd ${BIN_PATH}/ARWpost 2> /dev/null
[[ $? -ne 0 ]] && shutdown_execution "ERROR in processing this script ($0). Exiting ..." 1


if [ $CONFIG == 'D' ] ||  [ $CONFIG == 'E' ] ||  [ $CONFIG == 'F' ]; then
    
    mensagem ">>>>>>> Program arwpost.exe (STARTING) for config:$CONFIG"    

    #####################
    ###   Domain D1   ### 
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- STARTING"
    echo -e ">> SIGMA output <<\n"
         
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 1 SIG $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_SIG_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.SIG.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_SIG_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        # shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
    
        cp ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-SIG-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_SIG_D1=1
        #shutdown_execution "ERROR: Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ..." 1
        # shutdown_execution  "ERROR: problem in execution of ${BIN_PATH}/ARWpost/namelist.ARWpost.sh. Exiting."  1
    fi
    
    echo -e ">> PRESSURE output <<\n"
    
    ${BIN_PATH}/ARWpost/namelist.ARWpost.sh ${DIR_WRF_OUTPUT} 1 PRES $INTERVAL_PLOT_IN_SECONDS $MERCATOR_DEFS ${START_YEAR}-${START_MONTH}-${START_DAY}-${START_HOUR} ${END_YEAR}-${END_MONTH}-${END_DAY}-${END_HOUR}
          
    STATUS_PRES_D1=$?

    # First, backup the log file to the WRF output dir
    cp ${BIN_PATH}/ARWpost/namelist.ARWpost ${DIR_WRF_OUTPUT}/namelist.ARWpost.PRES.D1  2>/dev/null
    
    # Next, verify the output from status
    if [ ${STATUS_PRES_D1} -eq 0 ]; then
        ./ARWpost.exe >& ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1
    
        cp ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log ${DIR_WRF_OUTPUT} 2> /dev/null
        grep -i "Successful completion of ARWpost" ARWpost-PRES-D1-${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}.log
        [[ $? -ne 0 ]] && STATUS_PRES_D1=1        
    fi
    
    mensagem ">>>>>>> D1:generating ${BIN_PATH}/ARWpost/namelist.ARWpost and then executing ${BIN_PATH}/ARWpost/ARWpost.exe --- ENDING"
    
    if [ $STATUS_SIG_D1 -eq 0 ] && [ $STATUS_PRES_D1 -eq 0 ]; then
        exit 0
    else
        exit 2
    fi

    # Return to the main function
    exit 0
    
    
fi


