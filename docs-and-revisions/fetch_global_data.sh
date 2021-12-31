#!/bin/bash -x
#
#  Codificação: UTF-8
#  Last revision: 2021-12-23
#  
#  fetch_global_data.sh: fetch the files resulted from execution of global model (GFS, etc)
#
#  Parameter:
#    $1 : directory to download
#    $2 : date-time of initialization: 2021120100 (2021-12-01 00UTC)
#    $3 : time of forecast (in hours): 24, 48, 72
#    $4 : GLOBAL_DATA_TIME_INTERVAL time step for integration in integer seconds
#    $4 : time 
#    $3 : a resolucao espacial dos dados globais e logo 
#       a extensao do arquivo de dados: 1p00,0p50,0p25
# RES_G_NCEP=$1
# 20211223: the parameter will contain the PATH and the FILENAME
#           of the 
#  Return:
#    0: sucess
#    1: error: in the initial phase: setting dir and space


# TODO TODO
# Check the parameters (all needed)
# test $2 is digit 10*[:digit:] or 10*[0-9]
# if [ $2 
DATE_TIME_INIT=$2
FORECAST_TIME=$3
# WRF_TIME_STEP=$4
GLOBAL_DATA_TIME_INTERVAL=$4

DATE_TIME_INIT=$2
INIT_YEAR=$(echo $DATE_TIME_INIT | cut -c 1-4)
INIT_MONTH=$(echo $DATE_TIME_INIT | cut -c 5-6)
INIT_DAY=$(echo $DATE_TIME_INIT | cut -c 7-8)
INIT_HOUR=$(echo $DATE_TIME_INIT | cut -c 9-10)
INIT_DATE_TIME=$(echo $DATE_TIME_INIT | cut -c 1-8)


# Definição da função que cria o arquivo para ser usado pelo ftp.
function criar_ftpgfs  {
	echo "user anonymous user@icea.gov.br"             > ftpgfs
	echo "bin"                                          >> ftpgfs
	echo "hash"                                         >> ftpgfs
	echo "cd "$FTP_DIR                                  >> ftpgfs
}

# Definição da busca dos dados 
# FTP_DIR=/pub/data/nccf/com/gfs/prod/gfs.$DATA/
# Em 31out05: a partir de 13out e 08nov05, exclusivamente,
#             os dados gfs deverão ser acessados através do
#             seguinte diretório:
FTP_DIR=/pub/data/nccf/com/gfs/prod/gfs.$INIT_DATE_TIME/$HORA_INICIAL/
FTP_DIR_SST=/pub/data/nccf/com/gfs/prod/sst.$DATA_SST/
FTP_SITE=ftpprd.ncep.noaa.gov
#FTP_SITE=140.90.33.31
# export ARQUIVO_SST=sst2dvar_grb_0.5

# Cria o diretório de backup dos dados GFS (buscados do NCEP)
if [ ! -d $1 ]; then
	mkdir -p $1
fi

cd $1

#    BUSCA DOS DADOS GLOBAIS PARA INICIALIZAÇÃO E FRONTEIRA
#-------------------------------------------------------------------
echo
echo "Obtendo dados GFS (GRIB2) de $FTP_SITE."
echo "  Diretorio: $FTP_DIR"
echo "  Data hora: $DATA $HORA"
echo

#-------------------------------------------------------------------
#    Download dos dados GFS do site ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20050101
# gfs.t18z.pgrbanl
#-------------------------------------------------------------------

# Em 03jun12: foi acrescido um teste antes do incremento.

# Em 25out2020: ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201025/12/gfs.t12z.pgrb2.0p25.f072
#               337123 KB 


if [ $1 != $(pwd) ]; then 
  echo " Estamos no diretório errado. Saindo ... ";
  exit 1;
fi


# 20211223: testing for free disk space
#DISK_FREE_SPACE=$(df -h | grep )
#if [ $(DISK_FREE_SPACE) -gt DIR_DADOS_GFS != `pwd` ]; then 
#  echo " Estamos no diretório errado. Saindo ... ";
#  exit 1;
#fi


if [ x$3 = x"gfs1p00" ]; then 
    RES_G_NCEP="1p00"
elif [ x$3 = x"gfs0p50" ]; then  
    RES_G_NCEP="0p50"
elif [ x$3 = x"gfs0p25" ]; then
    RES_G_NCEP="gfs0p25"
fi
	  

# 20211223: GFS data from NCEP
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t"$HORA_INICIAL"z.pgrb2.1p00.f$HORA_PREVISAO
# ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201025/12/gfs.t12z.pgrb2.1p00.f000

# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t12z.pgrb2.1p00.f000
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20210308/12/gfs.t12z.pgrb2.1p00.f000

if [ x$3 = x"gfs1p00" ] -o [ x$3 = x"gfs0p50" ] -o [ x$3 = x"gfs0p25" ]; then
	COPIADOS=1
	while [ $COPIADOS -eq 1 ]
	do 
		HORA_PREVISAO_NUM=0
		while [ "$HORA_PREVISAO_NUM" -le "$FORECAST_TIME" ]
		do
            # printf %03d 012 : o 012 é interpretado como OCTAL		
			HORA_PREVISAO=$(printf %03d "$HORA_PREVISAO_NUM")
			if [ -e "$1/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO" ]; then
				if [ `du -ks "$1/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO" | cut -f1` -gt 25000 ]; then
					echo "Arquivo $D1/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO copiado."
					COPIADOS=0
				fi
			else
				echo
				COPIADOS=1
				echo "Arquivo $1/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO NÂO COPIADO."
				# wget -c --passive-ftp ftp://$FTP_SITE$FTP_DIR/gfs.t"$HORA_INICIAL"z.pgrb2."RES_G_NCEP".f$HORA_PREVISAO
				wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$INIT_DATE_TIME/$HORA_INICIAL/atmos/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO
			fi
			# Incrementa somente se tiver sido copiado.
			if [ $COPIADOS -eq 0 ] ; then 
			    echo "Incremento: $GLOBAL_DATA_TIME_INTERVAL"
			  HORA_PREVISAO_NUM=$(expr $HORA_PREVISAO_NUM \+ $GLOBAL_DATA_TIME_INTERVAL)
			fi
		done
	done
fi



# 20211223: WRF data from CPTEC
# http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/2021/12/16/00/
# http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/2021/12/16/00/WRF_cpt_05KM_2021121600_2021121601.grib2

if [ x$3 = x"cptec_wrf_5km" ]; then
	COPIADOS=1
	while [ $COPIADOS -eq 1 ]
	do 
		HORA_PREVISAO_NUM=0
		while [ "$HORA_PREVISAO_NUM" -le "$FORECAST_TIME" ]
		do
            # printf %03d 012 : o 012 é interpretado como OCTAL		
			TIME_FORECAST=$(printf %03d "$(HORA_PREVISAO_NUM)")
			if [ -e "$1/WRF_cpt_05KM_${DATE_TIME_INIT}_${INIT_YEAR}${INIT_MONTH}${INIT_DAY}${TIME_FORECAST}.grib2" ]; then
				if [ $(du -ks "$1/WRF_cpt_05KM_${DATE_TIME_INIT}_${INIT_YEAR}${INIT_MONTH}${INIT_DAY}${TIME_FORECAST}.grib2" | cut -f1) -gt 25000 ]; then
				
					echo "Arquivo $1/WRF_cpt_05KM_${DATE_TIME_INIT}_${INIT_YEAR}${INIT_MONTH}${INIT_DAY}${TIME_FORECAST}.grib2."
					COPIADOS=0
				fi
			else
				echo
				COPIADOS=1
				echo "Arquivo $1/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f${TIME_FORECAST} NÂO COPIADO."
				wget -c http://ftp.cptec.inpe.br/modelos/tempo/WRF/ams_05km/brutos/${INIT_YEAR}/${INIT_MONTH}/${INIT_DAY}/${INIT_HOUR}/WRF_cpt_05KM_${DATE_TIME_INIT}_${INIT_YEAR}${INIT_MONTH}${INIT_DAY}${TIME_FORECAST}.grib2
			fi
			# Incrementa somente se tiver sido copiado.
			if [ $COPIADOS -eq 0 ] ; then 
			    echo "Incremento: ${GLOBAL_DATA_TIME_INTERVAL}"
			  HORA_PREVISAO_NUM=$(expr ${HORA_PREVISAO_NUM} \+ ${GLOBAL_DATA_TIME_INTERVAL})
			fi
		done
	done
fi


