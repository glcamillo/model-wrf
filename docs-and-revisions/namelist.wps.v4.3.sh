#!/bin/bash -f
#  set echo
#
#  Codificação: UTF-8
#  Last revision: 2021-12-23
#
#  namelist.wps.sh : cria o Namelist para o WPS (namelist.wps)
#   06jul10: arquivo criado para facilitar o processamento
#          automatico dos scripts. Originalmente nao existia. Cap Gerson. 
#   08jul10: script chamado com dois parametros. Isso facilita o uso pelo MM5 e WRF:
#          $1: WPS,MM5                          $2: $WPS_PATH/data/FILE

### TODO em revisão e atualização para a nova versão
#   12out21: INÍCIO: atualização para a v4.3 do WRF

#  Build the Namelist
#

SUBLINHADO=_     # O bash não substitui variáveis quando na seguinte situação: _$VAR.

# Em 19jun2021: já implementado no script de execução principal
# if test -e ./namelist.wps; then
#   rm ./namelist.wps
# fi

cat << End_Of_Namelist > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $(_MAXNES),
 start_date = '$(INICIO_ANO)-$(INICIO_MES)-$(INICIO_DIA)$(SUBLINHADO)$(INICIO_HORA):00:00', '$(INICIO_ANO)-$(INICIO_MES)-$(INICIO_DIA)$(SUBLINHADO)$(INICIO_HORA):00:00', '$(INICIO_ANO)-$(INICIO_MES)-$(INICIO_DIA)$(SUBLINHADO)$(INICIO_HORA):00:00',
 end_date   = '$FIM_ANO-$FIM_MES-$FIM_DIA$SUBLINHADO$FIM_HORA:00:00', '$FIM_ANO-$FIM_MES-$FIM_DIA$SUBLINHADO$FIM_HORA:00:00', '$FIM_ANO-$FIM_MES-$FIM_DIA$SUBLINHADO$FIM_HORA:00:00',
 interval_seconds = $(INTERVALO),
 io_form_geogrid = 2,
 active_grid = .true.,.true.,
 opt_output_from_geogrid_path = '$(WPS_PATH)/data/',
/

&geogrid
 parent_id         = 1, $(_PARENT_ID_2), $(_PARENT_ID_3),
 parent_grid_ratio = 1, $(_PARENT_RATIO_2), $(_PARENT_RATIO_3),
 i_parent_start    = 1, $(_I_PARENT_START_2),       $(_I_PARENT_START_3),
 j_parent_start    = 1, $(_J_PARENT_START_2),       $(_J_PARENT_START_3),
 e_we              =  $(_E_WE_1), $(_E_WE_2), $(_E_WE_3),
 e_sn              =  $(_E_SN_1), $(_E_SN_2), $(_E_SN_3),
 geog_data_res = 'default','default','default'
 dx = $(_DX_1),
 dy = $(_DY_1),
 map_proj = '$(_MAP_PROJECTION)',
 ref_lat   =  $(_REF_LAT),
 ref_lon   =  $(_REF_LON),
 truelat1  =  $(_TRUELAT1),
 truelat2  =  $(_TRUELAT2),
 stand_lon =  $(_STAND_LON),
 geog_data_path = '$(GEODATA_PATH)'
/

&ungrib
 out_format = '$(1)',
 prefix = '$(2)',
/

&metgrid
 fg_name = '$(WPS_PATH)/data/FILE'
 opt_output_from_metgrid_path = '$(WPS_PATH)/data/',
 io_form_metgrid = 2, 
/


End_Of_Namelist

return 0

#   out_format = 'WPS',
#   prefix = '$WPS_PATH/data/FILE',
