#!/bin/bash

# Enc: UTF-8
# namelist.ARWpost.sh
#
# Uso
# ./namelist.ARWpost.sh $$DIR_SAIDA_WRF    1|2|3    0|1|2
# 
# Modificações por Cap Gerson. (G&M@Jesus)
# 17jul10: originalmente o presente arquivo não existia,
#   mas para facilitar o processamento automáticos dos scripts,
#   foi necessário criá-lo.

if [ -e ./namelist.ARWpost ]; then
   rm ./namelist.ARWpost
fi

# Em 17jul10: Não pode haver underline entre expansão de variáveis.
TRACO=_

# Em 17jul10: Primeiro parametro: caminho dos dados ($DIR_SAIDA_WRF)
#               Segundo parametro: numero do domínio a ser processado
# Em 21jul10: opção do interp_method: escolhida através de variável passada
#            através do runwrf.sh.
CAMINHO=$1
DOMINIO=$2
TIPO_NIVEL_SAIDA=$3

# Valores do parâmetro (variável TIPO_NIVEL_SAIDA):
# 0: padrão do modelo (sigma)
# 1: níveis em pressão
# 2: níveis em altura
# Valores do INTERP_METHOD :0 - sigma levels,  -1 - code defined "nice" height levels,  1 - user defined height or pressure levels
# INTERP_METHOD=0 (valor padrão)
INTERP_METHOD=0
if [ $TIPO_NIVEL_SAIDA -eq 0 ]; then
   echo -e "\n\nOs mesmos niveis de rodada do modelo (eta_levels)"
   INTERP_METHOD=0
   TIPO_NIVEL=SIG
elif [ $TIPO_NIVEL_SAIDA -eq 1 ]; then
   echo -e "\n\nSaida dos plots em niveis de pressao (mesmos do MM5)"
   INTERP_METHOD=1
   INTERP_LEVELS=1000.,950.,925.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
   TIPO_NIVEL=PRES
elif [ $TIPO_NIVEL_SAIDA -eq 2 ]; then
   echo -e "\n\nSaida dos plots em altura (km)"
   INTERP_METHOD=1
   INTERP_LEVELS=0.02,0.05,0.10,0.15,0.25,0.40,0.60,0.90,1.20,1.50,2.00,3.00,4.00,5.00,7.00,9.00,10.0,11.0,12.0,15.0,
   TIPO_NIVEL=ALT
fi

# Em 19jul10: INTERVALO: Intervalo entre os dados a processar 10800s=3 horas 
#             O parâmetro interval_seconds não deve estar entre aspas.
INTERVALO=10800

# Em 21jul10: para que gere os dados diagnósticos deve-se fazer o seguinte:
#   plot = 'all' ==>  plot = 'all_list'

# Obs.: deve-se terminar com / para que não interprete como nome de arquivo.
#  output_root_name = '$CAMINHO/'


cat << End_Of_Namelist > ./namelist.ARWpost
&datetime
 start_date = '$INICIO_ANO-$INICIO_MES-$INICIO_DIA$TRACO$INICIO_HORA:00:00',
 end_date   = '$FIM_ANO-$FIM_MES-$FIM_DIA$TRACO$FIM_HORA:00:00',
 interval_seconds = $INTERVALO,
 tacc = 0,
 debug_level = 0,
/

&io
 io_form_input  = 2,
 input_root_name = '$CAMINHO/mm5out_d0$DOMINIO'
 output_root_name = '$CAMINHO/mm5out_d0$DOMINIO$TRACO$TIPO_NIVEL'
 plot = 'all'
! Below is a list of all available diagnostics
! fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'
 fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,clfr'
 output_type = 'grads'
 mercator_defs = .False.
/
 split_output = .False.
 frames_per_outfile = 2

&interp
 interp_method = $INTERP_METHOD,
 interp_levels = $INTERP_LEVELS,
/
extrapolate = .False.

End_Of_Namelist
