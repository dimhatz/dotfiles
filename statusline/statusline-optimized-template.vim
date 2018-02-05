" This is a sample template for building advanced custom statusline.
" Run this whole file by ":so %" and modify till you get the desired result.
" Then include in vimrc or load as preferred, (while replacing globals with
" script-locals).
" In vim's statusline there is a maximum of 80 items that start with %
" The script also checks for this in the end.

" Note2: (After some testing)
" Overwriting &l:statusline is faster(!) than changing highlight groups
" (either with links or without) for the purposes of changing colors.
" Using conditional elements (created with NIVRConditional) seems just as fast
" on my slower machine.
" TODO make cool separators with their fg as bg normal and their bg as bg of
" surrounding areas

hi! N1       guifg=#f0f0f0 guibg=#005478 ctermfg=254 ctermbg=24
hi! N2       guifg=#f0f0f0 guibg=#444444 ctermfg=254 ctermbg=238
hi! N3       guifg=#7A6E4E guibg=#151515 ctermfg=137 ctermbg=233  gui=bold
" MyFileModified hl group for modified file's appearance
hi! MyFileModified     guifg=#ffb964 guibg=#073642 ctermfg=172 ctermbg=0
hi! I1       guifg=#f0f0f0 guibg=#752822 ctermfg=254 ctermbg=88
hi! R1       guifg=#f0f0f0 guibg=#662069 ctermfg=254 ctermbg=53
hi! V1       guifg=#fbfbfb guibg=#2F6300 ctermfg=255 ctermbg=22

hi! link User1 N1
hi! link User2 I1
hi! link User3 V1
" some color for replace mode goes here

hi! link User4 N2
" I2 and V2 are same as N2 for this theme
hi! link User5 N2
hi! link User6 N2
hi! link User7 StatusLineTermNC

function! NIVRConditional(hlArray, minwid, exprArray)
	" "hlArray" should be array of 4 strings (in statusline`s format like '%1*'
	" or '%#Normal#') representing highlightling for Normal, Insert, Visual and
	" Replace. Formatting like '%1*' till '%1*' will correspond to hi groups
	" User1 till User9.
	" "minwid" should be a string with a number, as described in :h statusline.
	" exprArray should be an array of 1 or 4 elements, depending on whether
	" expression shown in each mode (Norm, Ins etc) is different or the same.
	" Returns a string containing statusline "conditional elements". This
	" string can readily be appended to statusline.
	" Note: using conditional highlighting like this is a lot faster than when
	" switching with "hi! link" back and forth. On my slower machine there is a
	" cursor blink when entering insert mode if I use "autocmd InsertEnter" to
	" re-link hl group of an element to another hl group (or redefine the hl
	" group with "hi!")
	if (len(a:hlArray)!=#4)||len(a:exprArray)==#0
		return ''
	endif
	let [l:hlNormal, l:hlInsert, l:hlVisual, l:hlReplace]=a:hlArray
	let l:result=''
	let l:result.=l:hlNormal . '%' . a:minwid . '{mode()==#"n"?' . a:exprArray[0] . ':""}'
	if len(a:exprArray)==#4
		let l:result.=l:hlInsert . '%' . a:minwid
					\ . '{mode()==#"i"?' . a:exprArray[1] . ':""}'
		let l:result.=l:hlVisual . '%' . a:minwid
					\ . '{mode()==#"\<C-v>"||mode()==?"v"?' . a:exprArray[2] . ':""}'
		" " To save some statusline items budget (max is 80) we can skip
		" " everything in replace mode by commenting next 2 lines.
		" let l:result.=l:hlReplace . '%' . a:minwid
		" 			\ . '{mode()==#"R"?' . a:exprArray[3] . ':""}'
	else
		let l:result.=l:hlInsert . '%' . a:minwid
					\ . '{mode()==#"i"?' . a:exprArray[0] . ':""}'
		let l:result.=l:hlVisual . '%' . a:minwid
					\ . '{mode()==#"\<C-v>"||mode()==?"v"?' . a:exprArray[0] . ':""}'
		" " To save some statusline items budget (max is 80) we can skip
		" " everything in replace mode by commenting next 2 lines.
		" let l:result.=l:hlReplace . '%' . a:minwid
		" 			\ . '{mode()==#"R"?' . a:exprArray[0] . ':""}'
	endif
	return l:result
endfunction

let g:myLine=''

" Each visual mode will be shown with different text: "VISUAL", "V-BLOCK", "V-LINE"
let g:myVisualModesExpr='mode()==#"\<C-v>"?" V-BLCK ":mode()==#"V"?" V-LINE ":" VISUAL "'
let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '8'
			\ , ['" NORMAL "' , '" INSERT "', g:myVisualModesExpr,  '"  REPLACE "'])

" To have shown "VISUAL" for all of them.
" Comment out the above paragr and use the below 2 lines.
" let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '8'
" 			\ , ['" NORMAL "' , '" INSERT "', '" VISUAL "',  '" REPLACE "'])

let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '8'
			\ , ['&paste?"│ PASTE ":""'])

" RO will apear if either 'set readonly' or 'set nomodifiable' is true
let g:myLine.=NIVRConditional(['%4*', '%5*', '%6*', '%6*'], '4'
			\ , ['&l:readonly||!&l:modifiable?" RO ":""'])

" will be shown when not modified, one space after ## for breathing room.
let g:myLine.='%#LineNr# %{!&l:modified?expand("%:t"):""}'

" will be shown when file modified, no extra space due to the above.
let g:myLine.='%#MyFileModified#%{&l:modified?expand("%:t")." [+] ":""}'

" separator from left to right side, resetting color
let g:myLine.='%#LineNr#%='

" preview flag, shown as "[Preview]"
let g:myLine.='%w '

" filetype, shown as "vim" for vimscript etc
let g:myLine.='%{&l:filetype} '

" This error will be displayed when encoding is not utf-8
" Note: when creating new file, &fileencoding is not set, not even upon saving,
" but we can use &encoding instead. (Triple "&" before l:encoding: "&& &l:enc")
let g:myLine.='%#Error#%{&l:fileencoding!=#"utf-8"&&(&l:fileencoding==#""&&&l:encoding!=#"utf-8")?" NOT UTF-8! ":""}'

" 'minwid' here is set to 1 because encodings 'dos', 'unix', 'mac' are not of
" the same length and we pad with spaces manually, so that there is exactly one
" white space before and after the resulting string.
let g:myLine.=NIVRConditional(['%4*', '%5*', '%6*', '%6*'], '1'
			\ , ['" ".(&l:fileencoding?&l:fileencoding:&l:encoding)." │ ".&l:fileformat." "'])

" line percentage
let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '8'
			\ , ['line(".")*100/line("$")."% │ "'])

let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '3'
			\ , ['line(".")'])

let g:myLine.=NIVRConditional(['%1*', '%2*', '%3*', '%3*'], '-4'
			\ , ['":".virtcol(".")'])

let &statusline=g:myLine

" how many occurrences of % in the resulting string, should be less than 80
let g:myLineItemsNo=strlen(substitute(g:myLine, "[^%]", "","g"))
if g:myLineItemsNo <= 80
	echo "LineItems: " . g:myLineItemsNo . ". (Max is 80) All good."
else
	echohl Error
	echo "LineItems: " . g:myLineItemsNo . ". (Max is 80) Max exceeded."
	echohl Normal
endif

