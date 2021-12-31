* Grads
* Enc: UTF-8
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
* 22jul10: arquivo convertido para UTF-8.
*          Uso do script para plotagem da barra: 'run plot-cbar.gs'

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
*   COLORBAR()
*   'set gxout contour'
*   'd mconv'
   'run plot-cbar.gs'
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
*   COLORBAR()
*   'set gxout contour'
*   'd mconv'
     'run plot-cbar.gs'  
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
*   BARRA()
   'run plot-cbar.gs'

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
   'run plot-cbar.gs'
*   BARRA()
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
*   BARRA()
   'run plot-cbar.gs'

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()

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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()
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
   'run plot-cbar.gs'
*   BARRA()
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



quit
