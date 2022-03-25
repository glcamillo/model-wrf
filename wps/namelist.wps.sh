#!/bin/bash -f
#
#  Encoding UTF-8
#  Last revision: 2022-03-14
#
#  namelist.wps.sh : build the Namelist (namelist.wps) for the WPS system.
#          Namelist used by: WPS/geogrid.exe, WPS/ungrib.exe, and WPS/metgrid.exe
#          
#   06jul10: arquivo criado para facilitar o processamento
#          automatico dos scripts. Originalmente nao existia.
#   08jul10: script chamado com dois parametros. Isso facilita o uso pelo MM5 e WRF:
#          $1: WPS,MM5                          $2: $WPS_PATH/data/FILE
#   2021-10-12: start reviewing to follow the WRF version 4.3
#   2022-02-10: the model-wrf is running (not all tested)

#  Input Parameters:
#    $1 : output format: WPS
#    $2 : prefix (path+prefix) of data
#    $3 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $4 : date-time of ending of simulation (final date-time): 2021-12-02-00
#    $5 : temporal interval in which the input data are available (time step of global data, in hours): 1 (for cptec-wrf), 3 (for gfs), 6 (for gfs)
#    $6 : directory of static geographical data (topo, veg, soil use)

#  Output:
#    WPS/namelist.wps



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


# Output format: test for correct parameter
[ $1 != "WPS" ] && exit 1


# Start date-time simulation
# Test for correct parameter
[ -z $3 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $3 > /dev/null
[[ $? -ne 0 ]] && exit 1

START_YEAR=$(cut -d- -f 1 <<<  $3)
START_MONTH=$(cut -d- -f 2 <<<  $3)
START_DAY=$(cut -d- -f 3 <<<  $3)
START_HOUR=$(cut -d- -f 4 <<<  $3)

## DEBUG
f_debug $0 START_DATE_TIME $START_YEAR$START_MONTH$START_DAY$START_HOUR

# Ending date-time simulation
# Test for correct parameter
[ -z $4 ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  $4 > /dev/null
[[ $? -ne 0 ]] && exit 1

END_YEAR=$(cut -d- -f 1 <<<  $4)
END_MONTH=$(cut -d- -f 2 <<<  $4)
END_DAY=$(cut -d- -f 3 <<<  $4)
END_HOUR=$(cut -d- -f 4 <<<  $4)

## DEBUG
f_debug $0 END_DATE_TIME $END_YEAR$END_MONTH$END_DAY$END_HOUR

# Temporal interval of global data (time resolution)
# Test for correct parameter
declare -i GLOBAL_DATE_TIME_INTERVAL=0
[ -z $5 ] && exit 1
case $5 in
    1|3|6) GLOBAL_DATE_TIME_INTERVAL=$(( $GLOBAL_DATE_TIME_INTERVAL + ${5}*3600 )) ;;
    *) exit 2;;
esac

## DEBUG
f_debug $0 GLOBAL_DATE_TIME_INTERVAL $GLOBAL_DATE_TIME_INTERVAL


# Static geographical data
# Test for correct parameter
[ -z $6 ] && exit 1
GEODATA_PATH=$6

## DEBUG
f_debug $0 GEODATA_PATH $GEODATA_PATH



###################################################################
#
#                  Creating the bin/WPS/namelist.wps
#
###################################################################



cat << End_Of_Namelist > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = ${_MAX_DOMAIN},
 start_date = '${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00', '${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00', '${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}:00:00',
 end_date   = '${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00', '${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00', '${END_YEAR}-${END_MONTH}-${END_DAY}_${END_HOUR}:00:00',
 interval_seconds = ${GLOBAL_DATE_TIME_INTERVAL},
 io_form_geogrid = 2,
 active_grid = .true.,.true.,
 opt_output_from_geogrid_path = '${WPS_PATH}/data/',
/

&geogrid
 parent_id         = 1, ${_PARENT_ID_2},      ${_PARENT_ID_3},
 parent_grid_ratio = 1, ${_PARENT_RATIO_2},   ${_PARENT_RATIO_3},
 i_parent_start    = 1, ${_I_PARENT_START_2}, ${_I_PARENT_START_3},
 j_parent_start    = 1, ${_J_PARENT_START_2}, ${_J_PARENT_START_3},
 e_we              =  ${_E_WE_1}, ${_E_WE_2}, ${_E_WE_3},
 e_sn              =  ${_E_SN_1}, ${_E_SN_2}, ${_E_SN_3},
 geog_data_res = 'default','default','default'
 dx = ${_DX_1},
 dy = ${_DY_1},
 map_proj = '${_MAP_PROJECTION}',
 ref_lat   =  ${_REF_LAT},
 ref_lon   =  ${_REF_LON},
 truelat1  =  ${_TRUELAT1},
 truelat2  =  ${_TRUELAT2},
 stand_lon =  ${_STAND_LON},
 geog_data_path = '${GEODATA_PATH}'
/

&ungrib
 out_format = '$1',
 prefix = '$2',
/

&metgrid
 fg_name = '${WPS_PATH}/data/FILE'
 opt_output_from_metgrid_path = '${WPS_PATH}/data/',
 io_form_metgrid = 2, 
/


End_Of_Namelist

unset GLOBAL_DATE_TIME_INTERVAL GEODATA_PATH
unset START_YEAR START_MONTH START_DAY START_HOUR
unset END_YEAR  END_MONTH  END_DAY  END_HOUR

exit 0
