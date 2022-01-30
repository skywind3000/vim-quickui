"======================================================================
"
" input.vim - 
"
" Created by skywind on 2021/11/27
" Last Modified: 2021/11/30 01:50
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :

"----------------------------------------------------------------------
" internal variables
"----------------------------------------------------------------------
let s:has_nvim = g:quickui#core#has_nvim
let s:history = {}


"----------------------------------------------------------------------
" init
"----------------------------------------------------------------------
function! s:init_input_box(prompt, opts)
	let border = get(a:opts, 'border', g:quickui#style#border)
	let hwnd = {}
	let head = []
	if type(a:prompt) == v:t_list
		let head = deepcopy(a:prompt)
	else
		let head = split('' . a:prompt, "\n")
	endif
	let hwnd.h = 2 + len(head)
	let hwnd.lnum = 2 + len(head)
	if has_key(a:opts, 'w')
		let hwnd.w = a:opts.w
	else
		let limit = 8
		for text in head
			let width = strdisplaywidth(text)
			let limit = (limit < width)? width : limit
		endfor
		if &columns >= 80
			let limit = (limit < 50)? 50 : limit
		endif
		let hwnd.w = limit
	endif
	let hwnd.image = head + [' ', repeat(' ', hwnd.w)]
	let hwnd.bid = quickui#core#scratch_buffer('input', hwnd.image)
	let hwnd.opts = deepcopy(a:opts)
	let hwnd.opts.color = get(a:opts, 'color', 'QuickBG')
	let hwnd.opts.bordercolor = get(a:opts, 'bordercolor', 'QuickBorder')
	let hwnd.opts.text = get(a:opts, 'text', '')
	let hwnd.border = border
	let title = ' Input '
	let hwnd.rl = quickui#readline#new()
	if hwnd.opts.text != ''
		call hwnd.rl.set(hwnd.opts.text)
		call hwnd.rl.seek(0, 2)
		let hwnd.rl.select = 0
	endif
	let hwnd.pos = 0
	let hwnd.wait = get(a:opts, 'wait', 0)
	let hwnd.exit = 0
	let hwnd.strict = get(a:opts, 'strict', 1)
	let hwnd.history = get(hwnd.opts, 'history', '')
	if hwnd.history != ''
		let key = hwnd.history
		let hwnd.rl.history = [''] + get(s:history, key, [])
		" echom hwnd.rl.history
	endif
	if has_key(hwnd.opts, 'row') && has_key(hwnd.opts, 'col')
		" pass
	else
		let ww = hwnd.w
		let hh = hwnd.h
		let hwnd.opts.col = (&columns - ww) / 2
		let hwnd.opts.row = (&lines - hh) / 2
		let limit1 = (&lines - 2) * 82 / 100
		let limit2 = (&lines - 2)
		if hh + 8 < limit1
			let hwnd.opts.row = (limit1 - hh) / 2
		else
			let hwnd.opts.row = (limit2 - hh) / 2
		endif
	endif
	return hwnd
endfunc


"----------------------------------------------------------------------
" create input box object
"----------------------------------------------------------------------
function! s:vim_create_input(prompt, opts)
	let hwnd = s:init_input_box(a:prompt, a:opts)
	let opts = {'hidden':1, 'wrap':1}
	let opts.minwidth = hwnd.w
	let opts.maxwidth = hwnd.w
	let opts.minheight = hwnd.h
	let opts.minheight = hwnd.h
	let winid = popup_create(hwnd.bid, opts)
	if has_key(a:opts, 'line') == 0 || has_key(a:opts, 'col') == 0
		call quickui#utils#center(winid, 1)
	endif
	let opts = {'mapping':0, 'cursorline':0, 'drag':1}
	let opts.border = [0,0,0,0,0,0,0,0,0]
	if hwnd.border > 0
		let opts.borderchars = quickui#core#border_vim(hwnd.border)
		let opts.border = [1,1,1,1,1,1,1,1,1]
		let opts.close = 'button'
	endif
	let opts.padding = [1,1,1,1]
	if has_key(a:opts, 'title') && (a:opts.title != '')
		let opts.title = ' ' . a:opts.title . ' '
	endif
	let bc = hwnd.opts.bordercolor
	let opts.resize = 0
	let opts.highlight = hwnd.opts.color
	let opts.borderhighlight = [bc, bc, bc, bc]
	let opts.callback = function('s:popup_exit')
	let hwnd.winid = winid
	let local = quickui#core#popup_local(winid)
	let local.hwnd = hwnd
	call popup_setoptions(winid, opts)
	call popup_show(winid)
	redraw
	return hwnd
endfunc


"----------------------------------------------------------------------
" exit callback
"----------------------------------------------------------------------
function! s:popup_exit(winid, code)
	let local = quickui#core#popup_local(a:winid)
	let local.hwnd.exit = 1
endfunc


"----------------------------------------------------------------------
" neovim: create input
"----------------------------------------------------------------------
function! s:nvim_create_input(prompt, opts)
	let hwnd = s:init_input_box(a:prompt, a:opts)
	let opts = {'focusable':1, 'style':'minimal', 'relative':'editor'}
	let title = ' Input '
	let border = hwnd.border
	let back = quickui#utils#make_border(hwnd.w + 2, hwnd.h + 2, border, title, 1)
	let hwnd.back = back
	let opts.width = hwnd.w
	let opts.height = hwnd.h
	let opts.row = hwnd.opts.row
	let opts.col = hwnd.opts.col
	if has('nvim-0.6.0')
		let opts.noautocmd = 1
	endif
	let winid = nvim_open_win(hwnd.bid, 0, opts)
	let hwnd.winid = winid
	let background = -1
	if border > 0 && get(g:, 'quickui_nvim_simulate_border', 1) != 0
		let nbid = quickui#core#scratch_buffer('inputborder', back)
		let op = {'relative':'editor', 'focusable':1, 'style':'minimal'}
		let op.width = hwnd.w + 4
		let op.height = hwnd.h + 4
		let op.row = hwnd.opts.row - 2
		let op.col = hwnd.opts.col - 2
		let bordercolor = hwnd.opts.bordercolor
		if has('nvim-0.6.0')
			let op.noautocmd = 1
		endif
		let background = nvim_open_win(nbid, 0, op)
		call nvim_win_set_option(background, 'winhl', 'Normal:' . bordercolor)
	endif
	let hwnd.background = background
	call nvim_win_set_option(winid, 'winhl', 'Normal:' . hwnd.opts.color)
	return hwnd
endfunc


"----------------------------------------------------------------------
" redraw input area
"----------------------------------------------------------------------
function! s:update_input(hwnd)
	let hwnd = a:hwnd
	let rl = hwnd.rl
	let size = hwnd.w
	let ts = float2nr(reltimefloat(reltime()) * 1000)
	let blink = rl.blink(ts)
	let blink = (hwnd.wait)? 0 : blink
	let hwnd.pos = rl.slide(hwnd.pos, size)
	let display = rl.render(hwnd.pos, size)
	let cmdlist = ['syn clear']
	let x = 1
	let y = hwnd.lnum
	let content = []
	for [attr, text] in display
		let len = strwidth(text)
		let content += [text]
		let color = 'QuickInput'
		if attr == 1
			let color = (blink == 0)? 'QuickCursor' : 'QuickInput'
		elseif attr == 2
			let color = 'QuickVisual'
		elseif attr == 3
			let color = (blink == 0)? 'QuickCursor' : 'QuickVisual'
		endif
		let cmd = quickui#core#high_region(color, y, x, y, x + len, 1)
		let cmdlist += [cmd]
		let x += len
	endfor
	let text = join(content, '')
	call setbufline(hwnd.bid, y, text)
	call setbufvar(hwnd.bid, '&modified', 0)
	call quickui#core#win_execute(hwnd.winid, cmdlist)
	noautocmd redraw
	if 0
		echon 'blink='. blink 
		echon ' <'
		call rl.echo(blink, 0, hwnd.w) 
		echon '>'
	endif
endfunc


"----------------------------------------------------------------------
" select all text
"----------------------------------------------------------------------
function! s:select_all(hwnd)
	let hwnd = a:hwnd
	let rl = hwnd.rl
	let hwnd.pos = 0
	call rl.seek(0, 2)
	if rl.size > 0
		let rl.select = 0
	endif
	let hwnd.pos = rl.slide(hwnd.pos, hwnd.w)
endfunc


"----------------------------------------------------------------------
" create input box
"----------------------------------------------------------------------
function! quickui#input#create(prompt, opts)
	if s:has_nvim == 0
		let hwnd = s:vim_create_input(a:prompt, a:opts)
	else
		let hwnd = s:nvim_create_input(a:prompt, a:opts)
	endif
	let rl = hwnd.rl
	let accept = 0
	let result = ''
	silent! exec 'nohl'
	while hwnd.exit == 0
		call s:update_input(hwnd)
		try
			if hwnd.wait != 0
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
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		if ch == "\<ESC>" || ch == "\<c-c>"
			break
		endif
		if ch == ""
			continue
		elseif ch == "\<ESC>"
			break
		elseif ch == "\<cr>"
			let result = rl.update()
			if result != '' || hwnd.strict == 0
				let accept = 1
				call rl.history_save()
				break
			endif
		elseif ch == "\<LeftMouse>"
			if v:mouse_winid == hwnd.winid
				if v:mouse_lnum == hwnd.lnum
					let x = v:mouse_col - (s:has_nvim? 1 : 3)
					if x >= 0 && x < hwnd.w
						let pos = rl.mouse_click(hwnd.pos, x)
						call rl.seek(pos, 0)
						let rl.select = -1
					endif
				endif
			elseif s:has_nvim != 0
				if v:mouse_winid == hwnd.background
					if v:mouse_lnum == 1
						if v:mouse_col == hwnd.w + 4
							break
						endif
					endif
				endif
			endif
		elseif ch == "\<Up>" || ch == "\<c-p>"
			if len(rl.history) > 0
				call rl.feed("\<up>")
				call s:select_all(hwnd)
			endif
		elseif ch == "\<Down>" || ch == "\<c-n>"
			if len(rl.history) > 0
				call rl.feed("\<down>")
				call s:select_all(hwnd)
			endif
		elseif ch == "\<c-d>"
			redraw
			echon "winsize: " . hwnd.w
		elseif ch == "\<c-g>"
			call s:select_all(hwnd)
		elseif ch == "\<c-r>"
			let rop = {}
			let text = quickui#utils#read_eval(rop)
			let text = split(text, "\n", 1)[0]
			let text = substitute(text, '[\r\n\t]', ' ', 'g')
			if text != ''
				if rl.select >= 0
					call rl.visual_delete()
				endif
				call rl.insert(text)
			endif
		else
			call rl.feed(ch)
		endif
	endwhile
	if s:has_nvim == 0
		call popup_close(hwnd.winid)
	else
		call nvim_win_close(hwnd.winid, 0)
		if hwnd.background >= 0
			call nvim_win_close(hwnd.background, 0)
		endif
	endif
	call quickui#core#popup_clear(hwnd.winid)
	redraw
	if hwnd.history != ''
		let s:history[hwnd.history] = deepcopy(rl.history)
	endif
	return result
endfunc


"----------------------------------------------------------------------
" open input box
"----------------------------------------------------------------------
function! quickui#input#open(prompt, ...)
	let opts = {'title':'Input'}
	let opts.text = (a:0 >= 1)? (a:1) : ''
	if (a:0 >= 2) 
		let opts.history = a:2
	endif
	let opts.wait = get(g:, 'quickui_input_wait', 0)
	return quickui#input#create(a:prompt, opts)
endfunc


"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 0
	let opts = {}
	let opts.title = 'Input'
	" let opts.w = 50
	echo quickui#input#open("Enter your name:", 'haha', 'abc')
endif


