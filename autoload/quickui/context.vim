"======================================================================
"
" context.vim - 
"
" Created by skywind on 2019/12/19
" Last Modified: 2020/02/13 16:24
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :

"----------------------------------------------------------------------
" stats
"----------------------------------------------------------------------

" last position
let g:quickui#context#cursor = -1



"----------------------------------------------------------------------
" compile
"----------------------------------------------------------------------
function! quickui#context#compile(items, border)
	let menu = {'border':a:border}
	let items = []
	let helps = []
	let size_l = 0
	let size_r = 0
	let index = 0
	let helps = 0
	for item in a:items
		let ni = quickui#utils#item_parse(item)
		let ni.index = index
		let items += [ni]	
		let index += 1
		if ni.help != '' 
			let helps += 1
		endif
		" echo ni
		if ni.text_width > size_l 
			let size_l = ni.text_width
		endif
		if ni.desc_width > size_r
			let size_r = ni.desc_width
		endif
	endfor
	let stride = size_l + size_r + ((size_r > 0)? 2 : 0)
	for item in items
		call quickui#utils#context_align(item, size_l, size_r)
	endfor
	let menu.items = items
	let menu.helps = helps
	let image = []
	if a:border <= 0
		for item in items
			let image += [item.content]
		endfor
	else
		let pattern = quickui#core#border_get(a:border)
		let text = pattern[0] . repeat(pattern[1], stride + 2) . pattern[2]
		let image += [text]
		for item in items
			if item.is_sep
				let text = pattern[9] . repeat(pattern[4], stride + 2) . pattern[10]
				let image += [text]
			else
				let text = pattern[3] . ' ' . item.content . ' ' . pattern[5]
				let image += [text]
			endif
		endfor
		let text = pattern[6] . repeat(pattern[7], stride + 2) . pattern[8]
		let image += [text]
	endif
	let menu.image = image
	let menu.border = a:border
	let menu.height = len(image)
	let menu.width = (menu.height > 0)? strwidth(image[0]) : 0
	let menu.selected = -1
	let menu.size = len(items)
	let menu.exiting = 0
	let menu.state = 0
	let selection = []
	for item in menu.items
		if item.is_sep == 0
			let selection += [item.index]
		endif
	endfor
	let menu.selection = selection
	return menu
endfunc


"----------------------------------------------------------------------
" create menu object
"----------------------------------------------------------------------
function! s:vim_create_context(textlist, opts)
	let border = get(a:opts, 'border', g:quickui#style#border)
	let hwnd = quickui#context#compile(a:textlist, border)
	let winid = popup_create(hwnd.image, {'hidden':1, 'wrap':0})
	let w = hwnd.width
	let h = hwnd.height
	let hwnd.winid = winid
	let hwnd.index = get(a:opts, 'index', -1)
	let hwnd.opts = deepcopy(a:opts)
	let ignore_case = get(a:opts, 'ignore_case', 1)
	let opts = {'minwidth':w, 'maxwidth':w, 'minheight':h, 'maxheight':h}
	if has_key(a:opts, 'line') && has_key(a:opts, 'col')
		let opts.line = a:opts.line
		let opts.col = a:opts.col
	else
		let pos = quickui#core#around_cursor(w, h)
		let opts.line = pos[0]
		let opts.col = pos[1]
	endif
	call popup_move(winid, opts)
	call setwinvar(winid, '&wincolor', get(a:opts, 'color', 'QuickBG'))
	let opts = {'cursorline':0, 'drag':0, 'mapping':0}
	let opts.border = [0,0,0,0,0,0,0,0,0]
	let opts.title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
	let opts.padding = [0,0,0,0]
	let keymap = quickui#utils#keymap()
	let keymap['J'] = 'BOTTOM'
	let keymap['K'] = 'TOP'
	if has_key(a:opts, 'keymap')
		for key in keys(a:opts.keymap)
			let keymap[key] = a:opts.keymap[key]
		endfor
	endif
	let hwnd.code = 0
	let hwnd.state = 1
	let hwnd.keymap = keymap
	let hwnd.hotkey = {}
	for item in hwnd.items
		if item.enable != 0 && item.key_pos >= 0
			let key = ignore_case ? tolower(item.key_char) : item.key_char
			if get(a:opts, 'reserve', 0) == 0
				let hwnd.hotkey[key] = item.index
			elseif get(g:, 'quickui_protect_hjkl', 0) != 0
				let hwnd.hotkey[key] = item.index
			else
				if key != 'h' && key != 'j' && key != 'k' && key != 'l'
					let hwnd.hotkey[key] = item.index
				endif
			endif
		endif
	endfor
	let local = quickui#core#popup_local(winid)
	let local.hwnd = hwnd
	if get(a:opts, 'manual', 0) == 0
		let opts.callback = function('s:popup_exit')
		let opts.filter = function('s:popup_filter')
	endif
	if has_key(a:opts, 'zindex')
		let opts.zindex = a:opts.zindex
	endif
	call popup_setoptions(winid, opts)
	call quickui#context#update(hwnd)
	call popup_show(winid)
	return hwnd
endfunc


"----------------------------------------------------------------------
" render menu 
"----------------------------------------------------------------------
function! quickui#context#update(hwnd)
	let winid = a:hwnd.winid
	let size = len(a:hwnd.items)
	let w = a:hwnd.width
	let h = a:hwnd.height
	let cmdlist = ['syn clear']
	for item in a:hwnd.items
		let index = item.index
		if item.enable == 0 && item.is_sep == 0
			if a:hwnd.border == 0
				let py = index + 1
				let px = 1
				let ps = px + w
			else
				let py = index + 2
				let px = 3
				let ps = px + w - 4
			endif
			let cmd = quickui#core#high_region('QuickOff', py, px, py, ps, 1)
			let cmdlist += [cmd]
		elseif item.key_pos >= 0
			if a:hwnd.border == 0
				let px = item.key_pos + 1
				let py = index + 1
			else
				let px = item.key_pos + 3
				let py = index + 2
			endif
			let ps = px + 1
			let cmd = quickui#core#high_region('QuickKey', py, px, py, ps, 1)
			let cmdlist += [cmd]
		endif
		if index == a:hwnd.index
			if a:hwnd.border == 0
				let py = index + 1
				let px = 1
				let ps = px + w
			else
				let py = index + 2
				let px = 2
				let ps = px + w - 2
			endif
			let cmd = quickui#core#high_region('QuickSel', py, px, py, ps, 1)
			let cmdlist += [cmd]
		endif
	endfor
	call quickui#core#win_execute(winid, cmdlist)
	if a:hwnd.state != 0
		redraw
		if get(g:, 'quickui_show_tip', 0) != 0
			let help = ''
			if a:hwnd.index >= 0 && a:hwnd.index < len(a:hwnd.items)
				let help = a:hwnd.items[a:hwnd.index].help
				let head = g:quickui#style#tip_head
				if help != ''
					let help = quickui#core#expand_text(help)
					let help = '' . ((head != '')? (head . ' ') : '') . help
				endif
			endif
			echohl QuickHelp
			echo help
			echohl None
		endif
	endif
endfunc


"----------------------------------------------------------------------
" close context
"----------------------------------------------------------------------
function! quickui#context#close(hwnd)
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
	if !has_key(local, 'hwnd')
		return 0
	endif
	let hwnd = local.hwnd
	let code = a:code
	let hwnd.state = 0
	let hwnd.code = code
	call quickui#core#popup_clear(a:winid)
	if get(g:, 'quickui_show_tip', 0) != 0
		if get(hwnd.opts, 'lazyredraw', 0) == 0
			redraw
			echo ''
			redraw
		endif
	endif
	let g:quickui#context#code = code
	let g:quickui#context#current = hwnd
	let g:quickui#context#cursor = hwnd.index
	let redrawed = 0
	if has_key(hwnd.opts, 'callback')
		call call(hwnd.opts.callback, [code])
	endif
	silent! call popup_hide(a:winid)
	if code >= 0 && code < len(hwnd.items)
		let item = hwnd.items[code]
		if item.is_sep == 0 && item.enable != 0
			if item.cmd != ''
				redraw
				try
					exec item.cmd
				catch /.*/
					echohl Error
					echom v:exception
					echohl None
				endtry
			endif
		endif
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" key processing
"----------------------------------------------------------------------
function! s:popup_filter(winid, key)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.hwnd
	let winid = hwnd.winid
	if a:key == "\<ESC>" || a:key == "\<c-c>"
		call popup_close(a:winid, -1)
		return 1
	elseif a:key == "\<CR>" || a:key == "\<SPACE>"
		call s:on_confirm(hwnd)
		return 1
	elseif a:key == "\<LeftMouse>"
		return s:on_click(hwnd)
	elseif has_key(hwnd.hotkey, a:key)
		let key = hwnd.hotkey[a:key]
		if key >= 0 && key < len(hwnd.items)
			let item = hwnd.items[key]
			if item.is_sep == 0 && item.enable != 0
				let hwnd.index = key
				call quickui#context#update(hwnd)
				call popup_setoptions(winid, {})
				redraw
				call popup_close(winid, key)
				return 1
			endif
		endif
	elseif has_key(hwnd.keymap, a:key)
		let key = hwnd.keymap[a:key]
		if key == 'ESC'
			call popup_close(a:winid, -1)
			return 1
		elseif key == 'UP'
			let hwnd.index = s:cursor_move(hwnd, hwnd.index, -1)
		elseif key == 'DOWN'
			let hwnd.index = s:cursor_move(hwnd, hwnd.index, 1)
		elseif key == 'TOP'
			let hwnd.index = s:cursor_move(hwnd, hwnd.index, 'TOP')
		elseif key == 'BOTTOM'
			let hwnd.index = s:cursor_move(hwnd, hwnd.index, 'BOTTOM')
		endif
		if get(hwnd.opts, 'horizon', 0) != 0
			if key == 'LEFT'
				call popup_close(a:winid, -1000)
			elseif key == 'RIGHT'
				call popup_close(a:winid, -2000)
			elseif key == 'PAGEUP'
				call popup_close(a:winid, -1001)
			elseif key == 'PAGEDOWN'
				call popup_close(a:winid, -2001)
			endif
		endif
		call quickui#context#update(hwnd)
		return 1
	endif
	return 1
endfunc


"----------------------------------------------------------------------
" press enter or space
"----------------------------------------------------------------------
function! s:on_confirm(hwnd)
	let index = a:hwnd.index
	if index < 0 || index > len(a:hwnd.items)
		return 1
	endif
	let item = a:hwnd.items[index]
	if item.is_sep || item.enable == 0
		return 1
	endif
	call popup_close(a:hwnd.winid, index)
	return 1
endfunc


"----------------------------------------------------------------------
" mouse left click
"----------------------------------------------------------------------
function! s:on_click(hwnd)
	let hwnd = a:hwnd
	let winid = a:hwnd.winid
	if g:quickui#core#has_nvim == 0
		let pos = getmousepos()
		if pos.winid != winid
			call popup_close(winid, -2)
			return 0
		endif
		let index = -1
		if hwnd.border == 0
			let index = pos.line - 1
		else
			if pos.column > 1 && pos.column < hwnd.width
				if pos.line > 1 && pos.line < hwnd.height
					let index = pos.line - 2
				endif
			endif
		endif
		if index >= 0 && index < len(hwnd.items)
			let item = hwnd.items[index]
			if item.is_sep == 0 && item.enable != 0
				let hwnd.index = index
				call quickui#context#update(hwnd)
				call popup_setoptions(winid, {})
				redraw
				call popup_close(winid, index)
			endif
		endif
		return 1
	else
		if v:mouse_winid != winid
			return -2
		endif
		let index = -1
		if hwnd.border == 0
			let index = v:mouse_lnum - 1
		else
			if v:mouse_col > 1 && v:mouse_col < hwnd.width
				if v:mouse_lnum > 1 && v:mouse_lnum < hwnd.height
					let index = v:mouse_lnum - 2
				endif
			endif
		endif
		if index >= 0 && index < len(hwnd.items)
			let item = hwnd.items[index]
			if item.is_sep == 0 && item.enable != 0
				let hwnd.index = index
				call quickui#context#update(hwnd)
				redraw
				sleep 60m
				return index
			endif
		endif
		return -1
	endif
endfunc


"----------------------------------------------------------------------
" move cursor
"----------------------------------------------------------------------
function! s:cursor_move(menu, cursor, toward)
	let size = a:menu.size
	if type(a:toward) == v:t_number 
		if a:toward == 0 
			if size <= 0
				return -1
			elseif a:cursor < 0
				return a:cursor
			endif
			return (a:cursor >= size)? (size - 1) : a:cursor
		endif
	endif
	let selection = a:menu.selection
	if size == 0 || len(selection) == 0
		return -1
	endif
	let cursor = a:cursor + a:toward
	if type(a:toward) == v:t_number
		if a:toward < 0
			if a:cursor < 0
				return selection[0]
			endif
			let cursor = (cursor < 0)? 0 : cursor
			let pos = len(selection) - 1
			while pos >= 0
				if selection[pos] <= cursor
					return selection[pos]
				endif
				let pos -= 1
			endwhile
			return selection[0]
		else
			let pos = 0
			let limit = len(selection)
			while pos < limit
				if selection[pos] >= cursor
					return selection[pos]
				endif
				let pos += 1
			endwhile
			return selection[limit - 1]
		endif
	else
		if a:toward == 'TOP'
			return selection[0]
		elseif a:toward == 'BOTTOM'
			return selection[-1]
		endif
	endif
	return -1
endfunc


"----------------------------------------------------------------------
" open context menu in neovim and returns index
"----------------------------------------------------------------------
function! s:nvim_create_context(textlist, opts)
	let border = get(a:opts, 'border', g:quickui#style#border)
	let ignore_case = get(a:opts, 'ignore_case', 1)
	let hwnd = quickui#context#compile(a:textlist, border)
	let bid = quickui#core#scratch_buffer('context', hwnd.image)
	let hwnd.bid = bid
	let w = hwnd.width
	let h = hwnd.height
	let hwnd.index = get(a:opts, 'index', -1)
	let hwnd.opts = deepcopy(a:opts)
	let opts = {'width':w, 'height':h, 'focusable':1, 'style':'minimal'}
	let opts.relative = 'editor'
	if has_key(a:opts, 'line') && has_key(a:opts, 'col')
		let opts.row = a:opts.line - 1
		let opts.col = a:opts.col - 1
	else
		let pos = quickui#core#around_cursor(w, h)
		let opts.row = pos[0] - 1
		let opts.col = pos[1] - 1
	endif
	let winid = nvim_open_win(bid, 0, opts)
	let hwnd.winid = winid
	let keymap = quickui#utils#keymap()
	let keymap['J'] = 'BOTTOM'
	let keymap['K'] = 'TOP'
	let hwnd.code = 0
	let hwnd.state = 1
	let hwnd.keymap = keymap
	let hwnd.hotkey = {}
	for item in hwnd.items
		if item.enable != 0 && item.key_pos >= 0
			let key = ignore_case ? tolower(item.key_char) : item.key_char
			if get(a:opts, 'reserve', 0) == 0
				let hwnd.hotkey[key] = item.index
			elseif get(g:, 'quickui_protect_hjkl', 0) != 0
				let hwnd.hotkey[key] = item.index
			else
				if key != 'h' && key != 'j' && key != 'k' && key != 'l'
					let hwnd.hotkey[key] = item.index
				endif
			endif
		endif
	endfor
	let hwnd.opts.color = get(a:opts, 'color', 'QuickBG')
    call nvim_win_set_option(winid, 'winhl', 'Normal:'. hwnd.opts.color)
	let retval = -1
	while 1
		noautocmd call quickui#context#update(hwnd)
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
			let index = hwnd.index
			if index >= 0 && index < len(hwnd.items)
				let item = hwnd.items[index]
				if item.is_sep == 0 && item.enable != 0
					let retval = index
					break
				endif
			endif
		elseif ch == "\<LeftMouse>"
			let hr = s:on_click(hwnd)
			if hr == -2 || hr >= 0
				let retval = hr
				break
			endif
		elseif has_key(hwnd.hotkey, ch)
			let hr = hwnd.hotkey[ch]
			if hr >= 0
				let hwnd.index = hr
				let retval = hr
				break
			endif
		elseif has_key(hwnd.keymap, ch)
			let key = hwnd.keymap[ch]
			if key == 'ESC'
				break
			elseif key == 'UP'
				let hwnd.index = s:cursor_move(hwnd, hwnd.index, -1)
			elseif key == 'DOWN'
				let hwnd.index = s:cursor_move(hwnd, hwnd.index, 1)
			elseif key == 'TOP'
				let hwnd.index = s:cursor_move(hwnd, hwnd.index, 'TOP')
			elseif key == 'BOTTOM'
				let hwnd.index = s:cursor_move(hwnd, hwnd.index, 'BOTTOM')
			endif
			if get(hwnd.opts, 'horizon', 0) != 0
				if key == 'LEFT'
					let retval = -1000
					break
				elseif key == 'RIGHT'
					let retval = -2000
					break
				elseif key == 'PAGEUP'
					let retval = -1001
					break
				elseif key == 'PAGEDOWN'
					let retval = -2001
					break
				endif
			endif
		endif
	endwhile
	call nvim_win_close(winid, 0)
	if get(a:opts, 'lazyredraw', 0) == 0
		redraw
	endif
	if get(g:, 'quickui_show_tip', 0) != 0
		if get(a:opts, 'lazyredraw', 0) == 0
			echo ''
			redraw
		endif
	endif
	let g:quickui#context#code = retval
	let g:quickui#context#current = hwnd
	let g:quickui#context#cursor = hwnd.index
	if has_key(hwnd.opts, 'callback')
		call call(hwnd.opts.callback, [retval])
	endif
	if retval >= 0 && retval < len(hwnd.items)
		let item = hwnd.items[retval]
		if item.is_sep == 0 && item.enable != 0
			if item.cmd != ''
				redraw
				try
					exec item.cmd
				catch /.*/
					echohl Error
					echom v:exception
					echohl None
				endtry
			endif
		endif
	endif
	return retval
endfunc


"----------------------------------------------------------------------
" reduce with file types
"----------------------------------------------------------------------
function! quickui#context#reduce_items(textlist)
	let output = []
	let state = 1
	let index = 0
	let limit = len(a:textlist)
	for item in a:textlist
		if len(item) > 0
			let issep = ((item[0]) =~ '^-\+$')? 1 : 0
			if issep != 0
				if state == 0
					if index + 1 < limit
						let output += [item]
						let state = 1
					endif
				endif
			else
				if type(item) == v:t_string
					let output += [item]
					let state = 0
				elseif len(item) < 4
					let output += [item]
					let state = 0
				else
					for check in split(item[3], ',')
						if &ft == check
							let output += [item]
							let state = 0
							break
						endif
					endfor
				endif
			endif
		endif
		let index += 1
	endfor
	return output
endfunc


"----------------------------------------------------------------------
" create menu object
"----------------------------------------------------------------------
function! quickui#context#open(textlist, opts)
	let textlist = a:textlist
	if g:quickui#core#has_nvim == 0
		return s:vim_create_context(textlist, a:opts)
	else
		return s:nvim_create_context(textlist, a:opts)
	endif
endfunc


"----------------------------------------------------------------------
" testing suit 
"----------------------------------------------------------------------
if 0
	call quickui#utils#highlight('default')
	let lines = [
				\ "&New File\tCtrl+n",
				\ "&Open File\tCtrl+o", 
				\ ["&Close", 'echo 1234', 'help 1'],
				\ "--",
				\ "&Save\tCtrl+s",
				\ "Save &As",
				\ "Save All",
				\ "--",
				\ "&User Menu\tF9",
				\ "&Dos Shell",
				\ "~&Time %{&undolevels? '+':'-'}",
				\ ["S&plit", 'help 1', '', 'vim2'],
				\ "--",
				\ "E&xit\tAlt+x",
				\ "&Help",
				\ ]
	" echo quickui#core#pattern_ascii
	" let menu = quickui#context#menu_compile(lines, 1)
	let opts = {'cursor': -1, 'line2':'cursor+1', 'col2': 'cursor', 'horizon':1}
	" let opts.index = 2
	let opts.savepos = 'f'
	let opts.callback = 'MyCallback'
	let opts.reduce = 1
	function! MyCallback(code)
		echom "callback: " . a:code
	endfunc
	if 1
		let menu = quickui#context#open(lines, opts)
		" echo menu
	else
		let item = quickui#utils#item_parse("你好吗f&aha\tAlt+x")	
		echo item
	endif
endif



