"======================================================================
"
" main.vim - 
"
" Created by skywind on 2022/08/24
" Last Modified: 2022/08/24 20:24:47
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" extension map
"----------------------------------------------------------------------
let g:quickui = get(g:, 'quickui', {})
let s:quickui = {}


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:private = {}
let s:private.quickui = {}


"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
function! s:init()
	let quickui = {}
	for key in keys(s:quickui)
		let quickui[key] = s:quickui[key]
	endfor
	for key in keys(g:quickui)
		let quickui[key] = g:quickui[key]
	endfor
	let names = keys(quickui)
	call sort(names)
	let s:private.quickui = quickui
	let s:private.names = names
endfunc


"----------------------------------------------------------------------
" help
"----------------------------------------------------------------------
function! s:help(opts, argv)
endfunc


"----------------------------------------------------------------------
" list extension
"----------------------------------------------------------------------
function! s:list(opts, argv)
	let rows = []
	let highmap = {}
	let index = 1
	let rows += [['Extension', 'Help']]
	let highmap['0,0'] = 'Title'
	let highmap['0,1'] = 'Title'
	for name in s:private.names
		let help = get(s:private.quickui[name], 'help', '')
		let rows += [[name, help]]
		let highmap[index . ',0'] = 'Keyword'
		let highmap[index . ',1'] = 'Statement'
		let index += 1
	endfor
	call quickui#utils#print_table(rows, highmap)
endfunc


"----------------------------------------------------------------------
" main cmd
"----------------------------------------------------------------------
function! quickui#command#run(bang, cmdline) abort
	let [cmdline, op1] = quickui#core#extract_opts(a:cmdline)
	let cmdline = quickui#core#string_strip(cmdline)
	let name = ''
	if cmdline =~# '^\w\+'
		let name = matchstr(cmdline, '^\w\+')
		let cmdline = substitute(cmdline, '^\w\+\s*', '', '')
	endif
	let name = quickui#core#string_strip(name)
	let [cmdline, op2] = quickui#core#extract_opts(cmdline)
	let op2.cmdline = quickui#core#string_strip(cmdline)
	let opts = deepcopy(op1)
	for k in keys(op2)
		let opts[k] = op2[k]
	endfor
	let argv = quickui#core#split_argv(cmdline)
	call s:init()
	if name == ''
		if has_key(op1, 'h')
			call s:help(opts, argv)
		elseif has_key(op1, 'l')
			call s:list(opts, argv)
		endif
		return 0
	endif
	if has_key(s:private.quickui, name) == 0
		call quickui#utils#errmsg('invalid extension name: ' . name)
		return -1
	endif
	let obj = s:private.quickui[name]
	if has_key(obj, 'run') == 0
		call quickui#utils#errmsg('not find "run" funcref in extension: ' . name)
		return -2
	endif
	let hr = call(obj.run, [opts, argv])
	return hr
endfunc



"----------------------------------------------------------------------
" command line completion
"----------------------------------------------------------------------
function! quickui#command#complete(ArgLead, CmdLine, CursorPos)
	let candidate = []
	call s:init()
	if a:ArgLead =~ '^-'
		let flags = ['-h', '-l']
		for flag in flags
			if stridx(flag, a:ArgLead) == 0
				let candidate += [flag]
			endif
		endfor
		return candidate
	endif
	for name in s:private.names
		if stridx(name, a:ArgLead) == 0
			let candidate += [name]
		endif
	endfor
	return candidate
endfunc


"----------------------------------------------------------------------
" sub: main menu
"----------------------------------------------------------------------
function! s:sub_menu(opts, argv) abort
	let argv = a:argv
	if len(argv) == 0
		call quickui#menu#open()
	else
		call quickui#menu#open(argv[0])
	endif
endfunc

let s:quickui.menu = {
			\ 'run': function('s:sub_menu'),
			\ 'help': 'open main menu',
			\ }


"----------------------------------------------------------------------
" sub: context menu
"----------------------------------------------------------------------
function! s:sub_context(opts, argv) abort
	let context = []
	if exists('g:quickui_context')
		for item in g:quickui_context
			let context += [item]
		endfor
	endif
	if exists('b:quickui_context')
		if !empty(context)
			let context += ['--']
		endif
		for item in b:quickui_context
			let context += [item]
		endfor
	endif
	if exists('g:quickui_context_foot')
		if !empty(context)
			let context += ['--']
		endif
		for item in g:quickui_context_foot
			let context += [item]
		endfor
	endif
	let opts = {}
	if !empty(context)
		call quickui#tools#clever_context('_', context, opts)
	endif
endfunc

let s:quickui.context = {
			\ 'run': function('s:sub_context'),
			\ 'help': 'open context menu',
			\ }


"----------------------------------------------------------------------
" sub: terminal
"----------------------------------------------------------------------
function! s:sub_terminal(opts, argv) abort
	let cmd = a:opts.cmdline
	" echom printf("cmd is '%s', type: %d", cmd, type(cmd))
	" echom a:opts
	return quickui#terminal#open(cmd, a:opts)
endfunc

let s:quickui.terminal = {
			\ 'run': function('s:sub_terminal'),
			\ 'help': 'open terminal window',
			\ }


