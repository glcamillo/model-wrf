* Grads
* Enc: ISO 8859-1
* Modificações por Ten. Gerson (G&M@Jesus)
*  28fev05 Plotagem da vorticidade: mudança do multiplicador de 10.000 para 100.000.
*  13mar05: plotagem de vento em níveis sigma.
*  19jun05: novas variáveis para detectar o tamanho da plotagem (conf). 
*  06set05: plotagem de convergência de umidade em níveis sigma.
*  12set05: nova paleta de cores para DIV e W (paletaCoresDivW - 23 a 31).
*  06julho07: acrescimo de novos niveis sigma (rodada de 41 niveis).
*  07set07: funcoes de ajuste de paleta em arquivo separado.
*           Valor minimo para plotagem de prp: 0,1 -> 0,009
*  13mar08: uso do mapa de terreno no grads com a divisao politica por estados.
*           Arquivo brmap_hires fornecido pelo Cap Bastos.

* gradsc -blc "run plot.gs MMOUT_DOMAINx.ctl y"
function plot (args)
arq=subwrd(args,1)
conf=subwrd(args,2)


if ( conf != 1 & conf != 2 & conf != 3)
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
'run paletaCores.gs'


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
* Em 06julho07: acrescimo de novos niveis sigma. (G&M@Jesus)
niveisSigma.0 = 0.995
* Acrescimo => 41 niveis
niveisSigma.1 = 0.992
* Acrescimo => 41 niveis
niveisSigma.2 = 0.988
niveisSigma.3 = 0.985
niveisSigma.4 = 0.975
niveisSigma.5 = 0.965
niveisSigma.6 = 0.955
niveisSigma.7 = 0.940
niveisSigma.8 = 0.920
niveisSigma.9 = 0.900
niveisSigma.10 = 0.870
* Acrescimo => 41 niveis
niveisSigma.11 = 0.825

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

* Resoluções de Saída
if (conf = 1 | conf = 2)
   x_pontos = x700
   y_pontos = y525
else if (conf = 3)
   x_pontos = x500
   y_pontos = y700
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
  'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'
* Será usada a paleta da Vorticidade.
  'd mconv'
   PAL_DEF = 0
   NUM_SHADES = 13
   COLORBAR()
*   'set gxout contour'
*   'd mconv'
   'draw title Convergencia Umidade em 0.995 - 'data' 'hora
   'printim convumid_995-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

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
   'set ccols 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'
* Será usada a paleta da Vorticidade.
   'd mconv'
   PAL_DEF = 0
   NUM_SHADES = 13
   COLORBAR()
*   'set gxout contour'
*   'd mconv'
   'draw title Convergencia Umidade em 0.985 - 'data' 'hora
   'printim convumid_985-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


'set lev ' niveisSigma.0
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
  'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.0 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.0 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.0 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    
   i = i + 1
endwhile



* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.0
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.0 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.0 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.1
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   
   'draw title Vento, Temp e Alt Geop 'niveisSigma.1 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.1 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.1 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    
   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.1
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.1 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.1 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.2
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'

   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.2 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.2 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.2 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.2
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.2 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.2 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



'set lev ' niveisSigma.3
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'


   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.3 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.3 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.3 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.3
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.3 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.3 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.4
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
   'set clevs 3 5 8 12 16 20 25 30 35 40 45 50 55'
   'set ccols 41 42 43 44 45 46 47 48 49 50 51 52 53 54'
   'd u/0.5;v/0.5;mag(u/0.5,v/0.5)'
   PAL_DEF = 0
   BARRA()

   'set gxout contour'
*   'set digsize ' tam_digito
   'set ccolor 1'
   'set cthick 10'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
* 'set cthick 10': Espessura das linhas [1-20]   
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'

   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.4 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.4 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.4 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.4
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.4 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.4 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile



'set lev ' niveisSigma.5
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.5 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.5 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.5 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.5
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.5 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.5 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.6
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.6 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.6 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.6 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.6
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.6 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.6 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.7
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'

   'draw title Vento, Temp e Alt Geop 'niveisSigma.7 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.7 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.7 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'

   i = i + 1
endwhile


* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.7
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.7 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.7 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile




'set lev ' niveisSigma.8
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'

   'draw title Vento, Temp e Alt Geop 'niveisSigma.8 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.8 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.8 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'

   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.8
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.8 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.8 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


'set lev ' niveisSigma.9
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
* 'set strmden 1': Densidade das linhas 1 a 10 (padrão 5) - Quanto maior -> mais densas
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
*  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   
   'set gxout contour'
*  ccolor = 8 orange
   'set ccolor 8'
* 'set cthick 10': Espessura das linhas [1-20]   
   'set cthick 5'
*  cstyle 7 - dot dot dash
   'set cstyle 7'
**  'set clopts -1 -1 0.2'
* *  'set clopts -1 -1 0.2': Tamanho dos labels das linhas de contorno 0.09=padrão  
*  'set clab %gC'  NÃO É MAIS NECESSÁRIO
   'set cint 'CINT_H_SIG
   'd z'

   'draw title Vento, Temp e Alt Geop 'niveisSigma.9 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.9 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   teste = 'printim vnt-temp-sig-'niveisSigma.9 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
    
   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.9
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
*   'set gxout stream'
*   'set strmden 1'
*   'd u/0.5;v/0.5'
   'set gxout barb'
   'set hempref shem'
* This command controls the way wind barbs are plotted for any output where
*      wind barbs are produced.
* shem: overrides the default behavior so that all wind barbs are plotted
*      using the Southern Hemisphere convention.
   'd skip(u/0.5,8,8);v/0.5'

   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
*  'set clopts -1 -1 0.2'
   'set cint 2'
   'd (t - 273.16)'
*  'set clopts -1 -1 0.09'
   'draw title Vento, Temp e UR 'niveisSigma.9 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.9 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


'set lev ' niveisSigma.10
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
   'set cthick 10'
   'set cint 2'
  'd (t - 273.16)'
   'set gxout contour'
   'set ccolor 8'
   'set cthick 5'
   'set cstyle 7'
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.10 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.10 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.10
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
   'set gxout barb'
   'set hempref shem'
   'd skip(u/0.5,8,8);v/0.5'
   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'
   'd (t - 273.16)'
   'draw title Vento, Temp e UR 'niveisSigma.10 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.10 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

'set lev ' niveisSigma.11
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
   'set cthick 10'
   'set cint 2'
  'd (t - 273.16)'
   'set gxout contour'
   'set ccolor 8'
   'set cthick 5'
   'set cstyle 7'
   'set cint 'CINT_H_SIG
   'd z'
   'draw title Vento, Temp e Alt Geop 'niveisSigma.11 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.11 '-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile

* VENTO, TEMPERATURA, UR 
'set lev ' niveisSigma.11
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
   'set gxout barb'
   'set hempref shem'
   'd skip(u/0.5,8,8);v/0.5'
   'set gxout contour'
   'set ccolor 1'
   'set cthick 10'
   'set cint 2'
   'd (t - 273.16)'
   'draw title Vento, Temp e UR 'niveisSigma.11 ' ' data ' ' hora
   'printim vnt-temp-sig-'niveisSigma.11 'ur-' validade.i '.png ' x_pontos ' ' y_pontos ' white'
   i = i + 1
endwhile


quit
*********
*  SAIR
*********
return

function paletaCoresUR ()
     'set rgb 16 240 255 240'
     'set rgb 17 200 255 200'
     'set rgb 18 0 255 0'
     'set rgb 19 0 220 0'
     'set rgb 20 0 180 0'
     'set rgb 21 0 150 0'
     'set rgb 22 0 100 0'
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

*******************************************************  
* NÃO ACEITA COMENTÁRIOS DENTRO DE COMANDOS DE TOMADA DE DECISÃO (if, while)
*******************************************************
* FILLED CONTOURS OR SHADED GRIDS: quando se especifica níveis e cores para preenchimento de contornos (set gxout shaded) ou de células (set gxout grfill), deve-se especificar a quantidade de cores EM UMA UNIDADE A MAIS (set ccols) do que o nmero de contornos (set clevs). Ex.:
* set gxout shaded
* set clevs -5 -4 -3 -2 -1 1 2 3 4 5 (10)
* set ccols 16 17 18 19 20 1 21 22 23 24 25 (11)
******************************************************
* set cstyle style : Sets the contour linestyle. style options are: 
* 0 - no contours 
* 1 - solid 
* 2 - long dash 
* 3 - short dash 
* 4 - long dash, short dash 
* 5 - dotted 
* 6 - dot dash 
* 7 - dot dot dash 
********************************************************
* The GrADS Default Rainbow Sequence
* Col#  Description   Sample    R   G   B 
*  9   purple          160   0 200 
* 14   dark purple     110   0 220 
*  4   dark blue        30  60 255 
* 11   medium blue       0 160 255 
*  5   light blue        0 200 200 
* 13   aqua              0 210 140 
*  3   green             0 220   0 
* 10   yellow/green    160 230  50 
*  7   yellow          230 220  50 
* 12   dark yellow     230 175  45 
*  8   orange          240 130  40 
*  2   red             250  60  60 
*  6   magenta         240   0 130 
******************* FUNï¿½ES INTRï¿½SECAS ********************
* subwrd (string, n): This functions gets a single word from a string. The result is the nth word of string. If the string is too short, the result is NULL. n must be an integer.
* substr (string, start, length): This function gets part of a string. The sub-string of string starting at location start for length length will be returned. If the string is too short, the result will be short or NULL. start and length must be integers.
* sublin (string, n) This function gets a single line from a string containing several lines. The result is the nth line of string. If the string has too few lines, the result is NULL. n must be an integer. 
*********** COMANDOS QUERY *****************
* Depois de qualquer comando query, o valor a ser retornado ï¿½armazenado em %result%.
*    'query time'
*    say result
*    Time = 03Z13MAR1993 to 03Z13MAR1993  Sat to Sat

* Obs.: hï¿½casos em que o resultado por ser dado por:
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
* rn = prep nï¿½-convectiva acumulada (cm)
***************************************************
* if (a = b)
*     comando
* else
*     comando
* endif
************************************************
****   NÃO FICOU BOM *************
* *  TEMPERATURA E VENTO SUPERFÍCIE *
*  Início com i=2, pois o t=1 dá como grade indefinida
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
*  'disable print'
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
*  última linha do q shades = 6 3 >  

function BARRA (args)
**	circle colar bar
**	originally written by Paul Dirmeryer, COLA 
*	for the wx graphics on the COLA Web Page
**	generalized by Mike Fiorino, LLNL 26 Jul 1996
*
*	xc and yc are the center of the circle
*	bc is the background color
*
*	if not defined user upper left hand corner
**	sample call:  run cbarc 11 8.5 2  or run cbarc to use the defaults.

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
*	use black for the background as a default	
*
bc=subwrd(args,3)
if(bc = '' | bc='bc') ; bc=0; endif 

*
*	get the shades of the last graphic
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
    * ï¿½tima linha do q shades = 6 3 >  
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
*	default string
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
*	modifications by mike fiorino 940614
*
*	- the extreme colors are plotted as triangles
*	- the colors are boxed in white
*	- input arguments in during a run execution:
* 
*	run cbarn sf vert xmid ymid
*
*	sf   - scale the whole bar 1.0 = original 0.5 half the size, etc.
*	vert - 0 FORCES a horizontal bar = 1 a vertical bar
*	xmid - the x position on the virtual page the center the bar
*	ymid - the x position on the virtual page the center the bar
*
*	if vert,xmid,ymid are not specified, they are selected
*	as in the original algorithm
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
*	logic for setting the bar orientation with user overides
*
  if (ylo<ylolim | xd>xdlim1)
    vchk = 1
    if(vert = 0) ; vchk = 0 ; endif
  else
    vchk = 0
    if(vert = 1) ; vchk = 1 ; endif
  endif
*
*	vertical bar
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
*	horizontal bar
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
