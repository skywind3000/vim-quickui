"======================================================================
"
" confirm.vim - 
"
" Created by skywind on 2021/12/11
" Last Modified: 2021/12/13 22:07
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" build buttons
"----------------------------------------------------------------------
function! s:button_prepare(choices)
	let choices = quickui#utils#text_list_normalize(a:choices)
	let items = []
	let index = 0
	let max_size = 4
	for choice in choices
		let item = quickui#utils#item_parse(choice)
		let item.index = index
		let items += [item]
		let width = item.text_width
		let max_size = (max_size < width)? width : max_size
		let index += 1
	endfor
	for item in items
		let width = item.text_width
		let pad1 = (max_size - width) / 2
		let pad2 = max_size - width - pad1
		" let pad1 += 1
		" let pad2 += 1
		let item.text = repeat(' ', pad1) . item.text . repeat(' ', pad2)
		if item.key_pos >= 0
			let item.key_pos += pad1
		endif
		let item.text_width = strwidth(item.text)
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" synthesis button line
"----------------------------------------------------------------------
function! s:button_finalize(items, style)
	let items = a:items
	let final = ''
	let start = 0
	let index = len(a:items) - 1
	for item in a:items
		if 0
			let text = ' ' . item.text . ' '
		else
			let text = '<' . item.text . '>'
		endif
		let item.offset = -1
		let need = 0
		if 0
			let need = 1
			let text = '[' . text . ']'
		endif
		if item.key_pos >= 0
			let item.offset = start + 1 + item.key_pos + need
		endif
		let item.start = start
		let item.endup = start + item.text_width + 2 + need * 2
		let start += item.text_width + 2 + need * 2
		let final .= text
		if index > 0
			let final .= '  '
			let start += 2
		endif
		let index -= 1
	endfor
	return final
endfunc


"----------------------------------------------------------------------
" create highlight
"----------------------------------------------------------------------
function! s:hl_prepare(hwnd)
	let hwnd = a:hwnd
	let c1 = get(g:, 'quickui_button_color_on', 'QuickSel')
	let c2 = get(g:, 'quickui_button_color_off', 'QuickBG')
	let ck = get(g:, 'quickui_button_color_key', 'QuickKey')
	let hwnd.color_on = c1
	let hwnd.color_off = c2
	let hwnd.color_on2 = 'QuickButtonOn2'
	let hwnd.color_off2 = 'QuickButtonOff2'
	call quickui#highlight#clear('QuickBUttonOn2')
	call quickui#highlight#clear('QuickBUttonOff2')
	if 0
		call quickui#highlight#overlay('QuickButtonOn2', c1, ck)
		call quickui#highlight#overlay('QuickButtonOff2', c2, ck)
	else
		call quickui#highlight#make_underline('QuickButtonOn2', c1)
		call quickui#highlight#make_underline('QuickButtonOff2', c2)
	endif
endfunc


"----------------------------------------------------------------------
" calculate requirements
"----------------------------------------------------------------------
function! s:init(text, choices, index, title)
	let hwnd = {}
	let hwnd.text = quickui#utils#text_list_normalize(a:text)
	let hwnd.items = s:button_prepare(a:choices)
	let hwnd.final = s:button_finalize(hwnd.items, 0)
	let hwnd.index = a:index
	let button = ''
	let text_size = 40
	for text in hwnd.text
		let ts = strdisplaywidth(text)
		let text_size = (text_size < ts)? ts : text_size
	endfor
	let limit = &columns * 80 / 100
	let limit = get(g:, 'quickui_confirm_max_width', limit)
	let text_size = (text_size < limit)? text_size : limit
	let hwnd.btn_size = strdisplaywidth(hwnd.final)
	let hwnd.text_size = text_size
	let hwnd.w = (hwnd.btn_size > text_size)? hwnd.btn_size : text_size
	let hwnd.h = len(hwnd.text) + 3
	let hwnd.tw = hwnd.w + 4
	let hwnd.th = hwnd.h + 4
	let border = g:quickui#style#border
	let opts = {}
	let opts.w = hwnd.w
	let opts.h = hwnd.h
	let opts.border = get(g:, 'quickui_confirm_border', border)
	let opts.center = 1
	let opts.title = (a:title == '')? '' : (' ' . a:title . ' ')
	let opts.padding = [1, 1, 1, 1]
	let opts.button = 1
	let opts.wrap = 1
	let hwnd.opts = opts
	let content = deepcopy(hwnd.text)
	let content += [' ', ' ']
	let hwnd.padding = hwnd.w - hwnd.btn_size
	let content += [repeat(' ', hwnd.padding) . hwnd.final]
	let hwnd.content = content
	let hwnd.win = quickui#window#new()
	let hwnd.keymap = quickui#utils#keymap()
	let index = 1
	for item in hwnd.items
		if item.key_pos >= 0
			let ch = tolower(item.key_char)
			let hwnd.keymap[ch] = 'ACCEPT:' . index
		endif
		let index += 1
	endfor
	let hwnd.keymap['h'] = 'LEFT'
	let hwnd.keymap['l'] = 'RIGHT'
	call s:hl_prepare(hwnd)
	return hwnd
endfunc


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! s:draw_button(hwnd, index)
	let hwnd = a:hwnd
	let item = hwnd.items[a:index]
	let index = a:index
	let win = hwnd.win
	let top = hwnd.h - 1
	let off = hwnd.padding
	let x = item.start
	let e = item.endup
	if hwnd.index == index
		let c1 = hwnd.color_on
		let c2 = hwnd.color_on2
		" let c1 = 'QuickSel'
	else
		let c1 = hwnd.color_off
		let c2 = hwnd.color_off2
		" let c1 = 'QuickBG'
		" return
	endif
	if item.offset < 0
		call win.syntax_region(c1, off + x, top, off + e, top)
	else
		let u = item.offset + off
		call win.syntax_region(c1, off + x, top, u, top)
		call win.syntax_region(c2, u, top, u + 1, top)
		call win.syntax_region(c1, u + 1, top, off + e, top)
	endif
endfunc


"----------------------------------------------------------------------
" render
"----------------------------------------------------------------------
function! s:render(hwnd)
	let hwnd = a:hwnd
	let win = hwnd.win
	let off = hwnd.padding
	let top = hwnd.h - 1
	let index = 0
	call win.syntax_begin(1)
	for item in hwnd.items
		call s:draw_button(hwnd, index)
		let index += 1
	endfor
	" call win.syntax_region(ck, 12, 0, 13, 0)
	call win.syntax_end()
endfunc


"----------------------------------------------------------------------
" main entry
"----------------------------------------------------------------------
function! quickui#confirm#open(text, ...)
	let choices = (a:0 < 1)? " &OK " : (a:1)
	let index = (a:0 < 2)? 1 : (a:2)
	let title = (a:0 < 3)? 'Confirm' : (a:3)
	let choices = (choices == '')? " &OK " : choices
	let hwnd = s:init(a:text, choices, index - 1, title)
	let win = hwnd.win
	let accept = 0
	let size = len(hwnd.items)

	if size == 0
		return 0
	endif

	if has('nvim')
		let hwnd.opts.focusable = 1
	endif

	call win.open(hwnd.content, hwnd.opts)

	while 1
		call s:render(hwnd)
		redraw
		let ch = quickui#utils#getchar(1)
		if ch == "\<c-c>" || ch == "\<esc>"
			let accept = 0
			break
		elseif ch == "\<space>" || ch == "\<cr>"
			let accept = hwnd.index + 1
			break
		elseif win.quit != 0
			let accept = 0
			break
		elseif ch == "\<LeftMouse>"
			if has('nvim') == 0
				let pos = getmousepos()
				let x = pos.column - 1
				let y = pos.line - 1
			else
				let x = v:mouse_col - 1
				let y = v:mouse_lnum - 1
			endif
			if v:mouse_winid == win.winid
				if y == hwnd.h - 1 && x >= hwnd.padding
					let u = x - hwnd.padding
					for item in hwnd.items
						if u >= item.start && u < item.endup
							let accept = item.index + 1
							break
						endif
					endfor
					if accept > 0
						break
					endif
				endif
			elseif v:mouse_winid == win.info.border_winid
				if y == 0 && x == win.info.tw - 1
					let accept = 0
					break
				endif
			endif
		else
			let key = get(hwnd.keymap, ch, ch)
			if key == 'LEFT'
				let hwnd.index = (hwnd.index > 0)? (hwnd.index - 1) : 0
			elseif key == 'RIGHT'
				if hwnd.index < size - 1
					let hwnd.index += 1
				endif
			elseif key == 'HOME' || key == 'UP' || key == 'PAGEUP'
				let hwnd.index = 0
			elseif key == 'END' || key == 'DOWN' || key == 'PAGEDOWN'
				let hwnd.index = size - 1
			elseif key =~ '^ACCEPT:'
				let key = strpart(key, 7)
				let index = str2nr(key)
				if index > 0 && index <= size
					let accept = index
					break
				endif
			endif
		endif
	endwhile

	if accept > 0 && win.quit == 0
		let hwnd.index = accept - 1
		call s:render(hwnd)
		redraw
		sleep 15m
	endif

	call win.close()

	return accept
endfunc



