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
let g:centerBuf=winbufnr(0)

function! Render()
	" list of integers, representing vim's user buffers ids(aka non-help
	" non-quickfix)
	let g:listedBufNums=My_user_buffers()

	" any elements in myBufsOrder that are not in listedBufNums are removed
	function! InListedBufNums(idx, bufn)
		" ignoring idx, we dont need it
		return index(g:listedBufNums, a:bufn) !=# -1
	endfunction
	" filter() modifies in-place, which is what we need (not copying)
	call filter(g:myBufsOrder, function('InListedBufNums'))
	" with lambda
	" call filter(g:myBufsOrder, {idx, bufn -> index(g:listedBufNums, bufn) !=# -1})

	" dictionary, where every key is buffer number (unique id) and every value is
	" the dict (object) describing this buffer's representation
	let myBufReprs={}

	" buf number for current window (may or may not be listed)
	let currentBuf = winbufnr(0)

	" dictionary: keys are the filename tails to be displayed, values are the
	" number of occurrences for a tail. If that number is >1 it means we are
	" editing 2 files with the same filename, but from different dirs, so
	" disambugation will have to be performed.
	let tabs_per_tail = {}

	" Note: variables declared inside "for" are not local to "for" (same for
	" "while"). Iter variable "bufn" (below) also stays alive after "for" is ended.
	for bufn in g:listedBufNums
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
		let bufRep.isModified=getbufvar(bufn, '&modified')

		" determine highlight style
		if currentBuf ==# bufn && bufRep.isModified
			let bufRep.highlight = '%#MyCurrentBufMod#'
		elseif currentBuf ==# bufn && !bufRep.isModified
			let bufRep.highlight = '%#MyCurrentBuf#'
		elseif currentBuf !=# bufn && bufRep.isModified
			let bufRep.highlight = '%#MyTabBufMod#'
		else
			let bufRep.highlight = '%#MyTabBuf#'
		endif

		" update center buffer
		if bufn ==# currentBuf
			let g:centerBuf = bufn
		endif

		let bufpath = bufname(bufn)
		if strlen(bufpath)
			" not sure why ":~:." TODO check if needed. This is not full path.
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
			let bufRep.label = '[Scratch]'
		else " unnamed file
			let bufRep.label = '[No Name]'
		endif

		" add the representation to the dict of representations (bufn auto
		" converted to string as dict's key)
		let myBufReprs[bufn]=bufRep
		" string()
	endfor

	" sanity check: if center buffer is not in listed buffers, should never be
	" possible
	if index(g:listedBufNums, g:centerBuf) ==# -1
		echom 'Mytabline error: centerBuf not in Vims listed buffers! This must not happen!'
		let g:centerBuf = listedBufNums[0]
	endif

	echom 'tabs_per_tail '.string(tabs_per_tail)

	" ----------------------------------------------------------------------
	" disambiguate same-basename files by adding trailing path segments
	while len(filter(tabs_per_tail, 'v:val > 1'))
		let [ambiguous, tabs_per_tail] = [tabs_per_tail, {}]
		" only iterate over those that have path(not scratch, not unnamed)
		for key in keys(myBufReprs)
			let tab=myBufReprs[key]
			if !has_key(tab, 'path')
				continue
			endif
			if -1 < tab.sep && has_key(ambiguous, tab.label)
				let tab.sep = strridx(tab.path, g:dirsep, tab.sep - 1)
				let tab.label = tab.path[tab.sep + 1:]
			endif
			let tabs_per_tail[tab.label] = get(tabs_per_tail, tab.label, 0) + 1
		endfor
	endwhile
	" ----------------------------------------------------------------------
	" TODO: add separators and "+" to each entry, pad spaces left/right
	" ----------------------------------------------------------------------

	" calculate the widths
	for key in keys(myBufReprs)
		let repr = myBufReprs[key]
		let repr.width = strwidth(strtrans(repr.label))
	endfor

	" If center buffer's width is less than vim's width, there will be
	" available space to present more buffers to the left/right of the center.
	" There are 4 cases depending on whether the remaining bufs to the left/right
	" can each fit in half of the available space or not.
	" 1. If both fit, no trimming is needed.
	" 2,3. If only one fits, then the other needs to be gradually filled and trimmed,
	" using the former's extra space.
	" 4. Both overflow, so both need to be filled and trimmed, restricted to using
	" only own budget.


	let centerPosInMyBufsOrder = index(g:myBufsOrder, g:centerBuf)
	" arrays of numbers representing buffers to the left/right of center to be
	" presented to the user
	let leftBufs = []
	let rightBufs = []
	" sanity check, should always be true
	if centerPosInMyBufsOrder > -1
		" slicing index after : must not be negative (eg. -1 means last element)
		if centerPosInMyBufsOrder > 0
			let leftBufs = g:myBufsOrder[0:centerPosInMyBufsOrder-1]
		endif
		let rightBufs = g:myBufsOrder[centerPosInMyBufsOrder+1:]
	endif
	echom 'leftBufs:'.string(leftBufs)
	echom 'rightBufs'.string(rightBufs)

	" calculate each side's width
	let leftBufsWidth = 0
	let rightBufsWidth = 0
	for leftBufNum in leftBufs
		let leftBufsWidth += myBufReprs[leftBufNum].width
	endfor
	for rightBufNum in rightBufs
		let rightBufsWidth += myBufReprs[rightBufNum].width
	endfor

	" space left after g:centerBuf
	let budget = &columns - myBufReprs[g:centerBuf].width
	let leftBudget = budget / 2
	let rightBudget = budget - leftBudget

	echom 'leftBufsWidth: '.leftBufsWidth
	echom 'rightBufsWidth: '.rightBufsWidth
	echom 'leftBudget: '.leftBudget
	echom 'rightBudget: '.rightBudget

	" list of buffer nums that will be displayed (either full or trimmed)
	let visibles = []
	call add(visibles, g:centerBuf)

	" gradually adds bufnums from leftBufs to visibles and trims the
	" leftmost representation element by mutating its label directly
	" Closure: when function is a closure it has access to outer function's
	" scope vars.
	" Note: There is a weird behavior: if closure if called lexically-before
	" (and in the same scope as) its definition, the call is pushed to the end
	" of the enclosing function (like the opposite of javascript hoisting)!
	" If closure is called lexically-after (and in the same scope as) its
	" definition, it is called normally. In this case if the captured variables
	" used by closure were not defined lexically-before the call line, error
	" will be thrown.
	function! AddLefts() closure
		while len(leftBufs) > 0
			" remove tail
			let l:bufNum = remove(leftBufs, -1)
			let l:bufRepr = myBufReprs[l:bufNum]
			" prepend it to visibles
			call insert(visibles, l:bufNum)
			let leftBudget -= l:bufRepr.width
			" if budget is <=0, this is the last element and we trim its repr
			if leftBudget <= 0
				let l:bufRepr.label = '<' . l:bufRepr.label[-leftBudget+1:]
				return
			endif
		endwhile
	endfunction

	function! AddRights() closure
		while len(rightBufs) > 0
			" remove head
			let l:bufNum = remove(rightBufs, 0)
			let l:bufRepr = myBufReprs[l:bufNum]
			" append it to visibles
			call add(visibles, l:bufNum)
			let rightBudget -= l:bufRepr.width
			" if budget is <=0, this is the last element and we trim its repr
			if rightBudget <= 0
				let l:bufRepr.label = l:bufRepr.label[:l:bufRepr.width-2] . '>'
				return
			endif
		endwhile
	endfunction

	" TODO case 0: center buffer has huge name
	" case 1:
	if leftBufsWidth <= leftBudget && rightBufsWidth <= rightBudget
		let visibles = leftBufs + visibles + rightBufs
	endif
	" ----------------------------------------------------------------------
	echom 'myBufReprs '.string(myBufReprs)
	echom ' '
	echom 'myBufsOrder '.string(g:myBufsOrder)
	echom ' '
	echom 'listedBufNums '.string(g:listedBufNums)
endfunction

call Render()
