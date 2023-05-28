#!/bin/bash -f
#
#  Encoding: UTF-8
#  Last revision: 2023-02-24
#  
#  namelist.input.wrf.sh : build the Namelist for WRF program.
#    Used by:  WRF/run/real.exe and WRF/run/wrf.exe


#  Input Parameters:
#    $1 : number of NUM_METGRID_LEVELS
#    $2 : date-time of start of simulation: 2021-12-01-00 (00UTC)
#    $3 : date-time of ending of simulation (final date-time): 2021-12-02-00
#    $4 : run time length of forecast (in hours): 24, 48, 72
#    $5 : temporal interval in which the input data are available (time step of global data, in hours): 1 (cptec-wrf), 3 (gfs), 6 (gfs)
#  Output:
#    $WRF_PATH/run/namelist.input -> $WRF_PATH/test/em_real/namelist.input

#  ---  Errors and questions about running real.exe and wrf.exe
# 20220203: inclusion of ending data because this error in the real.exe
#           program.
#  run_days/run_hours takes precedence over the end times.
#  end_year                            = $FIM_ANO, $FIM_ANO, $FIM_ANO,
#  end_month                           = $FIM_MES, $FIM_MES, $FIM_MES,
#  end_day                             = $FIM_DIA, $FIM_DIA, $FIM_DIA,
#  end_hour                            = $FIM_HORA, $FIM_HORA, $FIM_HORA,
#  end_minute                          = 00,   00,   00,
#  end_second                          = 00,   00,   00,

# -----------------------------------

#  Changelog:
#  07jul10: arquivo criado para facilitar o processamento automatico dos scripts.
#  29jul10: recebe como parâmetro o valor de NUM_METGRID_LEVELS.
#  18jul10: teste do número de níveis nos dados de entrada (num_metgrid_levels). Padrão é 27.
#             Mas será usado o utilitário ncdump (do pacote ncdf) para obter essa informação.
#  29jul10: agora essa informação será recuperada no script runwrf.sh e passada como parâmetro.
#  20JUL10: Foi estabelecido uso de somente 31 níveis para o modelo,
#             conforme divisão dos níveis sigma no modelo MM5. A finalidade, por enquanto,
#             é ter um mesmo padrão de comparação para teste de resultados.
#             MKX=número de níveis sigma.   
#     ERRO:  First eta level should be 1.0 and the last 0.0 in namelist
#  26set13: O estabelecimento de quais niveis ETA e onde sera setado devera ser incluido no script
#             principal.
#  26set13: O estabelecimento de quais niveis ETA e onde sera setado devera ser incluido no script
#             principal. Removed from this script (MKX contains the number of VERTICAL SIGMA LEVELS)
#      if [ $MKX -eq 31 ]; then  ETA_LEVELS=1.000,0.997,0.995,0.990,0.985,0.980,0.975,0.970,0.965,0.955,0.945,0.920, 0.890,0.850,0.800,0.750,0.700,0.650,0.600,0.550,0.500,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.100,0.050,0.000,

#  23dez21: this script will be replicated to all configurations/domains to allow specialized local change in some other parameters.
#  03jan22: the number of vertical levels (e_vert) will com from config param file. And the variable is now _E_VERT (instead of MKX)

#   20211012: start reviewing to follow the WRF version 4.3
#   20220210: the model-wrf is running (not all tested)
#   20230222: modification of values (old values: dzstretch_s= 1.3,dzstretch_u=1.1)

###################################################################
# The namelist &diags requires
# p_lev_diags requires auxhist23 file information
#    auxhist23_interval (max_dom) and io_form_auxhist23
7
# &diags
# !  diag_nwp2 = 1
# p_lev_diags                     = 1,
# num_press_levels                = 5,

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



# 20220103: the number of vertical levels that METGRID will put in the files (met_em.d0x..)
# Test if ${1} is only number
[[ ${1} =~ ^[0-9][0-9]$ ]] || exit 1 
NUM_METGRID_LEVELS=$1

## DEBUG
f_debug $0 NUM_METGRID_LEVELS $NUM_METGRID_LEVELS

# Date-time of start of simulation (initialization start date-time). Test for correct parameter
# START_DATE_TIME variable used to adjust the filename for some output diagnostics
[ -z ${2} ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  ${2} > /dev/null
[[ $? -ne 0 ]] && exit 1
START_YEAR=$(cut -d- -f 1 <<<  ${2})
START_MONTH=$(cut -d- -f 2 <<<  ${2})
START_DAY=$(cut -d- -f 3 <<<  ${2})
START_HOUR=$(cut -d- -f 4 <<<  ${2})
START_DATE_TIME=${START_YEAR}-${START_MONTH}-${START_DAY}_${START_HOUR}



## DEBUG
f_debug $0 START_DATE_TIME $START_DATE_TIME

# Ending date-time simulation
# Test for correct parameter
[ -z ${3} ] && exit 1
grep -E '^20[1-2][0-9]-[0-1][0-9]-[0-3][0-9]-(00|06|12|18)' <<<  ${3} > /dev/null
[[ $? -ne 0 ]] && exit 1
END_DATE_TIME=${3}
END_YEAR=$(cut -d- -f 1 <<<  ${END_DATE_TIME})
END_MONTH=$(cut -d- -f 2 <<<  ${END_DATE_TIME})
END_DAY=$(cut -d- -f 3 <<<  ${END_DATE_TIME})
END_HOUR=$(cut -d- -f 4 <<<  ${END_DATE_TIME})

## DEBUG
f_debug $0 END_DATE_TIME $END_DATE_TIME

# Run time length of the forecast. Test for correct parameter
[ -z ${4} ] && exit 1
case ${4} in
    24|48|72) RUN_TIME_HOURS=${4};;
    *) exit 2;;
esac

## DEBUG
f_debug $0 RUN_TIME_HOURS $RUN_TIME_HOURS

# Temporal interval of global data (time resolution), in SECONDS
# Test for correct parameter
declare -i GLOBAL_DATE_TIME_INTERVAL=0
[ -z ${5} ] && exit 1
case ${5} in
    1|3|6) GLOBAL_DATE_TIME_INTERVAL=$(( $GLOBAL_DATE_TIME_INTERVAL + ${5}*3600 )) ;;
    *) exit 1 ;;
esac


## DEBUG
f_debug $0 "GLOBAL_DATE_TIME_INTERVAL (in seconds)" $GLOBAL_DATE_TIME_INTERVAL


###################################################################
#
#                  Creating the bin/WRF/run/namelist.input
#
###################################################################


if test -e ./namelist.input; then
   rm ./namelist.input
fi

cat << End_Of_Namelist > ./namelist.input
 &time_control
 run_days                            = 0,
 run_hours                           = ${RUN_TIME_HOURS},
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${START_YEAR}, ${START_YEAR}, ${START_YEAR},
 start_month                         = ${START_MONTH}, ${START_MONTH}, ${START_MONTH},
 start_day                           = ${START_DAY}, ${START_DAY}, ${START_DAY},
 start_hour                          = ${START_HOUR}, ${START_HOUR}, ${START_HOUR},
 start_minute                        = 00,   00,   00,
 start_second                        = 00,   00,   00, 
 end_year                            = ${END_YEAR}, ${END_YEAR}, ${END_YEAR},
 end_month                           = ${END_MONTH}, ${END_MONTH}, ${END_MONTH},
 end_day                             = ${END_DAY}, ${END_DAY}, ${END_DAY},
 end_hour                            = ${END_HOUR}, ${END_HOUR}, ${END_HOUR},
 end_minute                          = 00,   00,   00,
 end_second                          = 00,   00,   00,
 interval_seconds                    = ${GLOBAL_DATE_TIME_INTERVAL},
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = ${_T_INTERVAL_OUTPUT_1},  ${_T_INTERVAL_OUTPUT_2},   ${_T_INTERVAL_OUTPUT_3},
 frames_per_outfile                  = 1000, 1000, 1000,
 restart                             = .false.,
 restart_interval                    = 5000,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 !  Prints debug info:0(default),50,100,200,300 values give increasing prints
 debug_level                         = 0, 
 /
 

 &domains
 time_step                           = ${_WRF_TIME_STEP},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${_MAX_DOMAIN},
 e_we                                = ${_E_WE_1},   ${_E_WE_2},   ${_E_WE_3},
 e_sn                                = ${_E_SN_1},   ${_E_SN_2},   ${_E_SN_3},
 e_vert                              = ${_E_VERT},   ${_E_VERT},   ${_E_VERT},
 p_top_requested                     = 5000,
 num_metgrid_levels                  = ${NUM_METGRID_LEVELS},
 num_metgrid_soil_levels             = 4,
 dx                                  = ${_DX_1},
 dy                                  = ${_DY_1},
 grid_id                             = 1,     2,     3,
 parent_id                           = 1, ${_PARENT_ID_2},        ${_PARENT_ID_3},
 i_parent_start                      = 1, ${_I_PARENT_START_2},   ${_I_PARENT_START_3},
 j_parent_start                      = 1, ${_J_PARENT_START_2},   ${_J_PARENT_START_3},
 parent_grid_ratio                   = 1, ${_PARENT_RATIO_2},     ${_PARENT_RATIO_3},
 parent_time_step_ratio              = 1,     3,     3,
 feedback                            = ${_FEEDBACK},
! Smooth option: 0 (no smoothing) a 2 (smoothing-desmoothing (default))
 smooth_option                       = ${_SMOOTH},   !  Default = 2
 max_dz                              = 1000.,
 auto_levels_opt                     = 2,
 dzbot                               = 50.,
 dzstretch_s                         = 1.2,
 dzstretch_u                         = 1.06,

 /

 &physics
 mp_physics                          = ${_MP_PHYSICS_1},  ${_MP_PHYSICS_2},  ${_MP_PHYSICS_3},
 ra_lw_physics                       = 4,     4,     4,
 ra_sw_physics                       = 4,     4,     4,
 radt                                = 15,    15,    15,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = ${_BL_PBL_PHYSICS_1}, ${_BL_PBL_PHYSICS_2}, ${_BL_PBL_PHYSICS_3},
 num_soil_layers                     = 4, 
 bldt                                = 0,     0,     0,
 cu_physics                          = ${_CU_PHYSICS_1}, ${_CU_PHYSICS_1}, ${_CU_PHYSICS_1},
 cudt                                = 5,     5,     5,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 3,
 num_land_cat                        = 21,
 sf_urban_physics                    = 0,     0,     0,
 sf_ocean_physics                    = 0,
 sst_update                          = 0,
 !traj_opt                            = 0,
 !num_traj                            = 0,
 !mfshconv                            = 0, 0, 0,
 !icloud_bl                           = 0, 0, 0,
 o3input                             = 0,
 aer_opt                             = 0, 
 /


 &dynamics
 w_damping                           = 1,
 diff_opt                            = 1,    1,      1, 
 km_opt                              = 4,    4,      4, 
 damp_opt                            = 3, 
 diff_6th_opt                        = 0,    0,      0,
 diff_6th_factor                     = 0.12,  0.12,   0.12,
 base_temp                           = 290.,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2,
! damp_opt                            = 0,    0,     0,
 khdif                               = 0,    0,     0,
 kvdif                               = 0,    0,     0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,    1,     1,     
 scalar_adv_opt                      = 1,    1,     1,     
 /

 &fdda
 grid_fdda                           =  0,    0,     0,
 gfdda_inname                        = "wrffdda_d<domain>",
 gfdda_end_h                         =  0,    0,    0,
 gfdda_interval_m                    =  0,    0,    0,
 grid_sfdda                          =  0,    0,     0,
 sgfdda_inname                       = "wrfsfdda_d<domain>",
 sgfdda_end_h                        =  0,    0,    0,
 sgfdda_interval_m                   =  0,    0,    0,
 io_form_sgfdda                      =  2,
 pxlsm_soil_nudge                    =  0,    0,    0,
 obs_nudge_opt                       =  0,    0,    0,
 max_obs                             = 150000,
 fdda_start                          = 0.,    0.,   0.,
 fdda_end                            = 0.,    0.,   0.,
/
 
 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4, 
 specified                           = .true., .false., .false.,
 nested                              = .false., .true., .true.,
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /

 /
 

End_Of_Namelist

unset GLOBAL_DATE_TIME_INTERVAL
unset RUN_TIME_HOURS
unset START_DATE_TIME START_YEAR START_MONTH START_DAY START_HOUR
unset NUM_METGRID_LEVELS
