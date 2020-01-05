

"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:nvim_create_listbox(textlist, opts)
	let hwnd = {}
	let opts = {}
	let items = quickui#listbox#parse(a:textlist)
	let bid = quickui#core#neovim_buffer('listbox', items.image)
	let hwnd.items = items
	let hwnd.bid = bid
	let hwnd.keymap = quickui#utils#keymap()
	let hwnd.hotkey = items.keymap
	let hwnd.opts = deepcopy(a:opts)
	let hwnd.context = has_key(a:opts, 'context')? a:opts.context : {}
	let w = has_key(a:opts, 'w')? a:opts.w + 2 : items.displaywidth
	let h = has_key(a:opts, 'h')? a:opts.h : items.nrows
	if h + 6 > &lines
		let h = &lines - 6
		let h = (h < 1)? 1 : h
	endif
	if w + 4 > &columns
		let w = &columns - 4
		let w = (w < 1)? 1 : w
	endif
	let opts = {'width':w, 'height':h, 'focusable':1, 'style':'minimal'}
	let opts.relative = 'editor'
	if has_key(a:opts, 'line')
		let opts.row = a:opts.line - 1
	else
		let limit1 = (&lines - 2) * 80 / 100
		let limit2 = (&lines - 2)
		if h + 4 < limit1
			let opts.row = (limit1 - h) / 2 - 1
		else
			let opts.row = (limit2 - h) / 2 - 1
		endif
		let opts.row = (opts.row < 0)? 0 : opts.row
	endif
	if has_key(a:opts, 'col')
		let opts.col = a:opts.col - 1
	else
		let opts.col = (&columns - w) / 2 - 1
	endif
	let border = get(a:opts, 'border', g:quickui#style#border)
	let background = -1
	let hwnd.opts.color = get(a:opts, 'color', 'QuickBG')
	let color = hwnd.opts.color
	let winid = nvim_open_win(bid, 0, opts)
	let button = (get(a:opts, 'close', '') == 'button')? 1 : 0
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
		let back = quickui#utils#make_border(w, h, border, title, button)
		let nbid = quickui#core#neovim_buffer('listborder', back)
		let op = {'relative':'editor', 'focusable':1, 'style':'minimal'}
		let op.width = w + 2
		let op.height = h + 2
		let op.row = opts.row - 1
		let op.col = opts.col - 1
		let background = nvim_open_win(nbid, 0, op)
		call nvim_win_set_option(background, 'winhl', 'Normal:'. color)
	endif
	let hwnd.winid = winid
    call nvim_win_set_option(winid, 'winhl', 'Normal:'. color)
	if get(a:opts, 'index', 0) >= 0
		let moveto = get(a:opts, 'index', 0) + 1
		call quickui#core#win_execute(winid, 'normal! ggG')
		call quickui#core#win_execute(winid, ':' . moveto)
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
	if has_key(a:opts, 'syntax')
		let syntax = fnameescape(a:opts.syntax)
		call quickui#core#win_execute(winid, 'set ft=' . syntax)
	endif
	call quickui#listbox#highlight_keys(winid, items)
	call quickui#core#win_execute(winid, "setlocal cursorline scrolloff=0")
	let retval = -1
	while 1
		redraw!
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
			else
				let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
				call quickui#core#win_execute(winid, 'call ' . cmd)
			endif
		endif
	endwhile
	let hwnd.code = retval
	if retval > 0
		call quickui#core#win_execute(winid, ':' . (retval + 1))
	endif
	call nvim_win_close(winid, 0)
	if background >= 0
		call nvim_win_close(background, 0)
	endif
	redraw!
	let hwnd.state = 0
	let g:quickui#listbox#current = hwnd
	if has_key(hwnd.opts, 'callback')
		let F = function(hwnd.opts.callback)
		call F(retval)
	endif
	if retval >= 0 && retval < hwnd.items.nrows
		let cmd = hwnd.items.cmds[retval]
		if cmd != ''
			exec cmd
		endif
	endif
	return retval
endfunc


if 1
	let content = [
				\ ["[1]\tOpen &File\t(F3)", 'echo 1'],
				\ ["[2]\tChange &Directory\t(F2)", 'echo 2'],
				\ ["[3]\tHelp", 'echo 3'],
				\ "",
				\ "[4]\tE&xit",
				\ "[5]\t哈哈哈E&xit",
				\ ]
	" let content = []
	for ix in range(1000)
		let content += ['line: ' . ix]
	endfor
	function! MyCallback(code)
		let hwnd = g:quickui#listbox#current
		let context = hwnd.context
		echo "exit: ". a:code . ' context: '. context . ' tag: ' . hwnd.tag
	endfunc
	let opts = {'title': 'select', 'context':'hahaha', 'close':'button'}
	let opts.index = 400
	let opts.border = 2
	let opts.keymap = {'=':'TAG:1', '+':'TAG:1024'}
	let opts.callback = 'MyCallback'
	call quickui#listbox#open(content, opts)
	" call s:nvim_create_listbox(content, opts)
endif


