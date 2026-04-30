"======================================================================
"
" dialog.vim - data-driven dialog box
"
" Created by skywind on 2025/04/29
" Last Modified: 2025/04/29 00:00
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" internal variables
"----------------------------------------------------------------------
let s:has_nvim = g:quickui#core#has_nvim
let s:history = {}


"----------------------------------------------------------------------
" parse items: create internal control objects from user item list
"----------------------------------------------------------------------
function! s:parse_items(items) abort
	let controls = []
	let names = {}
	for i in range(len(a:items))
		let item = a:items[i]
		let tp = get(item, 'type', '')
		let ctrl = {}
		let ctrl.type = tp
		let ctrl.index = i
		let ctrl.line_start = 0
		let ctrl.line_count = 1
		let ctrl.focusable = 0
		if tp ==# 'label'
			let text = get(item, 'text', '')
			if type(text) == v:t_list
				let ctrl.lines = copy(text)
			else
				let ctrl.lines = split('' . text, "\n", 1)
			endif
			let ctrl.line_count = len(ctrl.lines)
		elseif tp ==# 'input'
			let name = get(item, 'name', '')
			if name ==# ''
				echoerr 'quickui#dialog: input control missing name'
				return []
			endif
			if has_key(names, name)
				echoerr 'quickui#dialog: duplicate name "' . name . '"'
				return []
			endif
			let names[name] = 1
			let ctrl.name = name
			let ctrl.prompt = get(item, 'prompt', '')
			let ctrl.value = get(item, 'value', '')
			let ctrl.history_key = get(item, 'history', '')
			let ctrl.prompt_width = 0
			let ctrl.input_col = 0
			let ctrl.input_width = 0
			let ctrl.focusable = 1
			let ctrl.rl = quickui#readline#new()
			call ctrl.rl.set(ctrl.value)
			call ctrl.rl.seek(0, 2)
			if ctrl.history_key != ''
				let key = ctrl.history_key
				let ctrl.rl.history = [''] + get(s:history, key, [])
			endif
			let ctrl.pos = 0
		elseif tp ==# 'radio'
			let name = get(item, 'name', '')
			if name ==# ''
				echoerr 'quickui#dialog: radio control missing name'
				return []
			endif
			if has_key(names, name)
				echoerr 'quickui#dialog: duplicate name "' . name . '"'
				return []
			endif
			let names[name] = 1
			let ctrl.name = name
			let ctrl.prompt = get(item, 'prompt', '')
			let ctrl.prompt_width = 0
			let ctrl.items = get(item, 'items', [])
			let ctrl.value = get(item, 'value', 0)
			let ctrl.cursor = ctrl.value
			let ctrl.vertical = get(item, 'vertical', -1)
			let ctrl.focusable = 1
			let ctrl.parsed = []
			for text in ctrl.items
				let parsed = quickui#utils#item_parse(text)
				let ctrl.parsed += [parsed]
			endfor
		elseif tp ==# 'check'
			let name = get(item, 'name', '')
			if name ==# ''
				echoerr 'quickui#dialog: check control missing name'
				return []
			endif
			if has_key(names, name)
				echoerr 'quickui#dialog: duplicate name "' . name . '"'
				return []
			endif
			let names[name] = 1
			let ctrl.name = name
			let ctrl.text = get(item, 'text', '')
			let ctrl.prompt = get(item, 'prompt', '')
			let ctrl.prompt_width = 0
			let ctrl.value = get(item, 'value', 0)
			let ctrl.focusable = 1
			let ctrl.parsed = quickui#utils#item_parse(ctrl.text)
		elseif tp ==# 'button'
			let name = get(item, 'name', 'button')
			if has_key(names, name)
				echoerr 'quickui#dialog: duplicate name "' . name . '"'
				return []
			endif
			let names[name] = 1
			let ctrl.name = name
			let ctrl.items = get(item, 'items', [])
			let ctrl.value = get(item, 'value', 0)
			let ctrl.focusable = 1
			let ctrl.parsed = []
			for text in ctrl.items
				let parsed = quickui#utils#item_parse(text)
				let ctrl.parsed += [parsed]
			endfor
		elseif tp ==# 'separator'
			let ctrl.line_count = 1
			let ctrl.focusable = 0
		elseif tp ==# 'dropdown'
			let name = get(item, 'name', '')
			if name ==# ''
				echoerr 'quickui#dialog: dropdown control missing name'
				return []
			endif
			if has_key(names, name)
				echoerr 'quickui#dialog: duplicate name "' . name . '"'
				return []
			endif
			let names[name] = 1
			let ctrl.name = name
			let ctrl.prompt = get(item, 'prompt', '')
			let ctrl.prompt_width = 0
			let ctrl.items = get(item, 'items', [])
			let ctrl.value = get(item, 'value', 0)
			if len(ctrl.items) > 0
				if ctrl.value < 0 | let ctrl.value = 0 | endif
				if ctrl.value >= len(ctrl.items)
					let ctrl.value = len(ctrl.items) - 1
				endif
			else
				let ctrl.value = 0
			endif
			let ctrl.focusable = 1
			let ctrl.dropdown_col = 0
			let ctrl.dropdown_width = 0
		else
			echoerr 'quickui#dialog: unknown control type "' . tp . '"'
			return []
		endif
		let controls += [ctrl]
	endfor
	return controls
endfunc


"----------------------------------------------------------------------
" calculate alignment groups and layout
"----------------------------------------------------------------------
function! s:calc_layout(hwnd, opts) abort
	let hwnd = a:hwnd
	let controls = hwnd.controls
	let gap = get(a:opts, 'gap', 1)
	let content_w = hwnd.w

	" -- pass 1: compute prompt alignment groups --
	" A group is a maximal consecutive run of controls that have a non-empty
	" prompt field. Only a focusable control without a prompt breaks a group;
	" labels never break groups.
	let groups = []
	let cur_group = []
	for ctrl in controls
		let has_prompt = 0
		if ctrl.type ==# 'input' || ctrl.type ==# 'radio' || ctrl.type ==# 'dropdown'
			let has_prompt = (ctrl.prompt !=# '') ? 1 : 0
		elseif ctrl.type ==# 'check'
			let has_prompt = (ctrl.prompt !=# '') ? 1 : 0
		endif
		if ctrl.type ==# 'label' || ctrl.type ==# 'separator'
			" labels/separators don't break alignment groups
			continue
		endif
		if has_prompt
			let cur_group += [ctrl]
		else
			if len(cur_group) > 0
				let groups += [cur_group]
				let cur_group = []
			endif
		endif
	endfor
	if len(cur_group) > 0
		let groups += [cur_group]
	endif

	" set prompt_width for each alignment group
	for group in groups
		let max_pw = 0
		for ctrl in group
			let pw = strdisplaywidth(ctrl.prompt)
			let max_pw = (max_pw < pw) ? pw : max_pw
		endfor
		let aligned_pw = max_pw + 2
		for ctrl in group
			let ctrl.prompt_width = aligned_pw
		endfor
	endfor

	" controls without prompt: prompt_width stays 0
	for ctrl in controls
		if ctrl.type ==# 'input' && ctrl.prompt_width == 0 && ctrl.prompt ==# ''
			let ctrl.prompt_width = 0
		endif
		if ctrl.type ==# 'radio' && ctrl.prompt_width == 0 && ctrl.prompt ==# ''
			let ctrl.prompt_width = 0
		endif
		if ctrl.type ==# 'check' && ctrl.prompt_width == 0 && ctrl.prompt ==# ''
			let ctrl.prompt_width = 0
		endif
		if ctrl.type ==# 'dropdown' && ctrl.prompt_width == 0 && ctrl.prompt ==# ''
			let ctrl.prompt_width = 0
		endif
	endfor

	" -- pass 1.5: expand width for prompt alignment inflation --
	" After alignment, check/radio may need more width than calc_width
	" estimated (their content width is fixed, unlike input/dropdown which
	" adapt via input_width/dropdown_width).
	for ctrl in controls
		let need = 0
		if ctrl.type ==# 'check'
			let need = ctrl.prompt_width + 4 + ctrl.parsed.text_width
		elseif ctrl.type ==# 'radio'
			" vertical-mode per-line width
			for p in ctrl.parsed
				let rn = ctrl.prompt_width + 4 + p.text_width
				let need = (need < rn) ? rn : need
			endfor
			" forced-horizontal width
			if ctrl.vertical == 0
				let hw = ctrl.prompt_width
				for p in ctrl.parsed
					let hw += 4 + p.text_width + 2
				endfor
				if len(ctrl.parsed) > 0
					let hw -= 2
				endif
				let need = (need < hw) ? hw : need
			endif
		endif
		if need > content_w
			let content_w = need
		endif
	endfor
	let max_w = &columns * 80 / 100
	if content_w > max_w
		let content_w = max_w
	endif
	let hwnd.w = content_w

	" -- pass 2: compute radio vertical layout --
	for ctrl in controls
		if ctrl.type !=# 'radio'
			continue
		endif
		let vert = ctrl.vertical
		if vert == 1
			let ctrl.is_vertical = 1
		elseif vert == 0
			let ctrl.is_vertical = 0
		else
			" auto: calculate horizontal width
			let hw = ctrl.prompt_width
			for p in ctrl.parsed
				" (*) text + 2 spaces gap
				let hw += 4 + p.text_width + 2
			endfor
			let hw -= 2   " remove trailing gap
			let ctrl.is_vertical = (hw > content_w) ? 1 : 0
		endif
		if ctrl.is_vertical
			let ctrl.line_count = len(ctrl.items)
		else
			let ctrl.line_count = 1
		endif
	endfor

	" -- pass 3: assign line positions with gap insertion --
	let y = 0
	let prev_type = ''
	for ctrl in controls
		if ctrl.type ==# 'separator'
			let ctrl.line_start = y
			let y += ctrl.line_count
			let prev_type = ''
			continue
		endif
		if prev_type !=# '' && prev_type !=# ctrl.type
			let y += gap
		endif
		let ctrl.line_start = y
		let y += ctrl.line_count
		let prev_type = ctrl.type
	endfor
	let hwnd.content_h = y

	" -- pass 4: compute input/dropdown col/width --
	for ctrl in controls
		if ctrl.type ==# 'input'
			let ctrl.input_col = ctrl.prompt_width
			let ctrl.input_width = content_w - ctrl.input_col
			if ctrl.input_width < 4
				let ctrl.input_width = 4
			endif
		elseif ctrl.type ==# 'dropdown'
			let ctrl.dropdown_col = ctrl.prompt_width
			let ctrl.dropdown_width = content_w - ctrl.dropdown_col
			if ctrl.dropdown_width < 4
				let ctrl.dropdown_width = 4
			endif
		endif
	endfor

	" -- height overflow check --
	let pad = get(a:opts, 'padding', [1,1,1,1])
	let border = get(a:opts, 'border', g:quickui#style#border)
	let total_h = hwnd.content_h + pad[0] + pad[2]
	if border > 0
		let total_h += 2
	endif
	if total_h > &lines - 2
		echoerr 'quickui#dialog: dialog too tall (' . total_h . ' lines, screen has ' . &lines . ')'
		return -1
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" build focus list from controls
"----------------------------------------------------------------------
function! s:build_focus_list(hwnd) abort
	let hwnd = a:hwnd
	let hwnd.focus_list = []
	let idx = 0
	for ctrl in hwnd.controls
		if ctrl.focusable
			let entry = {'index': idx, 'type': ctrl.type, 'control': ctrl}
			let hwnd.focus_list += [entry]
		endif
		let idx += 1
	endfor
endfunc


"----------------------------------------------------------------------
" build keymap: collect hotkeys from button/radio/check
"----------------------------------------------------------------------
function! s:build_keymap(hwnd) abort
	let hwnd = a:hwnd
	let hwnd.keymap = {}
	let used = {}
	for ctrl in hwnd.controls
		if ctrl.type ==# 'button'
			let bi = 0
			for p in ctrl.parsed
				if p.key_pos >= 0
					let ch = tolower(p.key_char)
					if has_key(used, ch)
						echoerr 'quickui#dialog: hotkey "' . ch . '" conflict between "' . used[ch] . '" and "' . ctrl.name . '"'
						return -1
					endif
					let used[ch] = ctrl.name
					let hwnd.keymap[ch] = {'action': 'button', 'control': ctrl, 'index': bi}
				endif
				let bi += 1
			endfor
		elseif ctrl.type ==# 'radio'
			let ri = 0
			for p in ctrl.parsed
				if p.key_pos >= 0
					let ch = tolower(p.key_char)
					if has_key(used, ch)
						echoerr 'quickui#dialog: hotkey "' . ch . '" conflict between "' . used[ch] . '" and "' . ctrl.name . '"'
						return -1
					endif
					let used[ch] = ctrl.name
					let hwnd.keymap[ch] = {'action': 'radio', 'control': ctrl, 'index': ri}
				endif
				let ri += 1
			endfor
		elseif ctrl.type ==# 'check'
			let p = ctrl.parsed
			if p.key_pos >= 0
				let ch = tolower(p.key_char)
				if has_key(used, ch)
					echoerr 'quickui#dialog: hotkey "' . ch . '" conflict between "' . used[ch] . '" and "' . ctrl.name . '"'
					return -1
				endif
				let used[ch] = ctrl.name
				let hwnd.keymap[ch] = {'action': 'check', 'control': ctrl}
			endif
		endif
	endfor
	return 0
endfunc


"----------------------------------------------------------------------
" build initial content lines
"----------------------------------------------------------------------
function! s:build_content(hwnd) abort
	let hwnd = a:hwnd
	let lines = repeat([''], hwnd.content_h)
	let w = hwnd.w
	for ctrl in hwnd.controls
		let y = ctrl.line_start
		if ctrl.type ==# 'label'
			for text in ctrl.lines
				let lines[y] = text . repeat(' ', w - strdisplaywidth(text))
				let y += 1
			endfor
		elseif ctrl.type ==# 'input'
			let prompt_text = ctrl.prompt
			if ctrl.prompt_width > 0
				let prompt_text .= repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
			endif
			let lines[y] = prompt_text . repeat(' ', w - strdisplaywidth(prompt_text))
		elseif ctrl.type ==# 'radio'
			call s:build_radio_line(hwnd, ctrl, lines)
		elseif ctrl.type ==# 'check'
			call s:build_check_line(hwnd, ctrl, lines)
		elseif ctrl.type ==# 'button'
			call s:build_button_line(hwnd, ctrl, lines)
		elseif ctrl.type ==# 'separator'
			let lines[y] = repeat(hwnd.sep_char, w)
		elseif ctrl.type ==# 'dropdown'
			call s:build_dropdown_line(hwnd, ctrl, lines)
		endif
	endfor
	let hwnd.content = lines
	return lines
endfunc


"----------------------------------------------------------------------
" build radio display line(s)
"----------------------------------------------------------------------
function! s:build_radio_line(hwnd, ctrl, lines) abort
	let ctrl = a:ctrl
	let y = ctrl.line_start
	let w = a:hwnd.w
	if ctrl.is_vertical
		let prefix = ''
		if ctrl.prompt_width > 0
			let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
		endif
		let ri = 0
		for p in ctrl.parsed
			let mark = (ri == ctrl.value) ? '(*) ' : '( ) '
			let line = ''
			if ri == 0
				let line = prefix . mark . p.text
			else
				let line = repeat(' ', ctrl.prompt_width) . mark . p.text
			endif
			let a:lines[y] = line . repeat(' ', w - strdisplaywidth(line))
			let y += 1
			let ri += 1
		endfor
	else
		let prefix = ''
		if ctrl.prompt_width > 0
			let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
		endif
		let line = prefix
		let ri = 0
		for p in ctrl.parsed
			let mark = (ri == ctrl.value) ? '(*) ' : '( ) '
			let line .= mark . p.text
			if ri < len(ctrl.parsed) - 1
				let line .= '  '
			endif
			let ri += 1
		endfor
		let a:lines[y] = line . repeat(' ', w - strdisplaywidth(line))
	endif
endfunc


"----------------------------------------------------------------------
" build check display line
"----------------------------------------------------------------------
function! s:build_check_line(hwnd, ctrl, lines) abort
	let ctrl = a:ctrl
	let y = ctrl.line_start
	let w = a:hwnd.w
	let mark = (ctrl.value) ? '[x] ' : '[ ] '
	let prefix = ''
	if ctrl.prompt_width > 0 && ctrl.prompt !=# ''
		let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
	elseif ctrl.prompt_width > 0 && ctrl.prompt ==# ''
		let prefix = repeat(' ', ctrl.prompt_width)
	endif
	let line = prefix . mark . ctrl.parsed.text
	let a:lines[y] = line . repeat(' ', w - strdisplaywidth(line))
endfunc


"----------------------------------------------------------------------
" build button display line
"----------------------------------------------------------------------
function! s:build_button_line(hwnd, ctrl, lines) abort
	let ctrl = a:ctrl
	let y = ctrl.line_start
	let w = a:hwnd.w
	" compute button text with padding (similar to confirm.vim)
	let max_bw = 4
	for p in ctrl.parsed
		let max_bw = (max_bw < p.text_width) ? p.text_width : max_bw
	endfor
	let final = ''
	let positions = []
	let start = 0
	let bi = len(ctrl.parsed) - 1
	for p in ctrl.parsed
		let pad1 = (max_bw - p.text_width) / 2
		let pad2 = max_bw - p.text_width - pad1
		let btext = repeat(' ', pad1) . p.text . repeat(' ', pad2)
		let btext_w = strwidth(btext)
		let display = '<' . btext . '>'
		let pos = {}
		let pos.start = start
		let pos.endup = start + btext_w + 2
		if p.key_pos >= 0
			let pos.offset = start + 1 + p.key_pos + pad1
		else
			let pos.offset = -1
		endif
		let positions += [pos]
		let final .= display
		let start += btext_w + 2
		if bi > 0
			let final .= '  '
			let start += 2
		endif
		let bi -= 1
	endfor
	let ctrl.btn_final = final
	let ctrl.btn_positions = positions
	let ctrl.btn_width = strdisplaywidth(final)
	" center the button line
	let padding_left = (w - ctrl.btn_width) / 2
	if padding_left < 0
		let padding_left = 0
	endif
	let ctrl.btn_padding = padding_left
	let line = repeat(' ', padding_left) . final
	if strdisplaywidth(line) < w
		let line .= repeat(' ', w - strdisplaywidth(line))
	endif
	let a:lines[y] = line
endfunc


"----------------------------------------------------------------------
" build dropdown display line (collapsed state)
"----------------------------------------------------------------------
function! s:build_dropdown_line(hwnd, ctrl, lines) abort
	let ctrl = a:ctrl
	let y = ctrl.line_start
	let w = a:hwnd.w
	let prefix = ''
	if ctrl.prompt_width > 0
		let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
	endif
	let sel_text = get(ctrl.items, ctrl.value, '')
	let inner_w = ctrl.dropdown_width - 2
	if inner_w < 1
		let inner_w = 1
	endif
	let display = sel_text
	let pad = inner_w - strdisplaywidth(display) - 2
	if pad < 0
		let display = ''
		let dw = 0
		for ch in split(sel_text, '\zs')
			let cw = strdisplaywidth(ch)
			if dw + cw > inner_w - 2
				break
			endif
			let display .= ch
			let dw += cw
		endfor
		let pad = inner_w - strdisplaywidth(display) - 2
	endif
	if pad < 0
		let pad = 0
	endif
	let dropdown_text = '[' . display . repeat(' ', pad) . ' v]'
	let line = prefix . dropdown_text
	let remain = w - strdisplaywidth(line)
	if remain > 0
		let line .= repeat(' ', remain)
	endif
	let a:lines[y] = line
endfunc


"----------------------------------------------------------------------
" calculate auto width
"----------------------------------------------------------------------
function! s:calc_width(controls, opts) abort
	let min_w = get(a:opts, 'min_w', 40)
	let max_w = &columns * 80 / 100
	let w = min_w

	for ctrl in a:controls
		if ctrl.type ==# 'label'
			for text in ctrl.lines
				let tw = strdisplaywidth(text)
				let w = (w < tw) ? tw : w
			endfor
		elseif ctrl.type ==# 'input'
			" prompt + at least 20 chars input area
			let pw = strdisplaywidth(ctrl.prompt) + 2
			let need = pw + 20
			let w = (w < need) ? need : w
		elseif ctrl.type ==# 'radio'
			let pw = strdisplaywidth(get(ctrl, 'prompt', ''))
			if pw > 0
				let pw += 2
			endif
			let rw = pw
			for p in ctrl.parsed
				let rw += 4 + p.text_width + 2
			endfor
			let rw -= 2
			let w = (w < rw) ? rw : w
		elseif ctrl.type ==# 'check'
			let pw = strdisplaywidth(get(ctrl, 'prompt', ''))
			if pw > 0
				let pw += 2
			endif
			let cw = pw + 4 + ctrl.parsed.text_width
			let w = (w < cw) ? cw : w
		elseif ctrl.type ==# 'dropdown'
			let pw = strdisplaywidth(get(ctrl, 'prompt', ''))
			if pw > 0
				let pw += 2
			endif
			let max_iw = 0
			for text in ctrl.items
				let iw = strdisplaywidth(text)
				let max_iw = (max_iw < iw) ? iw : max_iw
			endfor
			let need = pw + max_iw + 4
			let w = (w < need) ? need : w
		elseif ctrl.type ==# 'button'
			" estimate button line width
			let bw = 0
			let max_bw = 4
			for p in ctrl.parsed
				let max_bw = (max_bw < p.text_width) ? p.text_width : max_bw
			endfor
			for p in ctrl.parsed
				let bw += max_bw + 2
			endfor
			let bw += (len(ctrl.parsed) - 1) * 2
			let w = (w < bw) ? bw : w
		endif
	endfor

	let w = (w > max_w) ? max_w : w
	return w
endfunc


"----------------------------------------------------------------------
" prepare highlight groups for buttons
"----------------------------------------------------------------------
function! s:hl_prepare(hwnd) abort
	let c1 = get(g:, 'quickui_button_color_on', 'QuickSel')
	let c2 = get(g:, 'quickui_button_color_off', 'QuickBG')
	let a:hwnd.color_on = c1
	let a:hwnd.color_off = c2
	let a:hwnd.color_on2 = 'QuickButtonOn2'
	let a:hwnd.color_off2 = 'QuickButtonOff2'
	call quickui#highlight#clear('QuickButtonOn2')
	call quickui#highlight#clear('QuickButtonOff2')
	call quickui#highlight#make_underline('QuickButtonOn2', c1)
	call quickui#highlight#make_underline('QuickButtonOff2', c2)
	" prepare QuickOff for unfocused input:
	" keep QuickInput bg (visible box) + muted fg from theme's Disable color
	call quickui#highlight#clear('QuickOff')
	call quickui#highlight#overlay('QuickOff', 'QuickInput', 'QuickDefaultDisable')
endfunc


"----------------------------------------------------------------------
" render input control
"----------------------------------------------------------------------
function! s:render_input(hwnd, ctrl, focused) abort
	let ctrl = a:ctrl
	let rl = ctrl.rl
	let win = a:hwnd.win
	let y = ctrl.line_start
	let col = ctrl.input_col
	let iw = ctrl.input_width

	" rebuild the prompt portion
	let prompt_text = ctrl.prompt
	if ctrl.prompt_width > 0
		let prompt_text .= repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
	endif

	if a:focused
		let ctrl.pos = rl.slide(ctrl.pos, iw)
		let display = rl.render(ctrl.pos, iw)
		let ts = float2nr(reltimefloat(reltime()) * 1000)
		let blink = rl.blink(ts)

		" build line text and highlight regions
		let x = col
		for [attr, text] in display
			let tlen = strwidth(text)
			if attr == 1
				let color = (blink == 0) ? 'QuickCursor' : 'QuickInput'
			elseif attr == 2
				let color = 'QuickVisual'
			elseif attr == 3
				let color = (blink == 0) ? 'QuickCursor' : 'QuickVisual'
			else
				let color = 'QuickInput'
			endif
			call win.syntax_region(color, x, y, x + tlen, y)
			let x += tlen
		endfor

		" rebuild full line from display
		let line = prompt_text
		for [attr, text] in display
			let line .= text
		endfor
		let remain = a:hwnd.w - strdisplaywidth(line)
		if remain > 0
			let line .= repeat(' ', remain)
		endif
		call win.set_line(y, line, 0)
	else
		" unfocused: show static text with QuickOff highlight
		let text = rl.update()
		" render visible portion
		let visible_w = iw
		let vis_text = text
		if strdisplaywidth(vis_text) > visible_w
			" truncate
			let vis_text = ''
			let vw = 0
			for ch in split(text, '\zs')
				let cw = strdisplaywidth(ch)
				if vw + cw > visible_w
					break
				endif
				let vis_text .= ch
				let vw += cw
			endfor
		endif
		let vis_text .= repeat(' ', visible_w - strdisplaywidth(vis_text))
		let line = prompt_text . vis_text
		let remain = a:hwnd.w - strdisplaywidth(line)
		if remain > 0
			let line .= repeat(' ', remain)
		endif
		call win.set_line(y, line, 0)
		call win.syntax_region('QuickOff', col, y, col + iw, y)
	endif
endfunc


"----------------------------------------------------------------------
" render radio control
"----------------------------------------------------------------------
function! s:render_radio(hwnd, ctrl, focused) abort
	let ctrl = a:ctrl
	let win = a:hwnd.win
	let y = ctrl.line_start
	let w = a:hwnd.w

	" reset cursor to value when unfocused
	if !a:focused
		let ctrl.cursor = ctrl.value
	endif

	" rebuild lines
	let lines = repeat([''], ctrl.line_count)
	if ctrl.is_vertical
		let prefix = ''
		if ctrl.prompt_width > 0
			let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
		endif
		let ri = 0
		for p in ctrl.parsed
			let mark = (ri == ctrl.value) ? '(*) ' : '( ) '
			let line = ''
			if ri == 0
				let line = prefix . mark . p.text
			else
				let line = repeat(' ', ctrl.prompt_width) . mark . p.text
			endif
			let lines[ri] = line . repeat(' ', w - strdisplaywidth(line))
			let ri += 1
		endfor
	else
		let prefix = ''
		if ctrl.prompt_width > 0
			let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
		endif
		let line = prefix
		let ri = 0
		for p in ctrl.parsed
			let mark = (ri == ctrl.value) ? '(*) ' : '( ) '
			let line .= mark . p.text
			if ri < len(ctrl.parsed) - 1
				let line .= '  '
			endif
			let ri += 1
		endfor
		let lines[0] = line . repeat(' ', w - strdisplaywidth(line))
	endif

	" update buffer lines
	let li = 0
	for line in lines
		call win.set_line(y + li, line, 0)
		let li += 1
	endfor

	" highlight focused: cursor item gets QuickSel
	if a:focused
		if ctrl.is_vertical
			" highlight the cursor item's line
			let sel_y = y + ctrl.cursor
			let mark_x = ctrl.prompt_width
			let p = ctrl.parsed[ctrl.cursor]
			let mark_end = mark_x + 4 + p.text_width
			call win.syntax_region('QuickSel', mark_x, sel_y, mark_end, sel_y)
		else
			" highlight the cursor option
			let x = ctrl.prompt_width
			let ri = 0
			for p in ctrl.parsed
				let item_w = 4 + p.text_width
				if ri == ctrl.cursor
					call win.syntax_region('QuickSel', x, y, x + item_w, y)
				endif
				let x += item_w + 2
				let ri += 1
			endfor
		endif
	endif
endfunc


"----------------------------------------------------------------------
" render check control
"----------------------------------------------------------------------
function! s:render_check(hwnd, ctrl, focused) abort
	let ctrl = a:ctrl
	let win = a:hwnd.win
	let y = ctrl.line_start
	let w = a:hwnd.w

	let mark = (ctrl.value) ? '[x] ' : '[ ] '
	let prefix = ''
	if ctrl.prompt_width > 0 && ctrl.prompt !=# ''
		let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
	elseif ctrl.prompt_width > 0 && ctrl.prompt ==# ''
		let prefix = repeat(' ', ctrl.prompt_width)
	endif
	let line = prefix . mark . ctrl.parsed.text
	let line .= repeat(' ', w - strdisplaywidth(line))
	call win.set_line(y, line, 0)

	if a:focused
		let mark_x = strdisplaywidth(prefix)
		let mark_end = mark_x + 4 + ctrl.parsed.text_width
		call win.syntax_region('QuickSel', mark_x, y, mark_end, y)
	endif
endfunc


"----------------------------------------------------------------------
" render button control
"----------------------------------------------------------------------
function! s:render_button(hwnd, ctrl, focused) abort
	let ctrl = a:ctrl
	let win = a:hwnd.win
	let y = ctrl.line_start
	let off = ctrl.btn_padding

	let bi = 0
	for pos in ctrl.btn_positions
		if a:focused && bi == ctrl.value
			let c1 = a:hwnd.color_on
			let c2 = a:hwnd.color_on2
		else
			let c1 = a:hwnd.color_off
			let c2 = a:hwnd.color_off2
		endif
		let x = pos.start
		let e = pos.endup
		if pos.offset < 0
			call win.syntax_region(c1, off + x, y, off + e, y)
		else
			let u = pos.offset + off
			call win.syntax_region(c1, off + x, y, u, y)
			call win.syntax_region(c2, u, y, u + 1, y)
			call win.syntax_region(c1, u + 1, y, off + e, y)
		endif
		let bi += 1
	endfor
endfunc


"----------------------------------------------------------------------
" render dropdown control (collapsed state)
"----------------------------------------------------------------------
function! s:render_dropdown(hwnd, ctrl, focused) abort
	let ctrl = a:ctrl
	let win = a:hwnd.win
	let y = ctrl.line_start
	let w = a:hwnd.w
	let prefix = ''
	if ctrl.prompt_width > 0
		let prefix = ctrl.prompt . repeat(' ', ctrl.prompt_width - strdisplaywidth(ctrl.prompt))
	endif
	let sel_text = get(ctrl.items, ctrl.value, '')
	let inner_w = ctrl.dropdown_width - 2
	if inner_w < 1
		let inner_w = 1
	endif
	let display = sel_text
	let pad = inner_w - strdisplaywidth(display) - 2
	if pad < 0
		let display = ''
		let dw = 0
		for ch in split(sel_text, '\zs')
			let cw = strdisplaywidth(ch)
			if dw + cw > inner_w - 2
				break
			endif
			let display .= ch
			let dw += cw
		endfor
		let pad = inner_w - strdisplaywidth(display) - 2
	endif
	if pad < 0
		let pad = 0
	endif
	let dropdown_text = '[' . display . repeat(' ', pad) . ' v]'
	let line = prefix . dropdown_text
	let remain = w - strdisplaywidth(line)
	if remain > 0
		let line .= repeat(' ', remain)
	endif
	call win.set_line(y, line, 0)
	if a:focused
		let col = ctrl.dropdown_col
		call win.syntax_region('QuickSel', col, y, col + ctrl.dropdown_width, y)
	endif
endfunc


"----------------------------------------------------------------------
" render all controls
"----------------------------------------------------------------------
function! s:render_all(hwnd) abort
	let hwnd = a:hwnd
	let win = hwnd.win
	let fi = hwnd.focus_index
	let focused_ctrl = (fi >= 0 && fi < len(hwnd.focus_list)) ? hwnd.focus_list[fi].control : v:null

	call win.syntax_begin(1)
	for ctrl in hwnd.controls
		let is_focused = (ctrl is focused_ctrl) ? 1 : 0
		if ctrl.type ==# 'input'
			call s:render_input(hwnd, ctrl, is_focused)
		elseif ctrl.type ==# 'radio'
			call s:render_radio(hwnd, ctrl, is_focused)
		elseif ctrl.type ==# 'check'
			call s:render_check(hwnd, ctrl, is_focused)
		elseif ctrl.type ==# 'button'
			call s:render_button(hwnd, ctrl, is_focused)
		elseif ctrl.type ==# 'dropdown'
			call s:render_dropdown(hwnd, ctrl, is_focused)
		endif
	endfor
	call win.update()
	call win.syntax_end()
endfunc


"----------------------------------------------------------------------
" collect result from all controls
"----------------------------------------------------------------------
function! s:collect_result(hwnd) abort
	let result = {}
	for ctrl in a:hwnd.controls
		if ctrl.type ==# 'input'
			let result[ctrl.name] = ctrl.rl.update()
		elseif ctrl.type ==# 'radio'
			let result[ctrl.name] = ctrl.value
		elseif ctrl.type ==# 'check'
			let result[ctrl.name] = ctrl.value
		elseif ctrl.type ==# 'dropdown'
			let result[ctrl.name] = ctrl.value
		endif
	endfor
	return result
endfunc


"----------------------------------------------------------------------
" handle mouse click: returns -1 if click outside or on border
"----------------------------------------------------------------------
function! s:handle_mouse(hwnd) abort
	let win = a:hwnd.win
	if s:has_nvim == 0
		" Vim: use getmousepos()
		" pos.column and pos.line are 1-based relative to content area
		" (border and padding are handled by popup engine)
		let pos = getmousepos()
		if pos.winid != win.winid
			return -1
		endif
		let x = pos.column - 1
		let y = pos.line - 1
	else
		" Neovim
		if v:mouse_winid == win.winid
			let x = v:mouse_col - 1
			let y = v:mouse_lnum - 1
		elseif has_key(win.info, 'border_winid') && v:mouse_winid == win.info.border_winid
			" check close button (top-right X)
			if v:mouse_lnum == 1 && v:mouse_col == win.info.tw
				let a:hwnd.exit = 1
				return -1
			endif
			return -1
		else
			return -1
		endif
	endif
	return s:dispatch_click(a:hwnd, x, y)
endfunc


"----------------------------------------------------------------------
" dispatch click to controls
"----------------------------------------------------------------------
function! s:dispatch_click(hwnd, x, a_y) abort
	let x = a:x
	let y = a:a_y
	if x < 0 || y < 0
		return -1
	endif
	for ctrl in a:hwnd.controls
		if y < ctrl.line_start || y >= ctrl.line_start + ctrl.line_count
			continue
		endif
		if ctrl.type ==# 'label'
			return 0
		endif
		" focus this control
		call s:focus_to_ctrl(a:hwnd, ctrl)
		if ctrl.type ==# 'input'
			" position readline cursor
			let rel_x = x - ctrl.input_col
			if rel_x >= 0 && rel_x < ctrl.input_width
				let pos = ctrl.rl.mouse_click(ctrl.pos, rel_x)
				call ctrl.rl.seek(pos, 0)
				let ctrl.rl.select = -1
			endif
			return 0
		elseif ctrl.type ==# 'radio'
			" determine which option was clicked
			if ctrl.is_vertical
				let row_off = y - ctrl.line_start
				if row_off >= 0 && row_off < len(ctrl.items)
					let ctrl.value = row_off
					let ctrl.cursor = row_off
				endif
			else
				let rx = ctrl.prompt_width
				let ri = 0
				for p in ctrl.parsed
					let item_w = 4 + p.text_width + 2
					if x >= rx && x < rx + item_w
						let ctrl.value = ri
						let ctrl.cursor = ri
						break
					endif
					let rx += item_w
					let ri += 1
				endfor
			endif
			return 0
		elseif ctrl.type ==# 'check'
			let ctrl.value = ctrl.value ? 0 : 1
			return 0
		elseif ctrl.type ==# 'button'
			" determine which button was clicked
			let off = ctrl.btn_padding
			let bx = x - off
			for bi in range(len(ctrl.btn_positions))
				let pos = ctrl.btn_positions[bi]
				if bx >= pos.start && bx < pos.endup
					let ctrl.value = bi
					let a:hwnd.exit_button = ctrl.name
					let a:hwnd.exit_index = bi
					let a:hwnd.exit = 1
					return 1
				endif
			endfor
			return 0
		elseif ctrl.type ==# 'separator'
			return 0
		elseif ctrl.type ==# 'dropdown'
			call s:focus_to_ctrl(a:hwnd, ctrl)
			let result = s:dropdown_open(a:hwnd, ctrl)
			if result >= 0
				let ctrl.value = result
			endif
			return 0
		endif
	endfor
	return 0
endfunc


"----------------------------------------------------------------------
" select all text in input control (Windows-style focus behavior)
"----------------------------------------------------------------------
function! s:input_select_all(ctrl) abort
	let rl = a:ctrl.rl
	if rl.size > 0
		let rl.select = 0
		call rl.seek(0, 2)
	endif
endfunc


"----------------------------------------------------------------------
" focus to a specific control
"----------------------------------------------------------------------
function! s:focus_to_ctrl(hwnd, ctrl) abort
	let fi = 0
	for entry in a:hwnd.focus_list
		if entry.control is a:ctrl
			let a:hwnd.focus_index = fi
			return
		endif
		let fi += 1
	endfor
endfunc


"----------------------------------------------------------------------
" dispatch hotkey: check global hotkeys for button/radio/check
" returns 1 if the key was consumed, 0 otherwise
"----------------------------------------------------------------------
function! s:dispatch_hotkey(hwnd, ch) abort
	let lower_ch = tolower(a:ch)
	if has_key(a:hwnd.keymap, lower_ch)
		let km = a:hwnd.keymap[lower_ch]
		if km.action ==# 'button'
			let km.control.value = km.index
			let a:hwnd.exit_button = km.control.name
			let a:hwnd.exit_index = km.index
			let a:hwnd.exit = 1
			call s:focus_to_ctrl(a:hwnd, km.control)
			return 1
		elseif km.action ==# 'radio'
			let km.control.value = km.index
			let km.control.cursor = km.index
			call s:focus_to_ctrl(a:hwnd, km.control)
			return 1
		elseif km.action ==# 'check'
			let km.control.value = km.control.value ? 0 : 1
			call s:focus_to_ctrl(a:hwnd, km.control)
			return 1
		endif
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" handle key dispatch
"----------------------------------------------------------------------
function! s:handle_key(hwnd, ch) abort
	let hwnd = a:hwnd
	let ch = a:ch
	let focus_size = len(hwnd.focus_list)

	" -- global keys --
	if ch == "\<ESC>" || ch == "\<c-c>"
		let hwnd.exit = 1
		let hwnd.exit_button = ''
		let hwnd.exit_index = -1
		return
	endif

	if ch == "\<Tab>"
		if focus_size > 0
			let fi = hwnd.focus_index
			let ctrl = hwnd.focus_list[fi].control
			if ctrl.type ==# 'button' && ctrl.value < len(ctrl.parsed) - 1
				let ctrl.value += 1
			else
				let hwnd.focus_index = (fi + 1) % focus_size
				let new_ctrl = hwnd.focus_list[hwnd.focus_index].control
				if new_ctrl.type ==# 'button'
					let new_ctrl.value = 0
				endif
			endif
		endif
		return
	endif

	if ch == "\<S-Tab>"
		if focus_size > 0
			let fi = hwnd.focus_index
			let ctrl = hwnd.focus_list[fi].control
			if ctrl.type ==# 'button' && ctrl.value > 0
				let ctrl.value -= 1
			else
				let hwnd.focus_index = (fi - 1 + focus_size) % focus_size
				let new_ctrl = hwnd.focus_list[hwnd.focus_index].control
				if new_ctrl.type ==# 'button'
					let new_ctrl.value = len(new_ctrl.parsed) - 1
				endif
			endif
		endif
		return
	endif

	" mouse click
	if ch == "\<LeftMouse>"
		call s:handle_mouse(hwnd)
		return
	endif

	" check close button (Vim only)
	if s:has_nvim == 0
		if hwnd.win.quit != 0
			let hwnd.exit = 1
			let hwnd.exit_button = ''
			let hwnd.exit_index = -1
			return
		endif
	endif

	" -- dispatch to focused control --
	" When focus is on an input, skip hotkey processing: all printable
	" characters go to readline first.  Hotkeys only fire when focus is
	" NOT on an input control.
	if focus_size == 0
		" no focusable controls -- try hotkeys then return
		call s:dispatch_hotkey(hwnd, ch)
		return
	endif
	let fi = hwnd.focus_index
	let ctrl = hwnd.focus_list[fi].control
	let tp = ctrl.type

	if tp ==# 'input'
		" input takes all keys except global ones (already handled above)
		call s:handle_input(hwnd, ctrl, ch)
	elseif tp ==# 'radio'
		if s:dispatch_hotkey(hwnd, ch)
			return
		endif
		call s:handle_radio(hwnd, ctrl, ch)
	elseif tp ==# 'check'
		if s:dispatch_hotkey(hwnd, ch)
			return
		endif
		call s:handle_check(hwnd, ctrl, ch)
	elseif tp ==# 'button'
		if s:dispatch_hotkey(hwnd, ch)
			return
		endif
		call s:handle_button(hwnd, ctrl, ch)
	elseif tp ==# 'dropdown'
		if s:dispatch_hotkey(hwnd, ch)
			return
		endif
		call s:handle_dropdown(hwnd, ctrl, ch)
	endif
endfunc


"----------------------------------------------------------------------
" handle input keys
"----------------------------------------------------------------------
function! s:handle_input(hwnd, ctrl, ch) abort
	let ch = a:ch
	let rl = a:ctrl.rl

	if ch == "\<CR>"
		let a:hwnd.exit_button = ''
		let a:hwnd.exit_index = 0
		let a:hwnd.exit = 1
		return
	endif

	" Up/Down: navigate focus (not history -- history uses Ctrl+Up/Down)
	if ch == "\<Up>"
		let size = len(a:hwnd.focus_list)
		if size > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + size) % size
		endif
		return
	endif
	if ch == "\<Down>"
		let size = len(a:hwnd.focus_list)
		if size > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % size
		endif
		return
	endif

	" Ctrl+Up / Ctrl+Down: history browsing
	if ch == "\<C-Up>" || ch == "\<c-p>"
		if len(rl.history) > 0
			call rl.feed("\<up>")
		endif
		return
	endif
	if ch == "\<C-Down>" || ch == "\<c-n>"
		if len(rl.history) > 0
			call rl.feed("\<down>")
		endif
		return
	endif

	" all other keys: delegate to readline
	call rl.feed(ch)
endfunc


"----------------------------------------------------------------------
" handle radio keys
"----------------------------------------------------------------------
function! s:handle_radio(hwnd, ctrl, ch) abort
	let ch = a:ch
	let size = len(a:ctrl.items)
	if size == 0
		return
	endif

	if ch == "\<CR>"
		let a:hwnd.exit_button = ''
		let a:hwnd.exit_index = 0
		let a:hwnd.exit = 1
		return
	endif

	" Space: select the item under cursor
	if ch == "\<Space>"
		let a:ctrl.value = a:ctrl.cursor
		return
	endif

	if a:ctrl.is_vertical
		" Vertical mode: Up/Down navigate within items, boundary -> control
		if ch == "\<Up>"
			if a:ctrl.cursor > 0
				let a:ctrl.cursor -= 1
			else
				let fsize = len(a:hwnd.focus_list)
				if fsize > 0
					let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + fsize) % fsize
				endif
			endif
			return
		endif
		if ch == "\<Down>"
			if a:ctrl.cursor < size - 1
				let a:ctrl.cursor += 1
			else
				let fsize = len(a:hwnd.focus_list)
				if fsize > 0
					let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % fsize
				endif
			endif
			return
		endif
	else
		" Horizontal mode: Up/Down switch between controls
		if ch == "\<Up>"
			let fsize = len(a:hwnd.focus_list)
			if fsize > 0
				let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + fsize) % fsize
			endif
			return
		endif
		if ch == "\<Down>"
			let fsize = len(a:hwnd.focus_list)
			if fsize > 0
				let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % fsize
			endif
			return
		endif
	endif

	" Left/Right: move cursor
	if ch == "\<Left>" || ch ==# 'h'
		let a:ctrl.cursor = (a:ctrl.cursor - 1 + size) % size
	elseif ch == "\<Right>" || ch ==# 'l'
		let a:ctrl.cursor = (a:ctrl.cursor + 1) % size
	endif
endfunc


"----------------------------------------------------------------------
" handle check keys
"----------------------------------------------------------------------
function! s:handle_check(hwnd, ctrl, ch) abort
	let ch = a:ch

	if ch == "\<CR>"
		let a:hwnd.exit_button = ''
		let a:hwnd.exit_index = 0
		let a:hwnd.exit = 1
		return
	endif

	if ch == "\<Up>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + fsize) % fsize
		endif
		return
	endif
	if ch == "\<Down>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % fsize
		endif
		return
	endif

	if ch == "\<Space>"
		let a:ctrl.value = a:ctrl.value ? 0 : 1
	endif
endfunc


"----------------------------------------------------------------------
" handle button keys
"----------------------------------------------------------------------
function! s:handle_button(hwnd, ctrl, ch) abort
	let ch = a:ch
	let size = len(a:ctrl.parsed)
	if size == 0
		return
	endif

	if ch == "\<Up>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + fsize) % fsize
		endif
		return
	endif
	if ch == "\<Down>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % fsize
		endif
		return
	endif

	if ch == "\<Left>" || ch ==# 'h'
		let a:ctrl.value = (a:ctrl.value > 0) ? (a:ctrl.value - 1) : 0
	elseif ch == "\<Right>" || ch ==# 'l'
		if a:ctrl.value < size - 1
			let a:ctrl.value += 1
		endif
	elseif ch == "\<Space>" || ch == "\<CR>"
		let a:hwnd.exit_button = a:ctrl.name
		let a:hwnd.exit_index = a:ctrl.value
		let a:hwnd.exit = 1
	endif
endfunc


"----------------------------------------------------------------------
" handle dropdown keys
"----------------------------------------------------------------------
function! s:handle_dropdown(hwnd, ctrl, ch) abort
	let ch = a:ch
	let size = len(a:ctrl.items)

	if ch == "\<CR>" || ch == "\<Space>"
		if size > 0
			let result = s:dropdown_open(a:hwnd, a:ctrl)
			if result >= 0
				let a:ctrl.value = result
			endif
		endif
		return
	endif

	if ch == "\<Up>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index - 1 + fsize) % fsize
		endif
		return
	endif
	if ch == "\<Down>"
		let fsize = len(a:hwnd.focus_list)
		if fsize > 0
			let a:hwnd.focus_index = (a:hwnd.focus_index + 1) % fsize
		endif
		return
	endif

	if size == 0
		return
	endif
	if ch == "\<Left>" || ch ==# 'h'
		let a:ctrl.value = (a:ctrl.value - 1 + size) % size
	elseif ch == "\<Right>" || ch ==# 'l'
		let a:ctrl.value = (a:ctrl.value + 1) % size
	endif
endfunc


"----------------------------------------------------------------------
" build visible lines for dropdown popup (handles scrolling)
"----------------------------------------------------------------------
function! s:dropdown_visible(items, offset, height, width) abort
	let inner_w = a:width - 2
	if inner_w < 1
		let inner_w = 1
	endif
	let lines = []
	for i in range(a:height)
		let idx = i + a:offset
		if idx < len(a:items)
			let text = a:items[idx]
			let tw = strdisplaywidth(text)
			if tw > inner_w
				let vis = ''
				let vw = 0
				for ch in split(text, '\zs')
					let cw = strdisplaywidth(ch)
					if vw + cw > inner_w
						break
					endif
					let vis .= ch
					let vw += cw
				endfor
				let text = vis
				let tw = vw
			endif
			let line = ' ' . text . repeat(' ', inner_w - tw) . ' '
		else
			let line = repeat(' ', a:width)
		endif
		let lines += [line]
	endfor
	return lines
endfunc


"----------------------------------------------------------------------
" open dropdown popup: returns selected index or -1 if cancelled
"----------------------------------------------------------------------
function! s:dropdown_open(hwnd, ctrl) abort
	let ctrl = a:ctrl
	let items = ctrl.items
	let size = len(items)
	if size == 0
		return -1
	endif

	" popup dimensions
	let popup_w = ctrl.dropdown_width
	let popup_h = size
	let max_h = &lines - 6
	if popup_h > max_h
		let popup_h = max_h
	endif
	if popup_h < 1
		let popup_h = 1
	endif

	" compute screen position of dropdown control area
	let has_border = a:hwnd.win.info.has_border
	let pad = a:hwnd.win.opts.padding
	let content_x = a:hwnd.win.x + (has_border ? 1 : 0) + pad[3]
	let content_y = a:hwnd.win.y + (has_border ? 1 : 0) + pad[0]

	let popup_x = content_x + ctrl.dropdown_col
	let popup_y = content_y + ctrl.line_start + 1

	" if not enough space below, show above
	let dropdown_border = get(a:hwnd.win.opts, 'border', g:quickui#style#border)
	let border_extra = (dropdown_border > 0) ? 2 : 0
	if popup_y + popup_h + border_extra > &lines
		let popup_y = content_y + ctrl.line_start - popup_h - border_extra
		if popup_y < 0
			let popup_y = 0
		endif
	endif

	" create popup window
	let win = quickui#window#new()
	let win_opts = {}
	let win_opts.w = popup_w
	let win_opts.h = popup_h
	let win_opts.x = popup_x
	let win_opts.y = popup_y
	let win_opts.z = a:hwnd.win.z + 10
	let win_opts.border = dropdown_border
	let win_opts.color = 'QuickBG'
	let win_opts.bordercolor = 'QuickBorder'
	if s:has_nvim
		let win_opts.focusable = 1
	endif

	" initial selection and scroll
	let selected = ctrl.value
	if selected < 0 || selected >= size
		let selected = 0
	endif
	let offset = 0
	if selected >= popup_h
		let offset = selected - popup_h + 1
	endif

	let vis_lines = s:dropdown_visible(items, offset, popup_h, popup_w)
	call win.open(vis_lines, win_opts)

	" event loop
	let result = -1
	while 1
		call win.syntax_begin(1)
		let vis_sel = selected - offset
		if vis_sel >= 0 && vis_sel < popup_h
			call win.syntax_region('QuickSel', 0, vis_sel, popup_w, vis_sel)
		endif
		call win.syntax_end()
		redraw

		try
			let code = getchar()
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry

		let ch = (type(code) == v:t_number) ? nr2char(code) : code
		if ch ==# ''
			continue
		endif

		if ch == "\<ESC>" || ch == "\<C-C>"
			break
		elseif ch == "\<CR>" || ch == "\<Space>"
			let result = selected
			break
		elseif ch == "\<Up>" || ch ==# 'k'
			let selected = (selected > 0) ? (selected - 1) : (size - 1)
		elseif ch == "\<Down>" || ch ==# 'j'
			let selected = (selected < size - 1) ? (selected + 1) : 0
		elseif ch == "\<Home>"
			let selected = 0
		elseif ch == "\<End>"
			let selected = size - 1
		elseif ch == "\<PageUp>"
			let selected = selected - popup_h
			if selected < 0 | let selected = 0 | endif
		elseif ch == "\<PageDown>"
			let selected = selected + popup_h
			if selected >= size | let selected = size - 1 | endif
		elseif ch == "\<LeftMouse>"
			let click = win.mouse_click()
			if click.x >= 0 && click.y >= 0
				let clicked = click.y + offset
				if clicked >= 0 && clicked < size
					let result = clicked
					break
				endif
			else
				break
			endif
		endif

		" adjust scroll offset
		if selected < offset
			let offset = selected
		elseif selected >= offset + popup_h
			let offset = selected - popup_h + 1
		endif

		" update visible lines
		let vis_lines = s:dropdown_visible(items, offset, popup_h, popup_w)
		call win.set_text(vis_lines)
	endwhile

	call win.close()
	return result
endfunc


"----------------------------------------------------------------------
" main entry: quickui#dialog#open(items, opts)
"----------------------------------------------------------------------
function! quickui#dialog#open(items, ...) abort
	let opts = (a:0 >= 1) ? a:1 : {}

	" -- empty items check --
	if len(a:items) == 0
		return {'button': '', 'button_index': -1}
	endif

	" -- parse items --
	let controls = s:parse_items(a:items)
	if type(controls) == v:t_list && len(controls) == 0
		return {'button': '', 'button_index': -1}
	endif

	" -- build hwnd --
	let hwnd = {}
	let hwnd.controls = controls
	let hwnd.focus_index = 0
	let hwnd.exit = 0
	let hwnd.exit_button = ''
	let hwnd.exit_index = -1
	let hwnd.validator = get(opts, 'validator', v:null)

	" -- calculate width --
	if has_key(opts, 'w')
		let hwnd.w = opts.w
	else
		let hwnd.w = s:calc_width(controls, opts)
	endif

	" -- calculate layout --
	if s:calc_layout(hwnd, opts) < 0
		return {'button': '', 'button_index': -1}
	endif

	" -- build focus list --
	call s:build_focus_list(hwnd)

	" -- initial focus --
	if has_key(opts, 'focus')
		let focus_name = opts.focus
		let fi = 0
		for entry in hwnd.focus_list
			if has_key(entry.control, 'name') && entry.control.name ==# focus_name
				let hwnd.focus_index = fi
				break
			endif
			let fi += 1
		endfor
	endif

	" -- select all for initially focused input --
	if len(hwnd.focus_list) > 0
		let fc = hwnd.focus_list[hwnd.focus_index].control
		if fc.type ==# 'input'
			call s:input_select_all(fc)
		endif
	endif

	" -- build keymap --
	if s:build_keymap(hwnd) < 0
		return {'button': '', 'button_index': -1}
	endif

	" -- compute separator character from border style --
	let border_style = get(opts, 'border', g:quickui#style#border)
	let border_chars = quickui#core#border_get(border_style)
	if len(border_chars) > 4 && border_chars[4] !=# ' '
		let hwnd.sep_char = border_chars[4]
	else
		let hwnd.sep_char = '-'
	endif

	" -- build content --
	let content = s:build_content(hwnd)

	" -- prepare highlight --
	call s:hl_prepare(hwnd)

	" -- window options --
	let border = get(opts, 'border', g:quickui#style#border)
	let padding = get(opts, 'padding', [1,1,1,1])
	let win_opts = {}
	let win_opts.w = hwnd.w
	let win_opts.h = hwnd.content_h
	let win_opts.border = border
	let win_opts.center = get(opts, 'center', 1)
	let win_opts.padding = padding
	let win_opts.color = get(opts, 'color', 'QuickBG')
	let win_opts.bordercolor = get(opts, 'bordercolor', 'QuickBorder')
	let win_opts.wrap = 1
	let title = get(opts, 'title', 'Dialog')
	if title !=# ''
		let win_opts.title = ' ' . title . ' '
	endif
	if get(opts, 'button', 1)
		let win_opts.button = 1
	endif
	if s:has_nvim
		let win_opts.focusable = 1
	endif

	let hwnd.padding_left = padding[3]

	" -- hide system cursor --
	let hide_system_cursor = get(opts, 'hide_system_cursor', 1)
	if hide_system_cursor != 0
		call quickui#utils#hide_system_cursor(1)
	endif

	" -- create window --
	let hwnd.win = quickui#window#new()
	call hwnd.win.open(content, win_opts)

	" -- main event loop --
	silent! exec 'nohl'
	while hwnd.exit == 0
		" determine wait mode based on focused control type
		let wait_mode = 1
		if len(hwnd.focus_list) > 0
			let fc = hwnd.focus_list[hwnd.focus_index].control
			if fc.type ==# 'input'
				let wait_mode = 0
			endif
		endif

		call s:render_all(hwnd)
		redraw

		" check close button (Vim)
		if s:has_nvim == 0 && hwnd.win.quit != 0
			let hwnd.exit = 1
			let hwnd.exit_button = ''
			let hwnd.exit_index = -1
			break
		endif

		try
			if wait_mode != 0
				let code = getchar()
			else
				let code = getchar(0)
			endif
		catch /^Vim:Interrupt$/
			let code = "\<C-C>"
		endtry

		if type(code) == v:t_number && code == 0
			try
				exec 'sleep 15m'
				continue
			catch /^Vim:Interrupt$/
				let code = "\<c-c>"
			endtry
		endif

		let ch = (type(code) == v:t_number) ? nr2char(code) : code
		if ch ==# ''
			continue
		endif

		let prev_fi = hwnd.focus_index
		call s:handle_key(hwnd, ch)

		" select all when keyboard navigation moves focus to an input
		if hwnd.focus_index != prev_fi && hwnd.exit == 0
			if ch != "\<LeftMouse>"
				let fc = hwnd.focus_list[hwnd.focus_index].control
				if fc.type ==# 'input'
					call s:input_select_all(fc)
				endif
			endif
		endif

		" -- validator check before exit --
		if hwnd.exit != 0 && hwnd.exit_index >= 0 && hwnd.validator != v:null
			let vresult = s:collect_result(hwnd)
			let vresult.button = hwnd.exit_button
			let vresult.button_index = hwnd.exit_index
			let errmsg = call(hwnd.validator, [vresult])
			if type(errmsg) == v:t_string && errmsg !=# ''
				let hwnd.exit = 0
				call s:render_all(hwnd)
				redraw
				echohl ErrorMsg
				echo errmsg
				echohl None
			endif
		endif
	endwhile

	" -- brief render of final state --
	if hwnd.exit_button !=# '' && hwnd.exit_index >= 0
		call s:render_all(hwnd)
		redraw
		sleep 15m
	endif

	" -- save history --
	for ctrl in hwnd.controls
		if ctrl.type ==# 'input' && ctrl.history_key !=# ''
			call ctrl.rl.history_save()
			let s:history[ctrl.history_key] = deepcopy(ctrl.rl.history)
		endif
	endfor

	" -- close window --
	call hwnd.win.close()

	" -- restore system cursor --
	if hide_system_cursor != 0
		call quickui#utils#hide_system_cursor(0)
	endif

	" -- build return value --
	let result = s:collect_result(hwnd)
	let result.button = hwnd.exit_button
	let result.button_index = hwnd.exit_index
	return result
endfunc
