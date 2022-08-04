#!/bin/bash -x
#
#  Encoding: UTF-8
#  Last revision: 2022-05-18
#  
#  fetch_global_data.sh: fetch the files resulted from execution of global model (GFS, etc)
#
#  Parameter:
#    $1 : directory to download
#    $2 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $3 : run time of forecast (in hours): 24, 48, 72
#    $4 : temporal interval in which the input data are available (time step of global data, in hours): 1 (cptec-wrf), 3 (gfs), 6 (gfs)
#    $5 : gfs1p00 gfs0p50 gfs0p25 cptec_wrf_5km

#   20211012: start reviewing to follow the WRF version 4.3
#   20220210: the model is running now, but there is still more
#             development and testing to go


#  Return:
#    0: sucess
#    1: error: in the initial phase: setting dir and space



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
    [ $DEBUG == 1 ] && echo -e "\033[33;1m DEBUG (${1}):${2}=${3}\033[m \n"
}


###################################################################
#
#              Verifying and copying the parameters
#
###################################################################



## DEBUG
f_debug $0 DIR_WPS_INPUT $1
[ -z ${1} ] && exit 2
# Data dir for INPUT global: if it no exists, then create.
if [ ! -d ${1} ]; then
    mkdir -p ${1}
    [ $? -ne 0 ] && exit 1
fi
# Enter in the data dir
# DIR_WPS_INPUT=DIR_DATA_INPUT/yyyy-mm-dd-HH-[gfs|cptec-wrf]
cd $1 2>/dev/null


# Date-time of start of simulation (initialization start date-time)
# Test for correct parameter
[ -z ${2} ] && exit 2
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  ${2} > /dev/null
[[ $? -ne 0 ]] && exit 2


START_YEAR=$(cut -d- -f 1 <<<  ${2})
START_MONTH=$(cut -d- -f 2 <<<  ${2})
START_DAY=$(cut -d- -f 3 <<<  ${2})
START_HOUR=$(cut -d- -f 4 <<<  ${2})

START_DATE="$START_YEAR""$START_MONTH""$START_DAY"
START_DATE_TIME="$START_YEAR""$START_MONTH""$START_DAY""$START_HOUR"
## DEBUG
f_debug $0 START_DATE_TIME $START_DATE_TIME

# Run time length of the forecast
# Test for correct parameter
[ -z $3 ] && exit 2
case $3 in
    24|48|72) RUN_TIME_HOURS=$3 ;;
    *) exit 2 ;;
esac
## DEBUG
f_debug $0 RUN_TIME_HOURS $RUN_TIME_HOURS


# Temporal interval of global data (time resolution)
# Test for correct parameter
[ -z $4 ] && exit 2
case $4 in
    1|3|6) GLOBAL_DATE_TIME_INTERVAL=$4 ;;
    *) exit 2 ;;
esac
## DEBUG
f_debug $0 GLOBAL_DATE_TIME_INTERVAL $GLOBAL_DATE_TIME_INTERVAL

# Global data source and resolution
# Test for correct parameter
[ -z $5 ] && exit 2
case $5 in
    gfs1p00|gfs0p50|gfs0p25|cptec_wrf_5km) GD_SOURCE=$5 ;;
    *) exit 2 ;;
esac
## DEBUG
f_debug $0 GD_SOURCE $GD_SOURCE




###################################################################
#            Fetch Global Data for Initialization and
#             Lateral and Boundary Conditions (LBC)
#
#  Global Data: GFS from NCEP (NOMADS)
###################################################################


#-------------------------------------------------------------------
if [ $1 != $(pwd) ]; then 
  echo " Estamos no diretório errado. Saindo ... ";
  exit 1;
fi



if [ ${GD_SOURCE} = "gfs0p25" ] || [ ${GD_SOURCE} = "gfs0p50" ] || [ ${GD_SOURCE} = "gfs1p00" ]; then

#-------------------------------------------------------------------
#    Download dos dados GFS do site ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20050101
#-------------------------------------------------------------------
# Em 03jun12: foi acrescido um teste antes do incremento.
# Em 25out2020: ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201025/12/gfs.t12z.pgrb2.0p25.f072
#               337123 KB 

[ ${GD_SOURCE} = "gfs1p00" ] && RES_G_NCEP="1p00" && F_MIN_LENGTH_GD=39000  #40M
[ ${GD_SOURCE} = "gfs0p50" ] && RES_G_NCEP="0p50" && F_MIN_LENGTH_GD=140000 # 140M
[ ${GD_SOURCE} = "gfs0p25" ] && RES_G_NCEP="0p25" && F_MIN_LENGTH_GD=480000 # 480M


# 20211223: GFS data from NCEP
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t"$HORA_INICIAL"z.pgrb2.1p00.f$TIME_FORECAST
# ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201025/12/gfs.t12z.pgrb2.1p00.f000

# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t12z.pgrb2.1p00.f000
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20210308/12/gfs.t12z.pgrb2.1p00.f000


    COPIADOS=1
    while [ $COPIADOS -eq 1 ]
    do 
        NUM_TIME_FORECAST=0
        while [ $NUM_TIME_FORECAST -le $RUN_TIME_HOURS ]
        do
            # printf %03d 012 : o 012 é interpretado como OCTAL		
            TIME_FORECAST=$(printf %03d "$NUM_TIME_FORECAST")
            if [ -e "$1/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}" ]; then
                
                F_LENGTH=$(du -k "$1/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}" | cut -f1 2>/dev/null)
                
                if [ ${F_LENGTH} -gt ${F_MIN_LENGTH_GD} ]; then
                    echo "File COPIED: $1/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST} copiado."
                    COPIADOS=0
                else
                    wget -c -a wget-gfs-t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}.log https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${START_DATE}/${START_HOUR}/atmos/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}
                fi
            else
                echo
                COPIADOS=1
                echo "File NOT copied:  $1/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}"
                wget -c -a wget-gfs-t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}.log https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${START_DATE}/${START_HOUR}/atmos/gfs.t${START_HOUR}z.pgrb2.${RES_G_NCEP}.f${TIME_FORECAST}
            fi
            # Increment only if copied.
            if [ $COPIADOS -eq 0 ] ; then 
                echo "Increment: ${GLOBAL_DATE_TIME_INTERVAL}"
                NUM_TIME_FORECAST=$(( $NUM_TIME_FORECAST + $GLOBAL_DATE_TIME_INTERVAL ))
            fi
        done
    done
fi




###################################################################
#            Fetch Global Data for Initialization and
#             Lateral and Boundary Conditions (LBC)
#
#  Global Data: WRF from CPTEC
#
# 20211223: WRF data from CPTEC
# http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/2021/12/16/00/
# http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/2021/12/16/00/WRF_cpt_05KM_2021121600_2021121601.grib2
#
# http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/2022/01/27/00/
#
# WRF_cpt_05KM_2022012700_2022012700.ctl	2022-01-27 02:36 	7.7K
# WRF_cpt_05KM_2022012700_2022012700.grib2	2022-01-27 02:36 	261M
# WRF_cpt_05KM_2022012700_2022012700.grib2.idx	2022-01-27 02:36 	2.4K
# WRF_cpt_05KM_2022012700_2022012701.ctl	2022-01-27 02:39 	7.7K
# WRF_cpt_05KM_2022012700_2022012701.grib2	2022-01-27 02:39 	340M
#
# WRF_cpt_05KM_2022020600_2022020618.grib2  FORECAST_TIME=2022-02-06 00UTC + 18h => 2022-02-06 18UTC
# WRF_cpt_05KM_2022020600_2022020700.grib2  FORECAST_TIME=2022-02-06 00UTC + 24h => 2022-02-07 00UTC
#
# FORECAST_TIME = END_YEAR END_MONTH END_DAY END_HOUR
###################################################################


# These variables control the forecast end date and time.
#   They are only updated in case of sucessul download (LAST_FILE_COPIED=0)
END_YEAR=$START_YEAR
END_MONTH=$START_MONTH
END_DAY=$START_DAY
END_HOUR=$START_HOUR

if [ ${GD_SOURCE} = "cptec_wrf_5km" ]; then

    F_MIN_LENGTH_GD_00=250000 # 261M
    F_MIN_LENGTH_GD=320000    # 340M,380M,395M,409M(2d),412M(3d)

    # (LAST_FILE_COPIED=0 sucessfully download of last forecast file 
    COPIADOS=1
    while [ $COPIADOS -eq 1 ]
    do 
        # This variable controls the lenght of forecast time
        NUM_TIME_FORECAST=0
        while [ $NUM_TIME_FORECAST -le $RUN_TIME_HOURS ]
        do

          
            # printf %03d 012 : o 012 é interpretado como OCTAL		
            END_HOUR=$(printf %02d $END_HOUR)
            
            if [ -e "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" ]; then
                
                if [ x${END_HOUR} = x"00" ]; then
                    F_LENGTH=$(du -k "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" | cut -f1 2>/dev/null)
                    
                    if [ $F_LENGTH -gt $F_MIN_LENGTH_GD_00 ]; then
                        echo "Arquivo "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" copiado."
                        COPIADOS=0
                    fi
                else
                    F_LENGTH=$(du -k "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" | cut -f1 2>/dev/null)
                    
                    if [ $F_LENGTH -gt $F_MIN_LENGTH_GD ]; then
                        echo "Arquivo "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" copiado."
                        COPIADOS=0
                    fi
                fi
            else
                COPIADOS=1
                echo "Arquivo "$1/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2" NÂO COPIADO."
                wget -c -a wget-cptec-wrf-${START_DATE_TIME}.log http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/${START_YEAR}/${START_MONTH}/${START_DAY}/${START_HOUR}/WRF_cpt_05KM_${START_DATE_TIME}_${END_YEAR}${END_MONTH}${END_DAY}${END_HOUR}.grib2
            fi
            
            # Increment only if copied.
            if [ $COPIADOS -eq 0 ] ; then 
                echo "Increment in time forecast (hours): $GLOBAL_DATE_TIME_INTERVAL"
                NUM_TIME_FORECAST=$(( $NUM_TIME_FORECAST + $GLOBAL_DATE_TIME_INTERVAL ))
                END_HOUR=$(( 10#$END_HOUR + $GLOBAL_DATE_TIME_INTERVAL ))
                ## DEBUG
                f_debug $0 NUM_TIME_FORECAST $NUM_TIME_FORECAST
                f_debug $0 END_HOUR $END_HOUR
                
                # We reached hour 24: need to update the date for the next day
                if [ $END_HOUR -ge 24 ]; then
                    END_HOUR=$(($END_HOUR - 24))
                    END_DATE=$(date +%Y%m%d  --date="${END_YEAR}${END_MONTH}${END_DAY} +1 day")
                    ## DEBUG
                    f_debug $0 END_HOUR $END_HOUR
                    f_debug $0 END_DATE $END_DATE

                    END_YEAR=$(echo $END_DATE | cut -c 1-4)
                    END_MONTH=$(echo $END_DATE | cut -c 5-6)
                    END_DAY=$(echo $END_DATE | cut -c 7-8)
                    ## DEBUG
                    f_debug $0 END_YEAR-END_MONTH-END_DAY "$END_YEAR-$END_MONTH-$END_DAY"
               fi                  
            fi
        done
    done
fi


exit 0
