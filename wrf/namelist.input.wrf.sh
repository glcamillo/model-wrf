#!/bin/bash -f
#  set echo
#
# Codif: UTF-8
#
#  namelist.input.wrf.sh : cria o Namelist para o WRF ($WRF_PATH//test/em_real/namelist.input)
#   07jul10: arquivo criado para facilitar o processamento automatico dos scripts.Cap Gerson. 
#   29jul10: recebe como parâmetro o valor de NUM_METGRID_LEVELS.
# Em 26set13: O estabelecimento de quais niveis ETA e onde sera setado devera ser incluido no script
#             principal.

#  Build the Namelist
#

# SUBLINHADO=_     # O bash não substitui variáveis quando na seguinte situação: _$VAR.

# Em 18jul10: teste do número de níveis nos dados de entrada (num_metgrid_levels). Padrão é 27.
#             Mas será usado o utilitário ncdump (do pacote ncdf) para obter essa informação.
# Em 29jul10: agora essa informação será recuperada no script runwrf.sh e passada como parâmetro.
NUM_METGRID_LEVELS=$1
ETA_LEVELS=$NUM_NIVEIS_ETA_SIGMA

if test -e ./namelist.input; then
   rm ./namelist.input
fi

# Em 20JUL10: Foi estabelecido uso de somente 31 níveis para o modelo,
#             conforme divisão dos níveis sigma no modelo MM5. A finalidade, por enquanto,
#             é ter um mesmo padrão de comparação para teste de resultados.
#             MKX=número de níveis sigma.   
#     ERRO:  First eta level should be 1.0 and the last 0.0 in namelist

# Em 26set13: O estabelecimento de quais niveis ETA e onde sera setado devera ser incluido no script
#             principal.
# if [ $MKX -eq 31 ]; then
#  ETA_LEVELS=1.000,0.997,0.995,0.990,0.985,0.980,0.975,0.970,0.965,0.955,0.945,0.920,0.890,0.850,0.800,0.750,0.700,0.650,0.600,0.550,0.500,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.100,0.050,0.000,
# ETA_LEVELS=1.000,0.997,0.995,0.990,0.985,0.980,0.975,0.970,0.965,0.955,0.945,0.930,0.910,0.890,0.850,0.800,0.750,0.700,0.650,0.600,0.550,0.500,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.050,0.000,
#fi


echo $ETA_LEVELS

cat << End_Of_Namelist > ./namelist.input


 &time_control
 run_days                            = 0,
 run_hours                           = $_TIMAX,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $INICIO_ANO, $INICIO_ANO, $INICIO_ANO,
 start_month                         = $INICIO_MES,   $INICIO_MES,   $INICIO_MES,
 start_day                           = $INICIO_DIA,   $INICIO_DIA,   $INICIO_DIA,
 start_hour                          = $INICIO_HORA,   $INICIO_HORA,   $INICIO_HORA,
 start_minute                        = 00,   00,   00,
 start_second                        = 00,   00,   00,
 end_year                            = $FIM_ANO, $FIM_ANO, $FIM_ANO,
 end_month                           = $FIM_MES,   $FIM_MES,   $FIM_MES,
 end_day                             = $FIM_DIA,   $FIM_DIA,   $FIM_DIA,
 end_hour                            = $FIM_HORA,   $FIM_HORA,   $FIM_HORA,
 end_minute                          = 00,   00,   00,
 end_second                          = 00,   00,   00,
 interval_seconds                    = $INTERVALO
 input_from_file                     = .true.,.true.,.true.,
 history_interval                    = 180,  60,   60,
 frames_per_outfile                  = 1000, 1000, 1000,
 restart                             = .false.,
 restart_interval                    = 5000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 /

 &domains
 time_step                           = $_TISTEP,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = $_MAXNES,
 e_we                                = $_E_WE_1,    $_E_WE_2,   $_E_WE_3,
 e_sn                                = $_E_SN_1,    $_E_SN_2,   $_E_SN_3,
 e_vert                              = $MKX,    $MKX,    $MKX,
 eta_levels                          = $ETA_LEVELS
 p_top_requested                     = 10000,
 num_metgrid_levels                  = $NUM_METGRID_LEVELS,
 num_metgrid_soil_levels             = 4,
 dx                                  = $_DX_1, $_DX_2,  $_DX_3,
 dy                                  = $_DY_1, $_DY_2,  $_DY_3,
 grid_id                             = 1,     2,     3,
 parent_id                           = 1, $_PARENT_ID_2, $_PARENT_ID_3,
 i_parent_start                      = 1, $_I_PARENT_START_2,       $_I_PARENT_START_3,
 j_parent_start                      = 1, $_J_PARENT_START_2,       $_J_PARENT_START_3,
 parent_grid_ratio                   = 1,     3,     3,
 parent_time_step_ratio              = 1,     3,     3,
 feedback                            = 1,
 smooth_option                       = 0
 /

 &physics
 mp_physics                          = 3,     3,     3,
 ra_lw_physics                       = 1,     1,     1,
 ra_sw_physics                       = 1,     1,     1,
 radt                                = 30,    30,    30,
 sf_sfclay_physics                   = 1,     1,     1,
 sf_surface_physics                  = 2,     2,     2,
 bl_pbl_physics                      = 1,     1,     1,
 bldt                                = 0,     0,     0,
 cu_physics                          = 1,     1,     0,
 cudt                                = 5,     5,     5,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 sf_urban_physics                    = 0,     0,     0,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 /

 &fdda
 /

 &dynamics
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 0,      0,      0,
 diff_6th_factor                     = 0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 0,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.2,    0.2,    0.2
 khdif                               = 0,      0,      0,
 kvdif                               = 0,      0,      0,
 non_hydrostatic                     = .true., .true., .true.,
 moist_adv_opt                       = 1,      1,      1,     
 scalar_adv_opt                      = 1,      1,      1,     
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,
 nested                              = .false., .true., .true.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /

End_Of_Namelist
