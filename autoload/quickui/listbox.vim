"======================================================================
"
" listbox.vim - 
"
" Created by skywind on 2019/12/20
" Last Modified: 2023/08/30 14:47
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :

"----------------------------------------------------------------------
" stats
"----------------------------------------------------------------------

" last position
let g:quickui#listbox#cursor = -1  


"----------------------------------------------------------------------
" parse
"----------------------------------------------------------------------
function! quickui#listbox#parse(textlist)
	let items = {'image': [], 'column':0, 'nrows':0, 'keys':[], 'cmds':[]}
	let items.keymap = {}
	let items.displaywidth = 0
	let sizes = []
	let objects = []
	let spliter = '  '
	for description in a:textlist
		let obj = quickui#core#single_parse(description)
		let objects += [obj]
		if obj.key_pos >= 0
			let items.keymap[tolower(obj.key_char)] = items.nrows
		endif
		let items.nrows += 1
		while len(sizes) < obj.size
			let sizes += [0]
		endwhile
		let items.column = len(sizes)
		let index = 0
		for part in obj.part
			let size = strdisplaywidth(obj.part[index])
			if size > sizes[index]
				let sizes[index] = size
			endif
			let index += 1
		endfor
	endfor
	for obj in objects
		let start = 1
		let index = 0
		let output = ' '
		let ni = ['', -1]
		for part in obj.part
			let size = strdisplaywidth(part)
			let need = sizes[index]
			if size >= need
				let element = part
			else
				let element = part . repeat(' ', need - size)
			endif
			if obj.key_idx == index
				let ni[0] = obj.key_char
				let ni[1] = start + obj.key_pos
			endif
			let output .= element
			if index + 1 < len(obj.part)
				let output .= spliter
			endif
			let start += strchars(element) + strchars(spliter)
			let index += 1
		endfor
		let items.image += [output . ' ']
		let items.keys += [ni]
		let items.cmds += [obj.cmd]
		let size = strdisplaywidth(output) + 1
		if size > items.displaywidth
			let items.displaywidth = size
		endif
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" reposition text offset
"----------------------------------------------------------------------
function! quickui#listbox#reposition()
	exec 'normal! zz'
	let height = winheight(0)
	let size = line('$')
	let curline = line('.')
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
" highlight keys
"----------------------------------------------------------------------
function! s:highlight_keys(winid, items)
	let items = a:items
	let index = 0
	let cmdlist = []
	while index < items.nrows
		let key = items.keys[index]
		if key[1] >= 0
			let px = key[1] + 1
			let py = index + 1
			let cmd = quickui#core#high_region('QuickKey', py, px, py, px + 1, 1)
			let cmdlist += [cmd]
		endif
		let index += 1
	endwhile
	call quickui#core#win_execute(a:winid, cmdlist)
endfunc


"----------------------------------------------------------------------
" init window
"----------------------------------------------------------------------
function! s:vim_create_listbox(textlist, opts)
	let hwnd = {}
	let opts = {}
	let items = quickui#listbox#parse(a:textlist)
	let winid = popup_create(items.image, {'hidden':1, 'wrap':0})
	let bufnr = winbufnr(winid)
	let hwnd.winid = winid
	let hwnd.items = items
	let hwnd.bufnr = bufnr
	let hwnd.keymap = quickui#utils#keymap()
	let hwnd.hotkey = items.keymap
	let hwnd.opts = deepcopy(a:opts)
	let hwnd.context = has_key(a:opts, 'context')? a:opts.context : {}
	let minsize = strdisplaywidth(get(a:opts, 'title', ''))
	let minsize = max([items.displaywidth, minsize])
	let border = get(a:opts, 'border', g:quickui#style#border)
	let w = has_key(a:opts, 'w')? a:opts.w : minsize
	let h = has_key(a:opts, 'h')? a:opts.h : items.nrows
	if h + 6 > &lines
		let h = &lines - 6
		let h = (h < 1)? 1 : h
	endif
	if w + 4 > &columns
		let w = &columns - 4
		let w = (w < 1)? 1 : w
	endif
	let opts = {"minwidth":w, "minheight":h, "maxwidth":w, "maxheight":h}
	let ww = w + ((border != 0)? 2 : 0)
	let hh = h + ((border != 0)? 2 : 0)
	if has_key(a:opts, 'line')
		let opts.line = a:opts.line
	else
		let limit1 = (&lines - 2) * 90 / 100
		let limit2 = (&lines - 2)
		if h + 4 < limit1
			let opts.line = (limit1 - hh) / 2
		else
			let opts.line = (limit2 - hh) / 2
		endif
		let opts.line = (opts.line < 1)? 1 : opts.line
	endif
	if has_key(a:opts, 'col')
		let opts.col = a:opts.col
	else
		let opts.col = (&columns - ww) / 2
		let opts.col = (opts.col < 1)? 1 : opts.col
	endif
	call popup_move(winid, opts)
	call setwinvar(winid, '&wincolor', get(a:opts, 'color', 'QuickBG'))
	if get(a:opts, 'index', 0) >= 0
		let moveto = get(a:opts, 'index', 0) + 1
		call popup_show(winid)
		call win_execute(winid, 'normal! G')
		call win_execute(winid, ':' . moveto)
		call win_execute(winid, 'normal! G')
		call win_execute(winid, ':' . moveto)
		call win_execute(winid, 'call quickui#listbox#reposition()')
	endif
	let opts = {'cursorline':1, 'drag':1, 'mapping':0}
	if get(a:opts, 'manual', 0) == 0
		let opts.filter = function('s:popup_filter')
		let opts.callback = function('s:popup_exit')
	endif
	let opts.border = [0,0,0,0,0,0,0,0,0]
	if border > 0
		let opts.borderchars = quickui#core#border_vim(border)
		let opts.border = [1,1,1,1,1,1,1,1,1]
	endif
	if has_key(a:opts, 'title') && (a:opts.title != '')
		let opts.title = ' ' . a:opts.title . ' '
	endif
	let opts.padding = [0,1,0,1]
	if has_key(a:opts, 'close') && (a:opts.close != '')
		let opts.close = a:opts.close
	endif
	let local = quickui#core#popup_local(winid)
	let local.hwnd = hwnd
	let local.winid = winid
	let keymap = hwnd.keymap
	if !has_key(a:opts, 'horizon')
		let keymap["\<LEFT>"] = 'HALFUP'
		let keymap["\<RIGHT>"] = 'HALFDOWN'
		let keymap["h"] = 'HALFUP'
		let keymap["l"] = 'HALFDOWN'
	endif
	if has_key(a:opts, 'keymap')
		for key in keys(a:opts.keymap)
			let keymap[key] = a:opts.keymap[key]
		endfor
	endif
	let hwnd.state = 1
	let hwnd.code = 0
	let hwnd.tag = ''
	let bc = get(a:opts, 'bordercolor', 'QuickBorder')
	let opts.borderhighlight = [bc, bc, bc, bc]	
	call popup_setoptions(winid, opts)
	call win_execute(winid, 'syn clear')
	if has_key(a:opts, 'syntax')
		call win_execute(winid, 'set ft=' . fnameescape(a:opts.syntax))
	endif
	" call s:highlight_keys(winid, items)
	call s:highlight_keys(winid, items)
	call popup_show(winid)
	return hwnd
endfunc


"----------------------------------------------------------------------
" close list box
"----------------------------------------------------------------------
function! quickui#listbox#close(hwnd)
	if a:hwnd.winid > 0
		call popup_close(a:hwnd.winid)
		call quickui#core#popup_clear(a:hwnd.winid)
		let a:hwnd.winid = -1
	endif
endfunc


"----------------------------------------------------------------------
" handle exit code
"----------------------------------------------------------------------
function! s:popup_exit(winid, code)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.hwnd
	let code = a:code
	if a:code > 0
		call win_execute(a:winid, ':' . a:code)
		redraw
		let code = a:code - 1
	endif
	let hwnd.state = 0
	let hwnd.code = code
	let g:quickui#listbox#cursor = quickui#utils#get_cursor(a:winid) - 1
	call quickui#core#popup_clear(a:winid)
	silent! call popup_hide(a:winid)
	let g:quickui#listbox#current = hwnd
	if has_key(hwnd.opts, 'callback')
		call call(hwnd.opts.callback, [code])
	endif
	if code >= 0 && code < hwnd.items.nrows
		let cmd = hwnd.items.cmds[code]
		if cmd != ''
			redraw
			try
				exec cmd
			catch /.*/
				echohl Error
				echom v:exception
				echohl None
			endtry
		endif
	endif
endfunc


"----------------------------------------------------------------------
" key processing
"----------------------------------------------------------------------
function! s:popup_filter(winid, key)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.hwnd
	let keymap = hwnd.keymap
	if a:key == "\<ESC>" || a:key == "\<c-c>"
		call popup_close(a:winid, -1)
		return 1
	elseif a:key == "\<CR>" || a:key == "\<SPACE>"
		return popup_filter_menu(a:winid, "\<CR>")
	elseif a:key == "\<LeftMouse>"
		let pos = getmousepos()
		if pos.winid == a:winid
			if pos.line > 0
				call win_execute(a:winid, ':' . pos.line)
				call popup_setoptions(a:winid, {})
				redraw
				return popup_filter_menu(a:winid, "\<CR>")
			endif
		endif
	elseif a:key == ':' || a:key == '/' || a:key == '?'
		call quickui#utils#search_or_jump(a:winid, a:key)
		return 1
	elseif has_key(hwnd.hotkey, a:key)
		let index = hwnd.hotkey[a:key]
		call popup_close(a:winid, index + 1)
		return 1
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		if strpart(key, 0, 4) == 'TAG:'
			let hwnd.tag = strpart(key, 4)
			return popup_filter_menu(a:winid, "\<CR>")
		elseif key == 'ESC'
			call popup_close(a:winid, -1)
			return 1
		elseif key == 'NEXT' || key == 'PREV'
			call quickui#utils#search_next(a:winid, key)
		else
			let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
			call win_execute(a:winid, 'call ' . cmd)
			return 1
		endif
	endif
	return popup_filter_menu(a:winid, a:key)
endfunc


"----------------------------------------------------------------------
" how to move cursor
"----------------------------------------------------------------------
function! quickui#listbox#cursor_movement(where)
	let curline = line('.')
	let endline = line('$')
	let height = winheight('.')
	if a:where == 'TOP'
		let curline = 0
	elseif a:where == 'BOTTOM'
		let curline = line('$')
	elseif a:where == 'UP'
		let curline = curline - 1
	elseif a:where == 'DOWN'
		let curline = curline + 1
	elseif a:where == 'PAGEUP'
		let curline = curline - height
	elseif a:where == 'PAGEDOWN'
		let curline = curline + height
	elseif a:where == 'HALFUP'
		let curline = curline - height / 2
	elseif a:where == 'HALFDOWN'
		let curline = curline + height / 2
	elseif a:where == 'KEEP'
	endif
	if curline < 1
		let curline = 1
	elseif curline > endline
		let curline = endline
	endif
	noautocmd exec ":" . curline
	noautocmd exec "normal! 0"
endfunc


"----------------------------------------------------------------------
" block and return result
"----------------------------------------------------------------------
function! quickui#listbox#inputlist(textlist, opts)
	if g:quickui#core#has_nvim != 0
		let opts = deepcopy(a:opts)
		if has_key(opts, 'callback')
			unlet opts['callback']
		endif
		return s:nvim_create_listbox(a:textlist, opts)
	endif
	let opts = deepcopy(a:opts)
	let opts.manual = 1
	if has_key(opts, 'callback')
		call remove(opts, 'callback')
	endif
	if len(a:textlist) == 0
		return -1000
	endif
	let hwnd = s:vim_create_listbox(a:textlist, opts)
	let winid = hwnd.winid
	let hr = -1
	" call win_execute(winid, 'normal zz')
	call popup_show(winid)
	while 1
		redraw
		try
			let code = getchar()
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		if ch == "\<ESC>" || ch == "\<c-c>"
			break
		elseif ch == " " || ch == "\<cr>"
			let cmd = 'let g:quickui#listbox#index = line(".")'
			call win_execute(winid, cmd)
			let hr = g:quickui#listbox#index - 1
			break
		elseif ch == "\<LeftMouse>"
			let pos = getmousepos()
			if pos.winid == winid
				if pos.line > 0
					call win_execute(winid, ':' . pos.line)
					call popup_setoptions(winid, {})
					redraw
					let hr = pos.line - 1
					break
				endif
			endif
		elseif ch == ':' || ch == '/' || ch == '?'
			call quickui#utils#search_or_jump(winid, ch)
			call popup_hide(winid)
			call popup_show(winid)
		elseif has_key(hwnd.hotkey, ch)
			let hr = hwnd.hotkey[ch]
			if hr >= 0
				break
			endif
		elseif has_key(hwnd.keymap, ch)
			let key = hwnd.keymap[ch]
			if key == 'ESC'
				break
			elseif key == 'NEXT' || key == 'PREV'
				call quickui#utils#search_next(winid, key)
				call popup_hide(winid)
				call popup_show(winid)
			else
				let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
				call win_execute(winid, 'call ' . cmd)
				call popup_hide(winid)
				call popup_show(winid)
			endif
		endif
	endwhile
	" echo 'size: '. winheight(winid)
	if hr > 0
		call quickui#core#win_execute(winid, ':' . (hr + 1))
		redraw
	endif
	let g:quickui#listbox#cursor = quickui#utils#get_cursor(winid) - 1
	call quickui#listbox#close(hwnd)
	return hr
endfunc


"----------------------------------------------------------------------
" create list box in neovim
"----------------------------------------------------------------------
function! s:nvim_create_listbox(textlist, opts)
	let hwnd = {}
	let opts = {}
	let items = quickui#listbox#parse(a:textlist)
	let bid = quickui#core#scratch_buffer('listbox', items.image)
	let hwnd.items = items
	let hwnd.bid = bid
	let hwnd.keymap = quickui#utils#keymap()
	let hwnd.hotkey = items.keymap
	let hwnd.opts = deepcopy(a:opts)
	let hwnd.context = has_key(a:opts, 'context')? a:opts.context : {}
	let border = get(a:opts, 'border', g:quickui#style#border)
	let minsize = strdisplaywidth(get(a:opts, 'title', ''))
	let minsize = max([items.displaywidth, minsize])
	let w = has_key(a:opts, 'w')? a:opts.w : minsize + 2
	let h = has_key(a:opts, 'h')? a:opts.h : items.nrows
	if h + 6 > &lines
		let h = &lines - 6
		let h = (h < 1)? 1 : h
	endif
	if w + 4 > &columns
		let w = &columns - 4
		let w = (w < 1)? 1 : w
	endif
	let ww = w + ((border != 0)? 2 : 0)
	let hh = h + ((border != 0)? 2 : 0)
	let opts = {'width':w, 'height':h, 'focusable':1, 'style':'minimal'}
	let opts.relative = 'editor'
	if has_key(a:opts, 'line')
		let opts.row = a:opts.line - 1
	else
		let limit1 = (&lines - 2) * 90 / 100
		let limit2 = (&lines - 2)
		" echom printf("limit1=%d limit2=%d h=%d hh=%d", limit1, limit2, h, hh)
		if h + 4 < limit1
			let opts.row = (limit1 - hh) / 2
		else
			let opts.row = (limit2 - hh) / 2
		endif
		let opts.row = (opts.row < 0)? 0 : opts.row
	endif
	if has_key(a:opts, 'col')
		let opts.col = a:opts.col - 1
	else
		let opts.col = (&columns - ww) / 2 - 1
		let opts.col = (opts.col < 0)? 0 : opts.col
	endif
	let border = get(a:opts, 'border', g:quickui#style#border)
	let background = -1
	let hwnd.opts.color = get(a:opts, 'color', 'QuickBG')
	let color = hwnd.opts.color
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let opts.row += 1
		let opts.col += 1
	endif
	if has('nvim-0.6.0')
		let opts.noautocmd = 1
	endif
	let winid = nvim_open_win(bid, 0, opts)
	let button = (get(a:opts, 'close', '') == 'button')? 1 : 0
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
		let back = quickui#utils#make_border(w, h, border, title, button)
		let nbid = quickui#core#scratch_buffer('listborder', back)
		let op = {'relative':'editor', 'focusable':1, 'style':'minimal'}
		let op.width = w + 2
		let op.height = h + 2
		let op.row = opts.row - 1
		let op.col = opts.col - 1
		let bordercolor = get(a:opts, 'bordercolor', 'QuickBorder')
		if has('nvim-0.6.0')
			let op.noautocmd = 1
		endif
		let background = nvim_open_win(nbid, 0, op)
		call nvim_win_set_option(background, 'winhl', 'Normal:'. bordercolor)
	endif
	let hwnd.winid = winid
    call nvim_win_set_option(winid, 'winhl', 'Normal:'. color)
	if get(a:opts, 'index', 0) >= 0
		let moveto = get(a:opts, 'index', 0) + 1
		call quickui#core#win_execute(winid, 'noautocmd normal! ggG')
		call quickui#core#win_execute(winid, 'noautocmd :' . moveto)
		call quickui#core#win_execute(winid, 'noautocmd normal! 0')
	endif
	let border = get(a:opts, 'border', 1)
	let keymap = hwnd.keymap
	if !has_key(a:opts, 'horizon')
		let keymap["\<LEFT>"] = 'HALFUP'
		let keymap["\<RIGHT>"] = 'HALFDOWN'
		let keymap["h"] = 'HALFUP'
		let keymap["l"] = 'HALFDOWN'
	endif
	if has_key(a:opts, 'keymap')
		for key in keys(a:opts.keymap)
			let keymap[key] = a:opts.keymap[key]
		endfor
	endif
	let hwnd.state = 1
	let hwnd.code = 0
	let hwnd.tag = ''
	call quickui#core#win_execute(winid, 'setlocal nowrap')
	call quickui#core#win_execute(winid, 'syn clear')
	if has_key(a:opts, 'syntax')
		let syntax = fnameescape(a:opts.syntax)
		call quickui#core#win_execute(winid, 'set ft=' . syntax)
	endif
	call s:highlight_keys(winid, items)
	call quickui#core#win_execute(winid, "setlocal cursorline scrolloff=0")
	if exists('+cursorlineopt')
		call quickui#core#win_execute(winid, "setlocal cursorlineopt=both")
	endif
	let retval = -1
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
		elseif ch == "\<cr>" || ch == "\<space>"
			let retval = quickui#utils#get_cursor(winid) - 1
			break
		elseif ch == "\<LeftMouse>"
			if v:mouse_winid == winid
				if v:mouse_lnum > 0
					let cmd = ':' . v:mouse_lnum
					call quickui#core#win_execute(winid, cmd)
					redraw!
					sleep 10m
					let retval = v:mouse_lnum - 1
					break
				endif
			elseif v:mouse_winid == background
				if button != 0 && v:mouse_lnum == 1
					if v:mouse_col == w + 2
						break
					endif
				endif
			endif
		elseif ch == ':' || ch == '/' || ch == '?'
			call quickui#utils#search_or_jump(winid, ch)
			let cmd = 'call quickui#listbox#cursor_movement("KEEP")'
			noautocmd call quickui#core#win_execute(winid, cmd)
		elseif has_key(hwnd.hotkey, ch)
			let retval = hwnd.hotkey[ch]
			break
		elseif has_key(keymap, ch)
			let key = keymap[ch]
			if strpart(key, 0, 4) == 'TAG:'
				let hwnd.tag = strpart(key, 4)
				let retval = quickui#utils#get_cursor(winid) - 1
				break
			elseif key == "ESC"
				break
			elseif key == 'NEXT' || key == 'PREV'
				call quickui#utils#search_next(winid, key)
			else
				let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
				noautocmd call quickui#core#win_execute(winid, 'call ' . cmd)
			endif
		endif
	endwhile
	let hwnd.code = retval
	if retval > 0
		call quickui#core#win_execute(winid, ':' . (retval + 1))
	endif
	let g:quickui#listbox#cursor = quickui#utils#get_cursor(winid) - 1
	call nvim_win_close(winid, 0)
	if background >= 0
		call nvim_win_close(background, 0)
	endif
	redraw!
	let hwnd.state = 0
	let g:quickui#listbox#current = hwnd
	if has_key(hwnd.opts, 'callback')
		call call(hwnd.opts.callback, [retval])
	endif
	if retval >= 0 && retval < hwnd.items.nrows
		let cmd = hwnd.items.cmds[retval]
		if cmd != ''
			try
				exec cmd
			catch /.*/
				echohl Error
				echom v:exception
				echohl None
			endtry
		endif
	endif
	return retval
endfunc


"----------------------------------------------------------------------
" open popup and run command when select an item
"----------------------------------------------------------------------
function! quickui#listbox#open(content, opts)
	if g:quickui#core#has_nvim == 0
		return s:vim_create_listbox(a:content, a:opts)
	else
		return s:nvim_create_listbox(a:content, a:opts)
	endif
endfunc



