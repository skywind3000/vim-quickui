"======================================================================
"
" textbox.vim - 
"
" Created by skywind on 2019/12/27
" Last Modified: 2020/01/02 04:21
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
	let botline = topline + height - 1
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
	let opts.highlight = get(a:opts, 'color', 'QuickBG')
	if has_key(a:opts, 'index')
		let index = (a:opts.index < 1)? 1 : a:opts.index
		let opts.firstline = index
		call win_execute(winid, ':' . index)
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
	if has_key(a:opts, 'bordercolor')
		let opts.borderhighlight = repeat([a:opts.bordercolor], 4)
	endif
	if has_key(a:opts, 'syntax')
		call win_execute(winid, 'set ft=' . fnameescape(a:opts.syntax))
	endif
	let cursor = get(a:opts, 'cursor', -1)
	call setbufvar(winbufnr(winid), '__quickui_cursor__', cursor)
	call setbufvar(winbufnr(winid), '__quickui_line__', -1)
	if get(a:opts, 'number', 0) != 0
		call win_execute(winid, 'setlocal number')
	endif
	call win_execute(winid, 'setlocal tabstop=' . get(a:opts, 'tabstop', 4))
	call popup_setoptions(winid, opts)
	call quickui#utils#update_cursor(winid)
	call popup_show(winid)
	redraw
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
			redraw
			call quickui#utils#update_cursor(a:winid)
		endif
	endif
	return popup_filter_yesno(a:winid, a:key)
endfunc


"----------------------------------------------------------------------
" open
"----------------------------------------------------------------------
function! quickui#textbox#open(textlist, opts)
	let maxheight = (&lines) * 70 / 100
	let maxwidth = (&columns) * 80 / 100
	let opts = deepcopy(a:opts)
	let maxheight = has_key(opts, 'maxheight')? opts.maxheight : maxheight
	let maxwidth = has_key(opts, 'maxwidth')? opts.maxwidth : maxwidth
	if has_key(opts, 'h') == 0
		let size = (type(a:textlist) == v:t_list)? len(a:textlist) : 20
		let opts.h = (size < maxheight)? size : maxheight
	endif
	if has_key(opts, 'w') == 0
		if type(a:textlist) == v:t_list
			let opts.w = 1
			for line in a:textlist
				let size = strdisplaywidth(line)
				let opts.w = (size < opts.w)? opts.w : size
			endfor
			if opts.w > maxwidth
				let opts.w = maxwidth
			endif
			if get(a:opts, 'number', 0) != 0
				let opts.w += len(string(len(a:textlist))) + 3
			endif
		endif
	endif
	call quickui#textbox#create(a:textlist, opts)
endfunc


"----------------------------------------------------------------------
" run shell command and display result in the text box
"----------------------------------------------------------------------
function! quickui#textbox#command(cmd, opts)
	let text = quickui#utils#system(a:cmd)
	let linelist = []
	let enc = get(g:, 'quickui_shell_encoding', '')
	for line in split(text, "\n")
		if enc != ''
			let line = iconv(line, enc, &encoding)
		endif
		let line = trim(line, "\r")
		let linelist += [line]
	endfor
	call quickui#textbox#open(linelist, a:opts)
endfunc


"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 0
	let lines = []
	for i in range(2000)
		let lines += ['printf("%d\n", ' . (i + 1) . ');']
	endfor
	let opts = {}
	let opts.index = 30
	let opts.resize = 1
	let opts.title = "title"
	let opts.syntax = "cpp"
	let opts.color = "QuickBox"
	" let opts.bordercolor = "QuickBG"
	let opts.cursor = 38
	let opts.number = 1
	" let opts.exit_on_click = 0
	let winid = quickui#textbox#open(lines, opts)
	" call getchar()
	" call quickui#textbox#close(winid)
endif




