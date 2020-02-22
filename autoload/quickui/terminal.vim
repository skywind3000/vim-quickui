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
	else
		let bid = quickui#core#scratch_buffer('terminal', [])
		let opts = {'focusable':1, 'style':'minimal', 'relative':'editor'}
		let opts.width = w
		let opts.height = h
		let opts.row = hwnd.opts.line - 1 + ((border > 0)? 1 : 0)
		let opts.col = hwnd.opts.col - 1 + ((border > 0)? 1 : 0)
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
		call quickui#core#win_execute(winid, init)
		startinsert
	endif
	return hwnd
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
		if has_key(hwnd.opts, 'callback')
			let F = function(hwnd.opts.callback)
			call F(hwnd.code)
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
		if has_key(hwnd.opts, 'callback')
			let F = function(hwnd.opts.callback)
			call F(hwnd.code)
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
	return quickui#terminal#create(a:cmd, opts)
endfunc


