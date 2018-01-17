" Overwriting &l:statusline is faster(!) than changing highlight groups
" (either with links or without) for the purposes of changing colors.
" TODO make cool separators with their fg as bg normal and their bg as bg of
" surrounding areas


" hi! N1       guifg=#ffffff guibg=#005478 ctermfg=254 ctermbg=24
hi! N1       guifg=#f0f0f0 guibg=#005478 ctermfg=254 ctermbg=24
hi! N2       guifg=#f0f0f0 guibg=#444444 ctermfg=254 ctermbg=238
hi! N3       guifg=#7A6E4E guibg=#151515 ctermfg=137 ctermbg=233  gui=bold
hi! Mmod     guifg=#ffb964 guibg=#073642 ctermfg=172 ctermbg=0
" hi! Mmod     guifg=#ffb964 guibg=#151515 ctermfg=172 ctermbg=233
hi! I1       guifg=#f0f0f0 guibg=#752822 ctermfg=254 ctermbg=88
hi! R1       guifg=#f0f0f0 guibg=#662069 ctermfg=254 ctermbg=53
hi! V1       guifg=#fbfbfb guibg=#2F6300 ctermfg=255 ctermbg=22
hi! IA1      guifg=#4e4e4e guibg=#1c1c1c ctermfg=239 ctermbg=234
hi! IA2      guifg=#4e4e4e guibg=#262626 ctermfg=239 ctermbg=235
hi! IA3      guifg=#4e4e4e guibg=#302028 ctermfg=239 ctermbg=236

hi! link User1 N1
hi! link User2 I1
hi! link User3 V1
hi! link User4 N2
hi! link User5 N2
hi! link User6 N2
hi! link User7 StatusLineTermNC

function! MyNormalConditional(hlcode, minwid, expression) abort
	" produces a string for evaluation in statusline that will be highlighted
	" when in normal mode, or will be empty(and highlighted) otherwise, thus invisible.
	" usage:
	" let g:myLine.=MyNormalConditional('%7*', '1', '"NORMAL"')
	" will result in:
	" let g:myLine.='%7*%1{mode()==#"n"?"NORMAL":""}'
	return a:hlcode . '%' . a:minwid . '{mode()==#"n"?' . a:expression . ':""}'
endfunction

function! MyInsertConditional(hlcode, minwid, expression) abort
	return a:hlcode . '%' . a:minwid . '{mode()==#"i"?' . a:expression . ':""}'
endfunction

function! MyVisualConditional(hlcode, minwid, expression) abort
	return a:hlcode . '%' . a:minwid . '{mode()==#"\<C-v>"||mode()==?"v"?' . a:expression . ':""}'
endfunction

let g:myLine=''
let g:myLine.=MyNormalConditional('%1*', '8', '" NORMAL "')
let g:myLine.=MyInsertConditional('%2*', '8', '" INSERT "')
let g:myLine.=MyVisualConditional('%3*', '8', '" VISUAL "')

let g:myLine.=MyNormalConditional('%1*', '8', '&paste?"│ PASTE ":""')
let g:myLine.=MyInsertConditional('%2*', '8', '&paste?"│ PASTE ":""')
let g:myLine.=MyVisualConditional('%3*', '8', '&paste?"│ PASTE ":""')

" RO will apear if either 'set readonly' or 'set nomodifiable' is true
let g:myLine.=MyNormalConditional('%4*', '4', '&l:readonly||!&l:modifiable?" RO ":""')
let g:myLine.=MyInsertConditional('%5*', '4', '&l:readonly||!&l:modifiable?" RO ":""')
let g:myLine.=MyVisualConditional('%6*', '4', '&l:readonly||!&l:modifiable?" RO ":""')

" will be shown when file modified, one space after ## for breathing room.
let g:myLine.='%#Mmod# %{&l:modified?expand("%:t")." [+] ":""}'

" will be shown when not modified, note no space before %{}, as opposed to the
" 'modified' option above. Otherwise else 2 spaces will be shown.
let g:myLine.='%#LineNr#%{!&l:modified?expand("%:t"):""}'

" separator
let g:myLine.='%='

let g:myLine.='%w '

let g:myLine.='%{&l:filetype} '

" this will be displayed when encoding is not utf-8
let g:myLine.='%#Error#%{&l:fileencoding!=#"utf-8"?" NOT UTF-8! ":""}'

" 'minwid' here is set to 1 because encodings 'dos', 'unix', 'mac' not the same
" length and we pad with spaces manually, so that there is exactly one white
" space before and after the resulting string.
let g:myLine.=MyNormalConditional('%4*', '1', '" ".&l:fileencoding." │ ".&l:fileformat." "')
let g:myLine.=MyInsertConditional('%5*', '1', '" ".&l:fileencoding." │ ".&l:fileformat." "')
let g:myLine.=MyVisualConditional('%6*', '1', '" ".&l:fileencoding." │ ".&l:fileformat." "')

let g:myLine.=MyNormalConditional('%1*', '8', 'line(".")*100/line("$")."% │ "')
let g:myLine.=MyInsertConditional('%2*', '8', 'line(".")*100/line("$")."% │ "')
let g:myLine.=MyVisualConditional('%3*', '8', 'line(".")*100/line("$")."% │ "')

let g:myLine.=MyNormalConditional('%1*', '3', 'line(".")')
let g:myLine.=MyInsertConditional('%2*', '3', 'line(".")')
let g:myLine.=MyVisualConditional('%3*', '3', 'line(".")')


let g:myLine.=MyNormalConditional('%1*', '-4', '":".virtcol(".")')
let g:myLine.=MyInsertConditional('%2*', '-4', '":".virtcol(".")')
let g:myLine.=MyVisualConditional('%3*', '-4', '":".virtcol(".")')
" virtcol(".")

let &statusline=g:myLine

" len(a:000) --> length of param list (...), a:000[0] -> first param
