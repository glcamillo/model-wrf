* Grads
* Enc: UTF-8

* Modificações por Ten. Gerson (G&M@Jesus)
*  28fev05 Plotagem da vorticidade: mudança do multiplicador de 10.000 para 100.000.
*  19jun05: novas variáveis para detectar o tamanho da plotagem (conf). 
*  05set05: na função BARRA foi colocado um teste para
*      verificar se os valores são constantes (Constant
*      fiel. Value=0). Caso positivo, termina o proces-
*      samento da função.
*  12set05: nova paleta de cores para DIV e W (paletaCoresDivW - 23 a 31).
*  15out05: plotagem da altura da camada limite (pblh).
*  08jan07: inclusao funcao para calculo do WEAT INDEX.
*  03fev07: calculo do SWEAT INDEX finalizado [weatindex()].
*  07set07: funcoes de ajuste de paleta em arquivo separado.
*           Valor minimo para plotagem de prp: 0,1 -> 0,009
*  13mar08: uso do mapa de terreno no grads com a divisao politica por estados.
*           Arquivo brmap_hires fornecido pelo Cap Bastos.
*  22mai08: inclusao da plotagem de vento em 925/850/700 usando barbelas.
*  22mai08: inclusao da plotagem de velocidade vertical em 950/850.
*           O nivel 950 e interpolado, pois o nivel padrao mais proximo e 925hPa.
*  11abr10: modificacao do parametro y, que e o responsavel pelo tamanho da imagem.
*  22jul10: arquivo convertido para UTF-8.
*           Uso do script para plotagem da barra: 'run plot-cbar.gs'
*           Resolvido vento barbelas em níveis (estava incorretamente sendo plotado (u10,v10)

* gradsc -blc "run plot.gs MMOUT_DOMAINx.ctl y"
function plot (arg)
arq=subwrd(arg,1)
conf=subwrd(arg,2)


if ( conf != 1 & conf != 2 & conf != 3 & conf != 31)
  conf=1
endif

* y: tamanho do domínio. A configuração de geração dos plots varia conforme o tamanho do domínio.
* y = 1 a 4
* conf=1 
* conf=2   80x80  x700 y525
* conf=3 110x110  x500 y700

* 'open MMOUT_DOMAIN1.ctl'
'open 'arq

* Em 18abr10: This command turns off the display of the GrADS logo and the time label for sreen and printed output. 
'set grads off'


* Em 07set07: um arquivo que contera todas as funcoes de ajuste de
*             paleta de cores.
'run paletaCores.gs'


* Compound string variables: compound variables are used to construct arrays in scripts. A compound variable has a variable name
*           with segments separated by periods. For example:  varname.i.j
* niveisPressao.0 = 975

niveisPressao.0 = 925
niveisPressao.1 = 850
niveisPressao.2 = 700
niveisPressao.3 = 500
niveisPressao.4 = 300
niveisPressao.5 = 250
niveisPressao.6 = 200

validade.1 = 00
validade.2 = 03
validade.3 = 06
validade.4 = 09
validade.5 = 12
validade.6 = 15
validade.7 = 18
validade.8 = 21
validade.9 = 24
validade.10 = 27
validade.11 = 30
validade.12 = 33
validade.13 = 36
validade.14 = 39
validade.15 = 42
validade.16 = 45
validade.17 = 48
validade.18 = 51
validade.19 = 54
validade.20 = 57
validade.21 = 60
validade.22 = 63
validade.23 = 66
validade.24 = 69
validade.25 = 72



* Quantidade mínima de precipitação
min_prp = 0.5

* Tamanho do nmero a ser plotado
tam_digito = 0.8

* Resoluções de Saída
if (conf = 1 | conf = 2)
   x_pontos = x700
   y_pontos = y525
endif
if (conf = 3)
   x_pontos = x800
   y_pontos = y600
endif
if (conf = 31)
   x_pontos = x1000
   y_pontos = y750
endif
* N.B. There is no elseif construct in GrADS. 


**************
** Número de passos no tempo 5 = > 00 06 12 18 24
** Número de passos no tempo para saída padrão do MM5 (MMOUT_DOMAINx) => 9 => 00 03 06 09 12 15 18 21 24 = 10
**************
* 30 36 42 48 

'q file'
rec=sublin(result,5)
say rec
_endtime=subwrd(rec,12)
nPTempo=_endtime + 1

* Em 13mar08: arquivo brmap_hires fornecido pelo Cap Bastos e que fornece os contornos dos estados.
* 'set mpdset hires'
'set mpdset brmap_hires'



********************************************************
* Em 13mar08: radiacao de onda longa saindo do topo da atmosfera.
*  RADIACAO DE ONDA LONGA saindo do topo da atmosfera
********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
*   'set lev 500'
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
*   'set cmin 0.1'
*   'set cmax 1.6'
*   'set clevs 0.1 0.2 0.4 0.6 0.8 1 1.4 1.6'
* Número níveis = 8
*   'set ccols 56 57 58 59 60 61 62 63 64'
* Número cores = 9
    'd lwo'
*    PAL_DEF = 0
*    NUM_SHADES = 13
    val=BARRA()
*    say 'Valor de retorno BARRA() -w- = 'val
*    'set gxout contour'
*    'd lwo'
    'draw title Radiacao Onda Longa saindo do topo - 'data' 'hora
    'printim radiacao_olonga_topo-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
endwhile



quit



* #######################################################
*  SEVERE WEATHER THREAT INDEX
* SWEAT > 300 severe thunderstorms possible
* SWEAT > 400 thunderstorms with tornadoes possible
* Em 08jan07
* #######################################################
i=1
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  sweat = sweatindex (t,rh,u,v)
  'set gxout shaded'
  'set cmin 100' 
  'set cmax 450'
  'set clevs 100 150 200 250 300 350 400 450'
* Número níveis = 12                        
  'set ccols 41 42 43 44 45 46 47 48 49'
* Número cores = 13                 
  'd ' sweat
  PAL_DEF = 1
  BARRA()
*  'set gxout contour'
*  'set cmin 30' 
*  'set clab off'
*  'd ' aguaPRP
  'draw title SWEAT ' data ' ' hora
  'printim sweat-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile





* ALTURA DA CAMADA LIMITE PLANETÁRIA
* Começando com 2, pois o tempo 1 dá valor de grade indefinido.
i = 2
while (i < nPTempo)
*   'clear'
*   'set t ' i

*   'query time'
*    resultado=subwrd(result,3)
*    data=substr(resultado,4,9)
*    hora=substr (resultado,1,3)

*   'set gxout shaded'
*   'set clevs -300 -250 -200 -150 -100 -50 -25 25 50 100 150 200 250 300'
*   'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'

*   'd pblh'
*   PAL_DEF = 0
*   COLORBAR()

*   'draw title Altura camada limite (m) 'data' 'hora
*   'printim pblh-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



* DIFERENÇA DA ALTURA DA CAMADA LIMITE PLANETÁRIA entre o valor
*  atual e o anterior.
* Começando com 2, pois o tempo 1 dá valor de grade indefinido.
i = 3
while (i < nPTempo)
*   'clear'
*   'set t ' i

*   'query time'
*    resultado=subwrd(result,3)
*    data=substr(resultado,4,9)
*    hora=substr (resultado,1,3)

*   'set gxout shaded'
*   'set clevs -300 -250 -200 -150 -100 -50 -25 25 50 100 150 200 250 300'
*   'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'

*   'set csmooth on'
*   'd pblh - pblh(t-1)'
*   PAL_DEF = 0
*   COLORBAR()

*   'draw title Diferenca entre altura atual e a anterior (m) 'data' 'hora
*   'printim pblh-dif-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



*  PRESSÃO E PRECIPITAÇÃO
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)

   if (i = 1)
       'set cthick 10'
       'set ccolor 1'
       'set clab on'
       'set cint 2'
       'd pslv'
* Plotagem da espessura 1000-500hPa
       'set ccolor 14'
       'set cstyle 7'
       'set clopts -1 -1 0.2'
       'set cint 5'
       'd (h(lev=500) - h(lev=1000))/10'
       'set clopts -1 -1 0.09' 
* Em 15out05: plotagem destacada da linha de 540 dam
       'set clevs 5400'
       'set clab on'
       'set ccolor  3'
       'set cstyle 1'
       'set cthick 12'
       'd (h(lev=500) - h(lev=1000))'
       'draw title Pressao Sup e Espessura 1000-500 hPa ' data' 'hora
       'print'
       'printim prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
       teste = 'printim prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   else
       'set gxout shaded'
       'set cmin 0.1'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'
* Número níveis = 12                        
       'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'
* Número cores = 13                 
       'd (rc - rc (t - 1))  + (rn - rn (t - 1))'
       PAL_DEF = 0
       NUM_SHADES = 13
*       BARRA()
       COLORBAR()
       'set clab off'
       'set gxout contour'
       'set cmin 0.1'
       'set cmax 50'
*       'set clevs 0.5 1.5 2.5 3.5 4.5 6.5 7.5 8.5'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'       
       'd (rc - rc (t - 1)) + (rn - rn (t - 1))'
       'set cthick 10'
       'set ccolor 1'
       'set clab on'
       'set cint 2'
       'd pslv'

* Plotagem da espessura 1000-500hPa
       'set ccolor 2'
       'set cstyle 7'
* cstyle=3 short dash   7 dot dot dash 5 dotted
       'set clopts -1 -1 0.2'
       'set cint 5'
       'd (h(lev=500) - h(lev=1000))/10'
       'set clopts -1 -1 0.09' 
* Em 15out05: plotagem destacada da linha de 540 dam
       'set clevs 5400'
       'set clab on'
       'set ccolor  3'
       'set cstyle 1'
       'set cthick 12'
       'd h(lev=500) - h(lev=1000)'

       'draw title Pressao/PRP(mm/3h)/Espessura 1000-500(dam)-' data' 'hora
       'printim prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
       teste = 'printim prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
* say teste
    endif
    i = i + 1
endwhile


**************************************
*  PRESSÃO E PRECIPITAÇÃO  (convectiva)
**************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   if (i = 1)
       'set cthick 10'
       'set ccolor 1'
       'set clab on'
       'set cint 2'
       'd pslv'
       'draw title Pressao Superficie ' data' 'hora
       'printim prp-rc-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   else
       'set gxout shaded'
       'set cmin 0.1'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'
* Número níveis = 12                        
       'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'
* Número cores = 13                 
       'd (rc - rc (t - 1))'
       PAL_DEF = 0
       NUM_SHADES = 13
       val=BARRA()
*       say 'Valor de retorno BARRA() -rc- = 'val
       'set clab off'
       'set gxout contour'
       'set cmin 0.1'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'       
       'd (rc - rc (t - 1))'
       'set cthick 10'
       'set ccolor 1'
       'set clab on'
       'set cint 2'
       'd pslv'
       'draw title PressaoSup e Prp C (mm/3h)-' data' 'hora
       'printim prp-rc-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    endif
    i = i + 1
endwhile

*******************************************
*  PRESSÃO E PRECIPITAÇÃO  (não-convectiva)
*******************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   if (i = 1)
       'set cthick 10'
       'set ccolor 1'
       'd pslv'
       'set cthick 5'
       'set ccolor 3'
       'set clab on'
       'set cint 2'
       'd pslv'
       'draw title Pressao Superficie ' data' 'hora
       'printim prp-rn-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   else
       'set gxout shaded'
       'set cmin 0.1'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'
* Número níveis = 12                        
       'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'
* Número cores = 13                 
       'd (rn - rn (t - 1))'
       PAL_DEF = 0
       NUM_SHADES = 13
       BARRA()
       'set gxout contour'
       'set cmin 0.1'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'       
       'd (rn - rn (t - 1))'
       'set cthick 10'
       'set ccolor 1'
       'set clab on'
       'set cint 2'
       'd pslv'
       'draw title PressaoSup e Prp NC (mm/3h)-' data' 'hora
       'printim prp-rn-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    endif
    i = i + 1
endwhile

*********************************************************
* Em 22maio08: plotagem de w (velocidade vertical em m/s).
*  VELOCIDADE VERTICAL em 950 hPa
*********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 950'
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
   'set cmin 0.1'
   'set cmax 1.6'
   'set clevs 0.1 0.2 0.4 0.6 0.8 1 1.4 1.6'
* Número níveis = 8
   'set ccols 56 57 58 59 60 61 62 63 64'
* Número cores = 9
    'd w'
    PAL_DEF = 0
    NUM_SHADES = 13
    BARRA()
    'set gxout contour'
    'd w'
    'draw title Veloc. Vertical em 950hPa (m/s) - 'data' 'hora
    'printim w950-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
endwhile


*********************************************************
* Em 22maio08: plotagem de w (velocidade vertical em m/s).
*  VELOCIDADE VERTICAL em 850 hPa
*********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 850'
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
   'set cmin 0.1'
   'set cmax 1.6'
   'set clevs 0.1 0.2 0.4 0.6 0.8 1 1.4 1.6'
* Número níveis = 8
   'set ccols 56 57 58 59 60 61 62 63 64'
* Número cores = 9
    'd w'
    PAL_DEF = 0
    NUM_SHADES = 13
    BARRA()
    'set gxout contour'
    'd w'
    'draw title Veloc. Vertical em 850hPa (m/s) - 'data' 'hora
    'printim w850-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
endwhile




*********************************************************
* Em 05set05: plotagem de w (velocidade vertical em m/s).
*  VELOCIDADE VERTICAL em 700 hPa
*********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 700'
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
   'set cmin 0.1'
   'set cmax 1.6'
   'set clevs 0.1 0.2 0.4 0.6 0.8 1 1.4 1.6'
* Número níveis = 8
   'set ccols 56 57 58 59 60 61 62 63 64'
* Número cores = 9
    'd w'
    PAL_DEF = 0
    NUM_SHADES = 13
    BARRA()
    'set gxout contour'
    'd w'
    'draw title Veloc. Vertical em 700hPa (m/s) - 'data' 'hora
    'printim w700-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
endwhile

********************************************************
* Em 05set05: plotagem de w (velocidade vertical em m/s).
*  VELOCIDADE VERTICAL em 500 hPa
********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 500'
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
   'set cmin 0.1'
   'set cmax 1.6'
   'set clevs 0.1 0.2 0.4 0.6 0.8 1 1.4 1.6'
* Número níveis = 8
   'set ccols 56 57 58 59 60 61 62 63 64'
* Número cores = 9
    'd w'
    PAL_DEF = 0
    NUM_SHADES = 13
    val=BARRA()
*    say 'Valor de retorno BARRA() -w- = 'val
    'set gxout contour'
    'd w'
    'draw title Veloc. Vertical em 500hPa (m/s) - 'data' 'hora
    'printim w500-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
endwhile



*  FRAÇÃO DE NUVENS BAIXAS (oitavos)
*  
i=1
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  'set gxout shaded'
* Valores dados em porcentagem (0 a 0.9)
  'set cmin 4' 
  'set clevs 4 5 6 7 8'
  'set ccols 41 49 50 51 52 53'
  'd 8*clfrlo'
  PAL_DEF = 1
*  BARRA()
  'set gxout contour'
*  'set cmin 4'
  'd 8*clfrlo' 
  'draw title Fracao Nuvens Baixas (oitavos) ' data ' ' hora
  'printim nuv-baixa-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  teste = 'printim nuv-baixa-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile


***************************************************
*  ÁGUA PRECIPITÁVEL (em mm) - calculado pelo GraDs
* Em 28maio06: não será mais plotado (i=nPTempo)
****************************************************
i=1
i=nPTempo
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  aguaPRP = 'vint (pslv, q, 275)'
  'set gxout shaded'
  'set cmin 30' 
  'set cmax 85'
  'set clevs 30 35 40 45 50 55 60 65 70 75 80 85'
* Número níveis = 12                        
  'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'
* Número cores = 13                 
  'd ' aguaPRP
  PAL_DEF = 1
  BARRA()
*  'set gxout contour'
*  'set cmin 30' 
*  'set clab off'
*  'd ' aguaPRP
  'draw title Agua Precipitavel (mm) ' data ' ' hora
  'printim agua-prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  teste = 'printim agua-prp-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile


*************************************************
*  ÁGUA PRECIPITÁVEL (em mm) - calculado pelo MM5
*************************************************
i=1
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  'set gxout shaded'
  'set cmin 3' 
  'set cmax 8.5'
  'set clevs 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9'
* Número níveis = 12                        
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'
* Número cores = 13                 
  'd pwat'
  PAL_DEF = 1
  BARRA()
*  'set gxout contour'
*  'set cmin 3'
*  'set clab off' 
*  'd pwat'
*  'set cmin 3' 
*  'set cmax 8.5'
*  'set clevs 2.5 3 3.5 4 4.5 5 5.5 6'
*  'set clevs 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9'  
*  'd pwat'
  'draw title Agua Precipitavel (cm) ' data ' ' hora
  'printim agua-prp-pwat-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile

**********************************************
*  ÁGUA de CHUVA IRNW (Integrated Rain Water)
**********************************************
i=2
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  'set gxout shaded'
  'set cmin 0.1' 
  'set clevs 0.1 0.5 1 1.5 2 2.5 3 4 5 10 15 20' 
  'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55'  
  'd irnw*10'
  PAL_DEF = 0
  BARRA()
*  Para t=0 => Constant field. Value=0
*  'd irnw*10' => valores dados em cm
  'set gxout contour'
  'set cmin 0.1' 
  'set clevs 0.1 0.5 1 1.5 2 2.5 3 4 5 10 15 20' 
  'd irnw*10'
  'draw title Agua de Chuva (mm) ' data ' ' hora
  'printim int-rain-water-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile


*  TEMPERATURA
*  Começa com i=2, pois o t=1 dá como grade indefinida
i=2
while (i < nPTempo)
  'clear'
  'set t 'i
  'query time'
  resultado=subwrd(result,3)
  data=substr(resultado,4,9)
  hora=substr (resultado,1,3)
  'set gxout shaded'
  'd (t2m - 273.16)'
* Não funciona com COLORBAR 
  PAL_DEF = 0
  BARRA()
  'set gxout contour'
  'd (t2m - 273.16)'
  'draw title Temperatura em Sup ' data ' ' hora
  'printim temp-sup-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
  i = i + 1
endwhile


* Em 25set2006: foi comentado pois as imagens nao
*               sao plotadas corretamente.
* Em 09dez2006: apos orientacao do Oyama durante
*              XIV Congresso Met, a plotagem funciona
*              muito bem, atraves do uso de skip ().

*  VENTO EM SUPERFÍCIE EM VETORES
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout barb'
   'set hempref shem'
*This command controls the way wind barbs are plotted for any output where wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted using the Southern Hemisphere convention.
   'd skip(u10/0.5,8,8);v10/0.5;mag(u10/0.5,v10/0.5)'
   'set cthick 6'
   'draw title Vento a Superficie - 'data ' ' hora
   'printim vntsup-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



*  PRESSÃO E VENTO SUPERFÍCIE
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout stream'
   'set strmden 1'
   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u10/0.5;v10/0.5;mag(u10/0.5,v10/0.5)'
   if (i > 1)
     PAL_DEF = 0
     COLORBAR()
   endif
*   COLORBAR()
* Para t=1 o vento em superficie nao e plotado ???
   'set gxout contour'
   'set cthick 10'
   'set clab on'
   'set cint 2'
   'd pslv'
   'draw title Pressao e Vento a Superficie(kt)  'data' 'hora
   'printim press-vntsup-' validade.i '.png ' x_pontos ' '  y_pontos ' white'
   i = i + 1
endwhile



* ccolor 0 = background (black)   1 = foreground (white)


* VENTO E TEMPERATURA NOS NÍVEIS
*****************************
**  NÍVEL = 925 hPa
*****************************
'set lev ' niveisPressao.0
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set strmden 1'
* 'set strmden 1': Densidade das linhas 1 a 10 (padrï¿½ 5) - Quanto maior -> mais densas
   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set cstyle 7'
*   'set digsize ' tam_digito
   'set ccolor 1'
   'set cthick 10'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set clopts -1 -1 0.2'
* 'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NAO E MAIS NECESSARIO
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento e Temperatura 'niveisPressao.0 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.0 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* Em 22maio08: vento em barbelas.
* VENTO E TEMPERATURA NOS NÍVEIS BARBELAS
*****************************
**  NÍVEL = 925 hPa
*****************************
'set lev ' niveisPressao.0
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'set gxout barb'
   'set hempref shem'
*This command controls the way wind barbs are plotted for any output where wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'
   'd (t - 273.16)'
   'draw title Vento e Temperatura 'niveisPressao.0 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.0 'b-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



*****************************
**  NÍVEL = 925 hPa UMIDADE RELATIVA
*****************************
'set lev ' niveisPressao.0
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin 70'
   'set clevs 70 75 80 85 90 95'
   'set ccols 16 17 18 19 20 21 22'
   'd rh'
   PAL_DEF = 0  
   BARRA()
   'set gxout stream'
   'set strmden 1'
   'd u/0.5;v/0.5'
*   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'

   'set gxout contour'
   'set ccolor 1'
   'set cint 2'
   'set cthick 10'
   'set clopts -1 -1 0.2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento Temperatura UR 'niveisPressao.0 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.0 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 850 hPa
*****************************
'set lev ' niveisPressao.1
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)
   'set gxout stream'
   'set strmden 1'
   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()
   'set gxout contour'
   'set ccolor 1'
* set cthick 1-20 tamanho das linhas   
   'set cthick 10'
   'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento(kt) e Temp.(C) 'niveisPressao.1 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.1 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* Em 22maio08: vento em barbelas.
* VENTO E TEMPERATURA NOS NÍVEIS BARBELAS
*****************************
**  NÍVEL = 850 hPa
*****************************
'set lev ' niveisPressao.1
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'set gxout barb'
   'set hempref shem'
*This command controls the way wind barbs are plotted for any output where wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'
   'd (t - 273.16)'
   'draw title Vento e Temperatura 'niveisPressao.1 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.1 'b-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

************************************
**  NÍVEL = 850 hPa UMIDADE RELATIVA
************************************
'set lev ' niveisPressao.1
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin 70'
   'set clevs 70 75 80 85 90 95'
   'set ccols 16 17 18 19 20 21 22'
   'd rh'
   PAL_DEF = 0  
   BARRA()
   'set gxout stream'
   'set strmden 1'
   'd u/0.5;v/0.5'
*   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'

   'set gxout contour'
*  'set cstyle 7'
   'set ccolor 1'
   'set cint 2'
   'set cthick 10'
   'set clopts -1 -1 0.2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento Temperatura UR 'niveisPressao.1 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.1 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 700 hPa
*****************************
'set lev ' niveisPressao.2
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i


   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set strmden 1'
   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set cstyle 7'
   'set ccolor 1'
* set cthick 1-20 tamanho das linhas   
   'set cthick 10'
*  'set clab %gC' Nï¿½ FICOU BOM
   'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento(kt) e Temp.(C) 'niveisPressao.2 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.2 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* Em 22maio08: vento em barbelas.
* VENTO E TEMPERATURA NOS NÍVEIS BARBELAS
*****************************
**  NÍVEL = 700 hPa
*****************************
'set lev ' niveisPressao.2
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'set gxout barb'
   'set hempref shem'
*This command controls the way wind barbs are plotted for any output where wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'
   'd (t - 273.16)'
   'draw title Vento e Temperatura 'niveisPressao.2 'hPa ' data ' ' hora
   'printim vnt-temp-'niveisPressao.2 'b-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

*****************************
**  NÍVEL = 700 hPa UMIDADE RELATIVA
*****************************
'set lev ' niveisPressao.2
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin 70'
   'set clevs 70 75 80 85 90 95'
   'set ccols 16 17 18 19 20 21 22'
   'd rh'
   PAL_DEF = 0  
   BARRA()
   'set gxout stream'
   'set strmden 1'
   'd u/0.5;v/0.5'
   'set gxout contour'
   'set ccolor 1'
   'set cint 2'
   'set cthick 10'
   'set clopts -1 -1 0.2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento Temperatura UR 'niveisPressao.2 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.2 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 500 hPa
*****************************
'set lev ' niveisPressao.3
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i


   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set strmden 1'
   'set clevs 5 10 15 20 25 30 35 40 45 55 60 65 70'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set cstyle 7'
   'set ccolor 1'
   'set cthick 10'
*  set cthick 1-20 tamanho das linhas   
*  'set clab %gC' Nï¿½ FICOU BOM
   'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
*   'set digsize ' tam_digito  Nï¿½ TEVE O EFEITO DESEJADO
   'draw title Vento(kt) e Temp.(C) 'niveisPressao.3 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.3 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 500 hPa  VORTICIDADE
*****************************
'set lev ' niveisPressao.3
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin -12'
   'set cmax 12' 
   'set clevs -12 -10 -8 -6 -4 -2 -1 1 2 4 6 8 10 12'
   'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'
   'set csmooth on'
   'd 100000*hcurl (u, v)'
   PAL_DEF = 0
   COLORBAR()

   'set gxout contour'
   'set ccolor 1'
   'd h'
* z(3DNATIVE)=height (above ground) of the sigma levels  h(3DDERIVED)=geopotencial height
   'draw title Geop. e Vorticidade (10-5s) 'niveisPressao.3 'hPa 'data' 'hora
   'printim vort-'niveisPressao.3 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile 

*****************************
**  NÍVEL = 500 hPa  VORTICIDADE VOR
*****************************
'set lev ' niveisPressao.3
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set clevs -12 -10 -8 -6 -4 -2 -1 1 2 4 6 8 10 12'
   'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'

   'set csmooth on'
   'd 100000*vor'
   PAL_DEF = 0
   COLORBAR()

   'set gxout contour'
   'set ccolor 1'
   'd h'
* z(3DNATIVE)=height (above ground) of the sigma levels  h(3DDERIVED)=geopotencial height
   'draw title Geop. e Vorticidade (10-5s) 'niveisPressao.3 'hPa 'data' 'hora
   'printim vort-vor'niveisPressao.3 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 300 hPa
*****************************
'set lev ' niveisPressao.4
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set strmden 1'
   'set cmin 5'
   'set clevs 5 10 20 30 40 50 60 70 80 90 100 110'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set cstyle 7'
   'set ccolor 1'
   'set cthick 10'
*  'set clab %gC'
   'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento(kt) e Temp.(C) 'niveisPressao.4 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.4 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile
* set cthick 1-20 tamanho das linhas   

*****************************
**  NÍVEL = 250 hPa
*****************************
'set lev ' niveisPressao.5
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set strmden 1'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   'set cmin 5'
   'set clevs 5 10 20 30 40 50 60 70 80 90 100 110'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set cstyle 7'
   'set ccolor 1'
   'set cthick 10'
   'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
   'set clopts -1 -1 0.09'
   'draw title Vento(kt) e Temp.(C) 'niveisPressao.5 'hPa 'data' 'hora
   'printim vnt-temp-'niveisPressao.5 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*****************************
**  NÍVEL = 250 hPa  PLOTAGEM DO JATO
*****************************
'set lev ' niveisPressao.5
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin 70'
   'set clevs  70 80 90 100 110 120 130 140 150'
   'set ccols 41 45 46 47 48 49 50 51 52 53'
   'd mag(u/0.5, v/0.5)'
   PAL_DEF = 0
   BARRA()
   'set gxout stream' 
   'set strmden 1' 
   'set ccolor 1'
   'd u/0.5;v/0.5' 
   'draw title Vento e Jato (kt) 'niveisPressao.5 'hPa 'data' 'hora
   'printim jato-'niveisPressao.5 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



*****************************
**  NÍVEL = 250 hPa - DIVERGÊNCIA
*****************************
'set lev ' niveisPressao.5
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)

   'set gxout shaded'
   'set cmin 0'
   'set cmax 8'

*   'set clevs -12 -10 -8 -6 -4 -2 2 4 6 8 10 12'
   'set clevs 0 1 2 3 4 5 6 7'
   'set ccols 56 57 58 59 60 61 62 63 64'
* clevs=8  ccols=9 paletaCoresDivW()

  'd 100000*div'
   PAL_DEF = 0
   BARRA()

   'set gxout stream'
   'set strmden 1'
   'd u/0.5;v/0.5'

   'draw title Vento e Div (100.000*s-1) 'niveisPressao.5 'hPa 'data' 'hora
   'printim div-'niveisPressao.5 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

quit
*********
*  SAIR
*********
return

function paletaCoresUR ()
     'set rgb 16 255 255 255'
*     'set rgb 16 240 255 240'
     'set rgb 17 240 255 240'
*     'set rgb 17 200 255 200'
     'set rgb 18 200 255 200'
*     'set rgb 18 0 255 0'
     'set rgb 19 0 255 0'
*     'set rgb 19 0 220 0'
     'set rgb 20 0 220 0'
*     'set rgb 20 0 180 0'
     'set rgb 21 0 180 0'
*     'set rgb 21 0 150 0'
      'set rgb 22 0 150 0'
*     'set rgb 22 0 100 0'
return

function paletaCoresVort ()
     'set rgb 23 60    5 150'
     'set rgb 24 90   90 245'
     'set rgb 25 110 110 250'
     'set rgb 26 160 160 245'
     'set rgb 27 200 200 250'
     'set rgb 28 220 220 255'
     'set rgb 29 240 240 255'
     'set rgb 30 255 255 255'
     'set rgb 31 255 240 240'
     'set rgb 32 255 220 220'
     'set rgb 33 250 200 200'
     'set rgb 34 245 160 160'
     'set rgb 35 250 110 110'
     'set rgb 36 245  90  90'
     'set rgb 37 150   5  60'
return 

function paletaCoresPrP ()
* BRANCO
     'set rgb 41 255 255 255'
* ROXO     
     'set rgb 42 190 80 200'
     'set rgb 43 120 90 200'
     'set rgb 44 0  100 255'
     'set rgb 45 0  160 255'
     'set rgb 46 0  210 255'
     'set rgb 47 0  255 155'
     'set rgb 48 70 255 0'
     'set rgb 49 170 255 0'
     'set rgb 50 250 255 0'
     'set rgb 51 255 200 0'
     'set rgb 52 255 155 0'
     'set rgb 53 255 55  0'
* VERMELHO CLARO
     'set rgb 54 210 35 35'
* MARROM
return

function paletaCoresDivW ()
     'set rgb 55 255 255 255'
     'set rgb 56 255 255 164'
     'set rgb 57 252 242   0'
     'set rgb 58 252 234 124'
     'set rgb 59 244 194  60'
     'set rgb 60 244 162   4'
     'set rgb 61 244  98   4'
     'set rgb 62 228  22   4'
     'set rgb 63 228  50   4'
     'set rgb 64 196   2   4'
return

exit

* 12 Níveis

*******************************************************
* These are the BLUE shades
*set rgb 16   0   0 255
*set rgb 17  55  55 255
*set rgb 18 110 110 255
*set rgb 19 165 165 255
*set rgb 20 220 220 255
* These are the RED shades
*set rgb 21 255 220 220
*set rgb 22 255 165 165
*set rgb 23 255 110 110
*set rgb 24 255  55  55
*set rgb 25 255   0   0


********************************************************
* GLOBAL VARIABLES: Any variable name starting with an underscore (_) will be assumed to be a global variable, 
*    and will keep its value throughout an entire script file. An example of an assignment statement that defines
*    a global string variable is as follows:
*       _var1 = "global variable 1"
*
*
*******************************************************  
* NÃO ACEITA COMENTÁRIOS DENTRO DE COMANDOS DE TOMADA DE DECISÃO (if, while)
*******************************************************
* FILLED CONTOURS OR SHADED GRIDS: quando se especifica nï¿½eis e cores para preenchimento de contornos (set gxout shaded) ou de cï¿½ulas (set gxout grfill), deve-se especificar a quantidade de cores EM UMA UNIDADE A MAIS (set ccols) do que o nmero de contornos (set clevs). Ex.:
* set gxout shaded
* set clevs -5 -4 -3 -2 -1 1 2 3 4 5 (10)
* set ccols 16 17 18 19 20 1 21 22 23 24 25 (11)
*********** FUNÇÕES INTRÍNSECAS ********************
* subwrd (string, n): This functions gets a single word from a string. The result is the nth word of string. If the string is too short, the result is NULL. n must be an integer.
* substr (string, start, length): This function gets part of a string. The sub-string of string starting at location start for length length will be returned. If the string is too short, the result will be short or NULL. start and length must be integers.
* sublin (string, n) This function gets a single line from a string containing several lines. The result is the nth line of string. If the string has too few lines, the result is NULL. n must be an integer. 
*********** COMANDOS QUERY *****************
* Depois de qualquer comando query, o valor a ser retornado ï¿½armazenado em %result%.
*    'query time'
*    say result
*    Time = 03Z13MAR1993 to 03Z13MAR1993  Sat to Sat

* Obs.: há casos em que o resultado por ser dado por:
*    Time = 03:24Z13MAR1993 to 03:24Z13MAR1993  Sat to Sat
**************************************************
*
*    'query time'  => Time = 03Z13MAR1993
*   resultado=subwrd(result,3)  => 03Z13MAR1993
*   data=substr(resultado,4,9)  => 13MAR1993
*   hora=substr (resultado,1,3) => 03Z
*
***********************************************
* Default: set clab auto Uses a substituion string of %g
* Example: set clab %gK Puts a K on the end of each label
* set clab %g%% Puts a percent on the end
* set clab %.2f Puts two digits after the decimal point on each label
* set clab %03.0f Plots each contour value as a 3 digit integer with leading zeros
* set clab Foo Labels each contour with Foo 
* Warning!!!! No error checking is done on this string! If you specify a multiple substitution (ie, %g%i), the sprintf routine will look for non-existent arguments and the result will probably be a core dump. You should not use substitutions for types other that float (ie, %i or %s should not be used).
* This option gets reset to 'auto' when a clear is issued.
* auto - specifies that you do not want a previously specified string to be used, but instead wish to use the default substitution.
* set clopts color <thickness <size>>>: where color is the label color. -1 is the default, and indicates to use the contour line color as the label color; thickness is the label thickness. -1 is the default; size is the label size. 0.09 is the default.
* This setting stays set until changed by issuing another 'set clopts' command. 
********* Assignment  **********************
* Assignment   (variable = expression) Maximo 16 caracteres
*         nPTempo = 4
**************   Say/prompt  *******************
* Say/prompt (say expression  /  prompt expression)
* O prompt nao anexa fim de linha
*         qNPTempo = "Quantos passos no tempo?"
*         say qNPTempo
*         pull nPTempo
*         say  nPTempo
**************************************************
* set cmin value: Contours not drawn below this value. Reset by clear or display.
**************************************************
* 'd rc (t + 1) - rc) + (rn (t + 1) - rn)'
* rc = prep convectiva acumulada (cm)
* rn = prep não-convectiva acumulada (cm)
***************************************************
* if (a = b)
*     comando
* else
*     comando
* endif
************************************************
****   NÃO FICOU BOM *************
* *  TEMPERATURA E VENTO SUPERFÍCIE *
*  Começa com i=2, pois o t=1 dá como grade indefinida
* i=2
* while (i < nPTempo)
*  'clear'
*  'set t 'i
*  i = i + 1
*
*  'query time'
*  resultado=subwrd(result,3)
*  data=substr(resultado,4,9)
*  hora=substr (resultado,1,3)
*
*  'set gxout shaded'
*  'd (t2m - 273.16)'
*  'set gxout contour'
*  'd (t2m - 273.16)'
*  'set cthick 8'
*  'set ccolor 0'
*  'set gxout stream'
*  'd u10/0.5;v10/0.5;mag(u10/0.5,v10/0.5)'
*  'draw title Temperatura e Vento' data hora
*  'enable print printout'
*  'print'
*  *     'disable print'
*  'printim temp-vntsup' data hora '.png ' x_pontos ' ' y_pontos ' white'
*  teste = 'printim temp_vnt-sup' data hora '.png ' x_pontos ' ' y_pontos ' white'
* 
* endwhile
*************************************************************
*  ARQUIVO meteogram_gfs.gs do site grads.iges.org/grads
* function main(args)
* Make sure GrADS is in portrait mode
* 'q gxinfo'
* pagesize = sublin(result,2)
* xsize = subwrd(pagesize,4)
* ysize = subwrd(pagesize,6)
* if (xsize != 8.5 & ysize != 11)
*   say 'You must be in PORTRAIT MODE to draw a meteogram'
*   return
* endif
* Parse the arguments: name, date, longitude, latitude, units
* if (args = '')
*  prompt 'Enter location name --> '
*  pull name
*  prompt 'Enter forecast date (yyyymmddhh) --> '
*  pull date
*  prompt 'Enter longitude --> '
*  pull hilon
*  prompt 'Enter latitude --> '
*  pull hilat
*  prompt 'Metric units? [y/n] --> '
*  pull metric
*  if (metric='n' | metric='N') ; units='e' ; endif
* else
*  name  = subwrd(args,1)
*  date  = subwrd(args,2)
*  hilon = subwrd(args,3)
*  hilat = subwrd(args,4)
*  units = subwrd(args,5)
* endif

********************************************************
* > q shades
* Number of levels = 12
* 9 < 0
* 14 0 0.3
* 4 0.3 0.6
* 11 0.6 0.9
* 5 0.9 1.2
* 13 1.2 1.5
* 10 1.5 1.8
* 7 1.8 2.1
* 12 2.1 2.4
* 8 2.4 2.7
* 2 2.7 3
* 6 3 >

********************************************************
** ##################################################**
********************************************************
*  data = primeira linha (Number of levels = 12)
*  ll = número de níveis (12)
*  col.mm = número da cor da paleta (9) < 0    (14) 0 0.3     4 0.3 0.6
*  Última linha do q shades = 6 3 >  

function BARRA (args)
**      circle colar bar
**      originally written by Paul Dirmeryer, COLA 
*       for the wx graphics on the COLA Web Page
**      generalized by Mike Fiorino, LLNL 26 Jul 1996
*
*       xc and yc are the center of the circle
*       bc is the background color
*
*       if not defined user upper left hand corner
**      sample call:  run cbarc 11 8.5 2  or run cbarc to use the defaults.

xc=subwrd(args,1)
yc=subwrd(args,2)

if(xc='' | yc = '')
  'q gxinfo'
  card=sublin(result,2)
  pagex=subwrd(card,4)
  pagey=subwrd(card,6)
  xc=pagex
  yc=pagey
endif 

*
*       use black for the background as a default       
*
bc=subwrd(args,3)
if(bc = '' | bc='bc') ; bc=0; endif 

*
*       get the shades of the last graphic
*
ll = 12
if (PAL_DEF = 1)
  ll = NUM_SHADES
  ml=ll
  mm = 1
  while (mm <= ll)
    mmp1 = mm + 1
    col.mm = BAR_ccol.mmpl
    * col.mm = número da cor da paleta (9) < 0    (14) 0 0.3     4 0.3 0.6
    if (col.mm = 0)
       col.mm = bc
    endif
    lim.mm = BAR_clev.mmpl
    * Última linha do q shades = 6 3 >  
  endwhile
else
  'q shades'
  _shades = result

* Em 05set05 (0115P): quando ocorre plotagem de
*     campo em que os valores são todos iguais
*     a 0 (Constant field. Value = 0), deve-se
*     retornar um código de erro e parar o
*     processamento da presente função. Caso
*     contrário ela gerará um erro irrecuperável.
*     G&M@Jesus.
*  'query shades'

  shdinfo = _shades
  if (subwrd(shdinfo,1)='None') 
    say 'Não foi possível plotar a barra: sem info de shades.'
    say 'Possivelmente => Constant fiel. Value = 0.'
    return 1
  endif


  aa = 2.00
  rt = 0.59 * aa
  ro = 0.575 * aa
  ri = 0.30 * aa
  xa = xc + 0.05
  ya = yc + 0.05
  ll = 1
  data = sublin(_shades,1)
  ll = subwrd(data,5)
  ml=ll
  mm = 1
  while (mm <= ll)
    mmp1 = mm + 1
    data = sublin(_shades,mmp1)
    col.mm = subwrd(data,1)
    if (col.mm = 0)
      col.mm = bc
    endif
    lim.mm = subwrd(data,3)
    if (lim.mm = '>')
      lim.mm = ' '
      ml=ml-1
      break
    else 
      mm = mm + 1
    endif
  endwhile
endif 

dd = 3.1415926*0.5/ll
id = 3.1415926*1.50

'set line 'bc' 1 12'
x1 = xc - aa
xe = xc + 0.01
y1 = yc - aa
'draw polyf 'x1' 'yc' 'xe' 'yc' 'xe' 'y1
'set line 1 1 6'
'draw line 'x1' 'yc' 'xc' 'y1

'd 'ro'*cos('id')'
xfo = subwrd(result,4) + xa
'd 'ro'*sin('id')'
yfo = subwrd(result,4) + ya
'd 'ri'*cos('id')'
xfi = subwrd(result,4) + xa
'd 'ri'*sin('id')'
yfi = subwrd(result,4) + ya
mm = 1 

while(mm<=ll)    
  id = id - dd
  'd 'ro'*cos('id')'
  xlo = subwrd(result,4) + xa
  'd 'ro'*sin('id')'
  ylo = subwrd(result,4) + ya
  'd 'ri'*cos('id')'
  xli = subwrd(result,4) + xa
  'd 'ri'*sin('id')'
  yli = subwrd(result,4) + ya
  'd 'rt'*cos('id')'
  xft = subwrd(result,4) + xa
  'd 'rt'*sin('id')'
  yft = subwrd(result,4) + ya
 
  did = id * 180 / 3.14159 - 180

  'set line 'col.mm' 1 3'
  'draw polyf 'xfi' 'yfi' 'xfo' 'yfo' 'xlo' 'ylo' 'xli' 'yli
  'set line 'bc
  'draw line 'xfi' 'yfi' 'xfo' 'yfo
  'set string 1 r 4 'did
  'set strsiz 0.08 0.11'

  if(mm<=ml)
    'draw string 'xft' 'yft' 'lim.mm
  endif

  xfo = xlo
  yfo = ylo
  xfi = xli
  yfi = yli
  mm = mm + 1
endwhile
*
*       default string
*
'set string 1 l 4 0'
*
return
  


*
*  Script to plot a colorbar
*
*  The script will assume a colorbar is wanted even if there is 
*  not room -- it will plot on the side or the bottom if there is
*  room in either place, otherwise it will plot along the bottom and
*  overlay labels there if any.  This can be dealt with via 
*  the 'set parea' command.  In version 2 the default parea will
*  be changed, but we want to guarantee upward compatibility in
*  sub-releases.
*
*
*       modifications by mike fiorino 940614
*
*       - the extreme colors are plotted as triangles
*       - the colors are boxed in white
*       - input arguments in during a run execution:
* 
*       run cbarn sf vert xmid ymid
*
*       sf   - scale the whole bar 1.0 = original 0.5 half the size, etc.
*       vert - 0 FORCES a horizontal bar = 1 a vertical bar
*       xmid - the x position on the virtual page the center the bar
*       ymid - the x position on the virtual page the center the bar
*
*       if vert,xmid,ymid are not specified, they are selected
*       as in the original algorithm
*  

function COLORBAR (args)

*sf=subwrd(args,1)
*vert=subwrd(args,2)
*xmid=subwrd(args,3)
*ymid=subwrd(args,4)
xmid=' '
ymid=' '
*if(sf='');sf=1.0;endif
sf=1.0
*if(vert=''); vert=1; endif
vert=1
*
*  Check shading information
*
  'query shades'
  shdinfo = result
  if (subwrd(shdinfo,1)='None') 
    say 'Cannot plot color bar: No shading information'
    return
  endif

* 
*  Get plot size info
*
  'query gxinfo'
  rec2 = sublin(result,2)
* say rec2
rec3 = sublin(result,3)
* say rec3
  rec4 = sublin(result,4)
* say rec4
  xsiz = subwrd(rec2,4)
* say xsiz
  ysiz = subwrd(rec2,6)
* say ysiz
  ylo = subwrd(rec4,4)
* say ylo
  xhi = subwrd(rec3,6)
* say xhi
  xd = xsiz - xhi
* say xd
* say sf
xmid = xhi+xd/2
ymid = ysiz/2 
* say 'xmid='
* say xmid
* say 'ymid='
* say ymid

  ylolim=0.6*sf
  xdlim1=1.0*sf
  xdlim2=1.5*sf  
  barsf=0.8*sf
  yoffset=0.2*sf
  stroff=0.05*sf
  strxsiz=0.12*sf
  strysiz=0.13*sf
*
*  Decide if horizontal or vertical color bar
*  and set up constants.
*
  if (ylo<ylolim & xd<xdlim1) 
    say "Not enough room in plot for a colorbar"
    return
  endif
  cnum = subwrd(shdinfo,5)
*
*       logic for setting the bar orientation with user overides
*
  if (ylo<ylolim | xd>xdlim1)
    vchk = 1
    if(vert = 0) ; vchk = 0 ; endif
  else
    vchk = 0
    if(vert = 1) ; vchk = 1 ; endif
  endif
*
*       vertical bar
*

  if (vchk = 1 )

    if(xmid = '') ; xmid = xhi+xd/2 ; endif
    xwid = 0.2*sf
    ywid = 0.5*sf
    
    xl = xmid-xwid/2
    xr = xl + xwid
    if (ywid*cnum > ysiz*barsf) 
      ywid = ysiz*barsf/cnum
    endif
    if(ymid = '') ; ymid = ysiz/2 ; endif
    yb = ymid - ywid*cnum/2
    'set string 1 l 5'
    vert = 1

  else

*
*       horizontal bar
*

    ywid = 0.4
    xwid = 0.8

    if(ymid = '') ; ymid = ylo/2-ywid/2 ; endif
    yt = ymid + yoffset
    yb = ymid
    if(xmid = '') ; xmid = xsiz/2 ; endif
    if (xwid*cnum > xsiz*barsf)
      xwid = xsiz*barsf/cnum
    endif
    xl = xmid - xwid*cnum/2
    'set string 1 tc 5'
    vert = 0
  endif


*
*  Plot colorbar
*


  'set strsiz 'strxsiz' 'strysiz
  num = 0
  while (num<cnum) 
    rec = sublin(shdinfo,num+2)
    col = subwrd(rec,1)
    hi = subwrd(rec,3)
    if (vert) 
      yt = yb + ywid
    else 
      xr = xl + xwid
    endif

*   Draw the left/bottom triangle
    if (num = 0)
      if(vert = 1)
        xm = (xl+xr)*0.5
        'set line 'col
        'draw polyf 'xl' 'yt' 'xm' 'yb' 'xr' 'yt' 'xl' 'yt
        'set line 1 1 5'
        'draw line 'xl' 'yt' 'xm' 'yb
        'draw line 'xm' 'yb' 'xr' 'yt
        'draw line 'xr' 'yt' 'xl' 'yt
      else
        ym = (yb+yt)*0.5
        'set line 'col
        'draw polyf 'xl' 'ym' 'xr' 'yb' 'xr' 'yt' 'xl' 'ym
        'set line 1 1 5'
        'draw line 'xl' 'ym' 'xr' 'yb
        'draw line 'xr' 'yb' 'xr' 'yt
        'draw line 'xr' 'yt' 'xl' 'ym
      endif
    endif

*   Draw the middle boxes
    if (num!=0 & num!= cnum-1)
      'set line 'col
      'draw recf 'xl' 'yb' 'xr' 'yt
      'set line 1 1 5'
      'draw rec  'xl' 'yb' 'xr' 'yt
    endif

*   Draw the right/top triangle
    if (num = cnum-1)
      if (vert = 1)
        'set line 'col
        'draw polyf 'xl' 'yb' 'xm' 'yt' 'xr' 'yb' 'xl' 'yb
        'set line 1 1 5'
        'draw line 'xl' 'yb' 'xm' 'yt
        'draw line 'xm' 'yt' 'xr' 'yb
        'draw line 'xr' 'yb' 'xl' 'yb
      else
        'set line 'col
        'draw polyf 'xr' 'ym' 'xl' 'yb' 'xl' 'yt' 'xr' 'ym
        'set line 1 1 5'
        'draw line 'xr' 'ym' 'xl' 'yb
        'draw line 'xl' 'yb' 'xl' 'yt
        'draw line 'xl' 'yt' 'xr' 'ym
      endif
    endif

*   Put numbers under each segment of the color key
    if (num < cnum-1)
      if (vert) 
        xp=xr+stroff
        'draw string 'xp' 'yt' 'hi
      else
        yp=yb-stroff
       'draw string 'xr' 'yp' 'hi
      endif
    endif

*   Reset variables for next loop execution
    if (vert) 
      yb = yt
    else
      xl = xr
    endif
    num = num + 1

  endwhile

return
quit


* #######################################################################
* #################  function sweatindex ################################
* #######################################################################

*This script calculates the Sweat Index sw over an area, given the fields:
*relative humidity (rhprs %), temperature (tmpprs K), wind (ugrdprs; vgrdprs m/s)
*Written by Laura Bertolani and Massimo Bollasina - March 2001

function sweatindex (t,rh,u,v)

'set lev 850'
'tmpprs=t'
'rhprs=rh'
'ugrdprs=u'
'vgrdprs=v'
'define part1=(112+0.9*(tmpprs-273.15))*pow((rhprs/100),0.125)'
'define td850=part1-112+0.1*(tmpprs-273.15)'
'define t850=tmpprs(lev=850)-273.15'
'define u850=ugrdprs(lev=850)'
'define v850=vgrdprs(lev=850)'
'define t500=tmpprs(lev=500)-273.15'
'define dir850=180+atan2(u850,v850)*180/3.14159'
'set lev 500'
'define u500=ugrdprs(lev=500)'
'define v500=vgrdprs(lev=500)'
'define dir500=180+atan2(u500,v500)*180/3.14159'
'define deltafi=dir500-dir850'
'define termine1=12*maskout(td850,td850)'
'define termine1b=const(termine1,0.0,-u)'
'define termi=td850+t850-2*t500'
'define termi2=20*(termi-49)'
'define termine2=maskout(termi2,termi2)'
'define termine2b=const(termine2,0.0,-u)'
'define effe8=2*1.942*sqrt(u850*u850+v850*v850)'
'define termine3=maskout(effe8,effe8)'
'define termine3b=const(termine3,0.0,-u)'
'define effe5=1.942*sqrt(u500*u500+v500*v500)'
'define termine4=maskout(effe5,effe5)'
'define termine4b=const(termine4,0.0,-u)'
'define esse=sin(deltafi*3.14159/180)'
'define termi5=125*(esse+0.2)'
'define a=maskout(dir850,130-dir850)'
'define one1=const(const(a,1),0,-u)'
'define a=maskout(dir850,dir850-250)'
'define one1b=const(const(a,1),0,-u)'
'define a=maskout(dir500,210-dir500)'
'define one2=const(const(a,1),0,-u)'
'define a=maskout(dir500,dir500-310)'
'define one2b=const(const(a,1),0,-u)'
'define a=maskout(deltafi,-deltafi)'
'define one3=const(const(a,1),0,-u)'
'define a=maskout(effe8,15-effe8)'
'define one4=const(const(a,1),0,-u)'
'define b=maskout(effe5,15-effe5)'
'define one5=const(const(b,1),0,-u)'
'define termin5=termi5*(1-one1)*(1-one2)*(1-one3)*(1-one4)*(1-one5)*(1-one1b)*(1-one2b)'
'define termine5=maskout(termin5,termin5)'
'define termine5b=const(termine5,0.0,-u)'
'define sw=termine1b+termine2b+termine3b+termine4b+termine5b'

* 'd sw'
 return (sw)

* #################  function sweatindex ################################
