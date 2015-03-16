" Automatic reloading of .vimrc
"autocmd! bufwritepost .vimrc source %

" NeoBundle init
if !1 | finish | endif

if has('vim_starting')
   if &compatible
     set nocompatible               " Be iMproved
   endif

" Required:
set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!

NeoBundle 'matchit.zip'
NeoBundle 'nanotech/jellybeans.vim'     " jellybeans theme
NeoBundle 'morhetz/gruvbox'             " gruvbox theme
NeoBundle 'chriskempson/base16-vim'
NeoBundle 'vim-scripts/Wombat'
NeoBundle 'vim-scripts/wombat256.vim'
NeoBundle 'bling/vim-airline'
NeoBundle 'Valloric/YouCompleteMe'

" For theme related stuff, also check end of this file for mappings
NeoBundle 'vim-scripts/SyntaxAttr.vim' "check syntax group under cursor <F11>
NeoBundle 'gerw/vim-HiLinkTrace' "check all possible syntax groups under cursor <F9>
"NeoBundle 'guns/xterm-color-table.vim' "print color table with corresp color codes <F10>
"NeoBundle 'lilydjwg/colorizer' "print color table with corresp color codes <F8>

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


"" System general settings
set shortmess+=I                                    " disable start message
set mouse=a                                         "enable mouse
"set mousehide                                       "hide when characters are typed
"set history=1000                                    "number of command lines to remember
set encoding=utf-8                                  "set encoding for text
set ttyfast                                         "assume fast terminal connection, fast redraws
set hidden                                          "allow buffer switching without saving
"set autoread                                        "auto reload if file saved externally
"set fileformats+=mac                                "add mac to auto-detection of file format line endings
set nrformats-=octal                                "always assume decimal/hex numbers
""if !empty(&viminfo)									" ??? option to save/restore global variables
""  set viminfo^=!									" from sensible.vim
""endif
"set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
""set undofile										" creates .un~ file for every file edited
"set undolevels=100								      " use many muchos levels of undo
"
"" Visual general settings
""filetype plugin indent on      " (done in neobundle above) load filetype-specific indent files
"set number              " show line numbers
"set ruler				" show cursor coordinates
"set showcmd             " show command in bottom bar
"set noshowmode			" dont show mode, cause using airline
"set cursorline          " highlight current line
""set relativenumber		" count lines up/down starting with current line
"autocmd WinLeave * setlocal nocursorline	" only cursorline for current window/tab
"autocmd WinEnter * setlocal cursorline		" only cursorline for current window/tab
"syntax enable           " enable syntax processing, *syntax on* overrides with defaults!
"set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set scrolloff=200		" no. of lines shown above/below cursor, large no. will always have cursor in middle
"set sidescrolloff=5		" no. of lines shown left/right to the cursor. useful for long lines.
""set matchtime=5       " tens of a second to show matching paren (Default=5)
"set tabpagemax=50		" max no. of tab pages open (tabs)
"
"" Tabs and spaces
"set tabstop=4       " number of visual spaces per TAB
"set softtabstop=4   " number of spaces in tab when editing
"set shiftwidth=4    " for indentation command in normal mode
"set expandtab       " tabs are spaces
"set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
"set backspace=indent,eol,start      "allow backspacing everything in insert mode
set list                 "highlight whitespace
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮,nbsp:■	" whitespaces to show (tab:│\ old, ▸\ new)
"set shiftround			" Round indent to multiple of 'shiftwidth'. +Applies to > and <
"set smarttab		" insert blanks according to shiftwidth (else tabstop or softtabstop)
set wrap            " wrap text on eol (default)
let &showbreak='↪ '	" Char to signify line break
set autoindent		" The simplest automatic indent
""set complete-=i	" remove i(ncluded sources) option from defaults of completion
"
" Clipboard
if exists('$TMUX')
    set clipboard=
else
    if has('unnamedplus')
        set clipboard=unnamedplus                             "sync with "CLIPBOARD" OS clipboard, uses "+ register
    else
        set clipboard=unnamed                             "sync with "PRIMARY" OS clipboard, uses "* register
    endif
endif

" Searching
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          "ignore case for searching
"set smartcase           "do case-sensitive if there's a capital letter
"
" Wildmenu
set wildmenu            " visual autocomplete for command menu
set wildmode=list:longest		" if more than one match show list
set wildignorecase		" ignore case in wildmenu search
"
"" Keyboard and cursor
set timeout ttimeout         " enable separate mapping and keycode timeouts
set timeoutlen=250                                  "mapping timeout ms (default 1000)
set ttimeoutlen=50                                  "keycode timeout ms (default -1, unset when having ssh with latency)
"
"" Tags
"" if has('path_extra') " from sensible.vim
""  setglobal tags-=./tags tags^=./tags;
"" endif
"" set tags=tags;/			" from bling's vimrc
"set showfulltag 		" shows tag and search pattern as matches
"
" GUI
if has('gui_running')
	"set guicursor=n-v-c:blinkon0-block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175 "dont blink
	let &guicursor = substitute(&guicursor, 'n-v-c:', '&blinkon0-', '')
	"set guicursor=
	"set lines=999 columns=9999  " open maximized
	set guioptions-=t                                 "no tear off menu items
	set guioptions+=c                                 "no gui dialogs
	set guioptions-=T                                 "no toolbar icons
	set guioptions-=r                                   " no right scrollbar
	set guioptions-=l           " no left scrollbar
	set guioptions-=L           " no left scrollbar when vert. split
	set guioptions-=m           " no menu
	set guifont=MonaVu\ 10
else
	set t_Co=256			" terminal colors 256
endif

  colorscheme jellybat

"" Special highlight of 81st char in long line (from TARBALL)
highlight MyColorColumn guifg=#d8d8d8 guibg=#ab4642 guisp=NONE gui=NONE ctermfg=7 ctermbg=1 cterm=NONE
call matchadd('MyColorColumn', '\%81v', 100)

" Add tags from tag folder (libraries)
" remove searching tags in current file's directory
" tags should be read only from ~/tags/*.tags and from current working dir
set tags-=./tags
set tags-=./TAGS
set tags+=~/tags/cpp_std_gcc.tags
set tags+=~/tags/qt5.tags

" Key remaps
" Swap : and ; to make colon commands easier to type
" The vice versa remapping *may* break plugins - to be confirmed
nnoremap  ;  :
nnoremap  :  ;
vnoremap  ;  :
vnoremap  :  ;

" map leader key to , find char again \, find char again backwards |
let mapleader = ","
" the below 2 lines dont work somehow - spit message on startup TODO
"nnoremap \ ;
"nnoremap | ,

" " avoid unrecoverable deletion (of all entered chars in line) in insert mode
"inoremap <c-u> <c-g>u<c-u>
"" avoid unrecoverable deletion (of word before cursor) in insert mode
"inoremap <c-w> <c-g>u<c-w>

" for new xcape mappings of alts == - and +
"noremap - {
"noremap + }

" for navigation of wrapped lines --> investigate side effects
nnoremap j gj
nnoremap k gk

" map ) and ( to :bnext and :bprev
nnoremap <silent> ) :bnext<CR>
nnoremap <silent> ( :bprev<CR>

" for saving (writing out) as root - small delay on w in command line
cmap <F12> w !sudo tee % >/dev/null
"cmap www w !sudo tee % >/dev/null

" If you visually select something and hit paste
" that thing gets yanked into your buffer. This
" generally is annoying when you're copying one item
" and repeatedly pasting it. This changes the paste
" command in visual mode so that it doesn't overwrite
" whatever is in your paste buffer.
vnoremap p "_dP

" x in normal or visual will not overwrite the paste buffer
nnoremap x "_x
vnoremap x "_x

" X deletes to black hole till end of line
nnoremap X "_D

" Y yanks till end of line, instead of whole line
nnoremap Y y$

" stop highlighting search pressing <ESC>
" might spawn weird numbers on startup of terminal vim

" BEGIN_WORKAROUND
	" next 2 lines cause 1 in 10 starts in xterm having weird behavior (lines
	" swapped or copy pasted). <nowait> seems to be the culprit.
			"nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
			"nnoremap <nowait> <silent> <ESC> :nohls<CR><ESC>
			nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
			nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
" END_WORKAROUND

" GUI doesnt need workaround, so lets not add delay of <esc><esc>.
if has('gui_running')
	unmap <silent> <ESC><ESC>
	nnoremap <silent> <ESC> :nohlsearch<CR><ESC>
endif
" BEGIN_WORKAROUND2
" first map <ESC><ESC> globally, then override on per-buffer basis.
" The <buffer> mapping has precedence over global and nowait skips the timeout.
	"nnoremap <silent> <ESC><ESC> :nohlsearch<CR><ESC>
	"augroup no_highlight
		"autocmd BufEnter * nnoremap <buffer> <nowait> <silent> <ESC> :nohls<CR><ESC>
	"augroup END
" END_WORKAROUND2

"====[ Swap V and CTRL-v. Regular visual is now Shift-v. ]======
"====[ Block mode is more useful that Visual mode ]======
nnoremap    v   <C-V>
vnoremap    v   <C-V>
nnoremap <C-V>     V
vnoremap <C-V>     V
nnoremap    V   v
vnoremap    V   v

"====[ Use tab instead of % for jumping to matching parens - breaks <C-i> - bug ]
"nnoremap <tab> %
"vnoremap <tab> %

" move to beginning/end of line (also consider B and E as alternative)
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

"====[ '*' not to jump - screen might twitch a bit]==
"nnoremap * *<C-o>

"====[ '*' in visual will do search on selection - the correct way ]======
vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" enter paste mode on pressing F5, to stop autoindenting etc, not needed when
" using "+ register -- confirm
set pastetoggle=<F4>

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
endif

" $/^ doesn't do anything
"nnoremap $ <nop>
"nnoremap ^ <nop>


" TODO:
" Find mappings for the following actions
" - delete buffer aka :bd
" - save buffer aka :w
" - find better mapping for H and L, so that yL and dL etc work

" Plugin settings
"{{{
    let g:airline#extensions#tabline#enabled = 1
   "let g:airline#extensions#tabline#left_sep=' '
   "let g:airline#extensions#tabline#left_alt_sep='¦'
    let g:airline_powerline_fonts = 1
    "let g:airline_theme = 'jellybeans'
    set laststatus=2    " Always show status bar
" override space symbol if using fontconfig method of powerline fonts
"if !exists('g:airline_symbols')
"  let g:airline_symbols = {}
"endif
"let g:airline_symbols.space = "\ua0"
" ========================================
"if has('gui_running')
"	let g:airline_left_sep = '⮀' " ⮀   
"	let g:airline_left_alt_sep = '⮁'       " ⮁⮁⮁      
"	let g:airline_right_sep = '⮂'      " ⮂      
"	let g:airline_right_alt_sep = '⮃'      "       ⮃
"	let g:airline_branch_prefix = '⭠'   "
"	let g:airline_readonly_symbol = '⭤'        "
"	let g:airline_linecolumn_prefix = '⭡'      "
"
"	set guifont=Monaco-dim\ 10
"endif
" ========================================
"}}}
nnoremap <F11> :call SyntaxAttr()<CR>
"nnoremap <F10> :XtermColorTable<CR>
nnoremap <F9> :HLT<CR>
"nnoremap <F8> :ColorToggle<CR>
