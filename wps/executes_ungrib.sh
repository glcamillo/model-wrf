#!/bin/bash
#
#  Encoding UTF-8
#  Last revision: 2022-03-07
#  
#  wps/executes_ungrib.sh: set variables to the wps/link_grib.csh and
#              calls the program WPS/ungrib.exe
#  
#  Input Parameters:
#  $1 : directory of global data
#       DIR_WPS_INPUT=DIR_DATA_INPUT/yyyy-mm-dd-HH-[gfs|cptec-wrf]
#  $2 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#  $3 : time of initialization: 00 06 12 18
#  $4 : gfs1p00 gfs0p50 gfs0p25 cptec_wrf_5km

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


DIR_WPS_INPUT=$1

## DEBUG
f_debug $0 DIR_WPS_INPUT $1

# Start date-time simulation
# Test for correct parameter

## DEBUG
f_debug $0 START_DATE_TIME $2

[ -z $2 ] && exit 2
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $2 > /dev/null
[[ $? -ne 0 ]] && exit 1

START_DATE_TIME=$2
START_YEAR=$(cut -d- -f 1 <<<  ${START_DATE_TIME})
START_MONTH=$(cut -d- -f 2 <<<  ${START_DATE_TIME})
START_DAY=$(cut -d- -f 3 <<<  ${START_DATE_TIME})
START_HOUR=$(cut -d- -f 4 <<<  ${START_DATE_TIME})


## DEBUG
f_debug $0 INIT_TIME $3
case $3 in
    00|06|12|18) INIT_TIME=$3;;
    *) exit 2;;
esac

## DEBUG
f_debug $0 GD_SOURCE $4
# Global data source and resolution
# Test for correct parameter
[ -z $4 ] && exit 2
case $4 in
    gfs1p00|gfs0p50|gfs0p25|cptec_wrf_5km) GD_SOURCE=$4;;
    *) exit 2;;
esac

## DEBUG
f_debug $0 WPS_PATH $WPS_PATH
cd $WPS_PATH



###################################################################
#
#      Preparing: linking the input data to WPS/data
#      and
#      Calling ungrib.exe
#
###################################################################



# Apagaremos os arquivos GRIBFILE.
rm -f GRIBFILE*

#################################################################
# Link (with supplied script link_grib.csh) the input GRIB data #
#################################################################


if [ ${GD_SOURCE} = "gfs0p25" ] || [ ${GD_SOURCE} = "gfs0p50" ] || [ ${GD_SOURCE} = "gfs1p00" ]; then
    [ ${GD_SOURCE} = "gfs1p00" ] && RES_G_NCEP="1p00"
    [ ${GD_SOURCE} = "gfs0p50" ] && RES_G_NCEP="0p50"
    [ ${GD_SOURCE} = "gfs0p25" ] && RES_G_NCEP="0p25"

    # ./link_grib.csh /home/cirrus/model-data-input-global/2022-01-31-12-gfs/gfs.t12z.pgrb2.1p00.f???
    ./link_grib.csh ${DIR_WPS_INPUT}/gfs.t${INIT_TIME}z.pgrb2.${RES_G_NCEP}.f*

    [[ $? -ne 0 ]] && exit 1
fi

if [ ${GD_SOURCE} = "cptec_wrf_5km" ] ; then

    ./link_grib.csh ${DIR_WPS_INPUT}/WRF_cpt_05KM_${START_YEAR}${START_MONTH}${START_DAY}${START_HOUR}_*.grib2

    [[ $? -ne 0 ]] && exit 1
fi



#################################################################
# Link the "Vtable" (a table which tells WRF how to handle your #
#              GRIB files, in this case GFS data)               #
#################################################################
rm -f Vtable
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable


./ungrib.exe >& ${WPS_PATH}/ungrib-${START_DATE_TIME}.log



# Controla o resultado da execução. Caso haja problemas, o script terminará com
#        código de retorno 1 (erro).
grep -i "Successful completion of ungrib." ${WPS_PATH}/ungrib-${START_DATE_TIME}.log
[[ $? -ne 0 ]] &&  echo "ERROR: problem in (./ungrib.exe >& ${WPS_PATH}/ungrib-${START_DATE_TIME}.log). Exiting." && exit 1

exit 0

