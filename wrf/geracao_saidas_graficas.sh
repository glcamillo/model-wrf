#!/bin/bash
# hash-bang (#!) http://aurelio.net/shell/

#  Em 17jul10
#  geracao_saidas_graficas.sh: responsável pela geração
#           das plotagens gráficas dos dados de pós-processamento.
#           Pode ser usado tanto pelo processamento MM5 quanto WRF.
#  Codificação: UTF-8

DIR_SAIDA_DADOS=$1
CONFIG=$2
NIVEIS=$3
PROJECAO=$4



# ========================================================
#   CONFIGURACAO UM,DOIS,TRES,QUATRO  -  DOMÍNIO 1
# ========================================================
# SM 29 42/053 41
# PK 31 42/052 19
# CX 29 11/051 11
# FI 25 36/054 29

if [ $CONFIG = 'A' ] || [ $CONFIG = 'B' ] || [ $CONFIG = 'C' ] || [ $CONFIG = 'D' ]; then

cd $DIR_SAIDA_DADOS
OUTFILENAME=wrfout_d01_SIG
grads -blc "run plot-sigma-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
if [ ! -d plots ] ; then
    mkdir plots
fi
mv *.png plots

OUTFILENAME=wrfout_d01_PRES
grads -blc "run plot-pressao-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
if [ ! -d plots ] ; then
    mkdir plots
fi
mv *.png plots

# if [ -e $OUTFILENAME.ctl ]; then
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 1 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 5 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 9 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 1 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 5 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 9 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 1 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 5 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 9 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 1 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 5 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 9 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 1 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 5 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 9 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 1 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 5 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 9 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 1 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 5 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 9 FL"
#     if [ $_TIMAX = 2160 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
#     fi
#     if [ $_TIMAX = 2880 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 17 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 17 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 17 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 17 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 17 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 17 FL"
#     fi
#     if [ $_TIMAX = 4320 ]
#     then
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 PA"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 13 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 17 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 21 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -54 25 SM"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 13 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 17 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 21 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -32 -52 25 PK"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 13 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 17 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 21 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -29 -51 25 CX"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 13 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 17 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 21 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -26 -54 25 FI"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 17 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 21 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 25 CT"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 17 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 21 FL"
#     grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 25 FL"
#     fi
#     mv *.png plots
# fi

#######################
### DOMINIO DOIS  #####
#######################
OUTFILENAME=wrfout_d02_SIG
grads -blc "run plot-sigma-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
if [ ! -d plotsd2 ] ; then
  mkdir plotsd2
fi
mv *.png plotsd2
OUTFILENAME=wrfout_d02_PRES
if [ -e $OUTFILENAME ]; then
  grads -blc "run plot-pressao-wrf.gs $OUTFILENAME 1 $MKX $PROJECAO"
  mv *.png plotsd2
fi

#######################
### DOMINIO TRES  #####
#######################

OUTFILENAME=wrfout_d03_SIG
grads -blc "run plot-sigma-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
if [ ! -d plotsd3 ] ; then
  mkdir plotsd3
fi
mv *.png plotsd3


OUTFILENAME=wrfout_d03_ALT
if [ -e $OUTFILENAME ]; then
  grads -blc "run plot-altura-wrf.gs $OUTFILENAME 1 $MKX $PROJECAO"
  mv *.png plotsd3
fi

# Este ..fi.. é do if CONFIG.
fi



# ========================================================
#   CONFIGURACAO   L     -  DOMÍNIO 1
# ========================================================
# SM 29 42/053 41
# PK 31 42/052 19
# CX 29 11/051 11
# FI 25 36/054 29


if [ $CONFIG = 'L' ]; then
    cd $DIR_SAIDA_DADOS
    OUTFILENAME=wrfout_d01_SIG
    grads -blc "run plot-sigma-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
    if [ ! -d plots ] ; then
        mkdir plots
    fi
    mv *.png plots

    OUTFILENAME=wrfout_d01_PRES
    grads -blc "run plot-pressao-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
    if [ ! -d plots ] ; then
        mkdir plots
    fi
    mv *.png plots

    #######################
    ### DOMINIO DOIS  #####
    #######################
    OUTFILENAME=wrfout_d02_SIG
    grads -blc "run plot-sigma-wrf.gs $OUTFILENAME.ctl 1 $MKX $PROJECAO"
    if [ ! -d plotsd2 ] ; then
      mkdir plotsd2
    fi
    mv *.png plotsd2
    OUTFILENAME=wrfout_d02_PRES
    if [ -e $OUTFILENAME ]; then
      grads -blc "run plot-pressao-wrf.gs $OUTFILENAME 1 $MKX $PROJECAO"
      mv *.png plotsd2
    fi

# Este ..fi.. é do if CONFIG.
fi






# 
# grads -blc "run plot.gs $OUTFILENAME.ctl"
# grads -blc "run plot-perfil-vertical-vento.gs $OUTFILENAME.ctl"
# grads -bpc "run plot-meteograma.gs $OUTFILENAME.ctl"
# 
# if [ $MKX -eq 41 ] ; then
#         grads -blc "run plot-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
# else
#         grads -blc "run plot-sigma.gs $OUTFILENAME_SIGMA.ctl"
# fi
# 

# 
# fi
# 
# # =================================================================
# #   CONFIGURACAO CINCO, SEIS e NOVE  -  DOMÍNIO 1 e 2
# # =================================================================
# #  1  -   Para NIVES DE PRESSAO
# #  SP 23g37minS 46g39minW
# #  SJ 23g14minS 45g52minW
# #  
# #  
# if [ $CONFIG -eq 5 ] || [ $CONFIG -eq 6 ] || [ $CONFIG -eq 9 ] ; then
#         
#         cd $DIR_SAIDA_DADOS
#         
#         # Dominio UM
#         OUTFILENAME=wrfout_d01
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $OUTFILENAME.ctl"
# 
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $OUTFILENAME_SIGMA.ctl"
#         fi
# 
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 1 SP"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 5 SP"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 9 SP"
#         
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 1 SJ"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 5 SJ"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 9 SJ"
#         
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 13 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 17 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 13 SJ"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 17 SJ"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 13 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 17 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 21 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -24 -47 25 SP"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 13 SJ"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 17 SJ"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 21 SJ"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -23 -46 25 SJ"
#         fi      
#         mkdir -p plots
#         mv *.png plots
# 
#                 
#         # Dominio DOIS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $OUTFILENAME.ctl"
#         grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO SETE  -  DOMÍNIO 1 e 2
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# #  RF 08g07minS 34g55minW
# #  NT 05g54minS 34g15minW
# #  FZ 03g46minS 38g32minW
# #  SV 12g54minS 38g19minW
# 
# if [ $CONFIG -eq 7 ]; then
#         
#         cd $DIR_SAIDA_DADOS
#         
#         # Dominio UM
#         OUTFILENAME=wrfout_d01
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $OUTFILENAME.ctl"
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $OUTFILENAME_SIGMA.ctl"
#         fi
# 
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -08 -35 1 RF"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -08 -35 5 RF"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -08 -35 9 RF"
#         
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -08 -35 13 RF"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -08 -35 17 RF"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 RF"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 RF"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 RF"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 RF"
#         fi      
#         mkdir -p plots
#         mv *.png plots
# 
#                 
#         # Dominio DOIS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $OUTFILENAME.ctl"
#         grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO TRES  -  DOMÍNIO 1 e 2
# # ========================================================
# if [ $CONFIG -eq 3 ]; then
#         
#         cd $DIR_SAIDA_DADOS
#         
#         # Dominio UM
#         OUTFILENAME=wrfout_d01
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG1
# # Em 2010abr11: o tamanho da imagem e passado como parametro
# #               31: 1000x750
#         grads -blc "run plot.gs $OUTFILENAME.ctl 31"
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $OUTFILENAME_SIGMA.ctl 31"
#         else
#                 grads -blc "run plot-sigma.gs $OUTFILENAME_SIGMA.ctl 31"
#         fi
#         mkdir -p plots
#         mv *.png plots
# 
#         # Dominio DOIS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $OUTFILENAME.ctl 31"
#         grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl 31"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# 
# 
# # ========================================================
# #   CONFIGURACAO TRES e OITO  -  DOMÍNIO 1 e 2
# # ========================================================
# if [ $CONFIG -eq 3 ] || [ $CONFIG -eq 8 ]; then
#         
#         cd $DIR_SAIDA_DADOS
#         
#         # Dominio UM
#         OUTFILENAME=wrfout_d01
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG1
#         grads -blc "run plot.gs $OUTFILENAME.ctl"
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma.gs $OUTFILENAME_SIGMA.ctl"
#         fi
#         mkdir -p plots
#         mv *.png plots
# 
#         # Dominio DOIS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         grads -blc "run plot-d2.gs $OUTFILENAME.ctl"
#         grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl"
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# 
# # ========================================================
# #   CONFIGURACAO 1  -   DOMINIO 2
# # ========================================================
# #  GRADE METROPOLITANA POA.
# #  1  -   Para NIVES DE PRESSAO
# if [ $CONFIG -eq 1 ]; then
# 
#         cd $DIR_SAIDA_DADOS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         # b=batch l=landscape c=command
#         # grads -blc "run plot-skew-wrf.gs MMOUT_DOMAINx.ctl x y t l"
#         grads -blc "run plot-conf1-d2.gs $OUTFILENAME.ctl"
# 
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-conf1-d2-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
#         else
#                 grads -blc "run plot-conf1-d2-sigma.gs $OUTFILENAME_SIGMA.ctl"
#         fi      
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 1 PA"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 5 PA"
#         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 9 PA"
#         if [ $_TIMAX = 2160 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#         fi
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 PA"
#         fi
#         # Mover todos os arquivos de plotagem (png) para uma pasta 
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi
# 
# # ========================================================
# #   CONFIGURACAO ZERO   -   DOMINIO 2 e 3
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# # if [ $CONFIG -eq 0 ]; then
# # 
# # # DOMINIO DOIS DOIS DOIS
# #         
# #         cd $DIR_SAIDA_DADOS
# #         OUTFILENAME=wrfout_d02
# #         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
# #         grads -blc "run plot-d2.gs $OUTFILENAME.ctl"
# #         if [ $MKX -eq 41 ] ; then
# #                 grads -blc "run plot-sigma-d2-n41.gs $OUTFILENAME_SIGMA.ctl"
# #         else
# #                 grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl"
# #         fi
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 1 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 5 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 9 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 1 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 5 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 9 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 1 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 5 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 9 FL"
# #         if [ $_TIMAX = 2160 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
# #         fi
# #         if [ $_TIMAX = 2880 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 17 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 17 FL"
# #         fi
# #         if [ $_TIMAX = 4320 ]
# #         then
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 PA"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 13 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 17 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 21 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -25.3 -49.1 25 CT"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 13 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 17 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 21 FL"
# #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -27.6 -48.5 25 FL"
# #         fi
# #         mkdir -p plotsd2
# #         mv *.png plotsd2
# # 
# # # DOMINIO TRES TRES TRES
# # 
# # #         cd $DIR_SAIDA_DADOS
# # #         OUTFILENAME=wrfout_d03
# # #         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG3
# # #         grads -blc "run plot-conf1-d2.gs $OUTFILENAME.ctl"
# # #         if [ $MKX -eq 41 ] ; then
# # #                 grads -blc "run plot-conf1-d3-sigma-n41.gs $OUTFILENAME_SIGMA.ctl"
# # #         else
# #                 grads -blc "run plot-conf1-d3-sigma.gs $OUTFILENAME_SIGMA.ctl"
# # #         fi
# # #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 1 PA"
# # #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 5 PA"
# # #         grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 9 PA"
# # #         if [ $_TIMAX = 2160 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# # #         fi
# # #         if [ $_TIMAX = 2880 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
# # #         fi
# # #         if [ $_TIMAX = 4320 ]
# # #         then
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 PA"
# # #                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 PA"
# # #         fi
# # #         mkdir -p plotsd3
# # #         mv *.png plotsd3
# # fi
# 
# # ========================================================
# #   CONFIGURACAO DOIS e QUATRO  -  DOMINIO 2
# # ========================================================
# #  1  -   Para NIVES DE PRESSAO
# if [ $CONFIG -eq 2 ] || [ $CONFIG -eq 4 ]; then
#         
#         cd $DIR_SAIDA_DADOS
#         OUTFILENAME=wrfout_d02
#         OUTFILENAME_SIGMA=MMOUT_DOMAIN_SIG2
#         # b=batch l=landscape c=command
#         # grads -blc "run plot-skew-wrf.gs MMOUT_DOMAINx.ctl x y t l"
#         grads -blc "run plot-d2.gs $OUTFILENAME.ctl"
#         grads -blc "run plot-perfil-vertical-vento.gs $OUTFILENAME.ctl"
#         if [ $MKX -eq 41 ] ; then
#                 grads -blc "run plot-sigma-d2-n41.gs $OUTFILENAME_SIGMA.ctl"
#         else
#                 grads -blc "run plot-sigma-d2.gs $OUTFILENAME_SIGMA.ctl"
#         fi
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 1 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 5 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 9 PA"
# 
#         if [ $_TIMAX = 2160 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#         fi
#         if [ $_TIMAX = 2880 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#         fi
#         if [ $_TIMAX = 4320 ]
#         then
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 13 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 17 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 21 PA"
#                 grads -blc "run plot-skew-wrf.gs $OUTFILENAME.ctl -30 -51 25 PA"
#         fi
#         # Mover todos os arquivos de plotagem (png) para uma pasta 
#         mkdir -p plotsd2
#         mv *.png plotsd2
# fi



exit

