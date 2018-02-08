" location of vimrc on windows c:\users\username\_vimrc
set nocompatible               " Be iMproved

" set synmaxcol=128
" syntax sync minlines=256

" TODO make a check on startup to make sure that on windows the vimfiles dir is
" either empty or does not exist? (display an error and exit)
if !has('nvim') && (has('win32') || has('win64'))
	set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
	let g:plughomeddd='~/.vim/plugged'
else
	let g:plughomeddd='~/.vim/plugged'
endif

" always start in home dir on windows
cd ~

" ================== Plugin manager ===========================================
call plug#begin(g:plughomeddd)

" --------------- Themes + visual

" solarized, supposedly more consistent than orig
" prev romainl/flattened commit
Plug 'romainl/flattened', {'commit': '048ad9e570a6b0cd671618ccb0138c171e0b9c52'}

" original solarized
" prev altercation/vim-colors-solarized commit
Plug 'altercation/vim-colors-solarized', {'commit': '528a59f26d12278698bb946f8fb82a63711eec21'}

" another solarized, between the above 2
" prev lifepillar/vim-solarized8 commit
Plug 'lifepillar/vim-solarized8', {'commit': 'b64bca5f6ce418589986a03e37df53b3d0625575'}

" --------------- Plugins
" TODO: To delete buffer without closing its window: :BD
" qpkorr/vim-bufkill

" prev ap/vim-buftabline commit 12f29d2cb11d79c6ef1140a0af527e9231c98f69
Plug 'ap/vim-buftabline', {'commit': '12f29d2cb11d79c6ef1140a0af527e9231c98f69'}

" prev easymotion/vim-easymotion commit d55e7bf515eab93e0b49f6f762bf5b0bf808264d
Plug 'easymotion/vim-easymotion', {'commit': 'e4d71c7ba45baf860fdaaf8c06cd9faebdccbd50'}

" prev jiangmiao/auto-pairs commit
" Alternative: delimitmate, suggested by ycm, also neopairs by shougo
Plug 'jiangmiao/auto-pairs', {'commit': '6afc850e2429e6832a1b093e32a31e0b5eff477d'}

" prev tommcdo/vim-exchange commit
Plug 'tommcdo/vim-exchange', {'commit': '05d82b87711c6c8b9b7389bfb91c24bc4f62aa87'}

" prev tpope/vim-surround commit
Plug 'tpope/vim-surround', {'commit': 'e49d6c2459e0f5569ff2d533b4df995dd7f98313'}

" prev tomtom/tcomment_vim commit
Plug 'tomtom/tcomment_vim', {'commit': '6f1f24840be163e85d610837567221639e268ddc'}

" make vim-surround and vim-commentary repeatable
Plug 'tpope/vim-repeat', {'commit': '070ee903245999b2b79f7386631ffd29ce9b8e9f'}

" To check whether its working :echo vimproc#system('dir')
Plug 'Shougo/vimproc.vim', {'commit': '57cad7d28552a9098bf46c83111d9751b3834ef5'}

" Fullscreen gvim on windows (uses dll)
Plug 'derekmcloughlin/gvimfullscreen_win32', {'commit': '6abfbd13319f5b48e9630452cc7a7556bdef79bb'}

" Plug 'Shougo/neocomplete', {'commit': 'd8caad4fc14fc1be5272bf6ebc12048212d67d2c'}

" prev youcompleteme commit: bade99f5e9c5ba2f848cffb2d1a905e85d3ddb05
" update this on its own only with ":PlugUpdate YouCompleteMe"
Plug 'Valloric/YouCompleteMe', {'commit': '290dd94721d1bc97fab4f2e975a0cf6258abfbac'}

" autoclose tags for html, xhtml
Plug 'alvan/vim-closetag', {'commit': 'fafdc7439f7ffbf6bb9a300652e2506cb07515d3'}

" html5 omnicomplete and syntax (and indentation?)
Plug 'othree/html5.vim', {'commit': '916085df16ad6bd10ecbd37bc5d44b62f062572b'}

" css3 better completion
Plug 'othree/csscomplete.vim', {'commit': 'f0059f00df5890bf81d8f011d9b98354761a31f0'}

" javascript/jsdoc/ngdoc/flow syntax and indentation
Plug 'pangloss/vim-javascript', {'commit': 'cea724c0e1a330fff1d38018667a748c26559a57'}

" Better JSON highlighting, hides the quotes, on all lines except current - better readability.
Plug 'elzr/vim-json', {'commit': 'f5e3181d0b33a9c51377bb7ea8492feddca8b503'}


" -------------------- Plugin-related todo's ------------------------------
" TODO check out Ultisnips later, supposedly works well with ycm
" TODO check out nerdtree,
" TODO vim-javascript and flow for javascript static checking, also ternjs.
" TODO w0rp/ale, async linting, like syntastic?
" TODO check out ctrlp and also FelikZ/ctrlp-py-matcher for faster ctrlp
" also it is supposedly better on windows with ag. Ripgrep must be even
" faster.
" TODO check out IndentLine plugin to show "|" indent in projects using spaces.
" TODO check out EMMET plugin for efficient html production.
" TODO check out CompleteTags for xml, html, md
" TODO check out michaeljsmith/vim-indent-object for selecting based on indentation
" TODO FYI alternative for airline mgee/lightline-bufferline.
" TODO check out fast fold plugin, folding may slow down autocompletion.
" TODO check out dispatch as async runner
" TODO check out tagbar for code's outline based off tags (classes, methods etc)
" TODO tag generation and updating: Gutentags
" TODO check out chrisbra/NrrwRgn for focusing on excerpt of code (isolate and edit it)
" TODO check out sheerun/vim-polyglot: collection of language plugins (syntax,
" filetypes, indentation; like othree/html5 that is also included in it)
" TODO check out othree/javascript-libraries-syntax.vim: special syntax for js
" libs like react, angular, vue etc
" TODO integrate YCM error messages into lightline: use my vim-airline-loclist
" file as base (previously used to integrate with airline) or current airline.
call plug#end()

" Eclim -> was installed by the installer with checked android support.
" REMINDER: set encoding to utf-8 in eclipse too.

" Never upgrade vim-plug itself automatically:
delc PlugUpgrade
" =============================================================================

" ================== My settings =============================================
set backupcopy=yes " make windows change the linked file when editing symlinks
" no more netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
" ------------------ GUI fonts
" as of Jul 2017 nvim always returns 0 for has("gui_running")
if has("gui_running")
	if has("gui_gtk2") " TODO add gtk3 too
		set guifont=Source\ Code\ Pro\ Medium\ 10
		" no extra spacing - not checked on gtk vim linux
		set linespace=0
	elseif has("gui_win32")
		set guifont=Source_Code_Pro_Medium:h10:cANSI:qDRAFT
		" no extra spacing, linespace was 1 by default, increase if
		" underlines cover other lines
		set linespace=0
		" set renderoptions=type:directx " see below, do not set for now
	elseif has("x11")
	" Also for GTK 1
	endif
endif

" <C-CR> to switch between input languages
set imi=1
function! s:ChangeKeymapDDD()
	if &keymap !=# "greek"
		set keymap=greek
	else
		set keymap=""
		" iminsert becomes 0 here
		" now set it to 1, else the switch will only occur after "<esc>a"
		set imi=1
	endif
	return ""
endfunction

inoremap <C-CR> <C-R>=<SID>ChangeKeymapDDD()<CR>

"" System general settings
set shortmess+=I                                    " disable start message
set mouse=a                                         "enable mouse
set encoding=utf-8                                  "set encoding for text
set ttyfast                                         "assume fast terminal connection, fast redraws
set hidden                                          "allow buffer switching without saving
set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal/hex numbers

if exists('&shortname')                      "neovim does not have this
	set noshortname                      "no dos-style short names for files
endif

"" Visual general settings
set showcmd             " show (partial) command in bottom-right
set number              " show line numbers
syntax on           " syntax enable syntax processing, *syntax on* overrides with defaults!
set showmatch           " highlight matching [{()}]
set scrolloff=200       " no. of lines shown above/below cursor, large no. will always have cursor in middle
set noerrorbells visualbell t_vb= " no error bells at all
autocmd GUIEnter * set visualbell t_vb= " needed as gvim will reset t_vb

"" Tabs and spaces
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " for indentation command (">>") in normal mode
"set expandtab       " tabs are spaces
"set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start      "allow backspacing everything in insert mode
set list                 "highlight whitespace
"set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮,nbsp:■   " does not display on windows without directx render
set listchars=tab:│\ ,trail:•,extends:»,precedes:«,nbsp:■
"set shiftround          " Round indent to multiple of 'shiftwidth'. +Applies to > and <
"set smarttab            " insert blanks according to shiftwidth (else tabstop or softtabstop)
set wrap            " wrap text on eol (default)
" let &showbreak='↪ '    " does not display on windows without directx render
let &showbreak='▶ '      " Char to signify line break
set autoindent           " The simplest automatic indent

" ------------------------------------------------------------------------------
" Force redraw on focus gain, fixes some visual bugs under gvim + windows
" May cause commands that spawn windows command prompt (like :PingEclim
" to be shown without the returned text, but with "press any key"), to see
" them use :messages (":mes"). To manual redraw: <c-l>
" TODO on win10 there is no cmd popup! Investigate! Try on win10 (with
" different builds: github, tux, kaoriya):
" :echo system('dir')

" if has('gui_running')
" 	augroup RedrawOnFocusDDD
" 		autocmd!
" 		autocmd FocusGained * :redraw!
" 	augroup END
" endif
" ------------------------------------------------------------------------------

" Clipboard
if has('unnamedplus')
	set clipboard=unnamedplus                             "sync with "CLIPBOARD" OS clipboard, uses "+ register
else
	set clipboard=unnamed                             "sync with "PRIMARY" OS clipboard, uses "* register
endif

" Searching
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          "ignore case for searching

" Wildmenu
set wildmenu            " visual autocomplete for command menu
set wildmode=list:longest,full       " complete longest common, then cycle with tab, back cycle shift-tab
set wildignorecase                   " ignore case in wildmenu search

"" Keyboard and cursor
set timeout ttimeout         " enable separate mapping and keycode timeouts
set timeoutlen=400           " mapping timeout ms (default 1000)
set ttimeoutlen=50           " keycode timeout ms (default -1, unset when having ssh with latency)

" Add tags from tag folder (libraries)
" remove searching tags in current file's directory
" tags should be read only from ~/tags/*.tags and from current working dir
" (not from current file's dir if its different from working dir)
set tags-=./tags
set tags-=./TAGS

"" Tags
"" if has('path_extra') " from sensible.vim
""  setglobal tags-=./tags tags^=./tags;
"" endif
" set showfulltag         " shows tag and search pattern as matches

" always split below, when opening help/quickfix/etc
set splitbelow

" keep the cursor on the same colum when jumping and switching buffers (do not jump to beginning of the line)
set nostartofline

" GUI
if has('gui_running')
	set guicursor=a:blinkon0 " dont blink, the rest are defaults ddd new
	set guioptions-=t                                 "no tear off menu items
	set guioptions+=c                                 "no gui dialogs
	set guioptions-=T                                 "no toolbar icons
	set guioptions-=r                                   " no right scrollbar
	set guioptions-=l           " no left scrollbar
	set guioptions-=L           " no left scrollbar when vert. split
	set guioptions-=m           " no menu
	set guioptions-=e           " no ugly GUI-style tabline
endif

" Setting formatoptions to define behavior when pressing enter on commented line to
" continue comments etc
" "set formatoptions" can be overriden by plugins
" https://superuser.com/questions/401090/how-to-prevent-certain-vim-formatoptions-from-being-enabled-by-ftplugins
" -=c will remove comment auto-line-break (:h formatoptions)
augroup myFormatOptsDDD
	autocmd!
	autocmd FileType * setlocal formatoptions-=t formatoptions-=o
augroup END

" open file with cursor on last edit (from :h last-position-jump)
augroup openFileWithCursorAtLastEditDDD
	autocmd!
	au BufReadPost *
		\ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
		\ |   exe "normal! g`\""
		\ | endif
augroup END

" <cr> follows links in help files
augroup enterFollowHelpLinkDDD
	autocmd!
	autocmd FileType help nnoremap <buffer> <cr> <c-]>
augroup END

" always show gutter(sign column)
augroup AlwaysShowGutterDDD
	autocmd!
	autocmd BufEnter * sign define dummy
	autocmd BufEnter * execute 'sign place 999999 line=1 name=dummy buffer=' . bufnr('')
augroup END
" ----------------------- KEY REMAPS
" Swap : and ; to make colon commands easier to type
" The vice versa remapping *may* break plugins - to be confirmed
nnoremap  ;  :
"nnoremap  :  ;
xnoremap  ;  :
"xnoremap  :  ;

" make comma the new ; (normally comma repeats f-style movements, like ";" but
" in the opposite direction), make "\" the new comma.
nnoremap , ;
xnoremap , ;
nnoremap \ ,
xnoremap \ ,

" now "C-p" and "C-n" autocomplete the beginning of the command and search.
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Space is the new leader
nnoremap <Space> <Nop>
xnoremap <Space> <Nop>
onoremap <Space> <Nop>
let mapleader = "\<Space>"

" Disable <c-c> in insert, normally it exits to normal without triggering the
" InsertLeave autocommands - never a good idea.
inoremap <c-c> <nop>

" for navigation of wrapped lines --> investigate side effects
nnoremap j gj
nnoremap k gk

" map } and { to :bnext and :bprev
nnoremap <silent> } :bnext<CR>
nnoremap <silent> { :bprev<CR>

" jump paragraph with ( , )
nnoremap ( {
nnoremap ) }

" Paste over smth in visual does not overwrite the main '+' register.
xnoremap <silent> p p:let @+=@0<CR>
" TODO: detect when "dd"-ing empty/whitespace lines and stop overwriting "+"
" register, or bring back the other register.

" x will always delete to black hole
nnoremap x "_x
xnoremap x "_x

" X deletes to black hole till end of line
nnoremap X "_D

" Y yanks till end of line, instead of whole line
nnoremap Y y$

" BEGIN_ESCAPE_WORKAROUND
" <ESC> clears search highlights and exhange marking highlights.
" GUI doesnt need <ESC><ESC> workaround, so lets not add the its delay.
if has('gui_running')
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	" the <ESC> mapping unmaps cxc for some reason, so redo the mapping
	nnoremap <silent> cxc :execute "normal \<Plug>(ExchangeClear)"<CR>
else
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	nnoremap <silent> <ESC><ESC><ESC> :nohlsearch<CR><ESC>:execute "normal \<Plug>(ExchangeClear)"<CR>
	" the <ESC> mapping unmaps cxc for some reason, so redo the mapping
	nnoremap <silent> cxc :execute "normal \<Plug>(ExchangeClear)"<CR>
endif
" END_ESCAPE_WORKAROUND

"====[ Swap V and CTRL-v. Regular visual is now Shift-v. ]======
"====[ Block mode is more useful that Visual mode ]======
nnoremap    v   <C-V>
xnoremap    v   <C-V>
nnoremap <C-V>     V
xnoremap <C-V>     V
nnoremap    V   v
xnoremap    V   v

" move to beginning/end of line (also consider B and E as alternative)
" <C-H> by default in terminal is produced by backspace, using <C-J>
noremap <C-J> ^
noremap <C-K> $
" <C-K> appends to end of line, useful to escape auto-closing parens
inoremap <silent><C-J> <ESC><ESC>I
inoremap <silent><C-K> <ESC><ESC>A
" command mode move to beginning/end
cnoremap <C-A> <Home>
cnoremap <C-L> <End>

" ----------------------------------------------------------------
" <leader>c cd's into the directory on current file
nnoremap <leader>c :cd %:p:h<CR>

" Paste from main buffer into command mode, filterling out tabs and newlines
" does not modify my main "+" register, as it uses z register.
" This is useful for copy-pasting lines into command mode lines from vimrc.
" This will not work on multi-line selections to be pasted into command, use
" MyExecuteLineRangeDDD for this.
" double c-r at end to insert literally (whe yanked text contains "^h" it will
" not result in <BS> performed)
" <C-R>= prompts for an expression, BS will delete the 0 from the expression.
cnoremap <C-R> <C-R>=<SID>FilterNLTabYankToRegZ()<CR><BS><C-R><C-R>z
" filters tabs and new lines from clipboard: @+ into reg @z
" Tabs are replace by spaces just in case.
function! s:FilterNLTabYankToRegZ()
	let @z=substitute(@+, '\n', '', 'g')
	let @z=substitute(@z, '\t', ' ', 'g')
endfunction

" source selected lines into vim command (useful when testing scripts) using
":[range]MyExecuteLineRangeDDD    Execute text lines as ex commands.
" Also handles :h line-continuation.
" https://stackoverflow.com/questions/20262519/vim-how-to-source-a-part-of-the-buffer
command! -bar -range MyExecuteLineRangeDDD silent <line1>,<line2>yank z | let @z = substitute(@z, '\n\s*\\', '', 'g') | @z
xnoremap <Leader>r :MyExecuteLineRangeDDD<CR>

" use <C-T> to paste from specific register (the original <C-R> is now <C-T>)
cnoremap <C-T> <C-R>

" ----------------------------------------------------------------
" <C-Q> exits(if last window, else closes window), aka always close window.
" Now it will not quit when having open an single buffer and a help window!
" TODO: shorten this to an expression mapping
" nnoremap <expr> <C-Q> winnr() ==# winnr('$') ? execute 'quit'  : execute 'wincmd c')
nnoremap <C-Q> :call MyCloseFuncDDD()<CR>
function! MyCloseFuncDDD()
	if winnr() ==# winnr('$')
		quit
	else
		wincmd c
	endif
endfunction

" c-s writes(if buffer was modified), c-c deletes buffer
nnoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>
inoremap <silent><C-S> <ESC><ESC>:update<CR><ESC>

" <c-c> deletes current buffer.
" <c-c> interrupts terminal vim when busy (useful to break from endless loop)
" even if remapped. In GUI when remapped -> use CTRL-Break.
nnoremap <silent><C-C> :bdelete<CR>
" ----------------------------------------------------------------

" <leader>s performs substitution
nnoremap <Leader>s :%s/

" Reselect pasted text linewise, ( `[ is jump to beginning of changed/yanked )
nnoremap <Leader>v `[V`]

" Uppercase current word in norm/insert
nnoremap <C-\> gUiw
inoremap <C-\> <ESC>gUiwea

" Jump a word forward in insert mode, weirdly, does not break insert undo sequence.
inoremap <C-e> <ESC>ea
" Jump a word back in insert mode, weirdly, does not break insert undo sequence.
inoremap <C-b> <ESC>bi

"====[ '*' in visual to search on selection - the correct way ]=============
" <c-u> is needed to remove '<'> of visual
" edit: since * is just too far, <c-f> will become new * for visual and norm.
" xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
nnoremap * <nop>
xnoremap * <nop>
" <c-f> is the new * (F is for Find)
nnoremap <C-f> *
xnoremap <C-f> :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
" backward search on #
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
" The function itself
function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s = temp
endfunction

" In normal <leader>f will highlight all occurrences of word under cursor
nnoremap <Leader>f viw:<C-u>call <SID>VSetSearch()<CR>:<C-u>set hlsearch<CR>

" In visual search for current selection to make it substitution target
" xmap <Leader>s *:<C-u>%s//
xnoremap <Leader>s :<C-u>call <SID>VSetSearch()<CR>:<C-u>set hlsearch<CR>:<C-u>%s//

" <c-f> in insert types "="
inoremap <C-F> =
cnoremap <C-F> =

" <c-g> in insert types "+"
inoremap <C-G> +
cnoremap <C-G> +
" ============================================================================

" Cool terminal shape when in xterm
if &term =~ '^xterm'
	" solid underscore
	let &t_SI .= "\<Esc>[6 q"
	" solid block
	let &t_EI .= "\<Esc>[2 q"
	" 1 or 0 -> blinking block
	" 2 solid block
	" 3 -> blinking underscore
	" 4 -> solid underscore
	" Recent versions of xterm (282 or above) also support
	" 5 -> blinking vertical bar
	" 6 -> solid vertical bar

	" 24bit color for mintty -> to be checked on xterm, hopefully perform.
	" is not affected and we can stop sourcing custom color palette into xterm.
	if exists('$OS') && $OS ==# 'Windows_NT'
		set termguicolors
	endif
endif

" ---------------------- COLORS
set background=dark " for original solarized theme
colorscheme flattened_dark
let g:solarized_underline=1

" after 80 columns the following columns background will be lighter (range max 256)
let &colorcolumn=join(range(81,336),",")

" ------------------------------------------------------------------------------
" make completion dropdown same style as comments but underlined + not italic
" TODO make this copy values: bg->from Norm, fg->from Comment instead of hardcoded values
" To actually do the above may require parsing etc. For now lets set up
" hardcoded values depending on theme to being switched to (solarized light)
" http://vim.wikia.com/wiki/Override_Colors_in_a_Color_Scheme
" https://vi.stackexchange.com/questions/9675/use-variables-in-colorscheme
" https://vi.stackexchange.com/questions/9644/how-to-use-a-variable-in-the-expression-of-a-normal-command
" https://superuser.com/questions/466662/vim-how-to-auto-sync-custom-syntax-highlight-rules-when-colorscheme-changes
" https://stackoverflow.com/questions/12449248/vim-autocmd-for-removing-colorscheme-background-fail-to-run
" https://github.com/mhinz/vim-janah/issues/2
" when changing multiple stuff use pipes like this:
" autocmd ColorScheme * highlight Normal ctermbg=NONE guifg=lightgrey guibg=black | highlight MatchParen cterm=bold ctermfg=red ctermbg=NONE gui=bold guifg=red guibg=NONE

" my default pmenu colors for solarized_dark
function! s:ColorPopupMenuSolDarkDDD()
	highlight Pmenu term=bold cterm=underline,bold ctermfg=10 ctermbg=8
		\ gui=underline,bold guifg=#586e75 guibg=#002b36
endfunction

function! s:ColorPopupMenuSolLightDDD()
	highlight Pmenu term=bold cterm=underline,bold ctermfg=14 ctermbg=15
		\ gui=underline,bold guifg=#93a1a1 guibg=#fdf6e3
endfunction

function! s:EasymotionNoBoldDarkDDD()
	highlight! EasyMotionTarget ctermfg=12 guifg=#ff0000 gui=NONE cterm=NONE
	highlight! EasyMotionTarget2First ctermfg=14 guifg=#ffb400 gui=NONE cterm=NONE
	highlight! EasyMotionTarget2Second ctermfg=14 guifg=#b98300 gui=NONE cterm=NONE
endfunction

function! s:EasymotionNoBoldLightDDD()
	" EasyMotionTarget2First and second are reversed for better contrast
	highlight! EasyMotionTarget ctermfg=12 guifg=#ff0000 gui=NONE cterm=NONE
	highlight! EasyMotionTarget2Second ctermfg=14 guifg=#ffb400 gui=NONE cterm=NONE
	highlight! EasyMotionTarget2First ctermfg=14 guifg=#b98300 gui=NONE cterm=NONE
endfunction

" when colorscheme is changed to solarized family dark/light
augroup ColorschemeChangeDDD
	autocmd!
	autocmd ColorScheme flattened_dark,solarized8_dark,solarized8_dark_flat
			\ call <SID>ColorPopupMenuSolDarkDDD()
			\ | call <SID>EasymotionNoBoldDarkDDD()
	autocmd ColorScheme flattened_light,solarized8_light,solarized8_light_flat
			\ call <SID>ColorPopupMenuSolLightDDD()
			\ | call <SID>EasymotionNoBoldLightDDD()
augroup END

" Call once to set the defaults.
doautocmd <nomodeline> ColorschemeChangeDDD ColorScheme flattened_dark

" ------------ For any statusline plugin ----------------
set laststatus=2    " Always show status bar
" TODO create custom statusline, using variables instead of functions, so that
" evaluation is very fast. Change values of variables using autocmds that will
" run functions by "scheduling" them with timers (posibbly 0 length) to ensure
" completely non-blocking behavior.

" always show tabline (Note: there used to be a bug in powerline that setting
" tabline to 2 would cause vim to update the tabline for every keystroke)
set showtabline=2

" -------------------- Vim-easymotion
" TODO maybe redo mappings? (see above mapping leader to <nop>)
" The below will undo all easymotion mappings (dunno why)
" let g:EasyMotion_do_mapping = 0

" For better performance (also doesnt make sense to search offscreen)
let g:EasyMotion_off_screen_search=0
" improve readability
let g:EasyMotion_use_upper = 1
let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'

" new separate bindings for each shortcut
nnoremap <Leader>w :call feedkeys("\<Plug>(easymotion-prefix)w")<CR>
nnoremap <Leader>e :call feedkeys("\<Plug>(easymotion-prefix)e")<CR>
nnoremap <Leader>b :call feedkeys("\<Plug>(easymotion-prefix)b")<CR>
nnoremap <Leader>j :call feedkeys("\<Plug>(easymotion-prefix)j")<CR>
nnoremap <Leader>k :call feedkeys("\<Plug>(easymotion-prefix)k")<CR>
" feedkeys will not work with xnore, will cancel selection.
xmap <Leader>w <Plug>(easymotion-prefix)w
xmap <Leader>e <Plug>(easymotion-prefix)e
xmap <Leader>b <Plug>(easymotion-prefix)b
xmap <Leader>j <Plug>(easymotion-prefix)j
xmap <Leader>k <Plug>(easymotion-prefix)k

" -------------------- Auto-pairs
" Workaround to be used with completion plugins (<bs> == <c-h>)
" We can either have correct results after <BS> *OR* removed brackets after <BS>
let g:AutoPairsMapBS=0
let g:AutoPairsMapCh=0

" Do not map space: now entering "( T" will not result in "( T )" but in "( T)".
" Still a small price to pay for less bugs with completion plugins.
let g:AutoPairsMapSpace=0

" -------------------- Vim-exchange
" xnore does not work, so using xmap
xmap <C-X> <Plug>(Exchange)

" -------------------- Vim-surround
" s surrounds {move}, S surrounds line
let g:surround_no_mappings = 1
nmap s   <Plug>Ysurround
nmap S   <Plug>Yssurround
" ds mapping is already in place, but rebind as a reminder
nmap ds  <Plug>Dsurround
" cs mapping is already in place, but rebind as a reminder
nmap cs  <Plug>Csurround
xmap s   <Plug>VSurround
" REMINDER: to change surrounding html tags: "cst<newtag>"
" also: "dsb" == "ds)", because b -> ), B -> }, r -> ] (rect.), a -> > (angular)

" -------------------- Eclim
" make eclim and ycm/neocomplete play nice, omnifunc mapping in insert mode is <c-x><c-o>
let g:EclimCompletionMethod = 'omnifunc'

" do not echo error when completion fails - useful if neocomplete calls
" omnifunc eclim at inapropriate position.
" let g:EclimLogLevel = 'off'

" Disable eclim on mintty, causes errors on saving git commit message file.
" We have to make it into autocmd because eclim may not be loaded yet.
if exists('$OS') && $OS ==# 'Windows_NT' && &term =~ '^xterm'
	augroup disableEclimOnMinttyDDD
		autocmd!
		autocmd VimEnter * if exists(':EclimDisable') | execute 'EclimDisable' | endif
	augroup END
endif

" eclim set itself as omnifunc for html, xml, css (other langs too?) files.
" We undo that and enable vim's internal omnifunc.
" Remove these to get eclipse's autocompl/validation/indentation

" Disable eclim's validation for all filetypes
let g:EclimFileTypeValidate = 0

" Disable eclim's indentation for specific filetypes
let g:EclimHtmlIndentDisabled = 1
let g:EclimCssIndentDisabled = 1
let g:EclimJavascriptIndentDisabled = 1
let g:EclimXmlIndentDisabled = 1
let g:EclimDtdIndentDisabled = 1

" Disable eclim's validation for specific filetypes
let g:EclimHtmlValidate = 0
let g:EclimCssValidate = 0
let g:EclimJavascriptValidate = 0
let g:EclimXmlValidate = 0

" " alternative to set built-in (and modified by html5.vim?) indentation via indentexpr:
" " autocmd FileType html setlocal indentexpr=HtmlIndentGet(v:lnum)

autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS noci
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" -------------- youcompleteme
let g:ycm_auto_trigger = 0

" complete language keywords from vim syntax file
let g:ycm_seed_identifiers_with_syntax = 1

" complete using ctags
let g:ycm_collect_identifiers_from_tags_files = 1

let g:ycm_collect_identifiers_from_comments_and_strings = 1

" only menu (even if only one valid suggestion result), ycm auto sets it to menuone too
set completeopt=menuone
" set completeopt=menuone,noselect
" let g:ycm_always_populate_location_list = 1
" auto close preview after leaving insert mode
" Lets keep it == 0 since we dont allow it in menuopt anyway
let g:ycm_autoclose_preview_window_after_insertion = 1

" stop highlighting warning/error parts of line, causes highlighing at the
" same point in all the other open buffers
let g:ycm_enable_diagnostic_highlighting = 0

" if =1 adds preview to completeopt, if not there already, 0 is default
let g:ycm_add_preview_to_completeopt = 0

let g:ycm_min_num_of_chars_for_completion = 2

" complete in comments too
let g:ycm_complete_in_comments = 1

" force semantic completion, default is <c-space>
let g:ycm_key_invoke_completion = '<C-space>'

" manual trigger non-semantic completion
inoremap <silent><C-l> <C-r>=execute(['let g:ycm_auto_trigger=1' , 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI' , 'let g:ycm_auto_trigger=0'], "silent")<CR>

" any char on the cursor, for mulibyte chars works with :echo, but not with
" command like: let g:smth = {any of 2 lines below} (g:snth will not have
" correct value)
" strcharpart(getline('.')[col('.') - 1:], 0, 1)
" nr2char(strgetchar(getline('.')[col('.') - 1:], 0))

" any char before cursor incl.more that 1 byte in width, like Ä ä ö and 𠔻
" Works with let "g:xxx = " for multibyte chars:
" matchstr(getline('.'), '.\%' . col('.') . 'c')
" any char on cursor
" matchstr(getline('.'), '\%' . col('.') . 'c.')

" works
" inoremap <silent><C-x> <C-r>=execute(['let g:mmmm = matchstr(getline("."), ''.\%'' . col(".") . "c")', 'call feedkeys(g:mmmm, "nt")'])<CR>

" inoremap <silent><C-x> <C-r>=execute('let g:mmmm = matchstr(getline("."), ''.\%'' . col(".") . "c")')<CR><BS><C-r>=execute(['let g:ycm_auto_trigger = 1', 'call feedkeys(g:mmmm, "nt")', 'let g:ycm_auto_trigger = 0'])<CR>

function! MyDisableYCMAutoTrigger(timer)
	let g:ycm_auto_trigger = 0
endfunction
let g:c1 = 'let g:myCharBeforeCursor = matchstr(getline("."), ''.\%'' . col(".") . "c")'
let g:c2 = 'let g:ycm_auto_trigger = 1'
let g:c3 = 'call feedkeys(g:myCharBeforeCursor, "tn")'
let g:c4 = 'call timer_start(0, "MyDisableYCMAutoTrigger")'
inoremap <silent><C-v> <C-r>=execute(g:c1)<CR><BS><C-r>=execute([g:c2, g:c3, g:c4])<CR>
" let g:c4 = 'let g:ycm_auto_trigger = 0' will not work for some reason, it
" will prevent the popup from being shown. That's why we set ycm_auto_trigger
" =0 through zero duration timer. Possibly this has to do with async nature of
" ycm, the results may be returned after ycm_auto_trigger is set back to 0.

function! MyYcmManual()
	let l:charBeforeCursor = matchstr(getline("."), '.\%' . col(".") . "c")
	call feedkeys("\<BS>", "tn")
	let g:ycm_auto_trigger = 1
	call feedkeys(l:charBeforeCursor, "tn")
	call timer_start(0, "MyDisableYCMAutoTrigger")
	return ''
endfunction
inoremap <silent><C-v> <C-r>=MyYcmManual()<CR>


" inoremap <silent><C-x> <C-r>=execute('let g:mmmm = matchstr(getline("."), ''.\%'' . col(".") . "c")')<CR><BS><C-r>=execute('let g:ycm_auto_trigger = 1')<CR><C-r>=execute('call feedkeys(g:mmmm)')<CR><C-r>=execute('let g:ycm_auto_trigger = 0')<CR>


" inoremap <silent><C-x> <C-r>=execute('let g:MyLastCursorPosDDD=getpos(".")')<CR><C-Left><C-r>=execute(['let g:ycm_auto_trigger=1' , 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI', 'call setpos(".", g:MyLastCursorPosDDD)', 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI', 'let g:ycm_auto_trigger=0'])<CR>

" works
imap <silent><C-z> <C-r>=execute(['let g:MyLastCursorPosDDD=getpos(".")'])<CR><C-Left><C-Space><C-r>=execute('call setpos(".", g:MyLastCursorPosDDD)')<CR><C-Space>
" TODO: inore instead of imap and use feedkeys('\' . g:ycm_key_invoke_completion)

" Finding: in order to trigger eclim omni engine, g:ycm_auto_trigger must be
" set to 1 *from the start of vim*, else nothing happens after pressing ".". (Unlike neocomplete?)
" ycm will cache the line by just triggering <c-space> after ".": when moving
" to the initial position and pressing again <c-space> the cached results will
" be sorted and fuzzied. No need to flip g:ycm_auto_trigger.

" "HelloWorld.java 786L, 34609C written" bug!
" occurs when g:ycm_auto_trigger=1 from *vim start*, on the end
" of s.tst text:
" a to enter insert, <c-left> to move next to ".", then:
" <c-r>=execute 'doautocmd <nomodeline> ycmcompletemecursormove TextChangedI'

" -------------- vim-closetag
" REMINDER: pressing another > after "<tag>" will result in
" next-line-with-indentation and closing tag below. Useful behavior.
" filenames like *.xml, *.html, *.xhtml, ...
" Then after you press ">" in these files, this plugin will try to close the current tag.
let g:closetag_filenames = '*.xml,*.html,*.xhtml,*.phtml'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non closing tags self closing in the specified files.
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" integer value [0|1], default 0?
" This will make the list of non closing tags case sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
" let g:closetag_emptyTags_caseSensitive = 1

" Shortcut for closing tags, default is '>'
" let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is '<leader>>'
let g:closetag_close_shortcut = '<C-F7>'
" -------------- KAORIYA --------------------------------------------
" REMINDER: always delete the included vimrc AND gvimrc files
if has('kaoriya')
	let g:no_gvimrc_example = 1
	set ambiwidth=auto
	" TODO check for existence vimrc and gvimrc and show error
endif

" ------------ gvimfullscreen-win32 ----------------------------------
if has('win64')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen_64.dll'), "ToggleFullScreen", 0)<CR>
elseif has('win32')
	nnoremap <F11> <Esc>:call libcallnr(expand('$HOME\.vim\plugged\gvimfullscreen_win32\gvimfullscreen.dll'), "ToggleFullScreen", 0)<CR>
endif

" ------------ pangloss/vim-javascript ----------------------------------
" Enables syntax highlighting for JSDocs.
let g:javascript_plugin_jsdoc = 1

" Enables some additional syntax highlighting for NGDocs. Requires JSDoc plugin to be enabled as well.
let g:javascript_plugin_ngdoc = 1

" Enables syntax highlighting for Flow.
let g:javascript_plugin_flow = 1

" ------------ tomtom/tcomment_vim
" remove mappings with <c-_><c-_> and <leader>_
let g:tcommentMapLeader1 = ''
let g:tcommentMapLeader2 = ''
" TODO remove all tcomment mappings: let g:tcommentMaps = 0
" and manually create only the necessary ones

" ------------ vim-json ----------------------------------
" When using indentLine plugin use:
" let g:indentLine_noConcealCursor=""
" OR
" let g:indentLine_noConcealCursor="nc"
" source: https://github.com/elzr/vim-json/issues/23#issuecomment-40293049

" ------------ buftabline
" show "+" when modified
let g:buftabline_indicators=1
hi! link BufTabLineCurrent WildMenu
let g:buftabline_numbers=0

" ------------ my statusline -----------------------------
source ~/dotfiles/statusline-final.vim

" ---------------- profiling plugins ------------------------------------
" https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow
" profile start profile.log | profile func * | profile file *
" " At this point do slow actions
" profile pause
" :qa
" ----------------- debugging autocmd -------------------------------
" While testing autocommands, you might find the 'verbose' option to be useful:
" 	:set verbose=9
" This setting makes Vim echo the autocommands as it executes them.
" -------------------------------------------------------------------
" TODO beautify gutter sign error / warning
" -------------------------------------------------------------------
" TODO find a way to convert input to greek from vim, while still typing ENG
" some mapping to "set keymap=greek" or "set keymap=greek_utf-8" ασδφ.
" Source Code Pro Font cannot correctly display greek in comments because
" italics lack greek letters.
" Sauce Code Pro NF does not have this issue, because it uses automatically derived
" oblique. The resulting "Italics" have more inclination than SourceCodePro and
" some letters appear to be "cut" at the left edge.
" One fix would be forcing non-italics in comments:
" hi Comment gui=NONE
" but this will override the default colorscheme's behavior that may be using
" italics + color to distinguish comments, and reusing the color for smth else.
" Also, with auto-derived obliques it's not easy to distinguish "/", "|" and "\".
" -------------------------------------------------------------------
" for future fuzzy finder (like ctrlp)
" set wildignore+=*/build/**
