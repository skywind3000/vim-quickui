"======================================================================
"
" window.vim - 
"
" Created by skywind on 2021/12/08
" Last Modified: 2021/12/08 23:45
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" window class
"----------------------------------------------------------------------
let s:window = {}
let s:window.w = 1            " window width
let s:window.h = 1            " window height
let s:window.x = 1            " column starting from 0
let s:window.y = 1            " row starting from 0
let s:window.z = 40           " priority
let s:window.winid = -1       " window id
let s:window.dirty = 0        " need update buffer ?
let s:window.text = []        " text lines
let s:window.bid = -1         " allocated buffer id
let s:window.hide = 0         " visibility
let s:window.mode = 0         " mode: 0/created, 1/closed
let s:window.opts = {}        " creation options
let s:window.info = {}        " init environment
let s:window.quit = 0         " closed by button ? (vim only)


"----------------------------------------------------------------------
" internal 
"----------------------------------------------------------------------
let s:has_nvim = g:quickui#core#has_nvim
let s:has_nvim_060 = g:quickui#core#has_nvim_060


"----------------------------------------------------------------------
" prepare opts
"----------------------------------------------------------------------
function! s:window.__prepare_opts(textlist, opts)
	let opts = deepcopy(a:opts)
	let opts.x = get(a:opts, 'x', 1)
	let opts.y = get(a:opts, 'y', 1)
	let opts.z = get(a:opts, 'z', 40)
	let opts.w = get(a:opts, 'w', 1)
	let opts.h = get(a:opts, 'h', -1)
	let opts.hide = get(a:opts, 'hide', 0)
	let opts.wrap = get(a:opts, 'wrap', 0)
	let opts.color = get(a:opts, 'color', 'QuickBG')
	let opts.border = get(a:opts, 'border', 0)
	let self.opts = opts
	let self.bid = quickui#core#buffer_alloc()
	let self.dirty = 1
	let self.x = opts.x
	let self.y = opts.y
	let self.z = opts.z
	let self.w = (opts.w < 1)? 1 : (opts.w)
	let self.h = (opts.h < 1)? 1 : (opts.h)
	let self.hide = opts.hide
	let self.mode = 0
	if has_key(a:opts, 'padding')
		let self.opts.padding = a:opts.padding
	else
		let self.opts.padding = [0,0,0,0]
	endif
	let pad = self.opts.padding
	let info = self.info
	let info.tw = self.w + pad[1] + pad[3]
	let info.th = self.h + pad[0] + pad[2]
	let sum_pad = pad[0] + pad[1] + pad[2] + pad[3]
	let info.has_padding = (sum_pad > 0)? 1 : 0
	let border = quickui#core#border_auto(self.opts.border)
	let info.has_border = (self.opts.border > 0)? 1 : 0
	if info.has_border != 0
		let info.tw += 2
		let info.th += 2
	endif
	" echom info
	call self.set_text(a:textlist)
	if opts.h < 0
		let opts.h = len(self.text)
	endif
	let cmd = []
	if has_key(opts, 'tabstop')
		let cmd += ['setl tabstop=' . get(opts, 'tabstop', 4)]
	endif
	if has_key(opts, 'list')
		let cmd += [(opts.list)? 'setl list' : 'setl nolist']
	else
		let cmd += ['setl nolist']
	endif
	if get(opts, 'number', 0) != 0
		let cmd += ['setl number']
	else
		let cmd += ['setl nonumber']
	endif
	let cmd += ['setl scrolloff=0']
	let cmd += ['setl signcolumn=no']
	if has_key(opts, 'syntax')
		let cmd += ['set ft=' . fnameescape(opts.syntax)]
	endif
	if has_key(opts, 'cursorline')
		let need = (opts.cursorline)? 'cursorline' : 'nocursorlin'
		let cmd += ['setl ' . need]
		if exists('+cursorlineopt')
			let cmd += ['setl cursorlineopt=both']
		endif
	else
		let cmd += ['setl nocursorline']
	endif
	let cmd += ['setl nocursorcolumn nospell']
	let cmd += [opts.wrap? 'setl wrap' : 'setl nowrap']
	if has_key(opts, 'command')
		let command = opts.command
		if type(command) == type([])
			let cmd += command
		else
			let cmd += [''. command]
		endif
	endif
	let info.cmd = cmd
	let info.pending_cmd = []
	let info.border_winid = -1
	let info.border_bid = -1
endfunc


"----------------------------------------------------------------------
" win filter
"----------------------------------------------------------------------
function! s:popup_filter(winid, key)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.window_hwnd
endfunc


"----------------------------------------------------------------------
" exited
"----------------------------------------------------------------------
function! s:popup_exit(winid, code)
	let local = quickui#core#popup_local(a:winid)
	let hwnd = local.window_hwnd
	call quickui#core#popup_clear(a:winid)
	let hwnd.quit = 1
	let hwnd.winid = -1
endfunc


"----------------------------------------------------------------------
" create window in vim
"----------------------------------------------------------------------
function! s:window.__vim_create()
	let opts = {"hidden":1, "pos": 'topleft'}
	let opts.hidden = 1
	let opts.wrap = self.opts.wrap
	let opts.minwidth = self.w
	let opts.maxwidth = self.w
	let opts.minheight = self.h
	let opts.maxheight = self.h
	let opts.col = self.x + 1
	let opts.line = self.y + 1
	let opts.mapping = 0
	let opts.fixed = (opts.wrap == 0)? 1 : 0
	let opts.cursorline = get(self.opts, 'cursorline', 0)
	let opts.drag = get(self.opts, 'drag', 0)
	let opts.scrollbar = 0
	let opts.zindex = self.z + 1
	if get(self.opts, 'button', 0) != 0
		let opts.close = 'button'
	endif
	let self.winid = popup_create(self.bid, opts)
	let winid = self.winid
	let local = quickui#core#popup_local(winid)
	let local.window_hwnd = self
	let init = []
	let init += ['setlocal nonumber signcolumn=no scrolloff=0']
	call quickui#core#win_execute(winid, init, 1)
	let opts = {}
	let opts.filter = function('s:popup_filter')
	let opts.callback = function('s:popup_exit')
	let opts.highlight = self.opts.color
	let border = quickui#core#border_auto(self.opts.border)
	if self.info.has_border
		let opts.borderchars = border
		let opts.border = [1,1,1,1,1,1,1,1,1]
		let bc = get(self.opts, 'bordercolor', 'QuickBorder')
		let opts.borderhighlight = [bc, bc, bc, bc]
		if has_key(self.opts, 'title')
			let opts.title = self.opts.title
		endif
	endif
	if has_key(self.opts, 'padding') 
		let opts.padding = self.opts.padding
	endif
	call setwinvar(winid, '&wincolor', self.opts.color)
	call popup_setoptions(winid, opts)
	call quickui#core#win_execute(winid, self.info.cmd)
	let pc = self.info.pending_cmd
	if len(pc) > 0
		call quickui#core#win_execute(winid, pc)
		let self.info.pending_cmd = []
	endif
	let self.mode = 1
	if get(self.opts, 'center', 0) != 0
		call self.center()
	endif
	if self.hide == 0
		call popup_show(winid)
	endif
endfunc


"----------------------------------------------------------------------
" create window in nvim
"----------------------------------------------------------------------
function! s:window.__nvim_create()
	let opts = {'focusable':0, 'style':'minimal', 'relative':'editor'}
	let opts.row = self.y
	let opts.col = self.x
	let opts.width = self.w
	let opts.height = self.h
	let opts.focusable = get(self.opts, 'focusable', 0)
	if s:has_nvim_060
		let opts.noautocmd = 1
		let opts.zindex = self.z + 1
	endif
	let info = self.info
	let info.nvim_opts = opts
	let info.sim_border = 0
	let info.off_x = 0
	let info.off_y = 0
	let pad = self.opts.padding
	if info.has_border
		let info.sim_border = 1
		let info.off_x = 1
		let info.off_y = 1
		if info.has_padding
			let info.sim_border = 1
			let info.off_x += pad[3]
			let info.off_y += pad[0]
		endif
	endif
	if info.has_border
		let tw = info.tw
		let th = info.th
		let opts.col += info.off_x
		let opts.row += info.off_y
		let t = get(self.opts, 'title', '')
		let b = get(self.opts, 'button', 0)
		let border = self.opts.border
		let back = quickui#utils#make_border(tw - 2, th - 2, border, t, b)
		let info.border_bid = quickui#core#buffer_alloc()
		call quickui#core#buffer_update(info.border_bid, back)
		let op = {'relative':'editor', 'focusable':0, 'style':'minimal'}
		let op.focusable = get(self.opts, 'focusable', 0)
		let op.width = tw
		let op.height = th
		let op.col = self.x
		let op.row = self.y
		if s:has_nvim_060
			let op.noautocmd = 1
			let op.zindex = self.z
		endif
		let info.border_opts = op
		let init = []
		let init += ['setl tabstop=' . get(self.opts, 'tabstop', 4)]
		let init += ['setl signcolumn=no scrolloff=0 nowrap nonumber']
		let init += ['setl nocursorline nolist']
		if exists('+cursorlineopt')
			let init += ['setl cursorlineopt=both']
		endif
		let info.border_init = init
	endif
	let self.mode = 1
	if get(self.opts, 'center', 0) != 0
		call self.center()
	endif
	if self.hide == 0
		call self.__nvim_show()
	endif
endfunc


"----------------------------------------------------------------------
" nvim - show window
"----------------------------------------------------------------------
function! s:window.__nvim_show()
	if self.mode == 0
		return
	elseif self.winid >= 0
		return
	endif
	call self.move(self.x, self.y)
	let info = self.info
	let winid = nvim_open_win(self.bid, 0, info.nvim_opts)
	let self.winid = winid
	let color = self.opts.color
	call quickui#core#win_execute(winid, info.cmd)
	if len(info.pending_cmd) > 0
		call quickui#core#win_execute(winid, info.pending_cmd)
		let info.pending_cmd = []
	endif
    call nvim_win_set_option(self.winid, 'winhl', 'Normal:'. color)
	if info.has_border
		let bwid = nvim_open_win(info.border_bid, 0, info.border_opts)
		let info.border_winid = bwid
		call quickui#core#win_execute(bwid, info.border_init)
		call nvim_win_set_option(bwid, 'winhl', 'Normal:'. color)
	endif
	let self.hide = 0
endfunc


"----------------------------------------------------------------------
" nvim - hide window
"----------------------------------------------------------------------
function! s:window.__nvim_hide()
	if self.mode == 0
		return
	elseif self.winid < 0
		return
	endif
	let info = self.info
	if info.border_winid >= 0
		call nvim_win_close(info.border_winid, 1)
		let info.border_winid = -1
	endif
	if self.winid >= 0
		call nvim_win_close(self.winid, 1)
		let self.winid = -1
	endif
	let self.hide = 1
endfunc


"----------------------------------------------------------------------
" open window
"----------------------------------------------------------------------
function! s:window.open(textlist, opts)
	call self.close()
	call self.__prepare_opts(a:textlist, a:opts)
	if s:has_nvim == 0
		call self.__vim_create()
	else
		call self.__nvim_create()
	endif
	let self.mode = 1
endfunc



"----------------------------------------------------------------------
" close window
"----------------------------------------------------------------------
function! s:window.close()
	if self.winid >= 0
		if s:has_nvim == 0
			call popup_close(self.winid)
		else
			call nvim_win_close(self.winid, 1)
			if self.info.border_winid >= 0
				call nvim_win_close(self.info.border_winid, 1)
				let self.info.border_winid = -1
			endif
		endif
	endif
	let self.winid = -1
	if self.bid >= 0
		call quickui#core#buffer_free(self.bid)
		let self.bid = -1
	endif
	if has_key(self.info, 'border_bid')
		if self.info.border_bid >= 0
			call quickui#core#buffer_free(self.info.border_bid)
			let self.info.border_bid = -1
		endif
	endif
	let self.hide = 0
	let self.mode = 0
endfunc


"----------------------------------------------------------------------
" show the window
"----------------------------------------------------------------------
function! s:window.show(show)
	if self.mode == 0
		return
	elseif s:has_nvim == 0
		if a:show == 0
			if self.winid >= 0
				call popup_hide(self.winid)
			endif
		else
			if self.winid >= 0
				call popup_show(self.winid)
			endif
		endif
	else
		if a:show == 0
			call self.__nvim_hide()
		else
			call self.__nvim_show()
		endif
	endif
	let self.hide = (a:show == 0)? 1 : 0
endfunc


"----------------------------------------------------------------------
" move window
"----------------------------------------------------------------------
function! s:window.__move(x, y)
	let self.x = a:x
	let self.y = a:y
	if self.mode == 0
		return
	elseif s:has_nvim == 0
		if self.winid >= 0
			let opts = {}
			let opts.col = self.x + 1
			let opts.line = self.y + 1
			call popup_move(self.winid, opts)
		endif
	else
		let info = self.info
		let opts = info.nvim_opts
		let opts.col = self.x + info.off_x
		let opts.row = self.y + info.off_y
		if info.has_border != 0
			let opts = info.border_opts
			let opts.col = self.x
			let opts.row = self.y
		endif
		if self.winid >= 0
			let op = {'relative':'editor'}
			let op.col = info.nvim_opts.col
			let op.row = info.nvim_opts.row
			call nvim_win_set_config(self.winid, op)
		endif
		if info.has_border != 0
			if info.border_winid >= 0
				let op = {'relative':'editor'}
				let op.col = info.border_opts.col
				let op.row = info.border_opts.row
				call nvim_win_set_config(info.border_winid, op)
			endif
		endif
	endif
endfunc


"----------------------------------------------------------------------
" actual move
"----------------------------------------------------------------------
function! s:window.move(x, y)
	let x = a:x
	let y = a:y
	let w = self.info.tw
	let h = self.info.th
	let sw = &columns
	let sh = &lines
	let x = (x + w > sw)? (sw - w) : x
	let y = (y + h > sh)? (sh - h) : y
	let x = (x < 0)? 0 : x
	let y = (y < 0)? 0 : y
	" unsilent echom ['move', x, a:x, self.opts.x]
	call self.__move(x, y)
endfunc


"----------------------------------------------------------------------
" center window
"----------------------------------------------------------------------
function! s:window.center(...)
	let w = self.w
	let h = self.h
	let style = (a:0 < 1)? 0 : (a:1)
	if self.mode != 0
		let w = self.info.tw
		let h = self.info.th
	endif
	let x = (&columns - w) / 2
	if style == 0
		let height = &lines - &cmdheight - 1
		let middle = height * 38 / 100
		let y = middle - (h + 1) / 2
		let y = (y < 0)? 0 : y
	else
		let y = (&lines - h) / 2
		let limit1 = (&lines - 2) * 80 / 100
		let limit2 = (&lines - 2)
		if h + 8 < limit1
			let y = (limit1 - h) / 2
		else
			let y = (limit2 - h) / 2
		endif
	endif
	call self.move(x, y)
endfunc


"----------------------------------------------------------------------
" resize
"----------------------------------------------------------------------
function! s:window.resize(w, h)
	let self.w = a:w
	let self.h = a:h
	let info = self.info
	if self.mode == 0
		let info.tw = self.w
		let info.th = self.h
		return
	endif
	let pad = self.opts.padding
	let info.tw = self.w + pad[1] + pad[3]
	let info.th = self.h + pad[0] + pad[2]
	let info.tw += (info.has_border? 2 : 0)
	let info.th += (info.has_border? 2 : 0)
	if self.winid < 0 
		return
	endif
	if s:has_nvim == 0
		let opts = {}
		let opts.minwidth = self.w
		let opts.maxwidth = self.w
		let opts.minheight = self.h
		let opts.maxheight = self.h
		call popup_move(self.winid, opts)
	else
		let opts = info.nvim_opts
		let opts.width = self.w
		let opts.height = self.h
		if info.has_border
			let opts = info.border_opts
			let opts.width = info.tw
			let opts.height = info.th
			let t = get(self.opts, 'title', '')
			let b = self.opts.border
			let tw = info.tw
			let th = info.th
			let btn = get(self.opts, 'button', 0)
			let back = quickui#utils#make_border(tw - 2, th - 2, b, t, btn)
			call quickui#core#buffer_update(info.border_bid, back)
		endif
		if self.winid >= 0
			let op = {'width':self.w, 'height':self.h}
			call nvim_win_set_config(self.winid, op)
			if info.has_border
				if info.border_winid >= 0
					let op = {'width':info.tw, 'height':info.th}
					call nvim_win_set_config(info.border_winid, op)
				endif
			endif
		endif
	endif
endfunc


"----------------------------------------------------------------------
" execute commands
"----------------------------------------------------------------------
function! s:window.execute(cmdlist)
	if type(a:cmdlist) == v:t_string
		let cmd = split(a:cmdlist, '\n')
	else
		let cmd = a:cmdlist
	endif
	let winid = self.winid
	if winid >= 0
		let pc = self.info.pending_cmd
		if len(pc) > 0
			call quickui#core#win_execute(winid, pc)
			let self.info.pending_cmd = []
		endif
		if len(cmd) > 0
			call quickui#core#win_execute(winid, cmd)
		endif
	else
		if !has_key(self.info, 'pending_cmd')
			let self.info.pending_cmd = cmd
		else
			let self.info.pending_cmd += cmd
		endif
	endif
endfunc


"----------------------------------------------------------------------
" update text in buffer
"----------------------------------------------------------------------
function! s:window.update()
	if self.bid >= 0
		call quickui#core#buffer_update(self.bid, self.text)
	endif
endfunc


"----------------------------------------------------------------------
" set content
"----------------------------------------------------------------------
function! s:window.set_text(textlist)
	if type(a:textlist) == v:t_list
		let textlist = deepcopy(a:textlist)
	else
		let textlist = split(a:textlist, '\n', 1)
	endif
	let self.text = textlist
	call self.update()
endfunc


"----------------------------------------------------------------------
" set line
"----------------------------------------------------------------------
function! s:window.set_line(index, text, ...)
	let require = a:index + 1
	let refresh = (a:0 < 1)? 1 : (a:1)
	let index = a:index
	let update = 0
	if index < 0
		return
	elseif len(self.text) < require
		let self.text += repeat([''], require - len(self.text))
		let update = 1
	endif
	let self.text[a:index] = a:text
	if update != 0
		call self.update()
	elseif refresh != 0
		let bid = self.bid
		if bid >= 0
			call setbufvar(bid, '&modifiable', 1)
			call setbufline(bid, index + 1, [a:text])
			call setbufvar(bid, '&modified', 0)
		endif
	endif
endfunc


"----------------------------------------------------------------------
" get line
"----------------------------------------------------------------------
function! s:window.get_line(index)
	if a:index >= len(self.text)
		return ''
	endif
	return self.text[a:index]
endfunc


"----------------------------------------------------------------------
" syntax begin
"----------------------------------------------------------------------
function! s:window.syntax_begin(...)
	let info = self.info
	let info.syntax_cmd = ['syn clear']
	let info.syntax_mod = (a:0 < 1)? 1 : (a:1)
endfunc


"----------------------------------------------------------------------
" flush commands
"----------------------------------------------------------------------
function! s:window.syntax_end()
	let info = self.info
	if has_key(info, 'syntax_cmd') != 0
		if len(info.syntax_cmd) > 0
			call self.execute(info.syntax_cmd)
			let info.syntax_cmd = []
		endif
	endif
endfunc


"----------------------------------------------------------------------
" calculate region
"----------------------------------------------------------------------
function! s:window.syntax_region(color, x1, y1, x2, y2)
	let info = self.info
	if a:y1 == a:y2 && a:x1 >= a:x2
		return
	elseif has_key(info, 'syntax_cmd') != 0
		let x1 = a:x1 + 1
		let y1 = a:y1 + 1
		let x2 = a:x2 + 1
		let y2 = a:y2 + 1
		let cc = a:color
		let mm = info.syntax_mod
		let cmd = quickui#core#high_region(cc, y1, x1, y2, x2, mm)
		let info.syntax_cmd += [cmd]
		" echom cmd
	endif
endfunc


"----------------------------------------------------------------------
" click window
"----------------------------------------------------------------------
function! s:window.mouse_click()
	let winid = self.winid
	let retval = {'x':-1, 'y':-1}
	if g:quickui#core#has_nvim == 0
		let pos = getmousepos()
		if pos.winid != winid
			return retval
		endif
		if self.info.has_border == 0
			let retval.x = pos.column - 1
			let retval.y = pos.line - 1
		else
			let retval.x = pos.column - 2
			let retval.y = pos.line - 2
		endif
	else
		if v:mouse_winid != winid
			return retval
		endif
		if self.info.has_border == 0
			let retval.x = v:mouse_col - 1
			let retval.y = v:mouse_lnum - 1
		else
			let retval.x = v:mouse_col - 2
			let retval.y = v:mouse_lnum - 2
		endif
	endif
	return retval
endfunc


"----------------------------------------------------------------------
" refresh redraw
"----------------------------------------------------------------------
function! s:window.refresh()
	let winid = self.winid
	if g:quickui#core#has_nvim == 0
		if winid >= 0
			call popup_setoptions(winid, {})
		endif
	else
	endif
	redraw
endfunc


"----------------------------------------------------------------------
" constructor
"----------------------------------------------------------------------
function! quickui#window#new()
	let obj = deepcopy(s:window)
	return obj
endfunc


