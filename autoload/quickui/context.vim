"======================================================================
"
" context.vim - 
"
" Created by skywind on 2019/12/19
" Last Modified: 2019/12/19 15:21:18
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :

"----------------------------------------------------------------------
" compile
"----------------------------------------------------------------------
function! quickui#context#menu_compile(items, border)
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
" render a menu
"----------------------------------------------------------------------
function! quickui#context#menu_render(winid, menuobj, index, reuse)
	let image = a:menuobj.image
	if len(image) == 0 
		return
	endif
	let h = a:menuobj.height
	let w = a:menuobj.width
	let bufnr = winbufnr(a:winid)
	if a:reuse == 0
		let opts = {"minwidth":w, "minheight":h, "maxwidth":w, "maxheight":h}
		call popup_move(a:winid, opts)
		let index = 0
		while index < h
			call setbufline(bufnr, index + 1, image[index])
			let index += 1
		endwhile
		call win_execute(a:winid, "setlocal nowrap nonumber signcolumn=no")
	endif
	call setwinvar(a:winid, '&wincolor', 'QuickBG')
	call win_execute(a:winid, "syn clear")
	let size = len(a:menuobj.items)
	for item in a:menuobj.items
		let index = item.index
		if item.key_pos >= 0
			if a:menuobj.border == 0
				let px = item.key_pos + 1
				let py = index + 1
			else
				let px = item.key_pos + 3
				let py = index + 2
			endif
			let cmd = quickui#core#high_region('QuickKey', py, px, py, px + 1, 1)
			call win_execute(a:winid, cmd)
		endif
		if item.enable == 0 && item.is_sep == 0
			if a:menuobj.border == 0
				let py = index + 1
				let px = 1
				let ps = w
			else
				let py = index + 2
				let px = 3
				let ps = w - 4
			endif
			let cmd = quickui#core#high_region('QuickOff', py, px, py, px + ps, 1)
			call win_execute(a:winid, cmd)
		endif
		if index == a:index
			if a:menuobj.border == 0
				let py = index + 1
				let px = 1
				let ps = w
			else
				let py = index + 2
				let px = 2
				let ps = w - 2
			endif
			let cmd = quickui#core#high_region('QuickSel', py, px, py, px + ps, 1)
			call win_execute(a:winid, cmd)
		endif
	endfor
	" call win_execute(a:winid, 'syn')
endfunc


"----------------------------------------------------------------------
" keep cursor in range
"----------------------------------------------------------------------
function! s:cursor_within(size, cursor)
	if a:size <= 0
		return -1
	elseif a:cursor < 0
		return a:cursor
	endif
	return (a:cursor >= a:size)? (a:size - 1) : a:cursor
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
endfunc


"----------------------------------------------------------------------
" update keymap
"----------------------------------------------------------------------
function! s:build_keymap(menu)
	let maps = quickui#utils#keymap()
	for item in a:menu.items
		if item.key_pos >= 0 && item.is_sep == 0
			if item.enable
				let key = item.key_char
				let maps[tolower(key)] = item.index
			endif
		endif
	endfor
	return maps
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:win_pos_adjust(winw, winh, pos, options)
	let screen_w = &columns
	let screen_h = &lines
	let x = has_key(a:pos, 'col')? a:pos.col : -1
	let y = has_key(a:pos, 'line')? a:pos.line : -1
	if x < 0 || y < 0
		let x = (screen_w - winw) / 2 + 1
		let y = (screen_h - winh) / 2
		let y = (y < 1)? 1 : y
	endif
	if get(a:options, 'auto', 0)
		if x - 1 + winw > screen_w
			let x = screen_w - winw + 1
		endif
		if y - 1 + winh > screen_h
			let y = screen_h - winh + 1
		endif
		let x = (x < 1)? 1 : x
		let y = (y < 1)? 1 : y
	endif
	let a:pos.col = x
	let a:pos.line = y
endfunc


"----------------------------------------------------------------------
" show popup context menu
"----------------------------------------------------------------------
function! quickui#context#show(items, options)
	let border = get(a:options, 'border', g:quickui#style#border)
	let menu = quickui#context#menu_compile(a:items, border)
	let winid = quickui#core#popup_alloc('context')
	let size = len(a:items)
	let cursor = s:cursor_within(size, get(a:options, 'cursor', 0))
	let selected = -1
	let horizon = get(a:options, 'horizon', 0)
	let maps = s:build_keymap(menu)
	let a:options.cursor = cursor
	call popup_hide(winid)
	call quickui#context#menu_render(winid, menu, cursor, 0)
	let pos = {}
	let screen_w = &columns
	let screen_h = &lines
	if has_key(a:options, 'line') && has_key(a:options, 'col')
		let pos.line = a:options.line
		let pos.col = a:options.col
	else
		let pos.line = (screen_h - menu.height) / 2 + 1
		let pos.col = (screen_w - menu.width) / 2 + 1
	endif
	call popup_move(winid, pos)
	if get(a:options, 'fixed', 0) == 0
		let pos = popup_getpos(winid)
		let x = pos.col
		let y = pos.line
		let winw = menu.width
		let winh = menu.height
		if x - 1 + winw > screen_w
			let x = screen_w - winw + 1
		endif
		if y - 1 + winh > screen_h
			let y = screen_h - winh + 1
		endif
		let newpos = {}
		let newpos.col = (x < 1)? 1 : x
		let newpos.line = (y < 1)? 1 : y
		if newpos.col != pos.col || newpos.line != pos.line
			call popup_move(winid, newpos)
		endif
	endif
	while 1
		call quickui#context#menu_render(winid, menu, cursor, 1)
		call popup_show(winid)
		redraw
		if cursor >= 0 && cursor <= size && menu.helps > 0
			let help = menu.items[cursor].help
			echohl QuickHelp
			echo help
			echohl None
		endif
		try
			let code = getchar()
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		let action = (ch == "\<ESC>")? 'ESC' : get(maps, ch, '')
		if type(action) == v:t_string
			if ch == "\<c-c>" || ch == "\<ESC>" || action == 'ESC'
				break
			elseif action == 'ENTER'
				if cursor >= 0 && cursor < size
					let item = menu.items[cursor]
					if item.is_sep == 0 && item.enable
						let selected = cursor
						break
					endif
				endif
			elseif action == 'UP'
				let cursor = s:cursor_move(menu, cursor, -1)
			elseif action == 'DOWN'
				let cursor = s:cursor_move(menu, cursor, 1)
			elseif action == 'TOP' || action == 'PAGEUP'
				let cursor = s:cursor_move(menu, cursor, 'TOP')
			elseif action == 'BOTTOM' || action == 'PAGEDOWN'
				let cursor = s:cursor_move(menu, cursor, 'BOTTOM')
			elseif action == 'LEFT'
				if horizon
					let a:options.arrow = -1
					break
				endif
			elseif action == 'RIGHT'
				if horizon
					let a:options.arrow = 1
					break
				endif
			endif
			let a:options.cursor = cursor
		elseif type(action) == v:t_number
			if action >= 0 && action < size
				let cursor = action
				let a:options.cursor = cursor
				let item = menu.items[cursor]
				if item.is_sep == 0 && item.enable
					let selected = cursor
					break
				endif
			endif
		endif
	endwhile
	call quickui#core#popup_release('context', winid)
	redraw
	return selected
endfunc





"----------------------------------------------------------------------
" testing suit 
"----------------------------------------------------------------------
if 1
	call quickui#utils#highlight('default')
	let lines = [
				\ "&New File\tCtrl+n",
				\ "&Open File\tCtrl+o", 
				\ "&Close",
				\ "--",
				\ "&Save\tCtrl+s",
				\ "Save &As",
				\ "Save All",
				\ "-",
				\ "&User Menu\tF9",
				\ "&Dos Shell",
				\ "~&Time %{&undolevels? '+':'-'}",
				\ "--",
				\ "E&xit\tAlt+x",
				\ "&Help",
				\ ]
	" echo quickui#core#pattern_ascii
	" let menu = quickui#context#menu_compile(lines, 1)
	let opts = {'cursor': -1, 'line2':'cursor+1', 'col2': 'cursor', 'horizon':1}
	let opts.border = 2
	let index = quickui#context#show(lines, opts)
	echo index
endif



