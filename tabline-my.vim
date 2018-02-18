 hi! link NC Tabline
 hi! link NCMod Tabline
 hi! link Curr TablineSel
 hi! link CurrMod TablineSel

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
	call filter(g:myBufsOrder, funcref('InListedBufNums'))
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
			let bufRep.highlight = '%#CurrMod#'
		elseif currentBuf ==# bufn && !bufRep.isModified
			let bufRep.highlight = '%#Curr#'
		elseif currentBuf !=# bufn && bufRep.isModified
			let bufRep.highlight = '%#NCMod#'
		else
			let bufRep.highlight = '%#NC#'
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
	endfor

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

	" add spaces, "+" signs and separators, then calculate the widths
	for key in keys(myBufReprs)
		let repr = myBufReprs[key]
		let repr.label = '  ' . repr.label
		if repr.isModified
			let repr.label .= '+ '
		else
			let repr.label .= '  '
		endif
		" separator to the right
		let repr.sep = '|'
		let repr.width = strwidth(strtrans(repr.label))
	endfor

	" If after closing current buffer an unlisted buffer becomes current, we
	" must select another center buffer, to start building from it left and
	" right. This case can happen when a help file is open in :vsp and the
	" other (currently center) buffer is being closed -> help file becomes
	" current and the split closes.
	" Note: The purpose of g:centerBuf is to prevent displayed buffers
	" jumping around when an unlisted buffer is opened/closed.
	if index(g:listedBufNums, g:centerBuf) ==# -1
		let g:centerBuf = g:listedBufNums[0]
	endif

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
		" no error is thrown when index before ":" is >length, result is []
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

	" space left after g:centerBuf (-1 is to offset for center's separator)
	let budget = &columns - myBufReprs[g:centerBuf].width -1
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
			" +1 to offset for separator that will be added later
			let leftBudget -= l:bufRepr.width + 1
			" if budget is <=0, this is the last element and we trim its repr
			if leftBudget <= 0
				" Trimming from the left:
				" Starting point is -leftBudget, as this is how much we are
				" over the budget, thus so much we cut.
				" +1 is to account for "<" symbol.
				" -leftBudget+1 is guaranteed to be >0, no fear of overflowing
				"  the index. If it is past length-1, no error is thrown and
				"  empty string is the result.
				let l:bufRepr.label = '<' . l:bufRepr.label[-leftBudget+1:]
				" TODO: address the corner case as in AddRights below.
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
			" +1 to offset for separator that will be added later
			let rightBudget -= l:bufRepr.width + 1
			" if budget is <=0, this is the last element and we trim its repr
			if rightBudget <= 0
				" trimming from the right:
				" Ending point (last char to be included) is at index (width - 1),
				" another -1 is to account for "<" symbol. Further reducing the
				" ending point by how much we are over budget.
				" Checking to not overflow the index as negative index is
				" counting from the end.
				let l:end = l:bufRepr.width-2+rightBudget
				echom 'l:end: '.string(l:end)
				if l:end < 0
					let l:bufRepr.label = '>'
				else
					let l:bufRepr.label = l:bufRepr.label[:l:end] . '>'
				endif
				" HACK: for corner case when rightBudget (before subtraction)
				" is exactly 1, so even if the label will be ">", after adding
				" separator later, we will actually be over budget and tabline
				" will trim itself from the left. This is problematic when
				" first (leftmost) buffer is the current one: it becomes
				" trimmed by 1 char and prepended with "<" by vim.
				" So we empty rightmost element's separator.
				let l:bufRepr.sep = ''
				return
			endif
		endwhile
	endfunction

	" case 0: center buffer has huge name
	if budget <= 0
		let centerRep = myBufReprs[g:centerBuf]
		let centerRep.label = '<' . centerRep.label[-budget+1:]

		" case 1: left and right are within their budget
	elseif leftBufsWidth <= leftBudget && rightBufsWidth <= rightBudget
		let visibles = leftBufs + visibles + rightBufs

		" case 2: left fits, but right does not
	elseif leftBufsWidth <= leftBudget
		let rightBudget += leftBudget - leftBufsWidth
		call AddRights()
		let visibles = leftBufs + visibles

	" case 3: right fits, but left does not
	elseif rightBufsWidth <= rightBudget
		let leftBudget += rightBudget - rightBufsWidth
		call AddLefts()
		let visibles = visibles + rightBufs

	" case 4: both do not fit
	else
		call AddLefts()
		call AddRights()
	endif

	" make separator " " instead of "|" in current and the one to the left
	if index(visibles, currentBuf) > -1
		let myBufReprs[currentBuf].sep = ' '
		if index(visibles, currentBuf) > 0
			let myBufReprs[visibles[index(visibles, currentBuf)-1]].sep = ' '
		endif
	endif

	" final assembly
	let tabline = ''
	for bufn in visibles
		let rep = myBufReprs[bufn]
		let tabline .= rep.highlight . rep.label . rep.sep
	endfor
	let tabline .= '%#NC#%='
	" ----------------------------------------------------------------------
	echom 'myBufReprs '.string(myBufReprs)
	echom ' '
	echom 'myBufsOrder '.string(g:myBufsOrder)
	echom ' '
	echom 'listedBufNums '.string(g:listedBufNums)
	echom ' '
	echom 'visibles: '.string(visibles)
	echom ' '
	echom 'final rightBudget: '.string(rightBudget)
	echom ' '
	echom 'final leftBudget: '.string(leftBudget)
	echom ' '
	echom 'vims width: '.string(&columns)
	return tabline
endfunction

set tabline=%!Render()
" call Render()
