"======================================================================
"
" core.vim - 
"
" Created by skywind on 2019/12/18
" Last Modified: 2022/08/31 16:25
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
let g:quickui#core#has_vim9 = v:version >= 900
let g:quickui#core#has_popup = exists('*popup_create') && v:version >= 800
let g:quickui#core#has_floating = has('nvim-0.4')
let g:quickui#core#has_nvim_040 = has('nvim-0.4')
let g:quickui#core#has_nvim_050 = has('nvim-0.5.0')
let g:quickui#core#has_nvim_060 = has('nvim-0.6.0')
let g:quickui#core#has_vim_820 = (has('nvim') == 0 && has('patch-8.2.1'))
let g:quickui#core#has_win_exe = exists('*win_execute')
let g:quickui#core#has_vim9script = (v:version >= 900) && has('vim9script')


"----------------------------------------------------------------------
" internal variables
"----------------------------------------------------------------------
let s:windows = has('win32') || has('win16') || has('win64') || has('win95')


"----------------------------------------------------------------------
" object pool acquire
"----------------------------------------------------------------------
function! quickui#core#object_acquire(name)
	if !exists('g:quickui#core#__object_pool__')
		let g:quickui#core#__object_pool__ = {}
	endif
	if !has_key(g:quickui#core#__object_pool__, a:name)
		let g:quickui#core#__object_pool__[a:name] = []
	endif
	let array = g:quickui#core#__object_pool__[a:name]
	if len(array) == 0
		return v:null
	endif
	let obj = remove(array, -1)	
	return obj
endfunc


"----------------------------------------------------------------------
" object pool release
"----------------------------------------------------------------------
function! quickui#core#object_release(name, obj)
	if !exists('g:quickui#core#__object_pool__')
		let g:quickui#core#__object_pool__ = {}
	endif
	if !has_key(g:quickui#core#__object_pool__, a:name)
		let g:quickui#core#__object_pool__[a:name] = []
	endif
	call add(g:quickui#core#__object_pool__[a:name], a:obj)
endfunc


"----------------------------------------------------------------------
" replace string
"----------------------------------------------------------------------
function! quickui#core#string_replace(text, old, new)
	let l:data = split(a:text, a:old, 1)
	return join(l:data, a:new)
endfunc


"----------------------------------------------------------------------
" compose two string
"----------------------------------------------------------------------
function! quickui#core#string_compose(target, pos, source)
	if a:source == ''
		return a:target
	endif
	let pos = a:pos
	let source = a:source
	if pos < 0
		let source = strcharpart(a:source, -pos)
		let pos = 0
	endif
	let target = strcharpart(a:target, 0, pos)
	if strchars(target) < pos
		let target .= repeat(' ', pos - strchars(target))
	endif
	let target .= source
	let target .= strcharpart(a:target, pos + strchars(source))
	return target
endfunc


"----------------------------------------------------------------------
" fit size
"----------------------------------------------------------------------
function! quickui#core#string_fit(source, size)
	let require = a:size
	let source = a:source
	let size = len(source)
	if size <= require
		return source
	endif
	if require <= 2
		return repeat('.', (require < 0)? 0 : require)
	endif	
	let avail = require - 2
	let left = avail / 2
	let right = avail - left
	let p1 = strpart(source, 0, left)
	let p2 = strpart(source, size - right)
	let text = p1 . '..' . p2
	return text
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
" tabpage instance
"----------------------------------------------------------------------
function! quickui#core#instance(local)
	let local = a:local
	if local != 0
		if exists('t:__quickui__')
			return t:__quickui__
		endif
		let t:__quickui__ = {}
		return t:__quickui__
	else
		if exists('g:__quickui__')
			return g:__quickui__
		endif
		let g:__quickui__ = {}
		return g:__quickui__
	endif
endfunc


"----------------------------------------------------------------------
" buffer instance
"----------------------------------------------------------------------
function! quickui#core#object(bid)
	let name = '__quickui__'
	let bid = (a:bid > 0)? a:bid : (bufnr(''))
	if bufexists(bid) == 0
		return v:null
	endif
	let obj = getbufvar(bid, name)
	if type(obj) != v:t_dict
		call setbufvar(bid, name, {})
		let obj = getbufvar(bid, name)
	endif
	return obj
endfunc


"----------------------------------------------------------------------
" object cache: acquire
"----------------------------------------------------------------------
function! quickui#core#popup_alloc(name)
	let inst = quickui#core#instance(1)
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
	let inst = quickui#core#instance(1)
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
	let inst = quickui#core#instance(0)
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
	let inst = quickui#core#instance(0)
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
function! quickui#core#win_execute(winid, command, ...)
	let silent = (a:0 < 1)? 0 : (a:1)
	if g:quickui#core#has_popup != 0
		if type(a:command) == v:t_string
			keepalt call win_execute(a:winid, a:command, silent)
		elseif type(a:command) == v:t_list
			keepalt call win_execute(a:winid, join(a:command, "\n"), silent)
		endif
	elseif g:quickui#core#has_win_exe == 0
		let current = nvim_get_current_win()
		keepalt call nvim_set_current_win(a:winid)
		if type(a:command) == v:t_string
			if silent == 0
				exec a:command
			else
				silent exec a:command
			endif
		elseif type(a:command) == v:t_list
			if silent == 0
				exec join(a:command, "\n")
			else
				silent exec join(a:command, "\n")
			endif
		endif
		keepalt call nvim_set_current_win(current)
	else
		if type(a:command) == v:t_string
			keepalt call win_execute(a:winid, a:command, silent)
		elseif type(a:command) == v:t_list
			keepalt call win_execute(a:winid, join(a:command, "\n"), silent)
		endif
	endif
endfunc


"----------------------------------------------------------------------
" close window
"----------------------------------------------------------------------
function! quickui#core#win_close(winid, force)
	let [tnr, wnr] = win_id2tabwin(a:winid)
	if tnr <= 0 || wnr <= 0
		return -1
	endif
	if g:quickui#core#has_nvim == 0
		let cmd = 'close' . ((a:force != 0)? '!' : '')
		call quickui#core#win_execute(a:winid, cmd)
	else
		call nvim_win_close(a:winid, a:force)
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" alloc a new buffer
"----------------------------------------------------------------------
function! quickui#core#buffer_alloc()
	if !exists('s:buffer_array')
		let s:buffer_array = {}
	endif
	let index = len(s:buffer_array) - 1
	if index >= 0
		let bid = s:buffer_array[index]
		unlet s:buffer_array[index]
	else
		if g:quickui#core#has_nvim == 0
			let bid = bufadd('')
			call bufload(bid)
			call setbufvar(bid, '&buflisted', 0)
			call setbufvar(bid, '&bufhidden', 'hide')
			call setbufvar(bid, '&buftype', 'nofile')
			call setbufvar(bid, 'noswapfile', 1)
		else
			let bid = nvim_create_buf(v:false, v:true)
			call setbufvar(bid, '&buftype', 'nofile')
			call setbufvar(bid, '&bufhidden', 'hide')
			call setbufvar(bid, 'noswapfile', 1)
		endif
	endif
	call setbufvar(bid, '&modifiable', 1)
	silent call deletebufline(bid, 1, '$')
	call setbufvar(bid, '&modified', 0)
	call setbufvar(bid, '&filetype', '')
	return bid
endfunc


"----------------------------------------------------------------------
" free a buffer
"----------------------------------------------------------------------
function! quickui#core#buffer_free(bid)
	if !exists('s:buffer_array')
		let s:buffer_array = {}
	endif
	let index = len(s:buffer_array)
	let s:buffer_array[index] = a:bid
	call setbufvar(a:bid, '&modifiable', 1)
	silent call deletebufline(a:bid, 1, '$')
	call setbufvar(a:bid, '&modified', 0)
endfunc


"----------------------------------------------------------------------
" update content
"----------------------------------------------------------------------
function! quickui#core#buffer_update(bid, textlist)
	if type(a:textlist) == v:t_list
		let textlist = a:textlist
	else
		let textlist = split('' . a:textlist, '\n', 1)
	endif
	call setbufvar(a:bid, '&modifiable', 1)
	silent call deletebufline(a:bid, 1, '$')
	call setbufline(a:bid, 1, textlist)
	call setbufvar(a:bid, '&modified', 0)
endfunc


"----------------------------------------------------------------------
" clear content
"----------------------------------------------------------------------
function! quickui#core#buffer_clear(bid)
	call quickui#core#buffer_update(a:bid, [])
endfunc


"----------------------------------------------------------------------
" get a named buffer
"----------------------------------------------------------------------
function! quickui#core#scratch_buffer(name, textlist)
	if !exists('s:buffer_cache')
		let s:buffer_cache = {}
	endif
	if a:name != ''
		let bid = get(s:buffer_cache, a:name, -1)
	else
		let bid = -1
	endif
	if bid < 0 || bufexists(bid) == 0
		let bid = quickui#core#buffer_alloc()
		if a:name != ''
			let s:buffer_cache[a:name] = bid
		endif
	endif
	call quickui#core#buffer_update(bid, a:textlist)
	call setbufvar(bid, 'current_syntax', '')
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


function! quickui#core#border_convert(pattern, nvim_format)
	if type(a:pattern) == v:t_string
		let p = quickui#core#border_extract(a:pattern)
	else
		let p = a:pattern
	endif
	if len(p) == 0
		return []
	endif
	if a:nvim_format == 0
		let pattern = [ p[1], p[5], p[7], p[3], p[0], p[2], p[8], p[6] ]
	else
		let pattern = [ p[0], p[1], p[2], p[5], p[8], p[7], p[6], p[3] ]
	endif
	return pattern
endfunc

let s:border_styles = {}

let s:border_styles[0] = quickui#core#border_extract('           ')
let s:border_styles[1] = quickui#core#border_extract('+-+|-|+-+++')
let s:border_styles[2] = quickui#core#border_extract('┌─┐│─│└─┘├┤')
let s:border_styles[3] = quickui#core#border_extract('╔═╗║─║╚═╝╟╢')
let s:border_styles[4] = quickui#core#border_extract('╭─╮│─│╰─╯├┤')
let s:border_styles[5] = quickui#core#border_extract('/-\|-|\-/++')

let s:border_ascii = quickui#core#border_extract('+-+|-|+-+++')

let s:border_styles['none'] = []
let s:border_styles['single'] = s:border_styles[2]
let s:border_styles['double'] = s:border_styles[3]
let s:border_styles['rounded'] = s:border_styles[4]
let s:border_styles['solid'] = s:border_styles[0]
let s:border_styles['ascii'] = s:border_styles[1]
let s:border_styles['default'] = s:border_styles[1]

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
	return quickui#core#border_convert(border, 0)
endfunc

function! quickui#core#border_nvim(name)
	let border = quickui#core#border_get(a:name)
	return quickui#core#border_convert(border, 1)
endfunc

function! quickui#core#border_auto(name)
	if g:quickui#core#has_nvim == 0
		return quickui#core#border_vim(a:name)
	else
		return quickui#core#border_nvim(a:name)
	endif
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
	if cursor_pos[0] + a:height + 2 < &lines
		let row = cursor_pos[0] + 1
	else
		let row = cursor_pos[0] - a:height
	endif
	if cursor_pos[1] + a:width + 2 < &columns
		let col = cursor_pos[1] + 1
	else
		let col = cursor_pos[1] - a:width
	endif
	return quickui#core#screen_fit(row, col, a:width, a:height)
endfunc


"----------------------------------------------------------------------
" safe input
"----------------------------------------------------------------------
function! quickui#core#input(prompt, text)
	call inputsave()
	try
		let t = input(a:prompt, a:text)
	catch /^Vim:Interrupt$/
		let t = "\<c-c>"
	endtry
	call inputrestore()
	return t
endfunc


"----------------------------------------------------------------------
" safe change dir
"----------------------------------------------------------------------
function! quickui#core#chdir(path)
	if has('nvim')
		let cmd = haslocaldir()? 'lcd' : (haslocaldir(-1, 0)? 'tcd' : 'cd')
	else
		let cmd = haslocaldir()? ((haslocaldir() == 1)? 'lcd' : 'tcd') : 'cd'
	endif
	silent execute cmd . ' '. fnameescape(a:path)
endfunc


"----------------------------------------------------------------------
" full file name
"----------------------------------------------------------------------
function! quickui#core#fullname(f)
	let f = a:f
	if f =~ "'."
		try
			redir => m
			silent exe ':marks' f[1]
			redir END
			let f = split(split(m, '\n')[-1])[-1]
			let f = filereadable(f)? f : ''
		catch
			let f = '%'
		endtry
	endif
	if f == '%'
		let f = expand('%')
		if &bt == 'terminal' || &bt == 'nofile'
			let f = ''
		endif
	endif
	let f = fnamemodify(f, ':p')
	if s:windows
		let f = substitute(f, "\\", '/', 'g')
	endif
	if f =~ '\/$'
		let f = fnamemodify(f, ':h')
	endif
	return f
endfunc


"----------------------------------------------------------------------
" returns nearest parent directory contains one of the markers
"----------------------------------------------------------------------
function! quickui#core#find_root(name, markers, strict)
	let name = fnamemodify((a:name != '')? a:name : bufname('%'), ':p')
	let finding = ''
	" iterate all markers
	for marker in a:markers
		if marker != ''
			" search as a file
			let x = findfile(marker, name . '/;')
			let x = (x == '')? '' : fnamemodify(x, ':p:h')
			" search as a directory
			let y = finddir(marker, name . '/;')
			let y = (y == '')? '' : fnamemodify(y, ':p:h:h')
			" which one is the nearest directory ?
			let z = (strchars(x) > strchars(y))? x : y
			" keep the nearest one in finding
			let finding = (strchars(z) > strchars(finding))? z : finding
		endif
	endfor
	if finding == ''
		let path = (a:strict == 0)? fnamemodify(name, ':h') : ''
	else
		let path = fnamemodify(finding, ':p')
	endif
	if has('win32') || has('win16') || has('win64') || has('win95')
		let path = substitute(path, '\/', '\', 'g')
	endif
	if path =~ '[\/\\]$'
		let path = fnamemodify(path, ':h')
	endif
	return path
endfunc


"----------------------------------------------------------------------
" find project root
"----------------------------------------------------------------------
function! quickui#core#project_root(name, ...)
	let markers = ['.project', '.git', '.hg', '.svn', '.root']
	if exists('g:quickui_rootmarks')
		let markers = g:quickui_rootmarks
	elseif exists('g:asyncrun_rootmarks')
		let markers = g:asyncrun_rootmarks
	endif
	let path = quickui#core#fullname(a:name)
	let strict = (a:0 > 0)? (a:1) : 0
	return quickui#core#find_root(path, markers, strict)
endfunc


"----------------------------------------------------------------------
" expand macros
"----------------------------------------------------------------------
function! quickui#core#expand_macros()
	let macros = {}
	let macros['VIM_FILEPATH'] = expand("%:p")
	let macros['VIM_FILENAME'] = expand("%:t")
	let macros['VIM_FILEDIR'] = expand("%:p:h")
	let macros['VIM_FILENOEXT'] = expand("%:t:r")
	let macros['VIM_PATHNOEXT'] = expand("%:p:r")
	let macros['VIM_FILEEXT'] = "." . expand("%:e")
	let macros['VIM_FILETYPE'] = (&filetype)
	let macros['VIM_CWD'] = getcwd()
	let macros['VIM_RELDIR'] = expand("%:h:.")
	let macros['VIM_RELNAME'] = expand("%:p:.")
	let macros['VIM_CWORD'] = expand("<cword>")
	let macros['VIM_CFILE'] = expand("<cfile>")
	let macros['VIM_CLINE'] = line('.')
	let macros['VIM_VERSION'] = ''.v:version
	let macros['VIM_SVRNAME'] = v:servername
	let macros['VIM_COLUMNS'] = ''.&columns
	let macros['VIM_LINES'] = ''.&lines
	let macros['VIM_GUI'] = has('gui_running')? 1 : 0
	let macros['VIM_ROOT'] = quickui#core#project_root('%', 0)
	let macros['VIM_HOME'] = expand(split(&rtp, ',')[0])
	let macros['VIM_PRONAME'] = fnamemodify(macros['VIM_ROOT'], ':t')
	let macros['VIM_DIRNAME'] = fnamemodify(macros['VIM_CWD'], ':t')
	let macros['<cwd>'] = macros['VIM_CWD']
	let macros['<root>'] = macros['VIM_ROOT']
	if expand("%:e") == ''
		let macros['VIM_FILEEXT'] = ''
	endif
	return macros
endfunc


"----------------------------------------------------------------------
" write script to a file and return filename
"----------------------------------------------------------------------
function! quickui#core#write_script(command, pause)
	let tmpname = fnamemodify(tempname(), ':h') . '\quickui1.cmd'
	let command = a:command
	if s:windows != 0
		let lines = ["@echo off\r"]
		let $VIM_COMMAND = a:command
		let $VIM_PAUSE = (a:pause)? 'pause' : ''
		let lines += ["call %VIM_COMMAND% \r"]
		let lines += ["set VIM_EXITCODE=%ERRORLEVEL%\r"]
		let lines += ["call %VIM_PAUSE% \r"]
		let lines += ["exit %VIM_EXITCODE%\r"]
	else
		let shell = split(&shell, ' ', 1)[0]
		let lines = ['#! ' . shell]
		let lines += [command]
		if a:pause != 0
			if executable('bash')
				let pause = 'read -n1 -rsp "press any key to continue ..."'
				let lines += ['bash -c ''' . pause . '''']
			else
				let lines += ['echo "press enter to continue ..."']
				let lines += ['sh -c "read _tmp_"']
			endif
		endif
		let tmpname = fnamemodify(tempname(), ':h') . '/quickui1.sh'
	endif
	silent! call writefile(lines, tmpname)
	if s:windows == 0
		if exists('*setfperm')
			silent! call setfperm(tmpname, 'rwxrwxrws')
		endif
	endif
	return tmpname
endfunc


"----------------------------------------------------------------------
" string replace
"----------------------------------------------------------------------
function! quickui#core#string_replace(text, old, new)
	let data = split(a:text, a:old, 1)
	return join(data, a:new)
endfunc


"----------------------------------------------------------------------
" string strip
"----------------------------------------------------------------------
function! quickui#core#string_strip(text)
	return substitute(a:text, '^\s*\(.\{-}\)[\t\r\n ]*$', '\1', '')
endfunc



"----------------------------------------------------------------------
" extract opts+command
"----------------------------------------------------------------------
function! quickui#core#extract_opts(command)
	let cmd = substitute(a:command, '^\s*\(.\{-}\)[\s\r\n]*$', '\1', '')
	let opts = {}
	while cmd =~# '^-\%(\w\+\)\%([= ]\|$\)'
		let opt = matchstr(cmd, '^-\zs\w\+')
		if cmd =~ '^-\w\+='
			let val = matchstr(cmd, '^-\w\+=\zs\%(\\.\|\S\)*')
		else
			let val = ''
		endif
		let opts[opt] = substitute(val, '\\\(\s\)', '\1', 'g')
		let cmd = substitute(cmd, '^-\w\+\%(=\%(\\.\|\S\)*\)\=\s*', '', '')
	endwhile
	let cmd = substitute(cmd, '^\s*\(.\{-}\)\s*$', '\1', '')
	let cmd = substitute(cmd, '^@\s*', '', '')
	return [cmd, opts]
endfunc


"----------------------------------------------------------------------
" split cmdline to argv
"----------------------------------------------------------------------
function! quickui#core#split_argv(cmdline)
	let cmd = quickui#core#string_strip(a:cmdline)
	let argv = []
	while cmd =~# '^\%(\\.\|\S\)\+'
		let arg = matchstr(cmd, '^\%(\\.\|\S\)\+')
		let cmd = substitute(cmd, '^\%(\\.\|\S\)\+\s*', '', '')
		let val = substitute(arg, '\\\(\s\)', '\1', 'g')
		let argv += [val]
	endwhile
	return argv
endfunc


"----------------------------------------------------------------------
" execute string
"----------------------------------------------------------------------
function! quickui#core#execute_string(text) 
	let cmd = a:text
	if cmd =~ '^[a-zA-Z0-9_#]\+(.*)$'
		exec 'call ' . cmd
	elseif cmd =~ '^<key>'
		let keys = strpart(cmd, 5)
		call feedkeys(keys)
	elseif cmd =~ '^@'
		let keys = strpart(cmd, 1)
		call feedkeys(keys)
	elseif cmd =~ '^<plug>'
		let keys = strpart(cmd, 6)
		call feedkeys("\<plug>" . keys)
	else
		exec cmd
	endif
endfunc


