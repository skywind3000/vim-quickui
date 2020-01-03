"======================================================================
"
" core.vim - 
"
" Created by skywind on 2019/12/18
" Last Modified: 2019/12/18 15:58:00
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"======================================================================
" core routines
"======================================================================

"----------------------------------------------------------------------
" global variables
"----------------------------------------------------------------------
let g:quickui#core#has_nvim = has('nvim')
let g:quickui#core#has_popup = exists('*popup_create') && v:version >= 800
let g:quickui#core#has_floating = has('nvim-0.4')


"----------------------------------------------------------------------
" internal variables
"----------------------------------------------------------------------
let s:buffer_cache = {}


"----------------------------------------------------------------------
" replace string
"----------------------------------------------------------------------
function! quickui#core#string_replace(text, old, new)
	let l:data = split(a:text, a:old, 1)
	return join(l:data, a:new)
endfunc


"----------------------------------------------------------------------
" eval & expand: '%{script}' in string
"----------------------------------------------------------------------
function! quickui#core#expand_text(string) abort
	let partial = []
	let index = 0
	while 1
		let pos = stridx(a:string, '%{', index)
		if pos < 0
			let partial += [strpart(a:string, index)]
			break
		endif
		let head = ''
		if pos > index
			let partial += [strpart(a:string, index, pos - index)]
		endif
		let endup = stridx(a:string, '}', pos + 2)
		if endup < 0
			let partial += [strpart(a:stirng, index)]
			break
		endif
		let index = endup + 1
		if endup > pos + 2
			let script = strpart(a:string, pos + 2, endup - (pos + 2))
			let script = substitute(script, '^\s*\(.\{-}\)\s*$', '\1', '')
			let result = eval(script)
			let partial += [result]
		endif
	endwhile
	return join(partial, '')
endfunc


"----------------------------------------------------------------------
" escape key character (starts by &) from string
"----------------------------------------------------------------------
function! quickui#core#escape(text)
	let text = a:text
	let rest = ''
	let start = 0
	let obj = ['', '', -1, -1, -1]
	while 1
		let pos = stridx(text, '&', start)
		if pos < 0
			let rest .= strpart(text, start)
			break
		end
		let rest .= strpart(text, start, pos - start)
		let key = strpart(text, pos + 1, 1)
		let start = pos + 2
		if key == '&'
			let rest .= '&'
		elseif key == '~'
			let rest .= '~'
		else
			let obj[1] = key
			let obj[2] = strlen(rest)
			let obj[3] = strchars(rest)
			let obj[4] = strdisplaywidth(rest)
			let rest .= key
		endif
	endwhile
	let obj[0] = rest
	return obj
endfunc


"----------------------------------------------------------------------
" list parse
"----------------------------------------------------------------------
function! quickui#core#single_parse(description)
	let item = { 'part': [], 'size': 0 }
	let item.key_char = ''
	let item.key_pos = -1
	let item.key_idx = -1
	if type(a:description) == v:t_string
		let text = a:description
		let item.cmd = ''
	elseif type(a:description) == v:t_list
		let size = len(a:description)
		let text = (size > 0)? a:description[0] : ''
		let item.cmd = (size > 1)? a:description[1] : ''
	endif
	for text in split(text, "\t")
		let obj = quickui#core#escape(text)
		let item.part += [obj[0]]
		if obj[2] >= 0 && item.key_idx < 0
			let item.key_char = obj[1]
			let item.key_pos = obj[4]
			let item.key_idx = item.size
		endif
		let item.size += 1
	endfor
	return item
endfunc


"----------------------------------------------------------------------
" object
"----------------------------------------------------------------------
function! quickui#core#instance()
	if exists('t:__quickui__')
		return t:__quickui__
	endif
	let t:__quickui__ = {}
	return t:__quickui__
endfunc


"----------------------------------------------------------------------
" object cache: acquire
"----------------------------------------------------------------------
function! quickui#core#popup_alloc(name)
	let inst = quickui#core#instance()
	if !has_key(inst, 'popup_cache')
		let inst.popup_cache = {}
	endif
	if !has_key(inst.popup_cache, a:name)
		let inst.popup_cache[a:name] = []
	endif
	if !empty(inst.popup_cache[a:name])
		let winid = remove(inst.popup_cache[a:name], -1)
		return winid
	endif
	let opts = {"line":1, "col":1, "wrap":0, "pos": 'topleft'}
	let winid = popup_create([], opts)
	call popup_hide(winid)
	call win_execute(winid, 'setlocal nonumber nowrap signcolumn=no')
	call setwinvar(winid, '&wincolor', 'QuickBG')
	return winid
endfunc


"----------------------------------------------------------------------
" object cache: release
"----------------------------------------------------------------------
function! quickui#core#popup_release(name, winid)
	let inst = quickui#core#instance()
	if !has_key(inst, 'popup_cache')
		let inst.popup_cache = {}
	endif
	if !has_key(inst.popup_cache, a:name)
		let inst.popup_cache[a:name] = []
	endif
	silent! call popup_hide(a:winid)
	let size = len(inst.popup_cache[a:name])
	call insert(inst.popup_cache[a:name], a:winid, size)	
endfunc


"----------------------------------------------------------------------
" local object
"----------------------------------------------------------------------
function! quickui#core#popup_local(winid)
	let inst = quickui#core#instance()
	if !has_key(inst, 'popup_local')
		let inst.popup_local = {}
	endif
	if !has_key(inst.popup_local, a:winid)
		let inst.popup_local[a:winid] = {}
	endif
	return inst.popup_local[a:winid]
endfunc


"----------------------------------------------------------------------
" erase local data
"----------------------------------------------------------------------
function! quickui#core#popup_clear(winid)
	let inst = quickui#core#instance()
	if !has_key(inst, 'popup_local')
		let inst.popup_local = {}
	endif
	if has_key(inst.popup_local, a:winid)
		call remove(inst.popup_local, a:winid)
	endif
endfunc


"----------------------------------------------------------------------
" vim/nvim compatible
"----------------------------------------------------------------------
function! quickui#core#win_execute(winid, command)
	if g:quickui#core#has_popup != 0
		if type(a:command) == v:t_string
			call win_execute(a:winid, a:command)
		elseif type(a:command) == v:t_list
			call win_execute(a:winid, join(a:command, "\n"))
		endif
	else
		let current = nvim_get_current_win()
		call nvim_set_current_win(a:winid)
		if type(a:command) == v:t_string
			exec a:command
		elseif type(a:command) == v:t_list
			exec join(a:command, "\n")
		endif
		call nvim_set_current_win(current)
	endif
endfunc


"----------------------------------------------------------------------
" get a named buffer
"----------------------------------------------------------------------
function! quickui#core#neovim_buffer(name, textlist)
	let bid = get(s:buffer_cache, a:name, -1)
	if bid < 0
		let bid = nvim_create_buf(v:false, v:true)
		let s:buffer_cache[a:name] = bid
	endif
	call nvim_buf_set_lines(bid, 0, -1, v:true, a:textlist)
	return bid
endfunc


"----------------------------------------------------------------------
" dummy filter
"----------------------------------------------------------------------
function! quickui#core#mock_function(id, text)
	return 0
endfunc


"----------------------------------------------------------------------
" highlight region
"----------------------------------------------------------------------
function! quickui#core#high_region(name, srow, scol, erow, ecol, virtual)
	let sep = (a:virtual == 0)? 'c' : 'v'
	let cmd = 'syn region ' . a:name . ' '
	let cmd .= ' start=/\%' . a:srow . 'l\%' . a:scol . sep . '/'
	let cmd .= ' end=/\%' . a:erow . 'l\%' . a:ecol . sep . '/'
	return cmd
endfunc


"----------------------------------------------------------------------
" patterns
"----------------------------------------------------------------------
function! quickui#core#border_extract(pattern)
	let parts = ['', '', '', '', '', '', '', '', '', '', '']
	for idx in range(11)
		let parts[idx] = strcharpart(a:pattern, idx, 1)
	endfor
	return parts
endfunc


function! quickui#core#border_convert(pattern)
	if type(a:pattern) == v:t_string
		let p = quickui#core#border_extract(a:pattern)
	else
		let p = a:pattern
	endif
	let pattern = [ p[1], p[5], p[7], p[3], p[0], p[2], p[8], p[6] ]
	return pattern
endfunc

let s:border_styles = {}

let s:border_styles[1] = quickui#core#border_extract('+-+|-|+-+++')
let s:border_styles[2] = quickui#core#border_extract('┌─┐│─│└─┘├┤')
let s:border_styles[3] = quickui#core#border_extract('╔═╗║─║╚═╝╟╢')

let s:border_ascii = quickui#core#border_extract('+-+|-|+-+++')

function! quickui#core#border_install(name, pattern)
	let s:border_styles[a:name] = quickui#core#border_extract(a:pattern)
endfunc

function! quickui#core#border_get(name)
	if has_key(s:border_styles, a:name)
		return s:border_styles[a:name]
	endif
	return s:border_ascii
endfunc

function! quickui#core#border_vim(name)
	let border = quickui#core#border_get(a:name)
	return quickui#core#border_convert(border)
endfunc


"----------------------------------------------------------------------
" returns cursor position for screen coordination
"----------------------------------------------------------------------
function! quickui#core#cursor_pos()
	let pos = win_screenpos('.')
	return [pos[0] + winline() - 1, pos[1] + wincol() - 1]
endfunc


"----------------------------------------------------------------------
" screen boundary check, returns 1 for in screen, 0 for exceeding
"----------------------------------------------------------------------
function! quickui#core#in_screen(line, column, width, height)
	let x = a:column - 1
	let y = a:line - 1
	let w = a:width
	let h = a:height
	let screenw = &columns
	let screenh = &lines
	return (x >= 0 && y >= 0 && x + w <= screenw && y + h <= screenh)? 1 : 0
endfunc


"----------------------------------------------------------------------
" window fit screen
"----------------------------------------------------------------------
function! quickui#core#screen_fit(line, column, width, height)
	let x = a:column - 1
	let y = a:line - 1
	let w = a:width
	let h = a:height
	let screenw = &columns
	let screenh = &lines
	let x = (x + w > screenw)? screenw - w : x
	let y = (y + h > screenh)? screenh - h : y
	let x = (x < 0)? 0 : x
	let y = (y < 0)? 0 : y
	return [y + 1, x + 1]
endfunc


"----------------------------------------------------------------------
" fit screen
"----------------------------------------------------------------------
function! quickui#core#around_cursor(width, height)
	let cursor_pos = quickui#core#cursor_pos()
	let row = cursor_pos[0] + 1
	let col = cursor_pos[1] + 1
	if quickui#core#in_screen(row, col, a:width, a:height)
		return [row, col]
	endif
	if col + a:width - 1 > &columns
		let col = col - (1 + a:width)
		if quickui#core#in_screen(row, col, a:width, a:height)
			return [row, col]
		endif
	endif
	if row + a:height - 1 > &lines
		let row = row - (1 + a:height)
		if quickui#core#in_screen(row, col, a:width, a:height)
			return [row, col]
		endif
	endif
	let row = cursor_pos[0] + 1
	let col = cursor_pos[1] + 1
	return quickui#core#screen_fit(row, col, a:height, a:height)
endfunc



