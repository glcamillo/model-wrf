#!/bin/bash 
#
#  Codificacao: UTF-8
#
# ungrib.sh: script que servira para ler os dados GRIB2 para
#	entrada no modelo, pois o GRIB1 sera descontinuado
#	em 31jan08. A base do script e o programa ungrib
#	que pertence ao modelo WRF, mais precisamente ao WPS,
#	que trata da ingestao e conversao de dados.
#
# Versao: 0.1 (Dezembro2007/Janeiro2008)
#
# 30dez07: criacao deste script com o programa ungrib, que
#          foi compilado num Fedora 8. O ungrib faz parte
#          da versao WPS, 2.2.1 (WRF Preprocessing System).
#          ungrib.exe compilado com INTEL FORTRAN COMPILER
#          Version 10.0

cd $WORK_PATH/WPS/ungrib

# Apagaremos os arquivos GRIBFILE.
rm -f GRIBFILE*

#################################################################
# Link (with supplied script link_grib.csh) the input GRIB data #
#################################################################
z=z
Z=Z
./link_grib.csh $USER_PATH/gfs-data-$DATA$HORA_INICIAL$Z/gfs.t$HORA_INICIAL$z.pgrb2f*

#################################################################
# Link the "Vtable" (a table which tells WRF how to handle your #
#              GRIB files, in this case GFS data)               #
#################################################################
rm -f Vtable
ln -s Variable_Tables/Vtable.GFS Vtable

##########################################
########   Build the Namelist  ###########
##########################################
TRACO=_
if [ -e namelist.wps ]; then
   rm namelist.wps
fi

cat << End_Of_Namelist > namelist.wps

&share
 wrf_core = 'ARW',
 max_dom = 2,
 start_date = '$INICIO_ANO-$INICIO_MES-$INICIO_DIA$TRACO$INICIO_HORA:00:00','2006-08-16_12:00:00',
 end_date   = '$FIM_ANO-$FIM_MES-$FIM_DIA$TRACO$FIM_HORA:00:00','2006-08-16_12:00:00',
 interval_seconds = $INTERVALO
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,
 parent_grid_ratio =   1,   3,
 i_parent_start    =   1,  31,
 j_parent_start    =   1,  17,
 e_we              =  74, 112,
 e_sn              =  61,  97,
 geog_data_res     = '10m','2m',
 dx = 30000,
 dy = 30000,
 map_proj = 'lambert',
 ref_lat   =  34.83,
 ref_lon   = -81.03,
 truelat1  =  30.0,
 truelat2  =  60.0,
 stand_lon = -98.0,
 geog_data_path = '/mmm/users/wrfhelp/WPS_GEOG'
/

&ungrib
 out_format = 'MM5',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2, 
/

&mod_levs
 press_pa = 201300 , 200100 , 100000 , 
             95000 ,  90000 , 
             85000 ,  80000 , 
             75000 ,  70000 , 
             65000 ,  60000 , 
             55000 ,  50000 , 
             45000 ,  40000 , 
             35000 ,  30000 , 
             25000 ,  20000 , 
             15000 ,  10000 , 
              5000 ,   1000
/
End_Of_Namelist

##########################################
#####   Roda o programa ungrib ###########
##########################################
# Em 30dez07: ungrib.exe -> INTEL COMPILER Version 10.0
./ungrib.exe > ungrib-$DATA$HORA_INICIAL.log


