"======================================================================
"
" textbox.vim - 
"
" Created by skywind on 2019/12/27
" Last Modified: 2019/12/27 15:20:02
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" reposition
"----------------------------------------------------------------------
function! quickui#textbox#reposition()
	let curline = line('.')
	exec 'normal! zz'
	let height = winheight(0)
	let moveup = winline() - 1
	if moveup > 0
		exec "normal " . moveup . "\<c-e>"
		exec ":" . curline
	endif
	let size = line('$')
	let winline = winline()
	let topline = curline - winline + 1
	let botline = curline + height - 1
	let disline = botline - size
	if disline > 0
		exec 'normal ggG'
		exec ':' . curline
		exec 'normal G'
		exec ':' . curline
	endif
endfunc


"----------------------------------------------------------------------
" create textbox
"----------------------------------------------------------------------
function! quickui#textbox#create(textlist, opts)
	let winid = popup_create(a:textlist, {'hidden':1, 'wrap':1})
	let opts = {}
	let opts.maxheight = &lines - 2
	let opts.maxwidth = &columns
	if has_key(a:opts, 'w')
		let opts.minwidth = a:opts.w
		let opts.maxwidth = a:opts.w
	endif
	if has_key(a:opts, 'h')
		let opts.minheight = a:opts.h
		let opts.maxheight = a:opts.h
	endif
	if has_key(a:opts, 'line') && has_key(a:opts, 'col')
		let opts.line = a:opts.line
		let opts.col = a:opts.col
	endif
	if len(opts) > 0
		call popup_move(winid, opts)
	endif
	if has_key(a:opts, 'line') == 0 || has_key(a:opts, 'col') == 0
		" echo "FUCK"
		call quickui#utils#center(winid)
	endif
	let opts = {'mapping':0, 'cursorline':0, 'drag':1}
	let border = get(a:opts, 'border', 1)
	let opts.borderchars = quickui#core#border_vim(border)
	let opts.border = [1,1,1,1,1,1,1,1,1]
	let opts.title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
	let opts.padding = [0,1,0,1]
	let opts.close = 'button'
	let opts.filter = 'quickui#textbox#filter'
	let opts.callback = 'quickui#textbox#exit'
	let opts.resize = get(a:opts, 'resize', 0)
	if has_key(a:opts, 'color')
		let opts.highlight = a:opts.color
	endif
	if has_key(a:opts, 'index')
		let index = (a:opts.index < 1)? 1 : a:opts.index
		let opts.firstline = index
	endif
	let local = quickui#core#popup_local(winid)
	let local.winid = winid
	let local.keymap = quickui#utils#keymap()
	let local.keymap['x'] = 'ESC'
	let local.opts = deepcopy(a:opts)
	if has_key(a:opts, 'list')
		if a:opts.list
			call win_execute(winid, 'setl list')
		else
			call win_execute(winid, 'setl nolist')
		endif
	endif
	call popup_setoptions(winid, opts)
	call popup_show(winid)
	return winid
endfunc


"----------------------------------------------------------------------
" close textbox
"----------------------------------------------------------------------
function! quickui#textbox#close(winid)
	call popup_close(a:winid)
endfunc


"----------------------------------------------------------------------
" exit and quit
"----------------------------------------------------------------------
function! quickui#textbox#exit(winid, code)
	call quickui#core#popup_clear(a:winid)
endfunc


"----------------------------------------------------------------------
" filter
"----------------------------------------------------------------------
function! quickui#textbox#filter(winid, key)
	let local = quickui#core#popup_local(a:winid)
	let keymap = local.keymap
	if a:key == "\<ESC>" || a:key == "\<C-C>" || a:key == "\<cr>"
		call popup_close(a:winid, 0)
		return 1
	elseif a:key == " " || a:key == "x" || a:key == "q"
		call popup_close(a:winid, 0)
		return 1
	elseif a:key == "\<LeftMouse>"
		let pos = getmousepos()
		if pos.winid == a:winid && pos.line > 0
			if get(local.opts, 'exit_on_click', 0) != 0
				call popup_close(a:winid, 0)
				return 1
			endif
		endif
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		if key == "ENTER"
			call popup_close(a:winid, 0)
			return 1
		else
			call quickui#utils#scroll(a:winid, key)
		endif
	endif
	return popup_filter_yesno(a:winid, a:key)
endfunc


"----------------------------------------------------------------------
" open
"----------------------------------------------------------------------
function! quickui#textbox#open(textlist, opts)
	let size = len(a:textlist)
	let maxheight = (&lines) * 70 / 100
	let maxwidth = (&columns) * 80 / 100
	let opts = deepcopy(a:opts)
	if has_key(opts, 'h') == 0
		let opts.h = (size < maxheight)? size : maxheight
	endif
	if has_key(opts, 'w') == 0
		let opts.w = 1
		for line in a:textlist
			let size = strwidth(line)
			let opts.w = (size < opts.w)? opts.w : size
		endfor
		if opts.w > maxwidth
			let opts.w = maxwidth
		endif
	endif
	call quickui#textbox#create(a:textlist, opts)
endfunc



"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 0
	let lines = []
	for i in range(2000)
		let lines += ['text line ' . (i + 1)]
	endfor
	let opts = {}
	let opts.index = 30
	let opts.resize = 1
	let opts.title = "title"
	" let opts.exit_on_click = 0
	let winid = quickui#textbox#open(lines, opts)
	" call getchar()
	" call quickui#textbox#close(winid)
endif




