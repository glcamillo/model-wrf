'reinit'
'open wrfout_d01_SIG-new.ctl'

print_gif = 0 

'set display color white'
'set grads off'
'clear'
'set mpdset hires'
'set gxout shaded'

'q file'
*rec=sublin(result,6)
rec=sublin(result,6)
say 'FILE (rec): ' rec
_endfieldnr=subwrd(rec,5) + 6
*_endfieldnr=subwrd(rec,12)
say 'FILE (_endfieldnr): ' _endfieldnr

'q ctlinfo'
say 'FILE - CTLINFO:result: ' result
*rec=sublin(result,11)
rec=sublin(result,8)
say 'FILE - CTLINFO (rec-8): ' rec
rec=sublin(result,7)
say 'FILE - CTLINFO (rec-7): ' rec
rec=sublin(result,6)
say 'FILE - CTLINFO (rec-6): ' rec
rec=sublin(result,5)
say 'FILE - CTLINFO (rec-5): ' rec
rec=sublin(result,4)
say 'FILE - CTLINFO (rec-4): ' rec
rec=sublin(result,3)
say 'FILE - CTLINFO (rec-3): ' rec
rec=sublin(result,2)
say 'FILE - CTLINFO (rec-2): ' rec
rec=sublin(result,1)
say 'FILE - CTLINFO (rec-1): ' rec

rec=sublin(result,7)
say 'FILE - CTLINFO (rec): ' rec

_t=subwrd(rec,3)
say 'FILE - CTLINFO (_t-3): ' _t
_t=subwrd(rec,2)
say 'FILE - CTLINFO (_t-2): ' _t
_t=subwrd(rec,1)
say 'FILE - CTLINFO (_t-1): ' _t

_t=subwrd(rec,2)
say 'FILE - CTLINFO (_t): ' _t


***** Loop through time staring from t
t = 0
say 't= ' t
while ( t < _t )
  t = t + 1
  say 't= ' t  
  'set t 't
  fieldnr = 14
  
***** PLOT ALL THE FIELDS    
  while ( fieldnr < _endfieldnr )
    'clear'
    'q file'
    rec=sublin(result,fieldnr)
    say rec
    field=subwrd(rec,1)
    say field
    _levs=subwrd(rec,2)
    say _levs
  
    current_lev = 1
*    'set lev 'current_lev
    'set z 'current_lev
    if ( _levs = 1 ) 
      'clear'
      'd ' field
      'run cbar.gs'
      'draw title ' rec 

      if (print_gif = 1) 
        'printim 'field'.gif gif'
      else
        pull dummy
      endif
    else
    while ( current_lev < _levs )
      'clear'
      'set lev 'current_lev
      'd ' field
      'run cbar'
*      'draw title ' rec ' - lev ' current_lev
      'draw title ' rec ' - z ' current_lev
      current_lev = current_lev + 1

      if (print_gif = 1) 
        'printim 'field'_'current_lev'.gif gif'
      else
        pull dummy
      endif
    endwhile
    endif

  
    fieldnr = fieldnr + 1
    say 'fieldnr= ' fieldnr
  endwhile

endwhile
