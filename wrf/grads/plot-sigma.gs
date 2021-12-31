* Grads
* Enc: UTF-8

* Modificações por Ten. Gerson (G&M@Jesus)
*  28fev05 Plotagem da vorticidade: mudança do multiplicador de 10.000 para 100.000.
*  13mar05: plotagem de vento em níveis sigma.
*  19jun05: novas variáveis para detectar o tamanho da plotagem (conf). 
*  06set05: plotagem de convergência de umidade em níveis sigma.
*  12set05: nova paleta de cores para DIV e W (paletaCoresDivW - 23 a 31).
*  07set07: funcoes de ajuste de paleta em arquivo separado.
*           Valor minimo para plotagem de prp: 0,1 -> 0,009
*  13mar08: uso do mapa de terreno no grads com a divisao politica por estados.
*           Arquivo brmap_hires fornecido pelo Cap Bastos.
*  20jul10: uso de array e while para rodar as plotagens de vento nos
*           diversos níveis (elimina a repetição de funções).
*           Acréscimo do parâmetro de quantidade de níveis sigma.
*           Serão especificados quais níveis a plotar conforme o número de níveis
*           especificados no modelo (23, 26, 28, 31, 35).
*  21jul10: conversão para UTF-8
*  24jul10: uso da função plot-cbar.gs para plotagem da barra vertical à direita.
*           Foram habilitados as seguintes variáveis no mm5tograds.csh:
*              pslv, swd, lwd, swo, lwo, pblh, pblr  

*  Dados a plotar:
*    CONVERGÊNCIA DE UMIDADE em sigma 0.985
*    CONVERGÊNCIA DE UMIDADE em sigma 0.995
*    VENTO em linhas de corrente, TEMPERATURA
*    VENTO em barbelas, TEMPERATURA e UR

* gradsc -blc "run plot-sigma.gs MMOUT_DOMAINx.ctl y $MKX"
* Parâmetros: 1=nome arquivo 2=configuração tamanho plotagem (x e y) 3=número níveis sigma
function plot (args)
arq=subwrd(args,1)
conf=subwrd(args,2)
niveis=subwrd(args,3)

* Caso não seja passado o parâmetro, default é 31.
if (niveis < 20)
  niveis = 31
endif

if ( conf != 1 & conf != 2 & conf != 3  & conf != 31 & conf != 4)
  conf=1
endif


* y: tamanho do dominio. A configuração de geracao dos plots varia conforme o tamanho do dominio.
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
*'run paletaCores.gs'

* Compound string variables: compound variables are used to construct arrays in scripts. A compound variable has a variable name
*           with segments separated by periods. For example:  varname.i.j
niveisPressao.0 = 925
niveisPressao.1 = 850
niveisPressao.2 = 700
niveisPressao.3 = 500
niveisPressao.4 = 300
niveisPressao.5 = 250
niveisPressao.6 = 200


* Em 13ago05: valores de níveis sigma presentes no arquivo MMOUT_DOMAIN_SIG1.ctl,
*             após a inserção de três níveis no arquivo interpf.csh (0.97, 0.95 e 0.91)
*  zdef 26 levels 0.995 0.985 0.975 0.965 0.955 0.94 0.92 0.9 
*                 0.87  0.825 0.775 0.725 0.675 0.625 0.575 0.525 0.475 0.425
*                 0.375 0.325 0.275 0.225 0.175 0.125 0.075 0.025



* Em 22mar05: mudanca valores sigma. (G&M@Jesus)
*niveisSigma.0 = 0.995
*niveisSigma.1 = 0.985
*niveisSigma.2 = 0.975
*niveisSigma.3 = 0.965
*niveisSigma.4 = 0.955
*niveisSigma.5 = 0.940
*niveisSigma.6 = 0.920
*niveisSigma.7 = 0.900
*niveisSigma.8 = 0.870
*niveisSigma.9 = 0.825
* 
*  ETA_LEVELS=1.000,,,,,,,,,,,,,,,,,,,,,,0.450,0.400,0.350,0.300,0.250,0.200,0.150,0.100,0.050,0.000,


* Em 20jul10: niveis sigma (eta levels). (G&M@Jesus)
*             Será ajustado o valor da variável nsig, que conterá os níveis que serão plotados.
if ( niveis = 23 )
 nsig=21
 niveisSigma.0 = 0.997
 niveisSigma.1 = 0.995
 niveisSigma.2 = 0.990
 niveisSigma.3 = 0.985
 niveisSigma.4 = 0.980
 niveisSigma.5 = 0.975
 niveisSigma.6 = 0.970
 niveisSigma.7 = 0.965
 niveisSigma.8 = 0.955
 niveisSigma.9 = 0.945
 niveisSigma.10 = 0.930
 niveisSigma.11 = 0.910
 niveisSigma.12 = 0.890
 niveisSigma.13 = 0.850
 niveisSigma.14 = 0.800
 niveisSigma.15 = 0.750
 niveisSigma.16 = 0.700
 niveisSigma.17 = 0.650
 niveisSigma.18 = 0.600
 niveisSigma.19 = 0.550
 niveisSigma.20 = 0.500
endif


* zdef 31 levels 0.9985 0.996 0.9925 0.9875 0.9825 0.9775 0.9725
* 0.9675 0.96 0.95 0.9375 0.92 0.9 0.87 0.825 0.775 0.725 0.675
* 0.625 0.575 0.525 0.475 0.425 0.375 0.325 0.275 0.225 0.175
* 0.125 0.075 0.025

if ( niveis = 31 )
 nsig=21
 niveisSigma.0 = 0.996
 nSigmaAGL.0 = 28 metros
 niveisSigma.1 = 0.9875
 nSigmaAGL.1 = 87 metros
 niveisSigma.2 = 0.9825
 nSigmaAGL.2 = 123 metros
 niveisSigma.3 = 0.9775
 nSigmaAGL.3 = 160 metros
 niveisSigma.4 = 0.9675
 nSigmaAGL.4 = 231 metros
 niveisSigma.5 = 0.95
 nSigmaAGL.5 = 358 metros
 niveisSigma.6 = 0.92
 nSigmaAGL.6 = 580 metros
 niveisSigma.7 = 0.9
 nSigmaAGL.7 = 730 metros
 niveisSigma.8 = 0.825
 nSigmaAGL.8 = 1315 metros
 niveisSigma.9 = 0.775
 niveisSigma.10 = 0.725
 niveisSigma.11 = 0.675
 niveisSigma.12 = 0.625
 niveisSigma.13 = 0.575
 niveisSigma.14 = 0.525
 niveisSigma.15 = 0.475
 niveisSigma.16 = 0.425
 niveisSigma.17 = 0.375
 niveisSigma.18 = 0.325
 niveisSigma.19 = 0.275
 niveisSigma.20 = 0.225
endif


if ( niveis = 41 )
 nsig=21
 niveisSigma.0 = 0.997
 niveisSigma.1 = 0.995
 niveisSigma.2 = 0.990
 niveisSigma.3 = 0.985
 niveisSigma.4 = 0.980
 niveisSigma.5 = 0.975
 niveisSigma.6 = 0.970
 niveisSigma.7 = 0.965
 niveisSigma.8 = 0.955
 niveisSigma.9 = 0.945
 niveisSigma.10 = 0.930
 niveisSigma.11 = 0.910
 niveisSigma.12 = 0.890
 niveisSigma.13 = 0.850
 niveisSigma.14 = 0.800
 niveisSigma.15 = 0.750
 niveisSigma.16 = 0.700
 niveisSigma.17 = 0.650
 niveisSigma.18 = 0.600
 niveisSigma.19 = 0.550
 niveisSigma.20 = 0.500
endif



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

* Tamanho do número a ser plotado
tam_digito = 0.8

* Em 20jul10: mudança da resolução da conf=1 .
* Resoluções de Saída
if (conf = 1)
   x_pontos = x800
   y_pontos = y600
endif
if (conf = 2)
   x_pontos = x700
   y_pontos = y525
endif
if (conf = 3)
   x_pontos = x500
   y_pontos = y700
endif
if (conf = 4 )
   x_pontos = x1200
   y_pontos = y1020
endif
* Em 22mar05.
* Intervalo de altura geopotencial (dif. em metros)
CINT_H_SIG=300

**************
** Número de passos no tempo 5 = > 00 06 12 18 24
** Número de passos no tempo para saída padrão do MM5 (MMOUT_DOMAINx) => 9 => 00 03 06 09 12 15 18 21 24
**************
'q file'
rec=sublin(result,5)
_endtime=subwrd(rec,12)
nPTempo=_endtime + 1
say nPTempo

* Em 13mar08: arquivo brmap_hires fornecido pelo Cap Bastos e que fornece os contornos dos estados.
* 'set mpdset hires'
'set mpdset brmap_hires'

*******************************************************
******   CONVERGÊNCIA DE UMIDADE em sigma 0.995  ******
*******************************************************
* Em 08jun07: desabilitado devido a falta de resolucao
*             da plotagem.
* Em 05set05: plotagem de Convergência de UMIDADE em sigma 0.995

* This is a script for displaying moisture convergence 
* Written by Michael Maxwell 
*
* rh    = Relative Humidity in % 
* t     = Temp at *set level in degrees Kelvin
* tc    = Temp in degrees C
* td    = Dewpoint at *set level in degrees C
* e     = Vapor pressure        
* mixr  = Mixing ratio
* u     = U-wind in m/s
* v     = V-wind in m/s
* mconv = moisture convergence/divergence. convergence is positive and divergence is negative.

i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 0.995'

   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)

  'tc = (t-273.16)'
  'td = tc-((14.55+0.114*tc)*(1-0.01*rh) + pow((2.5+0.007*tc)*(1-0.01*rh),3) + (15.9+0.117*tc)*pow((1-0.01*rh),14))'
  'vapr = 6.112*exp((17.67*td)/(td+243.5))'
  'e = vapr*1.001+(lev-100)/900*0.0034'
  'mixr = 0.62197*(e/(lev-e))*1000'
  'mconv = (-1)*hdivg(u*mixr,v*mixr)*1e4'

  'set gxout shaded'
  'set clevs -1600 -1200 -800 -600 -400 -200 -100 100 200 400 600 800 1200 1600'
  'set ccols 39 38 37 36 35 34 33 32 31 21 22 23 24 25 26 27 28 29'
* Será usada a paleta da Vorticidade.
  'd mconv'
  'run rgbset.gs'
  'run cbarn.gs'
  'set gxout contour'
  'd mconv'
  'draw title Convergencia Umidade em 0.995 - 'data' 'hora
  'printim convumid_995-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


*******************************************************
******   CONVERGÊNCIA DE UMIDADE em sigma 0.985  ******
*******************************************************
* Em 05set05: plotagem de Convergência de UMIDADE em sigma 0.985

* This is a script for displaying moisture convergence 
* Written by Michael Maxwell 
*
* rh    = Relative Humidity in % 
* t     = Temp at *set level in degrees Kelvin
* tc    = Temp in degrees C
* td    = Dewpoint at *set level in degrees C
* e     = Vapor pressure        
* mixr  = Mixing ratio
* u     = U-wind in m/s
* v     = V-wind in m/s
* mconv = moisture convergence/divergence. convergence is positive and divergence is negative.

i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'set lev 0.985'

   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)

   'tc = (t-273.16)'
   'td = tc-((14.55+0.114*tc)*(1-0.01*rh) + pow((2.5+0.007*tc)*(1-0.01*rh),3) + (15.9+0.117*tc)*pow((1-0.01*rh),14))'
   'vapr = 6.112*exp((17.67*td)/(td+243.5))'
   'e = vapr*1.001+(lev-100)/900*0.0034'
   'mixr = 0.62197*(e/(lev-e))*1000'
   'mconv = (-1)*hdivg(u*mixr,v*mixr)*1e4'

   'set gxout shaded'
   'set clevs -1600 -1200 -800 -600 -400 -200 -100 100 200 400 600 800 1200 1600'
   'set ccols 39 38 37 36 35 34 33 32 31 21 22 23 24 25 26 27 28 29'
* Será usada a paleta da Vorticidade.
   'd mconv'
   'run rgbset.gs'
   'run cbarn.gs'
   'set gxout contour'
   'd mconv'
   'draw title Convergencia Umidade em 0.985 - 'data' 'hora
   'printim convumid_985-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




********************************************************
******   VENTO em linhas de corrente, TEMPERATURA  *****
* nsig = número de níveis sigma que serão plotados
********************************************************
n=0
*while (n < nsig)
*  Em 02nov13: serao plotados oitos niveis.
while (n < 8)
 'set lev ' niveisSigma.n
 i = 1
 while (i < nPTempo)
   'clear'
   'set t ' i

   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)

   'set gxout stream'
   'set cthick 10'
   'set strmden 4'
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas

   'set clevs   3  6  9 12 15 20 25 30 35 45'
   'set ccols   41 31 21 22 23 24 25 26 27 28 29'

   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'

   'run rgbset.gs'
   'run cbarn.gs'

   'set gxout contour'

*   'set cstyle 7'
*   'set digsize ' tam_digito
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'   
   'set clab masked'
  'd (t - 273.16)'
* plotagem dos títulos em dois níveis
   'set strsiz .2'
   'set string 1 l 6'
   'draw string 2.7 8.35 Vento (kt) e Temperatura (C)'
   'set strsiz .15'
   'set string 1 l 3'
   'draw string 7.5 8.0 '  data'-' hora
   'draw string 1.5 8.0 ' 'Nivel Sigma: ' niveisSigma.n '  Altura AGL: ' nSigmaAGL.n
* desenha o mapa
   'set mpdraw on'
   'draw map'
*   'draw title Vento e Temp. (nivel 'niveisSigma.n ')' data '-' hora
   'printim vnt-temp-sig-'niveisSigma.n '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    i = i + 1
 endwhile
 n = n + 1
endwhile

********************************************************
******     VENTO em barbelas, TEMPERATURA e UR     *****
* nsig = número de níveis sigma que serão plotados
********************************************************
n=0
*while (n < nsig)
*  Em 02nov13: serao plotados oitos niveis.
while (n < 8)
 'set lev ' niveisSigma.n
 i = 1
 while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
    resultado=subwrd(result,3)
    data=substr(resultado,4,9)
    hora=substr (resultado,1,3)
   'set gxout shaded'
   'set clevs 75 80 85 90 95 100'
   'set ccols 31 33 35 36 37 38 39'
   'd rh'
   'run rgbset.gs'
   'run cbarn.gs'
   'set gxout contour'
   'set cthick 10'
   'set cint 3'
   'set clab masked'
    'temp=(t - 273.16)'
    if ( temp <= 0 )
      'set ccolor 14'
      'd 'temp
    else
      'set ccolor 2'
      'd 'temp
    endif
   'set gxout barb'
   'set ccolor 1'
   'set cthick 4'
   'set hempref shem'
*   shem: padrão barbelas Hemisferio Sul
   'd skip(u/0.5,9,9);v/0.5'
* plotagem dos títulos em dois níveis
   'set strsiz .2'
   'set string 1 l 6'
   'draw string 2.7 8.35 Vento (kt), Temp (C), UR (%)'
   'set strsiz .15'
   'set string 1 l 3'
   'draw string 7.5 8.0 '  data'-' hora
   'draw string 1.5 8.0 ' 'Nivel Sigma: ' niveisSigma.n '  Altura AGL: ' nSigmaAGL.n
* desenha o mapa
   'set mpdraw on'
   'draw map'
*   'draw title Vento, Temp, UR (nivel 'niveisSigma.n ')' data'-' hora
   'printim vnt-temp-sig-ur-'niveisSigma.n '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
 endwhile
 n = n + 1
endwhile


********************************************************
* Em 13mar08: radiacao de onda longa saindo do topo da atmosfera.
*  RADIACAO DE ONDA LONGA saindo do topo da atmosfera
********************************************************
i = 1
while (i < nPTempo)
   'clear'
   'set t ' i
   'query time'
   resultado=subwrd(result,3)
   data=substr(resultado,4,9)
   hora=substr (resultado,1,3)
   'set gxout shaded'
   'd lwo'

   'run rgbset.gs'
   'run cbarn.gs'

* draw the map
   'set mpdraw on'
   'draw map'
   'draw title Radiacao Onda Longa saindo do topo - 'data'-'hora
   'printim radiacao_olonga_topo_sigma-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
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
* Trocada a paleta para rgbset.gs
       'set ccols 0 52 53 55 57 59 39 37 35 33 22 24 26 27 28'                 
       'd (rc - rc (t - 1))*10'
       'run rgbset.gs'
       'run cbarn.gs 1 1 9.7 4.2'
       'set clab off'
       'set gxout contour'
       'set cmin 0.009'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'       
       'd (rc - rc (t - 1))*10'
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
       'set clab on'
       'set cint 2'
       'd pslv'
       'set cthick 5'
       'set ccolor 3'
       'd pslv'
       'draw title Pressao Superficie ' data' 'hora
       'printim prp-rn-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   else
       'set gxout shaded'
       'set cmin 0.009'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'
* Número níveis = 14                        
       'set ccols 0 52 53 55 57 59 39 37 35 33 22 24 26 27 28' 
* Número cores = 15               
       'd (rn - rn (t - 1))*10'
       'run rgbset.gs'
       'run cbarn.gs 1 1 9.7 4.2'

       'set clab off'
       'set gxout contour'
       'set cmin 0.009'
       'set cmax 50'
       'set clevs 0.009 0.02 0.05 0.1 0.2 0.5 1 2 3 5 10 20 35 50'       
       'd (rn - rn (t - 1))*10'
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

quit

function zinterp(field,zgrid,zlev)
*----------------------------------------------------------------------
* 
* Bob Hart (hart@ems.psu.edu) /  PSU Meteorology
* 3/4/1999
*
* GrADS function to interpolate within a 3-D grid to a specified
* height level.  Can also be used on non-pressure level data, such
* as sigma or eta-coordinate output where height is a function
* of time and grid level.
* 
* Advantages:  Easy to use, no UDFs.  Disadvantages:  Can take 3-10 secs.
*
* Arguments:
*    field = name of 3-D grid to interpolate
*
*    zgrid = name of 3-D grid holding height values at each gridpoint
*            Units of measurement are arbitrary.
*
*    zlev  = height level at which to interpolate (having same units as zgrid)
*
* Function returns:  defined grid interp holding interpolated values
*
* NOTE:  Areas having zlev below bottom level or above upper level 
*        in output will be undefined.
*
* NOTE:  No distinction in the function is made between height above
*        sea level, height above ground surface, or geopotential. The
*        function will give output regardless of which is sent.  
*        It is up to the user to be aware which height variable is
*        being passed to the function and treat the output accordingly.
*
* Example function calls:
*
*      "d "zinterp(temp,height,5000)
*
* Would display a temperature field interpolated to 5000.
*      
*      "define t1000="zinterp(temp,height,1000)
*
* Would define a new variable, t1000, as a temp field at 1000.
*
*      "d p1000="zinterp(lev,height,1000)
*
* Would display a field of the pressure at a height of 1000.
*
* PROBLEMS:  Send email to Bob Hart (hart@ems.psu.edu)
* 
*-----------------------------------------------------------------------
*-------------------- BEGINNING OF FUNCTION ----------------------------
*-----------------------------------------------------------------------
*
* Get initial dimensions of dataset so that exit dimensions will be
* same

"q dims"
rec=sublin(result,4)
ztype=subwrd(rec,3)
if (ztype = "fixed") 
   zmin=subwrd(rec,9)
   zmax=zmin
else
   zmin=subwrd(rec,11)
   zmax=subwrd(rec,13)
endif

* Get full z-dimensions of dataset.

"q file"
rec=sublin(result,5)
zsize=subwrd(rec,9)

* Determine spatially varying bounding height levels for height surface
* zabove = height-value at level above ; zbelow = height value at level
* below for each gridpoint

"set z 2 "zsize
"define zabove=0.5*maskout("zgrid","zgrid"-"zlev")+0.5*maskout("zgrid","zlev"-"zgrid"(z-1))"
"set z 1 "zsize-1
"define zbelow=0.5*maskout("zgrid","zgrid"(z+1)-"zlev")+0.5*maskout("zgrid","zlev"-"zgrid")"

* Isolate field values at bounding height levels
* fabove = requested field value above height surface
* fbelow = requested field value below height surface

"set z 2 "zsize
"define fabove=zabove*0+"field
"set z 1 "zsize-1
"define fbelow=zbelow*0+"field

* Turn this 3-D grid of values (mostly undefined) into a 2-D height layer
* mean is used here below for simplicity, since mean ignores undefined
* values.

"set z 1"
"define zabove=mean(zabove,z=2,z="zsize")"
"define fabove=mean(fabove,z=2,z="zsize")"
"define zbelow=mean(zbelow,z=1,z="zsize-1")"
"define fbelow=mean(fbelow,z=1,z="zsize-1")"

* Finally, interpolate linearly in height and create surface.

"set z "zmin " " zmax

"define slope=(fabove-fbelow)/(zabove-zbelow)"
"define b=fbelow-slope*zbelow"
"define interp=slope*"zlev"+b"

* variable interp now holds height field and its named it returned
* for use by the user.

say "Done.  Newly defined variable interp has "zlev" "field"-field."

return(interp)



******************************************************************



quit

*********
*  SAIR
*********
return

function paletaCoresUR ()
     'set rgb 16 240 255 240'
     'set rgb 17 200 255 200'
     'set rgb 18 0 255 10'
     'set rgb 19 0 200 20'
     'set rgb 20 0 150 30'
     'set rgb 21 0 100 40'
     'set rgb 22 0 050 50'
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
*     'set rgb 64 196   2   4'
return

exit

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
    * col.mm = nmero da cor da paleta (9) < 0    (14) 0 0.3     4 0.3 0.6
    if (col.mm = 0)
       col.mm = bc
    endif
    lim.mm = BAR_clev.mmpl
    * Última linha do q shades = 6 3 >  
  endwhile
else
  'q shades'
  _shades = result
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
  rec3 = sublin(result,3)
  rec4 = sublin(result,4)
  xsiz = subwrd(rec2,4)
  ysiz = subwrd(rec2,6)
  ylo = subwrd(rec4,4)
  xhi = subwrd(rec3,6)
  xd = xsiz - xhi
  xmid = xhi+xd/2
  ymid = ysiz/2 

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