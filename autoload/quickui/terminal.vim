"======================================================================
"
" terminal.vim - 
"
" Created by skywind on 2020/02/03
" Last Modified: 2020/02/03 10:31:33
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" terminal return
"----------------------------------------------------------------------
let g:quickui#terminal#capture = []
let g:quickui#terminal#tmpname = ''


"----------------------------------------------------------------------
" create a terminal popup
"----------------------------------------------------------------------
function! quickui#terminal#create(cmd, opts)
	let w = get(a:opts, 'w', 80)
	let h = get(a:opts, 'h', 24)
	let winid = -1
	let title = has_key(a:opts, 'title')? (' ' . a:opts.title .' ') : ''
	let border = get(a:opts, 'border', g:quickui#style#border)
	let button = (get(a:opts, 'close', '') == 'button')? 1 : 0
	let color = get(a:opts, 'color', 'QuickTermBorder')
	let ww = w + ((border != 0)? 2 : 0)
	let hh = h + ((border != 0)? 2 : 0)
	let hwnd = {'opts':deepcopy(a:opts), 'code':-1}
	if !has_key(hwnd.opts, 'line')
		let limit1 = (&lines - 2) * 90 / 100
		let limit2 = (&lines - 2)
		if h + 4 < limit1
			let hwnd.opts.line = (limit1 - hh) / 2
		else
			let hwnd.opts.line = (limit2 - hh) / 2
		endif
		let hwnd.opts.line = (hwnd.opts.line < 1)? 1 : hwnd.opts.line
	endif
	if !has_key(hwnd.opts, 'col')
		let hwnd.opts.col = (&columns - ww) / 2
		let hwnd.opts.col = (hwnd.opts.col < 1)? 1 : hwnd.opts.col
	endif
	if has('nvim') == 0
		let opts = {'hidden': 1, 'term_rows':h, 'term_cols':w}
		let opts.term_kill = get(a:opts, 'term_kill', 'term')
		let opts.norestore = 1
		let opts.exit_cb = function('s:vim_term_exit')
		let opts.term_finish = 'close'
		let savedir = getcwd()
		if has_key(a:opts, 'cwd')
			call quickui#core#chdir(a:opts.cwd)
		endif
		let bid = term_start(a:cmd, opts)
		if has_key(a:opts, 'cwd')
			call quickui#core#chdir(savedir)
		endif
		if bid <= 0
			return -1
		endif
		let opts = {'maxwidth':w, 'maxheight':h, 'minwidth':w, 'minheight':h}
		let opts.wrap = 0
		let opts.mapping = 0
		let opts.title = title
		let opts.close = (button)? 'button' : 'none'
		let opts.border = border? [1,1,1,1,1,1,1,1,1] : repeat([0], 9)
		let opts.highlight = color
		let opts.borderchars = quickui#core#border_vim(border)
		let opts.drag = get(a:opts, 'drag', 1)
		let opts.resize = 0
		let opts.callback = function('s:vim_popup_callback')
		let winid = popup_create(bid, opts)
		call popup_move(winid, {'line':hwnd.opts.line, 'col':hwnd.opts.col})
		let hwnd.winid = winid
		let g:quickui#terminal#current = hwnd
		let s:current = hwnd
		call popup_show(winid)
		let init = []
		let init += ['setlocal nonumber norelativenumber scrolloff=0']
		let init += ['setlocal signcolumn=no']
		let init += ['setlocal bufhidden=wipe']
		call quickui#core#win_execute(winid, init)
	else
		let bid = quickui#core#scratch_buffer('terminal', [])
		let opts = {'focusable':1, 'style':'minimal', 'relative':'editor'}
		let opts.width = w
		let opts.height = h
		let opts.row = hwnd.opts.line - 1 + ((border > 0)? 1 : 0)
		let opts.col = hwnd.opts.col - 1 + ((border > 0)? 1 : 0)
		if has('nvim-0.6.0')
			let opts.noautocmd = 1
		endif
		let winid = nvim_open_win(bid, 1, opts)
		let hwnd.winid = winid
		let hwnd.background = -1
		if winid < 0
			return -1
		endif
		let cc = get(g:, 'terminal_color_0', 0)
		let hl = 'Normal:'.cc.',NonText:'.cc.',EndOfBuffer:'.cc
		" silent! call nvim_win_set_option(winid, 'winhl', hl)
		call setwinvar(winid, '&winhighlight', 'NormalFloat:Normal')
		if border > 0
			let title = has_key(a:opts, 'title')? ' ' . a:opts.title . ' ':''
			let back = quickui#utils#make_border(w, h, border, title, button)
			let nbid = quickui#core#scratch_buffer('terminalborder', back)
			let op = {'relative':'editor', 'focusable':0, 'style':'minimal'}
			let op.width = w + 2
			let op.height = h + 2
			let pos = nvim_win_get_config(winid)
			let op.row = hwnd.opts.line - 1
			let op.col = hwnd.opts.col - 1
			if has('nvim-0.6.0')
				let op.noautocmd = 1
			endif
			let background = nvim_open_win(nbid, 0, op)
			call nvim_win_set_option(background, 'winhl', 'Normal:'. color)
			let hwnd.background = background
		endif
		call nvim_set_current_win(winid)
		setlocal nomodified
		let opts = {'width': w, 'height':h}
		let opts.on_exit = function('s:nvim_term_exit')
		if has_key(a:opts, 'cwd')
			let opts.cwd = a:opts.cwd
		endif
		call termopen(a:cmd, opts)
		let g:quickui#terminal#current = hwnd
		let s:current = hwnd
		let init = []
		let init += ['setlocal nonumber norelativenumber scrolloff=0']
		let init += ['setlocal signcolumn=no']
		let init += ['setlocal bufhidden=wipe']
		call quickui#core#win_execute(winid, init)
		startinsert
	endif
	return hwnd
endfunc


"----------------------------------------------------------------------
" read back capture
"----------------------------------------------------------------------
function! s:capture_read()
	let g:quickui#terminal#capture = []
	if g:quickui#terminal#tmpname != ''
		let tmpname = g:quickui#terminal#tmpname
		let g:quickui#terminal#tmpname = ''
		if filereadable(tmpname)
			silent! let g:quickui#terminal#capture = readfile(tmpname)
			call delete(tmpname)
		endif
	endif
endfunc


"----------------------------------------------------------------------
" terminal exit_cb
"----------------------------------------------------------------------
function! s:vim_term_exit(job, message)
	if exists('s:current')
		let hwnd = s:current
		let hwnd.code = a:message
	endif
endfunc


"----------------------------------------------------------------------
" popup callback 
"----------------------------------------------------------------------
function! s:vim_popup_callback(winid, code)
	if exists('s:current')
		let hwnd = s:current
		let hwnd.winid = -1
		call s:capture_read()
		if has_key(hwnd.opts, 'callback')
			call call(hwnd.opts.callback, [hwnd.code])
		endif
	endif
endfunc


"----------------------------------------------------------------------
" neovim exit
"----------------------------------------------------------------------
function! s:nvim_term_exit(jobid, data, event)
	if exists('s:current')
		let hwnd = s:current
		let hwnd.code = a:data
		if hwnd.winid >= 0
			call nvim_win_close(hwnd.winid, 0)
		endif
		if hwnd.background >= 0
			call nvim_win_close(hwnd.background, 0)
		endif
		let hwnd.winid = -1
		let hwnd.background = -1
		call s:capture_read()
		if has_key(hwnd.opts, 'callback')
			call call(hwnd.opts.callback, [hwnd.code])
		endif
	endif
endfunc


"----------------------------------------------------------------------
" open terminal in popup window
"----------------------------------------------------------------------
function! quickui#terminal#open(cmd, opts)
	let opts = deepcopy(a:opts)
	let border = get(a:opts, 'border', g:quickui#style#border)
	if border == 0
		if has_key(opts, 'title')
			unlet opts['title']
		endif
		if has_key(opts, 'close')
			unlet opts['close']
		endif
	endif
	if has_key(opts, 'callback')
		if type(opts.callback) == v:t_string
			if opts.callback == ''
				unlet opts['callback']
			endif
		endif
	endif
	if has_key(opts, 'w')
		let opts.w = quickui#utils#read_size(opts.w, &columns)
	endif
	if has_key(opts, 'h')
		let opts.h = quickui#utils#read_size(opts.h, &lines)
	endif
	let g:quickui#terminal#capture = []
	let g:quickui#terminal#tmpname = ''
	let $VIM_INPUT = ''
	let $VIM_CAPTURE = ''
	if has_key(opts, 'input')
		if has('win32') || has('win64') || has('win95') || has('win16')
			let tmpname = fnamemodify(tempname(), ':h') . '\quickui1.txt'
		else
			let tmpname = fnamemodify(tempname(), ':h') . '/quickui1.txt'
		endif
		call writefile(opts.input, tmpname)
		let $VIM_INPUT = tmpname
	endif
	if has_key(opts, 'capture')
		if opts.capture
			if has('win32') || has('win64') || has('win95') || has('win16')
				let tmpname = fnamemodify(tempname(), ':h') . '\quickui2.txt'
			else
				let tmpname = fnamemodify(tempname(), ':h') . '/quickui2.txt'
			endif
			let g:quickui#terminal#tmpname = tmpname
			let $VIM_CAPTURE = tmpname
			if filereadable(tmpname)
				call delete(tmpname)
			endif
		endif
		unlet opts['capture']
	endif
	return quickui#terminal#create(a:cmd, opts)
endfunc


"----------------------------------------------------------------------
" dialog exit
"----------------------------------------------------------------------
function! s:dialog_callback(code)
	let args = {}
	let args.code = a:code
	let args.capture = g:quickui#terminal#capture
	call call(s:dialog_cb, [args])
endfunc


"----------------------------------------------------------------------
" dialog: run command line tool and capture result
" the callback function changes to a new prototype:
" function! Callback(args), where args is a tuple of (code, capture)
" where capture is a list of text lines in the $VIM_CAPTURE file
"----------------------------------------------------------------------
function! quickui#terminal#dialog(cmd, opts)
	let opts = deepcopy(a:opts)
	let opts.macros = quickui#core#expand_macros()
	if has_key(opts, 'prepare')
		call call(opts.prepare, [opts])
	endif
	let command = a:cmd
	for [key, val] in items(opts.macros)
		let replace = (key[0] != '<')? '$('.key.')' : key
		if key[0] != '<'
			exec 'let $' . key . ' = val'
		endif
		let command = quickui#core#string_replace(command, replace, val)
		if has_key(opts, 'cwd')
			let opts.cwd = quickui#core#string_replace(opts.cwd, replace, val)
		endif
	endfor
	let cwd = get(opts, 'cwd', '')
	if cwd != ''
		let previous = getcwd()
		call quickui#core#chdir(cwd)
		let opts.macros['VIM_CWD'] = getcwd()
		let opts.macros['VIM_RELDIR'] = expand("%:h:.")
		let opts.macros['VIM_RELNAME'] = expand("%:p:.")
		let opts.macros['VIM_CFILE'] = expand("<cfile>")
		let opts.macros['VIM_DIRNAME'] = fnamemodify(opts.macros['VIM_CWD'], ':t')
		let opts.macros['<cwd>'] = opts.macros['VIM_CWD']
		call quickui#core#chdir(previous)
	endif
	let pause = get(opts, 'pause', 0)
	let command = quickui#core#write_script(command, pause)
	if has_key(opts, 'callback')
		let l:F2 = opts.callback
		if type(l:F2) == v:t_string
			if l:F2 != ''
				let s:dialog_cb = function(l:F2)
				let opts.callback = function('s:dialog_callback')
				let opts.capture = 1
			endif
		elseif type(l:F2) == v:t_func
			let s:dialog_cb = function(l:F2)
			let opts.callback = function('s:dialog_callback')
			let opts.capture = 1
		endif
		unlet l:F2
	endif
	if has_key(opts, 'cwd')
		if opts.cwd == ''
			unlet opts['cwd']
		endif
	endif
	return quickui#terminal#open(command, opts)
endfunc


