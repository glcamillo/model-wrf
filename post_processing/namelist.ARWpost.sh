#!/bin/bash

# Enc: UTF-8
# Last revision: 2022-03-13

#
# namelist.ARWpost.sh
#
# Use
# ./namelist.ARWpost.sh DIR_WRF_OUTPUT DOMAIN TYPE_OUTPUT_LEVEL INTERVAL MERCATOR_DEFS START_YEAR-START_MONTH-START_DAY-START_HOUR  END_YEAR-END_MONTH-END_DAY-END_HOUR

#  Parameter:
#    $1 : dir of output data to process: $DIR_WRF_OUTPUT/wrfout_d0*
#    $2 : domain to process: D1 | D2 | D3
#    $3 : type of output to INTERPOLATE: TYPE_OUTPUT_LEVEL=SIG|PRES|ALT
#    $4 : interval (in seconds) between plots
#    $5 : mercator_defs: .True. or .False.
#    $6 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $7 : date-time of ending of plotting (final date-time): 2021-12-02-00

#  20200613: change in wrf.exe output filename:
#           wrfout_d01_2022-02-22_00:00:00 wrfout_d01_2022-02-22_00.nc   

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
#                  Verifying the parameters
#
###################################################################


# 
# 20220210: executed in the main script
#if [ -e ./namelist.ARWpost ]; then
#   rm ./namelist.ARWpost
# fi

f_debug $0 '$_1' $1
f_debug $0 '$_2' $2
f_debug $0 '$_3' $3
f_debug $0 '$_4' $4
f_debug $0 '$_5' $5
f_debug $0 '$_6' $6
f_debug $0 '$_7' $7


DIR_WRF_OUTPUT=$1
DOMAIN=$2
TYPE_OUTPUT_LEVEL=$3

# Valores do parâmetro (variável INTERP_METHOD):

# Valores do INTERP_METHOD :0 - sigma levels,  -1 - code defined "nice" height levels,  1 - user defined height or pressure levels
# INTERP_METHOD=0 (valor padrão)
# Em 26set13: foi acrescido o INTERP_LEVELS=$NUM_NIVEIS_ETA_SIGMA, sendo o NUM_NIVEIS_ETA_SIGMA setado no script run principal.
#
#  INTERP_METHOD: 0 | -1 | 1 (vide below)

if [ x$TYPE_OUTPUT_LEVEL == x"SIG" ]; then
   echo -e "\n\nOs mesmos niveis de rodada do modelo (eta_levels)"
   INTERP_METHOD=0
   INTERP_LEVELS="0"
   # INTERP_LEVELS=$NUM_NIVEIS_ETA_SIGMA
elif [ x"$TYPE_OUTPUT_LEVEL" == x"PRES" ]; then
   echo -e "\n\nSaida dos plots em niveis de pressao (mesmos do MM5)"
   INTERP_METHOD=1
   INTERP_LEVELS=1000.,950.,925.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
elif [ x"$TYPE_OUTPUT_LEVEL" == x"ALT" ]; then
   echo -e "\n\nSaida dos plots em altura (km)"
   INTERP_METHOD="-1"
   INTERP_LEVELS=0.02,0.05,0.10,0.15,0.25,0.40,0.60,0.90,1.20,1.50,2.00,3.00,4.00,5.00,7.00,9.00,10.0,11.0,12.0,15.0,
fi

# Em 19jul10: INTERVAL: Intervalo entre os dados a processar 10800s=3 horas 
#             O parâmetro interval_seconds não deve estar entre aspas.
# INTERVAL=10800
INTERVAL=$4

# Em 21jul10: para que gere os dados diagnósticos deve-se fazer o seguinte:
#   plot = 'all' ==>  plot = 'all_list'

# Obs.: deve-se terminar com / para que não interprete como nome de arquivo.
#  output_root_name = '$CAMINHO/'

[ -z $5 ] && exit 1
MERCATOR_DEFS=$5

# Start date-time simulation
# Test for correct parameter
[ -z $6 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $6 > /dev/null
[[ $? -ne 0 ]] && exit 1

START_YEAR=$(cut -d- -f 1 <<<  $6)
START_MONTH=$(cut -d- -f 2 <<<  $6)
START_DAY=$(cut -d- -f 3 <<<  $6)
START_HOUR=$(cut -d- -f 4 <<<  $6)


# Ending date-time simulation
# Test for correct parameter
[ -z $7 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $7 > /dev/null
[[ $? -ne 0 ]] && exit 1

END_YEAR=$(cut -d- -f 1 <<<  $7)
END_MONTH=$(cut -d- -f 2 <<<  $7)
END_DAY=$(cut -d- -f 3 <<<  $7)
END_HOUR=$(cut -d- -f 4 <<<  $7)


###################################################################
#
#        Creating the bin/ARWpost/namelist.ARWpost
#
###################################################################


cat << End_Of_Namelist > ./namelist.ARWpost
&datetime
 start_date = '${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00',
 end_date   = '${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00',
 interval_seconds = $INTERVAL,
 tacc = 0,
 debug_level = 30,
/

&io
  input_root_name = '${DIR_WRF_OUTPUT}/wrfout_d0${DOMAIN}_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}.nc',
  output_root_name = '${DIR_WRF_OUTPUT}/wrfout_d0${DOMAIN}_${TYPE_OUTPUT_LEVEL}_${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}',
  plot = 'all',
! plot = 'all_list'
! plot = 'all_list_file'
! plot = 'list'
! plot = 'file'
! Below is a list of all available diagnostics
! fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'
 fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,clfr',
 fields_file = 'arwpost_fields_file.txt',
 output_type = 'grads',
 mercator_defs = $MERCATOR_DEFS,
 split_output = .False.,
 frames_per_outfile = 100,
/

&interp
 interp_method = $INTERP_METHOD,
 interp_levels = $INTERP_LEVELS,
/
extrapolate = .False.

End_Of_Namelist


