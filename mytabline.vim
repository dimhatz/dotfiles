function! My_user_buffers() " help buffers are always unlisted, but quickfix buffers are not
	return filter(range(1,bufnr('$')),'buflisted(v:val) && "quickfix" !=? getbufvar(v:val, "&buftype")')
endfunction

" list of integers corresponding to buffer nums(ids). It must contain every
" buffer that is listed in vim and nothing more. Essentially this is list of
" buffers only with different order.
if !exists('g:myBufsOrder')
	let g:myBufsOrder=[]
endif

" path dir separator '/' on unix, '\' on windows
let g:dirsep = fnamemodify(getcwd(),':p')[-1:]

" buffer to keep in central position when current buffer is non-user
let g:centerbuf=winbufnr(0)

function! Render()
	" list of integers, representing vim's user buffers ids(aka non-help
	" non-quickfix)
	let g:vimBufNums=My_user_buffers()

	" any elements in myBufsOrder that are not in vimBufNums are removed
	" for bufn in g:myBufsOrder
	function! InVimBufNums(idx, bufn)
		" ignoring idx, we dont need it
		return index(g:vimBufNums, a:bufn) !=# -1
	endfunction
	" let g:myBufsOrder=[-1,-2,2,-3]
	" echom 'before filtering myBufsOrder: '.string(g:myBufsOrder, ',')
	" filter() modifies in-place, which is what we need (not copying)
	call filter(g:myBufsOrder, function('InVimBufNums'))
	" echom 'after filtering myBufsOrder: '.string(g:myBufsOrder, ',')
	" echom ' '
	" with lambda
	" call filter(g:myBufsOrder, {idx, bufn -> index(g:vimBufNums, bufn) !=# -1})

	" dictionary, where every key is buffer number (id) and every value is
	" the dict (object) describing this buffer's representation
	let myBufReps={}

	" buf number for current window (may or may not be listed)
	let currentbuf = winbufnr(0)

	" dictionary: keys are the filename tails to be displayed, values are the
	" number of occurrences for a tail. If that number is >1 it means we are
	" editing 2 files with the same filename, but from different dirs, so
	" disambugation will need to be performed.
	let tabs_per_tail = {}

	for bufn in g:vimBufNums
		" any buffer in vim's buf list and not in order list should be
		" appended to the order list
		if index(g:myBufsOrder, bufn) ==# -1
			" echom 'adding buf no: '.bufn
			call add(g:myBufsOrder, bufn)
			" echom 'myBufsOrder: '.string(g:myBufsOrder, ',')
			" echom ' '
		endif

		" representation for currently iterated buffer number
		let bufRep={}
		let isModified=getbufvar(bufn, '&modified')

		" determine highlight style
		if currentbuf ==# bufn && isModified
			let bufRep.highlight = '%#MyCurrentBufMod#'
		elseif currentbuf ==# bufn && !isModified
			let bufRep.highlight = '%#MyCurrentBuf#'
		elseif currentbuf !=# bufn && isModified
			let bufRep.highlight = '%#MyTabBufMod#'
		else
			let bufRep.highlight = '%#MyTabBuf#'
		endif

		" update center buffer
		if bufn ==# currentbuf
			let g:centerbuf = bufn
		endif
		" ---------------------------------
		let bufpath = bufname(bufn)
		if strlen(bufpath)
			" not sure why ":~:." TODO check if needed
			let bufRep.path = fnamemodify(bufpath, ':p:~:.')
			" Position of the separator in the path, after which the filename
			" begins. Will be moved towards the beginning of the string to
			" include preceding dirs during disambugation, if needed. Does not
			" count the trailing separator (if for example ":e wtfdir/", which
			" would produce illegal filename, but vim will allow it with a
			" warning and only complain upon saving).
			let bufRep.sep = strridx(bufRep.path, g:dirsep, strlen(bufRep.path) - 2) " keep trailing dirsep
			" label is what is to be displayed. Initially it is what follows the
			" sep position till the end. Can be disambugated later.
			let bufRep.label = bufRep.path[bufRep.sep + 1:]
			let tabs_per_tail[bufRep.label] = get(tabs_per_tail, bufRep.label, 0) + 1
		elseif -1 < index(['nofile','acwrite'], getbufvar(bufn, '&buftype')) " scratch buffer
			let bufRep.label = '!'
		else " unnamed file
			let bufRep.label =  isModified ? '+*' : '*'
		endif
		" ---------------------------------


		" add the representation to the dict of representations (bufn auto
		" converted to string as dict's key)
		let myBufReps[bufn]=bufRep
		" string()
	endfor
	echom string(myBufReps)
endfunction

call Render()
