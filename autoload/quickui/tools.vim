"======================================================================
"
" tools.vim - 
"
" Created by skywind on 2019/12/23
" Last Modified: 2019/12/23 21:22:46
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" list buffer ids
"----------------------------------------------------------------------
function! s:buffer_list()
    redir => buflist
    silent! ls
    redir END
    let bids = []
    for curline in split(buflist, '\n')
        if curline =~ '^\s*\d\+'
            let bid = str2nr(matchstr(curline, '^\s*\zs\d\+'))
            let bids += [bid]
        endif
    endfor
    return bids
endfunc


"----------------------------------------------------------------------
" get default width
"----------------------------------------------------------------------
function! s:get_tools_width()
	let width = get(g:, 'quickui_tools_width', 70)
endfunc


"----------------------------------------------------------------------
" locals
"----------------------------------------------------------------------
let s:keymaps = '123456789abcdefimnopqrstuvwxyz'


"----------------------------------------------------------------------
" switch buffer callback
"----------------------------------------------------------------------
function! quickui#tools#buffer_switch(bid)
	let code = g:quickui#listbox#current.tag
	let name = fnamemodify(bufname(a:bid), ':p')
	if code == ''
		exec s:switch . ' '. fnameescape(name)
	elseif code == '1'
		exec 'b '. a:bid
	elseif code == '2'
		exec 'vs '. fnameescape(name)
	elseif code == '3'
		exec 'tabe '. fnameescape(name)
	elseif code == '4'
		exec 'FileSwitch tabe ' . fnameescape(name)
	endif
endfunc


"----------------------------------------------------------------------
" get content
"----------------------------------------------------------------------
function! quickui#tools#list_buffer(switch)
	let bids = s:buffer_list()
	let content = []
	let index = 0
	let current = -1
	let bufnr = bufnr()
	let s:switch = a:switch
	for bid in bids
		let key = (index < len(s:keymaps))? strpart(s:keymaps, index, 1) : ''
		let text = '[' . ((key == '')? ' ' : ('&' . key)) . "]\t"
		let text .= "\t"
		let name = fnamemodify(bufname(bid), ':p')
		let main = fnamemodify(name, ':t')
		let path = fnamemodify(name, ':h')
		let buftype = getbufvar(bid, '&buftype')
		if main == ''
			continue
		elseif buftype == 'nofile' || buftype == 'quickfix'
			continue
		endif
		let text = text . main . " " . "(" . bid . ")\t" . path
		let cmd = 'call quickui#tools#buffer_switch(' . bid . ')'
		if a:switch != ''
			" let cmd = a:switch . ' ' . fnameescape(name)
		endif
		let content += [[text, cmd]]
		if bid == bufnr()
			let current = index
		endif
		let index += 1
	endfor
	let opts = {'title': 'Switch Buffer', 'index':current, 'close':'button'}
	let opts.border = g:quickui#style#border
	let opts.keymap = {}
	let opts.keymap["\<c-e>"] = 'TAG:1'
	let opts.keymap["\<c-]>"] = 'TAG:2'
	let opts.keymap["\<c-t>"] = 'TAG:3'
	let opts.keymap["\<c-g>"] = 'TAG:4'
	if exists('g:quickui_tools_width')
		let opts.w = quickui#utils#tools_width()
	endif
	" let opts.syntax = 'cpp'
	let maxheight = (&lines) * 60 / 100
	if len(content) > maxheight
		let opts.h = maxheight
	endif
	if len(content) == 0
		redraw
		echohl ErrorMsg
		echo "Empty buffer list"
		echohl None
		return -1
	endif
	call quickui#listbox#open(content, opts)
endfunc


"----------------------------------------------------------------------
" list function
"----------------------------------------------------------------------
function! quickui#tools#list_function()
	let ctags = get(g:, 'quickui_ctags_exe', 'ctags')
	if !executable(ctags)
		let msg = 'Not find ctags, add to $PATH or specify in '
		call quickui#utils#errmsg(msg . 'g:quickui_ctags_exe')
		return -1
	endif
	let items = quickui#tags#function_list(bufnr(), &ft)
	if len(items) == 0
		call quickui#utils#errmsg('No content !')
		return -2
	endif
	let content = []
	let cursor = -1
	let index = 0
	let ln = line('.')
	let maxsize = (&columns) * 60 / 100
	let maxheight = (&lines) * 60 / 100
	let maxwidth = 0
	for item in items
		if ln >= item.line
			let cursor = index
		endif
		let index += 1
		let text = '' . item.mode . '' . "   \t" . item.text
		let text = text . '  [:' . item.line . ']'
		let maxwidth = (maxwidth < len(text))? len(text) : maxwidth
		let text = substitute(text, '&', '&&', 'g')
		let content += [[text, ':' . item.line]]
	endfor
	let opts = {'title': 'Function List', 'close':'button'}
	if cursor >= 0
		let opts.index = cursor
	endif
	let limit = &columns * 90 / 100
	let opts.h = len(content)
	let opts.h = (opts.h < maxheight)? opts.h : maxheight
	let opts.w = (maxwidth < limit)? maxwidth : limit
	if opts.w < maxsize
		let opts.w = (opts.w < 60)? 60 : opts.w
	endif
	if exists('g:quickui_tools_width')
		let opts.w = quickui#utils#tools_width()
	endif
	" let content += ["1\t".repeat('0', 100)]
	call quickui#listbox#open(content, opts)
	return 0
endfunc


"----------------------------------------------------------------------
" preview register in popup and choose to paste
"----------------------------------------------------------------------
function! quickui#tools#list_register()
endfunc


"----------------------------------------------------------------------
" display python help in the textbox
"----------------------------------------------------------------------
function! quickui#tools#python_help(word)
	let python = get(g:, 'quickui_tools_python', '')
	if python == ''
		if executable('python')
			let python = 'python'
		elseif executable('python3')
			let python = 'python3'
		elseif executable('python2')
			let python = 'python2'
		endif
	endif
	let cmd = python . ' -m pydoc ' . shellescape(a:word)
	let title = 'PyDoc <'. a:word . '>'
	let opts = {'title':title}
	let opts.color = 'QuickBG'
	let opts.bordercolor = 'QuickBG'
	let opts.tabstop = 12
	call quickui#textbox#command(cmd, opts)
endfunc


"----------------------------------------------------------------------
" display messages
"----------------------------------------------------------------------
function! quickui#tools#display_messages()
	let x = ''
	redir => x
	silent! messages
	redir END
	let x = substitute(x, '[\n\r]\+\%$', '', 'g')
	let content = filter(split(x, "\n"), 'v:key != ""')
	if len(content) == 0
		call quickui#utils#errmsg('Empty messages')
		return -1
	endif
	let opts = {"close":"button", "title":"Vim Messages"}
	if exists('g:quickui_tools_width')
		let opts.w = quickui#utils#tools_width()
	endif
	call quickui#textbox#open(content, opts)
endfunc


"----------------------------------------------------------------------
" preview quickfix
"----------------------------------------------------------------------
function! quickui#tools#preview_quickfix(...)
	if quickui#preview#visible()
		call quickui#preview#close()
		return 0
	endif
	if &bt != 'quickfix'
		call quickui#utils#errmsg('Not in quickfix window !')
		return -1
	endif
	if !exists('b:__quickui_qf__')
		let b:__quickui_qf__ = {}
	endif
	let obj = b:__quickui_qf__
	if !has_key(obj, 'version')
		let obj.version = -1
	endif
	if b:changedtick != obj.version
		let obj.items = getqflist()
		let obj.version = b:changedtick
	endif
	let index = (a:0 > 0)? a:1 : line('.')
	if index < 1 || index > len(obj.items)
		call quickui#utils#errmsg('No information in this line')
		return -2
	endif
	let item = obj.items[index - 1]
	if item.valid == 0
		return -3
	endif
	if item.bufnr <= 0
		return -4
	endif
	let name = bufname(item.bufnr)
	call quickui#preview#open(name, item.lnum)
	" echom 'lnum:'. item.lnum
endfunc


"----------------------------------------------------------------------
" preview tag
"----------------------------------------------------------------------
function! quickui#tools#preview_tag(tagname)
	let tagname = (a:tagname == '')? expand('<cword>') : a:tagname
	if tagname == ''
		call quickui#utils#errmsg('Error: empty tagname')
		return 0
	endif
	let obj = quickui#core#object()
	let reuse = 0
	if has_key(obj, 'ptag')
		let ptag = obj.ptag
		if get(ptag, 'tagname', '') == tagname
			let reuse = 1
		endif
	endif
	if reuse == 0
		let obj.ptag = {}
		let ptag = obj.ptag
		let ptag.taglist = quickui#tags#tagfind(tagname)
		let ptag.tagname = tagname
		let ptag.index = 0
	else
		let ptag = obj.ptag
		let ptag.index += 1
		if ptag.index >= len(ptag.taglist)
			let ptag.index = 0
		endif
	endif
	if len(ptag.taglist) == 0
		call quickui#utils#errmsg('E257: preview: tag not find "' . a:tagname . '"')
		return 1
	endif
	if ptag.index >= len(ptag.taglist) || ptag.index < 0
		let ptag.index = 0
	endif
	let taginfo = ptag.taglist[ptag.index]
	let filename = taginfo.filename
	if !filereadable(filename)
		call quickui#utils#errmsg('E484: Can not open file '.filename)
		return 2
	endif
	if !has_key(taginfo, 'line')
		call quickui#utils#errmsg('Error: no "line" information in your tags, regenerate with -n')
		return 3
	endif
	call quickui#preview#open(filename, taginfo.line)
	let text = taginfo.name
	let text.= ' ('.(ptag.index + 1).'/'.len(ptag.taglist).') '
	let text.= filename
	if has_key(taginfo, 'line')
		let text .= ':'.taginfo.line
	endif
	call quickui#utils#print(text, 1)
	return 0
endfunc


"----------------------------------------------------------------------
" display vim help in popup
"----------------------------------------------------------------------
function! quickui#tools#display_help(tag)
	if !exists('s:help_tags')
		let fn = expand('$VIMRUNTIME/doc/tags')
		if filereadable(fn)
			let content = readfile(fn)
			let s:help_tags = {}
			for line in content
				let parts = split(line, "\t")
				if len(parts) >= 3
					let s:help_tags[parts[0]] = [parts[1], parts[2]]
				endif
			endfor
		endif
	endif
	if !exists('s:help_tags')
		call quickui#utils#errmsg('Sorry, not find help tags in $VIMRUNTIME')
		return -1
	endif
	if !has_key(s:help_tags, a:tag)
		call quickui#utils#errmsg('E149: Sorry, no help for '. a:tag)
		return -2
	endif
	let item = s:help_tags[a:tag]
	let name = expand($VIMRUNTIME . '/doc/' . item[0])
	let command = substitute(item[1], '\*', '', 'g')
	if !filereadable(name)
		call quickui#utils#errmsg('E484: Sorry, cannot open file '.name)
		return -3
	endif
	let content = readfile(name)
	let opts = {'syntax':'help', 'color':'QuickPreview', 'close':'button'}
	let opts.title = 'Help: ' . fnamemodify(name, ':t')
	let g:quickui#tools#hint = item[1]
	let opts.command = ['silent! exec g:quickui#tools#hint']
	let opts.command += ["exec 'nohl'"]
	let opts.command += ["normal zz"]
	let opts.w = 80
	" echom opts
	let winid = quickui#textbox#open(content, opts)
	return 0
endfunc



