"======================================================================
"
" textbox.vim - 
"
" Created by skywind on 2019/12/27
" Last Modified: 2020/02/20 02:29
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
function! s:vim_create_textbox(textlist, opts)
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
	let border = get(a:opts, 'border', g:quickui#style#border)
	let opts.border = [0,0,0,0,0,0,0,0,0]
	if border > 0
		let opts.borderchars = quickui#core#border_vim(border)
		let opts.border = [1,1,1,1,1,1,1,1,1]
		let opts.close = 'button'
	endif
	let opts.padding = [0,1,0,1]
	if has_key(a:opts, 'title') && (a:opts.title != '')
		let opts.title = ' '. a:opts.title . ' '
	endif
	let opts.filter = function('s:popup_filter')
	let opts.callback = function('s:popup_exit')
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
	if has_key(a:opts, 'callback')
		let local.callback = a:opts.callback
	endif
	if has_key(a:opts, 'list')
		if a:opts.list
			call win_execute(winid, 'setl list')
		else
			call win_execute(winid, 'setl nolist')
		endif
	endif
	let bc = get(a:opts, 'bordercolor', 'QuickBorder')
	let opts.borderhighlight = [bc, bc, bc, bc]	
	if has_key(a:opts, 'tabstop')
		call win_execute(winid, 'setlocal tabstop=' . get(a:opts, 'tabstop', 4))
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
	if cursor < 0
		call win_execute(winid, 'setlocal nocursorline')
	endif
	if has_key(a:opts, 'bordercolor')
		let c = a:opts.bordercolor
		let opts.borderhighlight = [c, c, c, c]	
	endif
	call popup_setoptions(winid, opts)
	call win_execute(winid, 'setlocal scrolloff=0')
	if has_key(a:opts, 'command')
		call quickui#core#win_execute(winid, a:opts.command)
	endif
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
function! s:popup_exit(winid, code)
	let topline = quickui#utils#get_topline(a:winid)
	let g:quickui#textbox#topline = topline
	let local = quickui#core#popup_local(a:winid)
	let g:quickui#textbox#current = local
	call quickui#core#popup_clear(a:winid)
	if has_key(local, 'callback')
		let l:F = function(local.callback)
		call l:F(topline)
		unlet l:F
	endif
endfunc


"----------------------------------------------------------------------
" filter
"----------------------------------------------------------------------
function! s:popup_filter(winid, key)
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
	elseif a:key == ':' || a:key == '/' || a:key == '?'
		call quickui#utils#search_or_jump(a:winid, a:key)
		noautocmd call quickui#utils#update_cursor(a:winid)
		redraw
		return 1
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		if key == "ENTER" || key == "ESC"
			call popup_close(a:winid, 0)
			return 1
		elseif key == 'NEXT' || key == 'PREV'
			call quickui#utils#search_next(a:winid, key)
			noautocmd call quickui#utils#update_cursor(a:winid)
			redraw
			return 1
		else
			noautocmd call quickui#utils#scroll(a:winid, key)
			redraw
			noautocmd call quickui#utils#update_cursor(a:winid)
		endif
	endif
	return popup_filter_yesno(a:winid, a:key)
endfunc


"----------------------------------------------------------------------
" create text box in neovim
"----------------------------------------------------------------------
function! s:nvim_create_textbox(textlist, opts)
	if type(a:textlist) == v:t_list
		let bid = quickui#core#scratch_buffer('textbox', a:textlist)
	elseif type(a:textlist) == v:t_string
		let bid = quickui#core#scratch_buffer('textbox', [a:textlist])
	elseif type(a:textlist) == v:t_number
		let bid = a:textlist
	endif
	let opts = {'focusable':1, 'style':'minimal', 'relative':'editor'}
	let opts.width = get(a:opts, 'w', 80)
	let opts.height = get(a:opts, 'h', 24)
	let opts.row = get(a:opts, 'line', 1) - 1
	let opts.col = get(a:opts, 'col', 1) - 1
	let border = get(a:opts, 'border', g:quickui#style#border)
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let opts.row += 1
		let opts.col += 1
	endif
	if has('nvim-0.6.0')
		let opts.noautocmd = 1
	endif
	let winid = nvim_open_win(bid, 0, opts)
	if has_key(a:opts, 'line') == 0 && has_key(a:opts, 'col') == 0
		call quickui#utils#center(winid)
	endif
	let color = get(a:opts, 'color', 'QuickBG')
    call nvim_win_set_option(winid, 'winhl', 'Normal:'. color)
	let opts.w = nvim_win_get_width(winid)
	let opts.h = nvim_win_get_height(winid)
	let button = (get(a:opts, 'close', '') == 'button')? 1 : 0
	let background = -1
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
		let w = opts.w
		let h = opts.h
		let back = quickui#utils#make_border(w, h, border, title, button)
		let nbid = quickui#core#scratch_buffer('textboxborder', back)
		let op = {'relative':'editor', 'focusable':1, 'style':'minimal'}
		let op.width = opts.w + 2
		let op.height = opts.h + 2
		let pos = nvim_win_get_config(winid)
		let op.row = pos.row - 1
		let op.col = pos.col - 1
		let bordercolor = get(a:opts, 'bordercolor', 'QuickBorder')
		if has('nvim-0.6.0')
			let op.noautocmd = 1
		endif
		let background = nvim_open_win(nbid, 0, op)
		call nvim_win_set_option(background, 'winhl', 'Normal:'. bordercolor)
	endif
	let init = ['syn clear']
	if has_key(a:opts, 'tabstop')
		let init += ['setlocal tabstop='. get(a:opts, 'tabstop', 4)]
	endif
	let init += ['setlocal signcolumn=no']
	let init += ['setlocal scrolloff=0']
	let init += ['setlocal wrap']
	let init += ['noautocmd exec "normal! gg"']
	if get(a:opts, 'number', 0) != 0
		let init += ['setlocal number']
	endif
	if has_key(a:opts, 'syntax')
		let init += ['set ft='.fnameescape(a:opts.syntax)]
		" echo "syntax: ". a:opts.syntax
	endif
	let cursor = get(a:opts, 'cursor', -1)
	call setbufvar(bid, '__quickui_cursor__', cursor)
	call setbufvar(bid, '__quickui_line__', -1)
	if has_key(a:opts, 'index')
		let index = (a:opts.index < 1)? 1 : a:opts.index
		let opts.firstline = index
		let init += ['noautocmd exec "normal! gg"']
		if index > 1
			let init += ['noautocmd exec "normal! '. (index - 1) . '\<c-e>"']
		endif
	endif
	call quickui#core#win_execute(winid, init)
	let highlight = 'Normal:'.color.',NonText:'.color.',EndOfBuffer:'.color
    call nvim_win_set_option(winid, 'winhl', highlight)
	if has_key(a:opts, 'command')
		call quickui#core#win_execute(winid, a:opts.command)
	endif
	noautocmd call quickui#utils#update_cursor(winid)
	let local = {}
	let local.winid = winid
	let local.keymap = quickui#utils#keymap()
	let local.keymap['x'] = 'ESC'
	let local.opts = deepcopy(a:opts)
	noautocmd redraw
	while 1
		noautocmd redraw!
		try
			let code = getchar()
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		if ch == "\<ESC>" || ch == "\<c-c>"
			break
		elseif ch == ' ' || ch == 'x' || ch == 'q'
			break
		elseif ch == "\<LeftMouse>"
			if v:mouse_winid == winid
				if v:mouse_lnum > 0 
					if get(a:opts, 'exit_on_click', 0) != 0
						break
					endif
				endif
			elseif v:mouse_winid == background
				if button != 0 && v:mouse_lnum == 1
					if v:mouse_col == opts.w + 2
						break
					endif
				endif
			endif
		elseif ch == '/' || ch == '?' || ch == ':'
			call quickui#utils#search_or_jump(winid, ch)
			noautocmd call quickui#utils#update_cursor(winid)
		elseif has_key(local.keymap, ch)
			let key = local.keymap[ch]
			if key == 'ENTER' || key == 'ESC'
				break
			elseif key == 'NEXT' || key == 'PREV'
				call quickui#utils#search_next(winid, key)
				noautocmd call quickui#utils#update_cursor(winid)
			else
				noautocmd call quickui#utils#scroll(winid, key)
				noautocmd call quickui#utils#update_cursor(winid)
			endif
		endif
	endwhile
	let topline = quickui#utils#get_topline(winid)
	let g:quickui#textbox#topline = topline
	call nvim_win_close(winid, 0)
	if background >= 0
		call nvim_win_close(background, 0)
	endif
	let g:quickui#textbox#current = local
	if has_key(a:opts, 'callback')
		let F = function(a:opts.callback)
		call F(topline)
	endif
	return topline
endfunc


"----------------------------------------------------------------------
" cross platform create
"----------------------------------------------------------------------
function! quickui#textbox#create(textlist, opts)
	if g:quickui#core#has_nvim == 0
		return s:vim_create_textbox(a:textlist, a:opts)
	else
		return s:nvim_create_textbox(a:textlist, a:opts)
	endif
endfunc


"----------------------------------------------------------------------
" open
"----------------------------------------------------------------------
function! quickui#textbox#open(textlist, opts)
	let maxheight = (&lines) * 70 / 100
	let maxwidth = (&columns) * 80 / 100
	let opts = deepcopy(a:opts)
	let opts.close = 'button'
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
	if has_key(opts, 'h')
		let minheight = get(opts, 'minheight', 1)
		let minheight = (minheight < 1)? 1 : minheight
		let opts.h = (opts.h < minheight)? minheight : opts.h
	endif
	if has_key(opts, 'w')
		let minwidth = get(opts, 'minwidth', 20)
		let minwidth = (minwidth < 1)? 1 : minwidth
		let opts.w = (opts.w < minwidth)? minwidth : opts.w
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
	let opts.border = 0
	" let opts.bordercolor = "QuickBG"
	let opts.cursor = 38
	let opts.number = 1
	" let opts.exit_on_click = 0
	let winid = quickui#textbox#open(lines, opts)
	" call getchar()
	" call quickui#textbox#close(winid)
endif




