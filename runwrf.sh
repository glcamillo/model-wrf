#!/bin/bash -x
#
#  Codificação: UTF-8

# Script para execução do modelo numerico de tempo WRF (open source de dominio publico)
#  Skamarock, W. C., J. B. Klemp, J. Dudhia, D. O. Gill, Z. Liu, J. Berner, W. Wang, J. G. Powers, M. G. Duda, D. M. Barker, and X.-Y. Huang, 2019: A Description of the Advanced Research WRF Version 4. NCAR Tech. Note NCAR/TN-556+STR, 145 pp. doi:10.5065/1dfh-6p97
#  Disponivel em: https://www2.mmm.ucar.edu/wrf/users/
#
# Versão: 0.1 (2009): foram feitas algumas tentativas para criar este script - sem sucesso.
#         1.0 (Junho/Julho2010): aproveitou-se a maior parte do run do MM5 e foi desenvolvido
#                          especificamente para proporcionar rodadas do WRF. Surgiu da necessidade
#                          do trabalho de pesquisa da EAO (CAP 2/2010). O trabalho consistirá em
#                          comparações de ventos em níveis baixos entre o MM5 e o WRF.
#         2.0 (abril/maio2011): modificacoes para tornar o codigo mais limpo e com algumas melhorias.
#                          Inclusao do sistema de multiplas configuracoes.
#         3.0 (maio2021): 
#             a) inclusao da escolha da resolucao dos dados globais: 1p00, 0p50, 0p25
#             b) inicio da inclusao de opcoes via parametro linha comando (emprestado do run.sh - RegCM)
#         4.0 (out2021): 
#             a) modificacao do script para seguir o estilo do script do RegCM (mais recente)
#             b) inclusao de novos dominios (incluindo o que sera usado para o projeto mestrado IFSC
#             c) adaptacao para a mais recente versao do WRF 4.3 de 10/5/21 (https://github.com/wrf-model/WRF/releases)
# ----------------------------------------
# Modificações por Cap Gerson (G&M@Jesus):
# JunJul10: criação deste script. Por enquanto, somente com a configuração 0.
# 21jul10: modificação do script namelist.ARWpost.sh para que aceite como parâmetro
#          o tipo de nível de saída (sigma, pressão, altura).
# 27jul10: a variável DIR_CORRENTE, nas rodadas com crontab, não deve ser especificada com `pwd`,
#          mas sim ajustá-la com o diretório /home/user/mm5.
# 28mar13: inserido um automatismo para modificacao da variável DIR_CORRENTE.
#  3out21: alteracao nomes variaveis: status_rodada_corrente  -> status-current-configuration.log
#                                     status-rodada.log -> status-components-out-execution.log

## TODO
#  Revisar o WPS (namelist.wps) cfe as novas versões WRF


# DADOS GLOBAIS NCEP: mudanças no acesso e em outros parametros (22 mar 2021)
# https://www.nco.ncep.noaa.gov/pmb/products/gfs/
# Tres resolucoes do modelo global GFS:  
#    0.25 degree resolution 	gfs.tCCz.pgrb2.0p25.fFFF 	ANL FH000 FH001-384
#    0.5 degree resolution 	gfs.tCCz.pgrb2.0p50.fFFF 	ANL FH000 FH003-384
#    1.0 degree resolution      gfs.tCCz.pgrb2.1p00.fFFF 	ANL FH000 FH003-384
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t"$HORA_INICIAL"z.pgrb2.1p00.f$HORA_PREVISAO



if [ 1 ]; then
      echo ; uname -r
fi


################################################################################
#                  Definições PADRÕES
################################################################################

# Variavel que vai controlar se todos os parametros (primordiais) foram passados via linha de comando.
NUM_PARAM=0

# Numero de nucleos de processamento.
NUM_PROC=1

# Opção padrão para o mpirun
OPCAO_1=""   # Opção que o mpirun aceita: --use-hwthread-cpus

# Resolucao dos dados globais NCEP: padrão 1 grau
RES_G_NCEP="1p00"

# Tempo de integração em horas
TEMPO_INTEGRACAO=24; export _TIMAX=1440

# Em 03jun2021: ajustada aqui e na função opcoes_rodada,
#      logo, não será mais aberta opção para escolha
COMPILADOR=GFORTRAN


# Em 08nov06: variavel para indicar que se quer ou 
#             nao inicilizar interativamente o grupo data-hora.
# Em 15ago10: tipos de inicializações do grupo data-hora
# AUTOMATICO=data do dia de hoje; hora=12
# MANUAL=mudança dos valores de data-hora dentro do script.
# INTERATIVA=o script solicita os valores via questionamentos.
#DH_INICIALIZACAO=AUTOMATICO
#DH_INICIALIZACAO=MANUAL
DH_INICIALIZACAO=INTERATIVA

#############   !!!!!       IMPORTANTE            !!!!     ########
# Para rodar via cron ajustar manualmente o diretório DIR_CORRENTE no início do
#       processamento do modelo.


################################################################################
#                  Funcoes Gerais
################################################################################


terminar_script () {
      echo -e "\n\n $1 \n\n" ; exit 1
}


mensagem () {
      echo -e "\n\n $1 \n\n" ;
}

# -------------------------------------------------------------
#  Funcao de AJUDA para parametros de linha de comando
# -------------------------------------------------------------
function ajuda
{
	echo " Uso: \$ $(basename "$0") [OPÇÕES]"
#	echo " -i no-ifrest|ifrest : no-ifrest (primeira rodada) ifrest (proximas rodadas)"
#        echo " --clm : Modelo de superfície padrão"
#        echo " --clm45 : Modelo de superfície CLM45"
	echo " -ts 2021-06-01-12 : (ano-mes-dia-hora) - data/hora inicial da integração"
#	echo " -gt2 2017-07-17-00] : (ano-mes-dia-hora) dados globais - data/hora final"
#	echo " -mdt1 [2017-04-17-00] : (ano-mes-dia-hora) rodada - data/hora inicial"
#	echo " -mdt2 [2017-06-17-00] : (ano-mes-dia-hora) rodada - data/hora final (melhor usar intervalos MENSAIS)"
#	echo " -tr mes|dia : duracao temporal da rodada (NAO IMPLEMENTADO) - padrao:mes"
	echo " -ti 24 | 48 | 72 : tempo resolucao em horas (padrao:24horas)"
	echo " -r 1p00 | 0p50 | 0p25 : resolucao dos dados globais NCEP (1|0,5|0,25 graus - padrão:1p00)"
	echo " [ -np 1 ] : numero de processadores usados (OPCIONAL) - padrão:1"
	echo " [ --use-hwthread-cpus ] : use hardware threads as independent cpus. (OPCIONAL) - padrão: vazio"

	echo " "
#	echo "Obs.: a) A duracao da primeira rodada sera dada pelo intervalo de"
#	echo "         tempo entre os valores de -mdt2 e -mdt1 (OBRIGATORIOS)."
#	echo "      b) As próximas rodadas serão calculadas incrementando o valor"
#	echo "         do mês, ou seja, se a -mdt2 2017-05-15-12, então a próxima"
#	echo "         rodada será no intervalo 2017-05-15-12 a 2017-06-15-12."
	exit 1

}

function res_g_ncep
{
    if [ x$1 = x"1p00" ]; then 
        RES_G_NCEP="1p00"
    elif [ x$1 = x"0p50" ]; then  
        RES_G_NCEP="0p50"
    elif [ x$1 = x"0p25" ]; then
         RES_G_NCEP="0p25"
    fi
	    
    
    NUM_PARAM=$(expr $NUM_PARAM + 1)
}


# Tempo (data-hora) início da integração
function t_start
{
    ANO=$(echo $1 | cut -d- -f 1)
    MES=$(echo $1 | cut -d- -f 2)
    DIA=$(echo $1 | cut -d- -f 3) 
    HORA=$(echo $1 | cut -d- -f 4)

    NUM_PARAM=$(expr $NUM_PARAM + 1)
}


# Tempo de integração: 24, 48 ou 72 horas
function t_integracao
{
    if [ x$1 = x"24" ]; then 
        TEMPO_INTEGRACAO=24; export _TIMAX=1440
    elif [ x$1 = x"48" ]; then
        TEMPO_INTEGRACAO=48; export _TIMAX=2880
    elif [ x$1 = x"72" ]; then
         TEMPO_INTEGRACAO=72; export _TIMAX=4320
    fi

    NUM_PARAM=$(expr $NUM_PARAM + 1)
}


################################################################################
################################################################################
#
#                                FUNÇÕES DE INICIALIZAÇÃO
#
################################################################################
################################################################################

# Em 15ago10: inclusão variáveis _IMVDIF e _ISOIL. O padrão permite
#             PBL 2 (Blackada) e 5 (MRF)
inicializa_opcoes_wrf () {
	export _CUMULUS_D1=3 ; export _CUMULUS_D2=3 ; export _CUMULUS_D3=1
	export _PBL_D1=5; export _PBL_D2=5; export _PBL_D3=5
	export _IMVDIF=1; export _ISOIL=1
	export _MKX=31 ; export MKX=31
	export COMPILADOR=GFORTRAN
	export FORMATO_DADOS=GRIB2
}

inicializacao_interativa () {

      echo '********************************'
      echo 'Rodando Modelo Numerico Regional'
      echo '********************************'
      echo 'Escolha a configuracao de grade predefinida:'
#      echo ' A - Centro da AS (90x90-36km) RSeSC (91x97-12km) Regiao Metropolitana (100x106-4km)' 
#       echo ' b - Conf.UM - RSeSC (90x95-12km) Regiao Metropolitana (100x100-4km)'
#       echo ' c - Conf.DOIS - Centro da America Sul (220x220-18km) RS/SC (202x202-6km)'
#      echo ' D - America do Sul (220x220-18km) Sao Paulo (202x202-6km)'
      echo ' L - Regiao SUL (90x90-18km) Leste de RS/SC/PR (133x133-6km)'
# 
#       echo ' e - Conf.QUATRO - Centro da America Sul (90x90-36km) RS (67x70-12km)'
#       echo ' f - Conf.CINCO - Centro e Sul do Brasil (90x90-36km) V.Paraiba (67x70-12km)'
#       echo ' g - Conf.SEIS - America do Sul (95x95-90km) Sao Paulo (67x70-30km)'
#       echo ' h - Conf.SETE - Regioes N e NE (90x95-45km) Nordeste (70x70-15km)'
#       echo ' i - Conf.OITO - Regiao NORTE (120x120-36km) Manaus (103x103-12km)'
#       echo ' j - Conf NOVE - America do Sul (220x220-18km) Sao Paulo (202x202-6km)'
#       echo ' d - Conf.TRES - America do Sul (135x135-36km) Regiao Norte - "Cabeca do Cachorro" (151x151-12km)'
      echo ' x - Sair'
      echo -n ' Escolha a opcao: '
      read resposta
      case $resposta in
	      [aA]) CONFIG=A; export _TISTEP=216 ; inicializa_opcoes_wrf ;;
	      [bB]) CONFIG=B; export _TISTEP=45 ; inicializa_opcoes_wrf ;;
	      [cC]) CONFIG=C; export _TISTEP=45 ; inicializa_opcoes_wrf ;;
	      [dD]) CONFIG=D; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [eE]) CONFIG=E; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [fF]) CONFIG=F; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [gG]) CONFIG=G; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [hH]) CONFIG=H; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [iI]) CONFIG=I; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [jJ]) CONFIG=J; export _TISTEP=90 ; inicializa_opcoes_wrf ;;
	      [kK]) CONFIG=K; export _TISTEP=45 ; inicializa_opcoes_wrf ;;
	      [lL]) CONFIG=L; export _TISTEP=108 ; inicializa_opcoes_wrf ;;
	      [xX]) terminar_script "Saindo ..." ;;
	      *) terminar_script "Opcao desconhecida. Saindo ..." ;;
      esac

###########################################################
# Em 03jun2021: agora essa informação será passada como
#      opção de linha de comando (parametrizada)
#      resposta=n
#      echo -e "\nOs dados NCEP estao disponiveis em torno de "
#      echo '3h30min apos a hora de inicializacao desejada.'
#	    while [ $resposta = n -o $resposta = N ]
#	    do	
#		    echo
#		    echo ' Escolha da data e hora de inicializacao: '
#		    read -p " Mes: " MES
#		    read -p " Dia: " DIA
#		    read -p " Hora: " HORA
#		    echo
#		    echo " DATA HORA da inicializacao: $ANO $MES $DIA ${HORA}Z"
#		    read -p ' Os dados estao corretos (s/n): ' resposta
#	    done
###########################################################

#       echo -e "\nEscolha o numero de niveis:"
#       echo ' 1 - 23 (padrao de instalacao)'
#       echo ' 2 - 26 niveis'
#       echo ' 3 - 31 niveis'
#       echo ' 4 - 41 niveis'
#       echo ' x - Sair'
#       echo -n ' Escolha a opcao: '
#       read resposta
#       case $resposta in
# 	      1) export _MKX=23 ; export MKX=23 ;;
# 	      2) export _MKX=26 ; export MKX=26 ;;
# 	      3) export _MKX=31 ; export MKX=31 ;;
# 	      4) export _MKX=41 ; export MKX=41 ;;
# 	      x) terminar_script "Saindo ..." ;;
# 	      *) terminar_script "Opcao desconhecida. Saindo ..." ;;
#       esac


      echo -e "\nEscolha de TISTEP "
      echo " O valor de TISTEP padrao e: $_TISTEP "
      read -p ' Deseja modifica-lo (s/n): ' resposta
      if [ $resposta = s ]; then
	      echo -n " Entre com o valor (3*dx): "
	      read resposta
	      _TISTEP=$resposta
	      export _TISTEP
      fi

#       echo -e "\nEscolha das opcoes de fisica (None=1,Kuo=2,Grell=3,AS=4,FC=5,KF=6,BM=7,KF2=8)"
#       echo -n " Entre com o valor para D1 <3>: "
#       read resposta
#       if [ $resposta -ge 1 -a $resposta -le 8 ] ; then
# 	      _CUMULUS_D1=$resposta
#       else terminar_script "Resposta fora das opcoes disponiveis."
#       fi
#       export _CUMULUS_D1
# 
#       if [ $CONFIG = 0 -o $CONFIG = 1 -o $CONFIG = 2 -o $CONFIG = 3 -o $CONFIG = 4 -o $CONFIG = 5 -o $CONFIG = 6 -o $CONFIG = 7 -o $CONFIG = 8 -o $CONFIG = 9 ] ; then
# 	      echo -n " Entre com o valor para D2 <3>: "
# 	      read resposta
# 	      if test $resposta -ge 1 -a $resposta -le 8 ; then
# 		      _CUMULUS_D2=$resposta
# 	      else terminar_script "Resposta fora das opcoes disponiveis."
# 	      fi
# 	      export _CUMULUS_D2
#       fi
# 
#       if [ $CONFIG = 0 ]; then
# 	      echo -n " Entre com o valor para D3 <1>: "
# 	      read resposta
# 	      if test $resposta -ge 1 -a $resposta -le 8 ; then
# 		      _CUMULUS_D3=$resposta
# 	      else terminar_script "Resposta fora das opcoes disponiveis."
# 	      fi
# 	      export _CUMULUS_D3
#       fi
# 
#       echo -e "\nEscolha das opcoes de PBL (planetary boundary layer)."
#       echo -e "0=no PBL fluxes, 1=bulk, 2=Blackadar, 3=Burk-Thompson,"
#       echo -e "4=Eta M-Y, 5=MRF, 6=Gayno-Seaman, 7=Pleim-Xiu"
#       echo -n "  Entre com o valor: "
#       read resposta
#       if [ $resposta -ge 1 -a $resposta -le 7 ] ; then
# 	      _PBL_D1=$resposta ; _PBL_D2=$resposta ; _PBL_D3=$resposta
#       else terminar_script "Resposta fora das opcoes disponiveis."
#       fi
#       export _PBL_D1 ; export _PBL_D2 ; export _PBL_D3 ;
# 

###########################################################
# Em 03jun2021: agora essa informação será passada como
#      opção de linha de comando (parametrizada)
#      echo 
#      echo 'Escolha o periodo da integracao:'
#      echo ' 1 - 24 horas'
#      echo ' 2 - 48 horas'
#      echo ' 3 - 72 horas'
#      echo ' x - Sair'
#      echo -n ' Escolha o periodo: '
#      read resposta
#      case $resposta in
#	      1) TEMPO_INTEGRACAO=24; export _TIMAX=1440 ;;
#	      2) TEMPO_INTEGRACAO=48; export _TIMAX=2880 ;;
#	      3) TEMPO_INTEGRACAO=72; export _TIMAX=4320 ;;
#	      x) terminar_script "Saindo ..." ;;
#	      *) terminar_script "Opcao desconhecida. Saindo ..." ;;
#      esac
###########################################################

###########################################################
# Em 03jun2021: agora essa informação será ajustada no início
#      e também na função opcoes_rodada
#      echo "  "
#      echo 'Escolha do compilador:'
#      echo ' 1 - PGI'
#      echo ' 2 - Intel'
#      echo ' 3 - GNU GFortran'
#      echo ' x - Sair'
#      echo -n ' Qual compilador: '
#      read resposta
#      case $resposta in
#	      1) COMPILADOR=PGI ;;
#	      2) COMPILADOR=INTEL ;;
#	      3) COMPILADOR=GFORTRAN ;;
#	      x) terminar_script "Saindo ..." ;;
#	      *) terminar_script "Opcao desconhecida. Saindo ..." ;;
#      esac
###########################################################

} # termino funcao inicializacao

opcoes_rodada () {
      CONFIG=a; export _TISTEP=216 ; inicializa_opcoes_wrf
      export _MKX=31 ; export MKX=31
      # Grell=3
      export _CUMULUS_D1=3 ; export _CUMULUS_D2=3 ; export _CUMULUS_D3=3
      # 5=MRF
      export _PBL_D1=5 ; export _PBL_D2=5 ; export _PBL_D3=5
      TEMPO_INTEGRACAO=24; export _TIMAX=1440
	  FORMATO_DADOS=GRIB2
	  COMPILADOR=GFORTRAN
}

################################################################################
################################################################################
#
#                                INICIO DO PROCESSAMENTO
#
################################################################################
################################################################################





################################################################################
#                   INICIO DO PROCESSAMENTO
################################################################################

# EM 03jun2021: até o momento, são três, mas cfe evolui o 
#      script, esse valor mudará
NUM_ARGUMENTOS=3 # ts   ti   r    (OBRIGATÓRIOS)
# ./runwrf.sh -ts 2021-06-10-00 -ti 24 -r 1p00
# O shell interpreta cada elemento como um argumento,
#    logo, número total são seis $#=6 ($0 é o comando)

echo "\$\# = $#"  

let result=$(($NUM_ARGUMENTOS * 2))

# Verifica número de argumentos: deve ser maior que o mínimo obrigatorio
if [ $# -lt $result ]; then
     ajuda
fi

# ===============================================================
#  Funcao para extracao de PARAMETROS da linha de comando 
# ===============================================================
while [ "$1" != "" ]; do
    case $1 in
        -i | --ifrest )         shift
                                parametro=$1
				                ifrest $parametro
                                ;;
#        --clm )                 sfc_model clm
#                                ;;
#        --clm45 )               sfc_model clm45
#                                ;;
        -ts | --t_start )    	shift
                                parametro=$1
                				t_start $parametro
                                ;;
#        -gt2 | --gdate2 )    	shift
#                                parametro=$1
#				                gdate2 $parametro				
#                                ;;
#        -mdt1 | --mdate1 )    	shift
#                                parametro=$1
#				                mdate1 $parametro				
#                                ;;
#        -mdt2 | --mdate2 )    	shift
#                                parametro=$1
#				                mdate2 $parametro				
#                                ;;
#        -tr | --durtemprodada ) shift
#                                export DURACAO_RODADA=$1			
#                                ;;
        -ti |  --t_integracao ) shift
                                parametro=$1                                   
                                t_integracao $parametro
                                ;;
        -r | --res_g_ncep )   	shift
                                parametro=$1
				                res_g_ncep $parametro			
                                ;;
        -np | --numproces )   	shift
                                export NUM_PROC=$1
                                ;;
        --use-hwthread-cpus )   OPCAO_1=$(echo "--use-hwthread-cpus")
                                ;;                           
        -h | --help )           ajuda
                                terminar_script " " 0
                                ;;
        * )                     ajuda
                                terminar_script " ERRO: faltam parametros. Saindo ...  " 1
    esac
    
    # Opção $1 já processada. O próximo argumento $2 será o $1.
    shift
done

#  Inicia variáveis de diretório principais
# inicia_var_dir


# Teste para verificar se todos os parametros foram passados
#     CORRETAMENTE
if [ $NUM_PARAM -ne 3 ]; then
    mensagem "  ERRO: falta(m) parametro(s)."
    ajuda
#	terminar_script "  ERRO: falta(m) parametro(s). Saindo ..." 1
fi





# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#      AJUSTE DAS VARIAVEIS DO MODELO WRF
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Em 28mar13: ajuste da variável DIR_CORRENTE. Se a inicializacao for manual ou
#             interativa, a variável será ajustada pelo `pwd` durante o processamento.
DIR_CORRENTE=/home/cirrus/modelo

if [ -z $1 ]; then
      HOUR=12
elif [ $1 = 12 ]; then HOUR=12
elif [ $1 = 00 ]; then HOUR=00
fi

if [ $DH_INICIALIZACAO = "AUTOMATICO" ]; then
      YEAR=`date +%Y` ; MONTH=`date +%m` ; DAY=`date +%d`
      ANO=$YEAR ; MES=$MONTH ; DIA=$DAY ; HORA=$HOUR
      opcoes_rodada
fi

if [ $DH_INICIALIZACAO = "MANUAL" ]; then
      ANO=2021; MES=10 ; DIA=25 ; HORA=12
      opcoes_rodada
fi

if [ $DH_INICIALIZACAO = "INTERATIVA" ]; then
#      ANO=2021 ; HORA=12
      inicializacao_interativa
fi

# Em 15ago10: Ajuste dos parâmetros de ISOIL e IMVDIF conforme escolha de PBL.
if [ $_PBL_D1 -eq 0 ] || [ $_PBL_D1 -eq 1 ] || [ $_PBL_D1 -eq 3 ]; then
  _IMVDIF=0 ; _ISOIL=0
fi
if [ $_PBL_D1 -eq 2 ] || [ $_PBL_D1 -eq 5 ] ; then
  _IMVDIF=1 ; _ISOIL=1
fi
if [ $_PBL_D1 -eq 4 ] || [ $_PBL_D1 -eq 6 ]; then
   _IMVDIF=0 ; _ISOIL=1
fi
if [ $_PBL_D1 -eq 7 ]; then
   _IMVDIF=1 ; _ISOIL=3
fi
export _IMVDIF ; export _ISOIL



INCR=6
ANO_SST=2006
MES_SST=04
DIA_SST=17
DATA_SST=$ANO_SST$MES_SST$DIA_SST

# Definições da data de inicialização e da data do último período de previsão
export HORA_INICIAL=$HORA
export DATA=$ANO$MES$DIA
export INICIO_ANO=$ANO 
export INICIO_MES=$MES
export INICIO_DIA=$DIA 
export INICIO_HORA=$HORA_INICIAL
export FIM_ANO=$ANO
# Caso estejamos no dia 31 de dezembro, o mesmo será pulado, cfe código a seguir.
export FIM_MES=$MES
# Caso seja final de mês, o código adiante ajustará corretamente o novo mês.
#export FIM_DIA=07
#export FIM_HORA=12
export INTERVALO=21600
# INTERVALO (s) 21600s=6h

if [ $TEMPO_INTEGRACAO = 24 ]
then
	RESULTADO=`expr $DIA + 1`
	export FIM_DIA=`printf %02d $RESULTADO`
	export FIM_HORA=$HORA_INICIAL
elif [ $TEMPO_INTEGRACAO = 36 ]
then
	RESULTADO=`expr $HORA_INICIAL + 12`
	export FIM_HORA=`printf %02d $RESULTADO`
if test $FIM_HORA -ge 24 ; then 
	RESULTADO=`expr $DIA + 2`
	export FIM_DIA=`printf %02d $RESULTADO`
	RESULTADO=`expr $FIM_HORA - 24`
	export FIM_HORA=`printf %02d $RESULTADO`
else 
	RESULTADO=`expr $DIA + 1`
	export FIM_DIA=`printf %02d $RESULTADO`
fi
elif [ $TEMPO_INTEGRACAO = 48 ]
then
	RESULTADO=`expr $DIA + 2`
	export FIM_DIA=`printf %02d $RESULTADO`
	export FIM_HORA=$HORA_INICIAL

elif [ $TEMPO_INTEGRACAO = 72 ]
then
	RESULTADO=`expr $DIA + 3`
	export FIM_DIA=`printf %02d $RESULTADO`
	export FIM_HORA=$HORA_INICIAL
fi



# 
# Em 05ago05: - caso seja final de mês, o código a seguir calculará a nova data.
#             - os valores de FIM_DIA acima calculados não levam em consideração a passagem
#               de mês.  
# Mês de fevereiro (considerando como de 28 dias)
if [ $MES = 02 ]; then
if [ $FIM_DIA -ge 29 ]; then
		RESULTADO=`expr $MES + 1`
		FIM_MES=`printf %02d $RESULTADO`
		RESULTADO=`expr $FIM_DIA - 28`
		FIM_DIA=`printf %02d $RESULTADO`
fi
fi 
# Meses de 30 dias
if [ $MES = 04 -o $MES = 06 -o $MES = 09 -o $MES = 11 ]; then 
if [ $FIM_DIA -ge 31 ]; then
		RESULTADO=`expr $MES + 1`
		FIM_MES=`printf %02d $RESULTADO`
		RESULTADO=`expr $FIM_DIA - 30`
		FIM_DIA=`printf %02d $RESULTADO`
fi
fi

# Meses de 31 dias exceto dezembro.
if [ $MES = 01 -o $MES = 03 -o $MES = 05 -o $MES = 07 -o $MES = 08 -o $MES = 10 ]; then
if [ $FIM_DIA -ge 32 ]; then
		RESULTADO=`expr $MES + 1`
		FIM_MES=`printf %02d $RESULTADO`
		RESULTADO=`expr $FIM_DIA - 31`
		FIM_DIA=`printf %02d $RESULTADO`
fi
fi

# Mês de dezembro.
if [ $MES = 12 ]; then 
if [ $FIM_DIA -ge 32 ]; then
	FIM_ANO=`expr $ANO + 1`
	FIM_MES=01
	RESULTADO=`expr $FIM_DIA - 31`
	FIM_DIA=`printf %02d $RESULTADO`
fi
fi

echo " " >> wrf.log
echo "INICIAL: $INICIO_ANO$INICIO_MES$INICIO_DIA-$INICIO_HORA" >> wrf.log
echo "FINAL: $FIM_ANO$FIM_MES$FIM_DIA-$FIM_HORA" >> wrf.log
let INTERVALO_HORAS=$INTERVALO/3600
echo "INTERVALO: $INTERVALO(s)  - $INTERVALO_HORAS(h)" >> wrf.log



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#      VARIAVEIS DO PERIODO DE INTEGRACAO
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#         VARIAVEIS DE DIRETORIOS
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Em 27abril05: modificação dos diretórios. (Cap Gerson)
# Em 31out05: modificação do diretório GFS (do sítio NCEP).

# Diretório PRINCIPAL => diretório do USUÁRIO
export USER_PATH=$HOME
# Diretório dos arquivos executáveis (pgi, gradsc, mm5)
export BIN_PATH=$USER_PATH/bin
# Diretório de instalação do Pgi
# export PGI_PATH=$BIN_PATH/pgi
# Diretório dos binários
BINARIOS_PATH=$USER_PATH/binarios
# Diretório de TRABALHO
export WORK_PATH=$USER_PATH/bin/WRF

# Em 03jul10: diretórios de trabalho para o WRF.
WRF_PATH=$USER_PATH/bin/WRF
# Em 06jul10: será exportada para ser usada pelos scripts do WPS.
export WPS_PATH=$USER_PATH/bin/WPS

# Diretório dos arquivos de terreno. O nome do diretório é aquele da descompactação.
export GEODATA_PATH=$USER_PATH/bin/WPS_GEOG

# Diretório backup dos arquivos de dados da rodada corrente.
#    Em 06jul10: será exportado em função do wps.
export DIR_DADOS_GFS=$USER_PATH/gfs-data-$DATA$HORA_INICIAL'Z'

# Diretório a será criado para backup dos resultados da rodada da grade corrente.
#   Sera configurado para o diretorio correto a seguir.
DIR_SAIDA_WRF=$DIR_DADOS_GFS/

# TODO TODO TODO TODO
# Em 07jun2011: Arquivo com o log das rodadas
RODADAS_LOG=$DIR_DADOS_GFS/rodadas-WRF-$DATA$HORA_INICIAL'.log'

# Em 24mai08: modificacao da variavel abaixo, pois no crontab ela nao era ajustada
#             de forma correta (algum problema com o retorno do pwd). Somente no run3.sh.
# DIR_CORRENTE=/home/mm5/modelo
# Em 01mai11: variável será exportada, pois será usada por um outro scritp (compilar-mm5.sh)
# Em 28mar13: a variavel DIR_CORRENTE será ajustada no início e deve conter, geralmente, o diretório
#             onde se encontra o script do modelo.
if [ $DH_INICIALIZACAO = "AUTOMATICO" ]; then
	export DIR_CORRENTE
else
	export DIR_CORRENTE=$(pwd)
fi


# Definição da busca dos dados 
# FTP_DIR=/pub/data/nccf/com/gfs/prod/gfs.$DATA/
# Em 31out05: a partir de 13out e 08nov05, exclusivamente,
#             os dados gfs deverão ser acessados através do
#             seguinte diretório:
FTP_DIR=/pub/data/nccf/com/gfs/prod/gfs.$DATA/$HORA_INICIAL/
FTP_DIR_SST=/pub/data/nccf/com/gfs/prod/sst.$DATA_SST/
FTP_SITE=ftpprd.ncep.noaa.gov
#FTP_SITE=140.90.33.31
# export ARQUIVO_SST=sst2dvar_grb_0.5


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#	     CRIACAO DO DIRETORIO DOS DADOS 
#      		E BUSCA DOS DADOS GLOBAIS   
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Definição da função que cria o arquivo para ser usado pelo ftp.
function criar_ftpgfs  {
	echo "user anonymous user@icea.gov.br"             > ftpgfs
	echo "bin"                                          >> ftpgfs
	echo "hash"                                         >> ftpgfs
	echo "cd "$FTP_DIR                                  >> ftpgfs
}


# Cria o diretório de backup dos dados GFS (buscados do NCEP)
if [ ! -d $DIR_DADOS_GFS ]; then
	mkdir -p $DIR_DADOS_GFS
fi

cd $DIR_DADOS_GFS

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


if [ $DIR_DADOS_GFS != `pwd` ]; then 
  echo " Estamos no diretório errado. Saindo ... ";
  exit 1;
fi


# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t"$HORA_INICIAL"z.pgrb2.1p00.f$HORA_PREVISAO
# ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201025/12/gfs.t12z.pgrb2.1p00.f000

# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.t12z.pgrb2.1p00.f000
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20210308/12/gfs.t12z.pgrb2.1p00.f000


if [ $DIR_DADOS_GFS != `pwd` ]; then 
  echo " Estamos no diretório errado. Saindo ... ";
  exit 1;
fi

if [ $FORMATO_DADOS = "GRIB2" ]; then
	COPIADOS=1
	while [ $COPIADOS -eq 1 ]
	do 
		HORA_PREVISAO_NUM=0
		while [ "$HORA_PREVISAO_NUM" -le "$TEMPO_INTEGRACAO" ]
		do
# printf %03d 012 : o 012 é interpretado como OCTAL		
			HORA_PREVISAO=`printf %03d "$HORA_PREVISAO_NUM"`
			if [ -e "$DIR_DADOS_GFS/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO" ]; then
				if [ `du -ks "$DIR_DADOS_GFS/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO" | cut -f1` -gt 25000 ]; then
					echo "Arquivo $DIR_DADOS_GFS/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO copiado."
					COPIADOS=0
				fi
			else
				echo
				COPIADOS=1
				echo "Arquivo $DIR_DADOS_GFS/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO NÂO COPIADO."
				# wget -c --passive-ftp ftp://$FTP_SITE$FTP_DIR/gfs.t"$HORA_INICIAL"z.pgrb2."RES_G_NCEP".f$HORA_PREVISAO
				wget -c https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$DATA/$HORA_INICIAL/atmos/gfs.t"$HORA_INICIAL"z.pgrb2."$RES_G_NCEP".f$HORA_PREVISAO
			fi
			# Incrementa somente se tiver sido copiado.
			if [ $COPIADOS -eq 0 ] ; then 
			    echo "Incremento: $INCR"
			  HORA_PREVISAO_NUM=`expr $HORA_PREVISAO_NUM \+ $INCR`
			fi
		done
	done
fi


# Em 17jun2021: verifica a última configuração executada: DIR_DADOS_GFS/wrf-CONFIG-CONTADOR
#         Permite que, para uma mesma data, possam ser executados diferentes domínios e 
#         diferentes configurações (física, pex).
ultima_configuracao ()
{
#ls | grep ^wrf | tr -s 'wrf' ' ' | tr -s '-' ' ' |cut -d' ' -f2
#ls | grep ^wrf | tr -s 'wrf' ' ' | tr -s '-' ' ' |cut -d' ' -f3
    echo -e "--- CONFIGURAÇÃO da PRÓXIMA RODADA (início) ---\n"
    cd $DIR_DADOS_GFS
    LISTA=$(ls -d wrf-$CONFIG-*)
    status=$?
    if [ $status -ne 0 ]; then
        VALOR_ULTIMA_CONF=0
        cd -  # volta para diretório anterior
        return $VALOR_ULTIMA_CONF
    else
#        LISTA=$(echo $LISTA | sort)
        for i in $LISTA; do
            VALOR=$(echo $i | cut -d'-' -f 3)
            if test ${VALOR} -ge 0  -a ${VALOR} -le 9; then
                echo "Valor dec = $VALOR"
                VALOR_ULTIMA_CONF=$VALOR
            fi
        done
        cd -  # volta para diretório anterior
        echo "Valor ultima configuracao: wrf-$CONFIG-$VALOR"
        return $VALOR_ULTIMA_CONF
    fi
}

proxima_rodada ()
{
        # Diretorio com os dados de saida do modelo (grade) corrente.
        ultima_configuracao
        retorno=$?
        echo "Retorno ultima configuracao = $retorno"
        DIR_SAIDA_WRF=$DIR_DADOS_GFS/wrf-$CONFIG-$retorno
        echo "Ultima configuracao executada: DIR_SAIDA_WRF = $DIR_SAIDA_WRF"
#        echo "DIR_SAIDA_WRF = $DIR_SAIDA_WRF"
        if [ -d $DIR_SAIDA_WRF ]; then
	        status=$(cat $DIR_SAIDA_WRF/status-current-configuration.log)
        else 
	        status=2
	    fi 

        # Valores para status:
        # 0 = diretório já existe e a rodada foi completada
        # 1 = diretório já existe e a rodada não foi completada com sucesso
        # 2 = diretório não existe ainda

        echo "status = $status"
        if [ $status -eq 0 ] || [ $status -eq 2 ] ; then
            echo "Configuração anterior executada com SUCESSO"
		    VALOR=`expr $retorno \+ 1`
		    DIR_SAIDA_WRF=$DIR_DADOS_GFS/wrf-$CONFIG-$VALOR
		    echo "Próxima configuração: DIR_SAIDA_WRF = $DIR_SAIDA_WRF"
		fi
        if [ $status -eq 1 ] ; then
            echo "Configuração anterior com ERRO."
            echo "Executar com mesmas configurações."
        fi

    echo -e "--- CONFIGURAÇÃO da PRÓXIMA RODADA (término) ---\n"	
    cd -
}


        
if [ ! -d $GEODATA_PATH ]; then
    echo "   "
    echo "ERRO. Dados de terreno não existem no diretório WPS/geog. ERRO"
    echo "   Instale-os a partir do script de instalação. "
    echo " Saindo ..."
    exit 1
fi


case $CONFIG in
############   CONF a - TRES DOMINIOS   ################
[aA]) # Configuração com tres dominios 
        # Variáveis usadas no mm5.deck do MM5.
        export _NESTIX_1=90;  export _NESTJX_1=90
        export _NESTIX_2=91;  export _NESTJX_2=97
        export _NESTIX_3=100;  export _NESTJX_3=106
        export _NESTI_2=34;   export _NESTJ_2=40
        export _NESTI_3=16;   export _NESTJ_3=34
        # Variáveis usadas no configure.user do MM5.
        export _MIX=100;       export _MJX=106
        export _MAXNES=3

        export _PARENT_ID_2=1;  export _PARENT_ID_3=2
        export _I_PARENT_START_2=38 ; export _I_PARENT_START_3=43
        export _J_PARENT_START_2=35 ; export _J_PARENT_START_3=14

        export _GEODATA_RES_1=10m; export _GEODATA_RES_2=5m; export _GEODATA_RES_3=2m
        export _MAP_PROJECTION=lambert
        export _E_WE_1=90;  export _E_WE_2=109;  export _E_WE_3=109
        export _E_SN_1=90;  export _E_SN_2=97;  export _E_SN_3=109
        export _DX_1=36000; export _DX_2=12000; export _DX_3=4000
        export _DY_1=36000; export _DY_2=12000; export _DY_3=4000
        export _REF_LAT=-30.166;   export _REF_LON=-55.212
        export _TRUELAT1=-30.166; export _TRUELAT2=-30.166; export _STAND_LON=-55.212
        
        proxima_rodada
;;
[bB]) 
;;
[cC])
;;
[dD]) # Configuração da area de Sao Paulo
        export _NESTIX_1=90;  export _NESTJX_1=90
        export _NESTIX_2=91;  export _NESTJX_2=97
        export _NESTIX_3=100;  export _NESTJX_3=106
        export _NESTI_2=34;   export _NESTJ_2=40
        export _NESTI_3=16;   export _NESTJ_3=34
        export _MIX=100;       export _MJX=106
        export _MAXNES=3

        export _PARENT_ID_2=1;  export _PARENT_ID_3=2
        export _I_PARENT_START_2=38 ; export _I_PARENT_START_3=43
        export _J_PARENT_START_2=35 ; export _J_PARENT_START_3=14

        export _GEODATA_RES_1=10m; export _GEODATA_RES_2=5m; export _GEODATA_RES_3=2m
        export _MAP_PROJECTION=lambert
        export _E_WE_1=90;  export _E_WE_2=109;  export _E_WE_3=109
        export _E_SN_1=90;  export _E_SN_2=97;  export _E_SN_3=109
        export _DX_1=36000; export _DX_2=12000; export _DX_3=4000
        export _DY_1=36000; export _DY_2=12000; export _DY_3=4000
        export _REF_LAT=-30.166;   export _REF_LON=-55.212
        export _TRUELAT1=-30.166; export _TRUELAT2=-30.166; export _STAND_LON=-55.212

        proxima_rodada
;;

[lL]) # Dois dominios: 
# D1: 90x90 18km = Região Sul
# D2: 133x133 6km = Leste de RS/SC/PR
        export _NESTIX_1=90;  export _NESTJX_1=90
        export _NESTIX_2=133;  export _NESTJX_2=133
#        export _NESTIX_3=100;  export _NESTJX_3=106
        export _NESTI_2=31;   export _NESTJ_2=27
        export _MIX=133;       export _MJX=133
        export _MAXNES=2

        export _PARENT_ID_2=1;
        export _I_PARENT_START_2=31 ; 
        export _J_PARENT_START_2=27 ; 

        export _GEODATA_RES_1=10m; export _GEODATA_RES_2=5m;
        export _MAP_PROJECTION=lambert
        export _E_WE_1=90;  export _E_WE_2=133;
        export _E_SN_1=90;  export _E_SN_2=133;
        export _DX_1=18000; export _DX_2=6000;
        export _DY_1=18000; export _DY_2=6000;
        export _REF_LAT=-28;   export _REF_LON=-51;
        export _TRUELAT1=-28.921; export _TRUELAT2=-28.921; export _STAND_LON=-50.857

        proxima_rodada

;; 


*) echo "Não válida ..."
esac

# Em 26set13: O estabelecimento de quais niveis ETA e onde sera setado devera ser incluido no script
#             principal. Foi retirado do script namelist.input.wrf.sh.
if [ $MKX -eq 31 ]; then
#  ETA_LEVELS=1.000,0.997,0.995,0.990,0.985,0.980,0.975,0.970,0.965,0.955,0.945,0.920,0.890,0.850,0.800,0.750,0.700,0.650,0.600,0.550,0.500,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.100,0.050,0.000,
export NUM_NIVEIS_ETA_SIGMA=1.000,0.997,0.995,0.990,0.985,0.980,0.975,0.970,0.965,0.955,0.945,0.930,0.910,0.890,0.850,0.800,0.750,0.700,0.650,0.600,0.550,0.500,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.050,0.000,
fi


if [ ! -d $WPS_PATH/data ]; then
    mkdir -p $WPS_PATH/data
    #  Em 18jul10: vamos deixar para apagar depois.
    #  rm -rf $WPS_PATH/data/*
fi

# Em 18jul10: se não houver o diretório então há duas opções:
# - primeira rodada; ou
# - rodada anterior com erro e foi escolhida a opção (a) na função proxima_rodada ().
if [ ! -d $DIR_SAIDA_WRF ]; then
    mkdir $DIR_SAIDA_WRF
fi

# Em 17jul10: criação do arquivo DIR_SAIDA_WRF/status-components-out-execution.log com os valores
#             que definem o status dos vários processamentos. Valores:
#      0 SUCESSO          diferente de 0 ERRO
#            Por padrão, todos serão setados para 1, caso o processamento tenha
#            sucesso, será ajustado para 0.
if test ! -e $DIR_SAIDA_WRF/status-components-out-execution.log ; then
  touch $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "# Valores que definem o status dos vários processamentos." >>  $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "#    0 SUCESSO     diferente de 0 ERRO " >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "GEOGRID 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "UNGRIB 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "METGRID 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "REAL 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "WRF 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "ARWPOST 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
  echo "GRADS 1" >> $DIR_SAIDA_WRF/status-components-out-execution.log
fi





###########################################################
###########################################################
#               INÍCIO DO PROCESSAMENTO
#
###########################################################
###########################################################
# Valores para status:
# 0 = diretório já existe e a rodada foi completada
# 1 = diretório já existe e a rodada não foi completada com sucesso
# 2 = diretório não existe ainda
echo 1 > $DIR_SAIDA_WRF/status-current-configuration.log



# ========================================================
# WPS: criação do namelist.wps que é usado
#      pelos programas geogrib.exe, ungrib.exe e metgrid.exe
# ========================================================
cd $WPS_PATH
cp $DIR_CORRENTE/wrf/namelist.wps.sh $WPS_PATH/
chmod u+x $WPS_PATH/namelist.wps.sh
if [ -e $WPS_PATH/namelis.wps ]; then
    rm -f $WPS_PATH/namelist.wps
fi

$WPS_PATH/namelist.wps.sh  WPS  $WPS_PATH/data/FILE

cp $WPS_PATH/namelist.wps $DIR_SAIDA_WRF




# ========================================================
#  GEOGRID: setup the Model domain (geogrid.exe)
#   Define the simulation domains, and to interpolate various
#         terrestrial data sets to the model grids 
#   Arquivo configuração: WPS/geogrid/GEOGRID.TBL
# ========================================================
status=$(cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep "GEOGRID" | cut -d' ' -f2)
if [ $status -ne 0 ]; then
    #  Em 18jul10: como estamos começando tudo do início, apagaremos o conteúdo.
    rm -rf $WPS_PATH/data/*

    cd $WPS_PATH
    if [ -e geogrid/GEOGRID.TBL ]; then
      rm -f geogrid/GEOGRID.TBL
    fi
    ln -s $WPS_PATH/geogrid/GEOGRID.TBL.ARW $WPS_PATH/geogrid/GEOGRID.TBL
    ./geogrid.exe >& geogrid-$DATA$HORA_INICIAL.log
    grep -i "Successful completion of geogrid." geogrid-$DATA$HORA_INICIAL.log
    retorno=$(echo $?)
    cp geogrid-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
    if test $retorno -ne 0 ; then
      echo -e "\nERRO   Problema na execucao do WPS/geogrid/geogrid.exe. Saindo ...   ERRO"
      exit 1
    fi
fi
sed -i /GEOGRID/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log



# ========================================================
#  UNGRIB
#   Arquivo configuração: WPS/Vtable -> WPS/ungrib/Variable_Tables/Vtable.GFS
#
#  Em 08jul10: Como o processamento do ungrib é usado tanto pelo
#       MM5 quanto pelo WRF, a execução será através do script
#       processa_ungrib.sh. A definição de qual saída (MM5 ou WPS)
#       será gerada, está definida no namelist.wps, que será criado
#       no início do processamento do WPS. Cap Gerson.
#  Em 25out20: houve alteração no nome dos arquivos NCEP, logo o processa_ungrib.sh
#       deverá ser alterado
# ========================================================
status=$(cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep "UNGRIB" | cut -d' ' -f2)
if [ $status -ne 0 ]; then
    cd $WPS_PATH
    cp $DIR_CORRENTE/wrf/processa_ungrib.sh $WPS_PATH
    chmod u+x processa_ungrib.sh
    #cp $DIR_CORRENTE/wrf/link_grib-data.csh $WPS_PATH
    cp $DIR_CORRENTE/wrf/link_grib.csh $WPS_PATH
    # Em 01jun2021: resol dados globais passado como parametro, pois o
    #        nome do arquivo sera diferente.
    ./processa_ungrib.sh  $RES_G_NCEP
    retorno=$(echo $?)
    cp ungrib-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
    if test $retorno -ne 0 ; then
        echo -e "\nERRO   Problema na execucao do WPS/ungrib/ungrib.exe. Saindo ...   ERRO"
        exit 1;
    fi
fi
sed -i /UNGRIB/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log


# ========================================================
#  METGRID: interpolate the input data onto our model domain (metgrid.exe)
#   Arquivo configuração: WPS/metgrid/METGRID.TBL
# ========================================================
status=`cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep -i "METGRID" | cut -d' ' -f2`
if [ $status -ne 0 ]; then
    cd $WPS_PATH
    if [ -e metgrid/METGRID.TBL ]; then
      rm -f metgrid/METGRID.TBL
    fi
    ln -s $WPS_PATH/metgrid/METGRID.TBL.ARW $WPS_PATH/metgrid/METGRID.TBL
    ./metgrid.exe >& metgrid-$DATA$HORA_INICIAL.log

    cat metgrid-$DATA$HORA_INICIAL.log | grep -i "Successful completion of metgrid."
    retorno=$(echo $?)
    cp metgrid-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
    if test $retorno -ne 0 ; then
      echo -e "\nERRO   Problema na execucao do WPS/metgrid/metgrid.exe. Saindo ...   ERRO"
      exit 1
    fi
fi
sed -i /METGRID/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log


# ========================================================
#  COPIAR LOGS + namelist.wps para
# ========================================================


# ========================================================
#  WRF
# ========================================================
status=`cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep -i "REAL" | cut -d' ' -f2`
if [ $status -ne 0 ]; then
    cd $WRF_PATH/run
    rm -f met_em*
    for met_em_files in $WPS_PATH/data/met_em*
    do
      ln -s $met_em_files
    done

    cp $DIR_CORRENTE/wrf/namelist.input.wrf.sh  $WRF_PATH/test/em_real/

    # Em 19jun2021: considerando problemas de usar um mesmo
    #   binário para diferentes plataformas, será usada a versão
    #   compilada durante instalação do NetCDF
    #   Normalmente instalado em: /home/USER/bin/lib/netcdf/bin/ncdump
    
    cp $DIR_CORRENTE/wrf/ncdump $WRF_PATH/run/
    # Em 18jul10: O utilitário ncdump verificará o valor de num_metgrid_levels.
    # Em 25set13: na instalacao padrao o ncdump nao teve setada a execucao.
    #             Sera incluido no script de instalacao install.sh.

    #   NUM_METGRID_LEVELS=`$WRF_PATH/run/ncdump -h $WPS_PATH/data/met_em.d01.$INICIO_ANO-$INICIO_MES-$INICIO_DIA'_'$INICIO_HORA:00:00.nc | grep num_metgrid_levels | head -n1 | cut -d' ' -f 3`
    # Em 19jun2021: será usado ncdump da versão instalada pelo NetCDF
    NUM_METGRID_LEVELS=$(ncdump -h $WPS_PATH/data/met_em.d01.$INICIO_ANO-$INICIO_MES-$INICIO_DIA'_'$INICIO_HORA:00:00.nc | grep num_metgrid_levels | head -n1 | cut -d' ' -f 3)


# TODO TODO testar o resultado do COMANDO NCDUMP ANTES DE SEGUIR

    # Apagar o arquivo (link) namelis.input anterior
    if [ -e test/em_real/namelist.input ]; then
      rm -f test/em_real/namelist.input
    fi
    # Criação do namelist.input
    cd $WRF_PATH/test/em_real/
    chmod u+x namelist.input.wrf.sh
    ./namelist.input.wrf.sh $NUM_METGRID_LEVELS


    cd $WRF_PATH/run
    rm -f namelist.input
    
    ln -s $WRF_PATH/test/em_real/namelist.input .

    # Em 20dez2020: inclusao . Nao sera preciso, pois os arquivos ja sao criados
    #   anteriormente 
    #  ln -sf "$WPS_PATH/data/met_em.d0?.20??-*" .
    
    # Em 21dez2020: nao e gerada saia que possa ser capturada.    
    # ./real.exe >& real-$DATA$HORA_INICIAL.log
    # cat real-$DATA$HORA_INICIAL.log | grep -i "SUCCESS COMPLETE REAL_EM INIT"
    # retorno=`echo $?`
    # mv real-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
    
    mpirun -np $NUM_PROC $WRF_PATH/run/real.exe
    #    cat rsl.out.0000 | grep -i "SUCCESS COMPLETE REAL_EM INIT"
    #  Em 20210826: segue o teste sugerido pela documentação:
    # cat rsl.out.0000 | grep -i "SUCCESS COMPLETE WRF"
    if [ ! -e rsl.out.0000 ]; then
      echo "ERRO Problema na execucao do real.exe (não foi gerado rsl.out.0000). Saindo ..."
      exit 1
    fi    
        
    grep -i "SUCCESS COMPLETE REAL_EM INIT" rsl.out.0000
    retorno=$(echo $?)
    
    if test $retorno -ne 0 ; then
      echo "ERRO   Problema na execucao do real.exe. Saindo ...    ERRO"
      exit 1
    fi
    # Copiar o arquivo para o diretorio de saida de dados
    cp rsl.out.0000 "$DIR_SAIDA_WRF/real-$DATA$HORA_INICIAL.log"    
fi

sed -i /REAL/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log

###TODO
# Em 20210826: outros testes a serem inclusos
#    Namelist options are written to a separate file, “namelist.output.”
#    Check the output times written to the wrfout* file by using the netCDF command:
#    ncdump –v Times wrfout_d01_yyyy-mm-dd_hh:00:00



# Em 19jul10: geração do arquivo wrf.print.out que conterá o namelist
#             e o resultado da rodada do modelo (wrf.exe)
cat $WRF_PATH/test/em_real/namelist.input > $WRF_PATH/run/wrf.print.out

status=$(cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep -i "WRF" | cut -d' ' -f2)
if [ $status -ne 0 ]; then
    cd $WRF_PATH/run

    echo -e "\n\n ... EXECUTANDO o programa de integracao numerica -> wrf.exe ...."

    # Em 6out21: nao e gerada saia que possa ser capturada
    
    # Em 6out2021: opcao para o mpiexec
    # Opcao usada por Cleber: mpiexec --use-hwthread-cpus -np 12 /.../wrf.exe
    # mpirun (Open MPI): -use-hwthread-cpus, --use-hwthread-cpus: Use hardware threads as independent cpus.
    # mpirun: /usr/bin/mpirun.openmpi /usr/bin/mpirun /home/cirrus/bin/lib/mpich/bin/mpirun
    # mpiexec: /usr/bin/mpiexec /usr/bin/mpiexec.openmpi /home/cirrus/bin/lib/mpich/bin/mpiexec /home/cirrus/bin/lib/mpich/bin/mpiexec.hydra

    # /usr/bin/mpiexec -> /etc/alternatives/mpiexec*
    # /usr/bin/mpirun -> /etc/alternatives/mpirun*
    
    # /etc/alternatives/mpiexec -> /usr/bin/mpiexec.openmpi*
    # /etc/alternatives/mpirun -> /usr/bin/mpirun.openmpi*

    # /usr/bin/mpirun.openmpi -> orterun*
    # /usr/bin/mpiexec.openmpi -> orterun*
    
    # Opcao anterior
    # TEMPO=`( time ./wrf.exe >> wrf.print.$DATA$HORA_INICIAL.out 2>&1 ) 2>&1`
    # Em 6out2021: nova opcao para execucao
    TEMPO=$(time mpirun $OPCAO_1 -np $NUM_PROC ./wrf.exe)
    
    TEMPO_TOTAL=$(cat rsl.out.0000 | grep "Timing for main" | awk '{ SUM += $9} END { print "Total Time WRF: " SUM }')

    echo -e "\n\n TEMPO DE INTEGRACAO: $TEMPO / $TEMPO_TOTAL (s)" >> wrf.print.out

    echo -e "\n Terminou de rodar o WRF (wrf.exe). Verificando se arquivos de saida foram criados."


    if [ -e wrfout_d01_$INICIO_ANO-$INICIO_MES-$INICIO_DIA'_'$INICIO_HORA:00:00 ] || [ -e wrfout_d02_$INICIO_ANO-$INICIO_MES-$INICIO_DIA'_'$INICIO_HORA:00:00 ] || [ -e wrfout_d03_$INICIO_ANO-$INICIO_MES-$INICIO_DIA'_'$INICIO_HORA:00:00 ]; then
        echo -e "\n\n  WRF OK -> Vamos para o ARWpost (pos-processamento) \n"
    else
        echo -e "\nERRO   Problema na execucao do wrf.exe. Saindo ...   ERRO"
        exit 1
    fi
    cp wrf.print.out $DIR_SAIDA_WRF/wrf.print.$DATA$HORA_INICIAL.out
    mv $WRF_PATH/run/wrfout_d0[1-3]*  $DIR_SAIDA_WRF
fi

sed -i /WRF/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log


###########################################################
###########################################################
#                  PÓS-PROCESSAMENTO
#                        ARWpost
# Valores passados como parâmetros:
# 1: Caminho dos dados  2:Número do domínio 3:Tipo de nível de saída
# Para o terceiro parâmetro:
# 0:níveis do modelo (sigma) 1:níveis de pressão  2:níveis em altura
###########################################################
###########################################################
status=`cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep -i "ARWPOST" | cut -d' ' -f2`
if [ $status -ne 0 ]; then
    cd $BIN_PATH/ARWpost
    # Apagar o arquivo (link) namelist.ARWpost anterior
    if [ -e namelist.ARWpost ]; then
          rm -f namelist.ARWpost
    fi
    cp $DIR_CORRENTE/wrf/namelist.ARWpost.sh .
    chmod u+x namelist.ARWpost.sh
    cp $DIR_CORRENTE/wrf/arwpost_fields_file.txt .
    # Domínio UM
    echo "ARWpost para o dominio 1"
    ./namelist.ARWpost.sh $DIR_SAIDA_WRF 1 0
    ./ARWpost.exe >& ARWpost-dominio1_sig-$DATA$HORA_INICIAL.log
    cp ARWpost-dominio1_sig-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
    cat ARWpost-dominio1_sig-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
    retorno=`echo $?`
    if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio UM - SIGMA). Saindo ...ERRO"
        exit 1
    fi
# Em 21jul10: Esta saída será em PRESSAO
#          e somente será gerada para este domínio, pois
#          a ideia precipua é o uso para o trabalho de pesquisa CAP.
      ./namelist.ARWpost.sh $DIR_SAIDA_WRF 1 1 
      ./ARWpost.exe >& ARWpost-dominio1_pres-$DATA$HORA_INICIAL.log
      cp ARWpost-dominio1_pres-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
      cat ARWpost-dominio1_pres-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
      retorno=`echo $?`
      if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio UM - PRESSAO) . Saindo ...ERRO"
        exit 1
      fi

#######################
### DOMINIO DOIS  #####
#######################
    if [ $CONFIG = 'A' ] || [ $CONFIG = 'J' ] || [ $CONFIG = 'L' ]; then
      # Domínio DOIS
      echo "ARWpost para o dominio 2"
      ./namelist.ARWpost.sh $DIR_SAIDA_WRF 2 0
      ./ARWpost.exe >& ARWpost-dominio2_sig-$DATA$HORA_INICIAL.log
      cp ARWpost-dominio2_sig-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
      cat ARWpost-dominio2_sig-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
      retorno=`echo $?`
      if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio DOIS - SIGMA) . Saindo ...ERRO"
        exit 1
      fi
# Em 21jul10: Esta saída será em PRESSÃO
#          e somente será gerada para este domínio, pois
#          a ideia precipua é o uso para o trabalho de pesquisa CAP.
      ./namelist.ARWpost.sh $DIR_SAIDA_WRF 2 1
      ./ARWpost.exe >& ARWpost-dominio2_pres-$DATA$HORA_INICIAL.log
      cp ARWpost-dominio2_pres-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
      cat ARWpost-dominio2_pres-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
      retorno=`echo $?`
      if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio DOIS - PRESSAO) . Saindo ...ERRO"
        exit 1
      fi
    fi

#######################
### DOMINIO TRES  #####
#######################
    if [ $CONFIG = 'A' ]; then
      # Domínio TRES
      echo "ARWpost para o dominio 3"
      ./namelist.ARWpost.sh $DIR_SAIDA_WRF 3 0
      ./ARWpost.exe >& ARWpost-dominio3_sig-$DATA$HORA_INICIAL.log
      cp ARWpost-dominio3_sig-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
      cat ARWpost-dominio3_sig-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
      retorno=`echo $?`
      if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio TRES - SIGMA) . Saindo ...ERRO"
        exit 1
      fi
# Em 21jul10: Esta saída será em ALTURA (metros, ou km)
#          e somente será gerada para este domínio, pois
#          a ideia precipua é o uso para o trabalho de pesquisa CAP.
      ./namelist.ARWpost.sh $DIR_SAIDA_WRF 3 2
      ./ARWpost.exe >& ARWpost-dominio3_alt-$DATA$HORA_INICIAL.log
      cp ARWpost-dominio3_alt-$DATA$HORA_INICIAL.log $DIR_SAIDA_WRF
      cat ARWpost-dominio3_alt-$DATA$HORA_INICIAL.log | grep -i "Successful completion of ARWpost"
      retorno=`echo $?`
      if test $retorno -ne 0 ; then
        echo -e "\nERRO Problema na execucao do ARWpost.exe (Dominio TRES - ALTURA) . Saindo ...ERRO"
        exit 1
      fi

    fi


fi
sed -i /ARWPOST/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log


###########################################################
###########################################################
#               GERAÇÃO DOS GRÁFICOS DE SAÍDA 
#                        GRADS
###########################################################
###########################################################
status=`cat $DIR_SAIDA_WRF/status-components-out-execution.log | grep -i "GRADS" | cut -d' ' -f2`
      if [ $status -ne 0 ]; then
      # Parâmetros: $1:Diretório saída dados      $2: Configuração corrente
	  # Em 18mar13: variavel abaixo usada para verificar o resultado das operacoes GrAds
	  GRADES_RESULTADO=0

      cp $DIR_CORRENTE/wrf/geracao_saidas_graficas.sh $DIR_SAIDA_WRF
      cp $DIR_CORRENTE/wrf/grads/plot-*.gs $DIR_SAIDA_WRF

      # Em 18dez13: inclusao da copia dos arquivos cbarn.gs e rgbset.gs considerando a adequacao
      #             das saidas graficas em funcao do GT de Modelagem Numerica.
      cp -f $DIR_CORRENTE/grads/cbarn.gs $DIR_CORRENTE/grads/rgbset.gs  $DIR_SAIDA_WRF

      cd $DIR_SAIDA_WRF
      chmod u+x geracao_saidas_graficas.sh
      ./geracao_saidas_graficas.sh $DIR_SAIDA_WRF  $CONFIG $MKX lambert
	  if test $? -ne 0 ; then
		GRADS_RESULTADO=1
	  fi
	  
	  # Em 10mai2021: SO ALTERA status processamento, se houve o mesmo
      if [ $GRADES_RESULTADO = '0' ]; then
          sed -i /GRADS/s/1/0/ $DIR_SAIDA_WRF/status-components-out-execution.log
      fi	  
	  
    # Em 03jun2011: arquivos gs serão apagados da rodada.
    # Em 10mai2021: SO APAGA se houve processamento na rodada
    rm -f $DIR_SAIDA_WRF/*.gs 2>/dev/null
fi


##################################################################
#  As plotagens a seguir são para o projeto de pesquisa CAP 2/2010.
##################################################################
if [ $CONFIG = 'A' ]; then
        cd $DIR_SAIDA_WRF
        cp $DIR_CORRENTE/wrf/grads/plot-sigma-projeto-wrf.gs .
        OUTFILENAME_SIGMA=wrfout_d03_SIG
        grads -blc "run plot-sigma-projeto-wrf.gs $OUTFILENAME_SIGMA.ctl"
        cp vento*.txt $DIR_CORRENTE/projeto
fi


#########################################
#  FINALIZANDO E AJUSTANDO O STATUS
#  Sera usado para executar o modelo nas mesmas confs,
#     a partir do ponto onde houve a falha. O arquivo status-components-out-execution.log
#     possui status para cada fase
#########################################

# Em 19mar13: modificacao do ajuste de saida.
# Valores para status:
# 0 = diretório já existe e a rodada foi completada
# 1 = diretório já existe e a rodada não foi completada com sucesso
# 2 = diretório não existe ainda
grep 1$ $DIR_SAIDA_WRF/status-components-out-execution.log
# $? = 0 foi encontrado um modulo com falha (saida 1)
if [ $? -eq 0 ]; then
    echo 1 > $DIR_SAIDA_WRF/status-current-configuration.log
    exit 1
fi

exit 0

