#!/bin/bash -x
#
#  Codificação: UTF-8
#  Last revision: 2021-12-23
#  
#  
# Parametro: 
#  $1 : a resolucao espacial dos dados globais e logo 
#       a extensao do arquivo de dados: 1p00,0p50,0p25
# RES_G_NCEP=$1
# 20211223: the parameter will contain the PATH and the FILENAME
#           of the 




cd $WPS_PATH

# Apagaremos os arquivos GRIBFILE.
rm -f GRIBFILE*

#################################################################
# Link (with supplied script link_grib.csh) the input GRIB data #
#################################################################
# Em 25out2020: nome dos arquivos foram alterados
z=z
Z=Z
# Em 21dez2021:
# ./link_grib.csh $DIR_DADOS_GFS/gfs.t$HORA_INICIAL$z.pgrb2f*
# ./link_grib.csh $DIR_DADOS_GFS/gfs.t$HORA_INICIAL$z.pgrb2.1p00.f*
# Em 01jun2021: como podem ser usados diferentes resol de dados globais,
#               o nome do arquivo deverá ser parametrizado pelo: $RES_G_NCEP
./link_grib.csh $DIR_DADOS_GFS/gfs.t$HORA_INICIAL$z.pgrb2."$RES_G_NCEP".f*


#################################################################
# Link the "Vtable" (a table which tells WRF how to handle your #
#              GRIB files, in this case GFS data)               #
#################################################################
rm -f Vtable
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable

# cd $WPS_PATH
# ./link_grib-data.csh .  $DIR_DADOS_GFS $HORA_INICIAL

# if [ -e Vtable ]; then
#   rm -f Vtable
# fi
# ln -s $WPS_PATH/ungrib/Variable_Tables/Vtable.GFS  Vtable
./ungrib.exe >& ungrib-$(DATA)$(HORA_INICIAL).log



# Controla o resultado da execução. Caso haja problemas, o script terminará com
#        código de retorno 1 (erro).
cat ungrib-$(DATA)$(HORA_INICIAL).log | grep -i "Successful completion of ungrib."
retorno=$(echo $?)
if test $retorno -ne 0 ; then
  echo "ERRO no UNGRIB"
  exit 1
fi

exit 0

