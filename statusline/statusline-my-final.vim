hi! N1 guifg=#eee8d5 guibg=#005478 ctermfg=7 ctermbg=24
" hi! N1 guifg=#f0f0f0 guibg=#005478 ctermfg=254 ctermbg=24
hi! link N2 Visual
hi! link N3 LineNr
hi! link MyFileModified CursorLineNr

let s:myActiveLine=''

" TODO add func from vim-fugitive
" paste sign
let s:myActiveLine.='%#N2#%4{&l:readonly||!&l:modifiable?" RO ":""}'

" read-only sign
let s:myActiveLine.='%7{&paste?" PASTE ":""}'

" print current working dir relatively to homedir (~)
" also works in tabline
let s:myActiveLine.=' %{pathshorten(fnamemodify(getcwd(),":~"))} '

" will be shown when not modified, one space after ## for breathing room.
let s:myActiveLine.='%#N3# %{!&l:modified?MyCurrFname():""}'

" will be shown when file modified, no extra space due to the above.
let s:myActiveLine.='%#MyFileModified#%{&l:modified?MyCurrFname():""}'
" extra padding space, else will be "file.txt[+]"
let s:myActiveLine.='%{&l:modified?"  [+]":""}'

" separator from left to right side, resetting color
let s:myActiveLine.='%#N3#%='

" filetype, shown as "vim" for vimscript etc
let s:myActiveLine.='%{&l:filetype!=#""?&l:filetype:"[No ft]"} '

" preview flag, shown as "[Preview]"
let s:myActiveLine.='%w '

" This error will be displayed when encoding is not utf-8
" Note: when creating new file, &fileencoding is not set, not even upon saving,
" but we can use &encoding instead. (Triple "&" before l:encodins: "&& &l:enc")
let s:myActiveLine.='%#Error#%{&l:fileencoding==#"utf-8"||(&l:fileencoding==#""&&&l:encoding==#"utf-8")?"":" fenc:".&l:fileencoding." | enc:".&l:encoding." "}'

" file format, displayed like "vim" for vimscript
let s:myActiveLine.='%#N2# '
let s:myActiveLine.='%{&l:fileformat} '

let s:myActiveLine.='%#N1# '

" virtual column (will take into account tabs x spaces_per_tab)
let s:myActiveLine.='%3{virtcol(".")}'
let s:myActiveLine.=' | '

" current line
let s:myActiveLine.='%4{line(".")}'
let s:myActiveLine.='/'

" total lines
let s:myActiveLine.='%-4{line("$")} '


" Inactive statusline, all one color
let s:myInactiveLine='%#N3#'
" read-only flag [RO]
let s:myInactiveLine.='%r'
" filename
let s:myInactiveLine.=' %{MyCurrFname()}'
" modified [+]
let s:myInactiveLine.=' %m'
" separator filetype and preview flag
let s:myInactiveLine.='%=%y%w'

augroup MyStatusLine
	autocmd!
	autocmd VimEnter,WinEnter,BufWinEnter * let &l:statusline=s:myActiveLine
	autocmd WinLeave * let &l:statusline=s:myInactiveLine
	autocmd ColorScheme * hi! N1 guifg=#f0f0f0 guibg=#005478 ctermfg=254 ctermbg=24
augroup END

function! MyCurrFname()
	" try to get file path relative to current dir
	let l:fname=expand('%:.')
	if l:fname==#''
		return '[No Name]'
	endif
	if l:fname[0]!=#'/' && l:fname[0]!=#'\'
		return pathshorten(l:fname)
	endif
	" try to get file path relative to home dir
	let l:relToHome=fnamemodify(l:fname, ":~")
	if l:relToHome[0]==#'~'
		return pathshorten(l:relToHome)
	endif
	" if none of the above apply
	return pathshorten(l:fname)
endfunction

let &statusline=s:myActiveLine

" " how many occurrences of % in the resulting string, should be less than 80
" " uncomment the below when testing
" let s:myActiveLineItemsNo=strlen(substitute(s:myActiveLine, "[^%]", "","g"))
" if s:myActiveLineItemsNo <= 80
" 	echo "LineItems: " . s:myActiveLineItemsNo . ". (Max is 80) All good."
" else
" 	echohl Error
" 	echo "LineItems: " . s:myActiveLineItemsNo . ". (Max is 80) Max exceeded."
" 	echohl Normal
" endif
