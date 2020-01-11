"======================================================================
"
" preview.vim - 
"
" Created by skywind on 2020/01/11
" Last Modified: 2020/01/11 11:30:20
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
let s:private = {'winid': -1}


"----------------------------------------------------------------------
" position to a proper location
"----------------------------------------------------------------------
function! s:around_cursor(width, height)
	let cursor_pos = quickui#core#cursor_pos()
	let row = cursor_pos[0] - a:height 
	let col = cursor_pos[1] + 1
	if quickui#core#in_screen(row, col, a:width, a:height)
		return [row, col]
	endif
	if col + a:width - 1 > &columns
		let col = col - (1 + a:width)
		if quickui#core#in_screen(row, col, a:width, a:height)
			return [row, col]
		endif
	endif
	if row < 1
		let row = row + (1 + a:height)
		if quickui#core#in_screen(row, col, a:width, a:height)
			return [row, col]
		endif
	endif
	if cursor_pos[0] - a:height - 2 < 1
		let row = cursor_pos[0] + 1
	else
		let row = cursor_pos[0] - a:height 
	endif
	if cursor_pos[1] + a:width + 2 < &columns
		let col = cursor_pos[1] + 1
	else
		let col = cursor_pos[1] - a:width
	endif
	return quickui#core#screen_fit(row, col, a:width, a:height)
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! quickui#preview#display(filename, lnum, opts)
	call quickui#preview#close()
	if !filereadable(a:filename)
		call quickui#utils#errmsg('E212: Can not open file: '. a:filename)
		return -1
	endif
	let bid = bufadd(a:filename)
	let winid = -1
	let title = has_key(a:opts, 'title')? (' ' . a:opts.title .' ') : ''
	let w = get(a:opts, 'w', -1)
	let h = get(a:opts, 'h', -1)
	let w = (w < 0)? 50 : w
	let h = (h < 0)? 10 : h
	let border = get(a:opts, 'border', g:quickui#style#border)
	let p = s:around_cursor(w + (border? 2 : 0), h + (border? 2 : 0))
	" echo p
	if has('nvim') == 0
		let winid = popup_create(bid, {'wrap':1, 'mapping':0, 'hidden':1})
		let opts = {'maxwidth':w, 'maxheight':h, 'minwidth':w, 'minheight':h}
		call popup_move(winid, opts)
		let opts = {'close':'button', 'title':title}
		let opts.border = border? [1,1,1,1,1,1,1,1,1] : repeat([0], 9)
		let opts.resize = 0
		let opts.highlight = 'QuickPreview'
		let opts.borderchars = quickui#core#border_vim(border)
		let opts.moved = 'any'
		let opts.drag = 1
		let opts.line = p[0]
		let opts.col = p[1]
		" let opts.fixed = 'true'
		call popup_setoptions(winid, opts)
		let s:private.winid = winid
		call popup_show(winid)
	else
	endif
	let cmdlist = ['setlocal signcolumn=no norelativenumber']
	if get(a:opts, 'number', 1) == 0
		let cmdlist += ['setlocal nonumber']
	else
		let cmdlist += ['setlocal number']
	endif
	if has_key(a:opts, 'index')
		let index = a:opts.index
		let cmdlist += ['let g:quickui#utils#__cursor_index = '.index]
	endif
	call quickui#core#win_execute(winid, cmdlist)
	return winid
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! quickui#preview#callback(winid, code)
	if has('nvim') == 0
		let s:private.winid = -1
	endif
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! quickui#preview#close()
	if s:private.winid >= 0
		if has('nvim') == 0
			call popup_close(s:private.winid, 0)
			let s:private.winid = -1
		else
		endif
	endif
endfunc



