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
" locals
"----------------------------------------------------------------------
let s:keymaps = '123456789abcdefimnopqrstuvwxyz'


"----------------------------------------------------------------------
" 
"----------------------------------------------------------------------
function! quickui#tools#buffer_switch(bid)
	let code = g:quickui#listbox#current.input
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
	let opts.keymap["\<c-e>"] = 'INPUT-1'
	let opts.keymap["\<c-]>"] = 'INPUT-2'
	let opts.keymap["\<c-t>"] = 'INPUT-3'
	let opts.keymap["\<c-g>"] = 'INPUT-4'
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
" display the command result in the textbox
"----------------------------------------------------------------------
function! quickui#tools#command_box(cmd, opts)
	let text = quickui#utils#system(a:cmd)
	let linelist = []
	for line in split(text, "\n")
		let line = trim(line, "\r")
		let linelist += [line]
	endfor
	call quickui#textbox#open(linelist, a:opts)
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
	call quickui#tools#command_box(cmd, opts)
endfunc


