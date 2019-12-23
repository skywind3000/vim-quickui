"======================================================================
"
" core.vim - 
"
" Created by skywind on 2019/12/18
" Last Modified: 2019/12/18 15:58:00
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" core routines
"----------------------------------------------------------------------

" replace string
function! quickui#core#string_replace(text, old, new)
	let l:data = split(a:text, a:old, 1)
	return join(l:data, a:new)
endfunc

" eval & expand: '%{script}' in string
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


