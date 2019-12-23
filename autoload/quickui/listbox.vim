"======================================================================
"
" listbox.vim - 
"
" Created by skywind on 2019/12/20
" Last Modified: 2019/12/20 15:31:14
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" parse
"----------------------------------------------------------------------
function! quickui#listbox#parse(lines)
	let items = {'image': [], 'column':0, 'nrows':0, 'keys':[]}
	let items.keymap = {}
	let items.displaywidth = 0
	let sizes = []
	let objects = []
	let spliter = '  '
	for line in a:lines
		let line = quickui#core#expand_text(line)
		let obj = quickui#utils#single_parse(line)
		let objects += [obj]
		if obj.key_pos > 0
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
	while index < items.nrows
		let key = items.keys[index]
		if key[1] >= 0
			let px = key[1] + 1
			let py = index + 1
			let cmd = quickui#core#high_region('QuickKey', py, px, py, px + 1, 1)
			call win_execute(a:winid, cmd)
		endif
		let index += 1
	endwhile
endfunc


"----------------------------------------------------------------------
" init window
"----------------------------------------------------------------------
function! quickui#listbox#create(textlist, opts)
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
	let opts = {"minwidth":w, "minheight":h, "maxwidth":w, "maxheight":h}
	if has_key(a:opts, 'line')
		let opts.line = a:opts.line
	else
		let limit1 = (&lines - 2) * 80 / 100
		let limit2 = (&lines - 2)
		if h + 4 < limit1
			let opts.line = (limit1 - h) / 2
		else
			let opts.line = (limit2 - h) / 2
		endif
		let opts.line = (opts.line < 1)? 1 : opts.line
	endif
	if has_key(a:opts, 'col')
		let opts.col = a:opts.col
	else
		let opts.col = (&columns - w) / 2
	endif
	call popup_move(winid, opts)
	call setwinvar(winid, '&wincolor', get(a:opts, 'color', 'TVisionBG'))
	if get(a:opts, 'index', 0) >= 0
		let moveto = get(a:opts, 'index', 0) + 1
		call popup_show(winid)
		call win_execute(winid, 'normal! G')
		call win_execute(winid, ':' . moveto)
		call win_execute(winid, 'normal! G')
		call win_execute(winid, ':' . moveto)
		call win_execute(winid, 'call quickui#listbox#reposition()')
	endif
	call s:highlight_keys(winid, items)
	let border = get(a:opts, 'border', 1)
	let opts = {}
	if get(a:opts, 'manual', 0) == 0
		let opts.filter = 'quickui#listbox#filter'
		let opts.callback = 'quickui#listbox#callback'
	endif
	let opts.cursorline = 1
	let opts.drag = 1
	let opts.border = [0,0,0,0,0,0,0,0,0]
	if border > 0
		let opts.borderchars = quickui#core#border_vim(border)
		let opts.border = [1,1,1,1,1,1,1,1,1]
	endif
	let opts.title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ' : ''
	let opts.padding = [0,1,0,1]
	let opts.cursorline = 1
	let opts.mapping = 0
	let opts.drag = 1
	if has_key(a:opts, 'close')
		let opts.close = a:opts.close
	endif
	call popup_setoptions(winid, opts)
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
	let hwnd.state = 1
	let hwnd.code = 0
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
function! quickui#listbox#callback(winid, code)
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
	call quickui#core#popup_clear(a:winid)
	if has_key(hwnd.opts, 'callback')
		let F = function(hwnd.opts.callback)
		call F(hwnd.context, code)
	endif
endfunc


"----------------------------------------------------------------------
" key processing
"----------------------------------------------------------------------
function! quickui#listbox#filter(winid, key)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.hwnd
	let keymap = hwnd.keymap
	if a:key == "\<ESC>" || a:key == "\<c-c>"
		call popup_close(a:winid, -1)
		return 1
	elseif a:key == "\<CR>" || a:key == "\<SPACE>"
		return popup_filter_menu(a:winid, "\<CR>")
	elseif has_key(hwnd.hotkey, a:key)
		let index = hwnd.hotkey[a:key]
		call popup_close(a:winid, index + 1)
		return 1
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
		call win_execute(a:winid, 'call ' . cmd)
		return 1
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
	endif
	if curline < 1
		let curline = 1
	elseif curline > endline
		let curline = endline
	endif
	exec ":" . curline
endfunc


"----------------------------------------------------------------------
" block and return result
"----------------------------------------------------------------------
function! quickui#listbox#inputlist(textlist, opts)
	let opts = deepcopy(a:opts)
	let opts.manual = 1
	if has_key(opts, 'callback')
		call remove(opts, 'callback')
	endif
	let hwnd = quickui#listbox#create(a:textlist, opts)
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
		elseif has_key(hwnd.hotkey, ch)
			let hr = hwnd.hotkey[ch]
			if hr >= 0
				break
			endif
		elseif has_key(hwnd.keymap, ch)
			let key = hwnd.keymap[ch]
			let cmd = 'quickui#listbox#cursor_movement("' . key . '")'
			call win_execute(winid, 'call ' . cmd)
			call popup_hide(winid)
			call popup_show(winid)
		endif
	endwhile
	" echo 'size: '. winheight(winid)
	call quickui#listbox#close(hwnd)
	return hr
endfunc


"----------------------------------------------------------------------
" any callback
"----------------------------------------------------------------------
function! quickui#listbox#execute(context, code)
	if a:code >= 0
		if a:code < len(a:context)
			exec a:context[a:code]
		endif
	endif
endfunc


"----------------------------------------------------------------------
" open popup and run command when select an item
"----------------------------------------------------------------------
function! quickui#listbox#any(content, opts)
	let opts = deepcopy(a:opts)
	let opts.callback = 'quickui#listbox#execute'
	let textlist = []
	let cmdlist = []
	for desc in a:content
		if type(desc) == v:t_string
			let textlist += [desc]
			let cmdlist += ['']
		elseif type(desc) == v:t_list
			let textlist += [(len(desc) > 0)? desc[0] : '']
			let cmdlist += [(len(desc) > 1)? desc[1] : '']
		endif
	endfor
	let opts.context = cmdlist
	call quickui#listbox#create(textlist, opts)
endfunc


"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 0
	let lines = [
				\ "[1]\tOpen &File\t(F3)",
				\ "[2]\tChange &Directory\t(F2)",
				\ "[3]\tHelp",
				\ "",
				\ "[4]\tE&xit",
				\ ]
	for ix in range(1000)
		let lines += ['line: ' . ix]
	endfor
	function! MyCallback(context, code)
		echo "exit: ". a:code . ' context: '. a:context . ' bufid: '. bufnr()
	endfunc
	let opts = {'title':'Select', 'border':1, 'index':400, 'close':'button'}
	let opts.context = 'asdfasdf'
	let opts.callback = 'MyCallback'
	if 1
		let inst = quickui#listbox#create(lines, opts)
		call popup_show(inst.winid)
	else
		let code = quickui#listbox#inputlist(lines, opts)
		echo "code: " . code
	endif
endif

if 0
	let content = [
				\ [ 'echo 1', 'echo 100' ],
				\ [ 'echo 2', 'echo 200' ],
				\ [ 'echo 3', 'echo 300' ],
				\ [ 'echo 4' ],
				\ [],
				\ [ 'echo 5', 'echo 500' ],
				\]
	let opts = {'title': 'select'}
	call quickui#listbox#any(content, opts)
endif



