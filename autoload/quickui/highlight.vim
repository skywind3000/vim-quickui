"======================================================================
"
" highlight.vim - 
"
" Created by skywind on 2021/12/12
" Last Modified: 2021/12/13 18:32
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:has_hlget = exists('*hlget')? 1 : 0
let s:has_hlset = exists('*hlset')? 1 : 0


"----------------------------------------------------------------------
" get highlighting group
"----------------------------------------------------------------------
function! s:sim_hlget(name)
	let error = 0
	redir => g:quickui_highlight_tmp
	try
		exec 'silent hi ' . a:name
	catch
		let error = 1
	endtry
	redir END
	if error != 0
		return []
	endif
	let capture = g:quickui_highlight_tmp
	let items = []
	for text in split(capture, '\n')
		let text = quickui#core#string_strip(text)
		if text == ''
			continue
		endif
		let item = {}
		let item.name = matchstr(text, '^\w\+')
		if item.name == ''
			continue
		endif
		let parts = split(text, ' ')
		if empty(parts)
			continue
		endif
		if text =~ ' cleared$'
			let item.cleared = v:true
		elseif text =~ ' links to \w\+$'
			let links = matchstr(text, ' links to \zs\w\+$')
			let item.linksto = quickui#core#string_strip(links)
		else
			for part in parts[1:]
				if part =~ '\w\+='
					let key = matchstr(part, '^\w\+')
					let val = matchstr(part, '^\w\+=\zs\%(\\.\|\S\)*')
					if key == 'term' || key == 'cterm' || key == 'gui'
						let opts = {}
						for element in split(val, ',')
							let opts[element] = v:true
						endfor
						let item[key] = opts
					else
						let item[key] = val
					endif
				elseif part == 'cleared'
				endif
			endfor
		endif
		let items += [item]
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" simulate hlset
"----------------------------------------------------------------------
function! s:sim_hlset(items)
	let skip = {'name':1, 'id':1, 'linksto':1, 'force':1}
	for item in a:items
		let name = get(item, 'name', '')
		if name == ''
			continue
		endif
		let force = get(item, 'force', v:false)
		let cmd = (force == 0)? 'hi ' : 'hi! '
		if get(item, 'cleared', v:false) == v:true
			exec cmd . 'clear ' . name
		else
			let part = []
			for key in keys(item)
				if has_key(skip, key) == 0
					let val = item[key]
					if type(val) == v:t_dict
						let r = join(keys(val), ',')
					else
						let r = val
					endif
					let part += [key . '=' . r]
				endif
			endfor
			let text = cmd . ' ' . name . ' ' . join(part, ' ')
			exec text
		endif
	endfor
endfunc


"----------------------------------------------------------------------
" get highlighting info
"----------------------------------------------------------------------
function! quickui#highlight#get(name, ...)
	let resolve = (a:0 > 0)? (a:1) : 0
	if s:has_hlget
		" return hlget(a:name, resolve)
	endif
	if !resolve
		return s:sim_hlget(a:name)
	endif
	let items = []
	for item in s:sim_hlget(a:name)
		if has_key(item, 'linksto') == 0
			let items += [item]
			continue
		endif
		let info = item
		while 1
			if has_key(info, 'linksto') == 0
				break
			endif
			let links = info.linksto
			let hr = s:sim_hlget(links)
			if empty(hr)
				break
			endif
			let info = hr[0]
		endwhile
		let info.name = item.name
		let items += [info]
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" set highlight group
"----------------------------------------------------------------------
function! quickui#highlight#set(items)
	if s:has_hlset
		" return hlset(a:items)
	endif
	call s:sim_hlset(a:items)
endfunc


"----------------------------------------------------------------------
" clear highlight
"----------------------------------------------------------------------
function! quickui#highlight#clear(name)
	if s:has_hlset
		let info = {'name': a:name, 'cleared': v:true}
		call hlset([info])
	else
		exec 'hi! clear ' . a:name
	endif
endfunc


"----------------------------------------------------------------------
" term add feature
"----------------------------------------------------------------------
function! quickui#highlight#term_add(info, what)
	let info = a:info
	let what = a:what
	if has_key(info, 'term')
		if type(info.term) == v:t_dict
			let info.term[what] = v:true
		elseif type(info.term) == v:t_string
			let opts = {}
			for key in split(info.term, ',')
				let opts[key] = v:true
			endfor
			let opts[what] = v:true
			let info.term = opts
		endif
	else
		let info.term = {}
		let info.term[what] = v:true
	endif
endfunc


"----------------------------------------------------------------------
" cterm add feature
"----------------------------------------------------------------------
function! quickui#highlight#cterm_add(info, what)
	let info = a:info
	let what = a:what
	if has_key(info, 'cterm')
		if type(info.cterm) == v:t_dict
			let info.cterm[what] = v:true
		elseif type(info.cterm) == v:t_string
			let opts = {}
			for key in split(info.cterm, ',')
				let opts[key] = v:true
			endfor
			let opts[what] = v:true
			let info.cterm = opts
		endif
	else
		let info.cterm = {}
		let info.cterm[what] = v:true
	endif
endfunc


"----------------------------------------------------------------------
" gui add feature
"----------------------------------------------------------------------
function! quickui#highlight#gui_add(info, what)
	let info = a:info
	let what = a:what
	if has_key(info, 'gui')
		if type(info.gui) == v:t_dict
			let info.gui[what] = v:true
		elseif type(info.gui) == v:t_string
			let opts = {}
			for key in split(info.gui, ',')
				let opts[key] = v:true
			endfor
			let opts[what] = v:true
			let info.gui = opts
		endif
	else
		let info.gui = {}
		let info.gui[what] = v:true
	endif
endfunc


"----------------------------------------------------------------------
" new underline
"----------------------------------------------------------------------
function! quickui#highlight#grant_underline(info)
	let info = a:info
	call quickui#highlight#term_add(info, 'underline')
	call quickui#highlight#cterm_add(info, 'underline')
	call quickui#highlight#gui_add(info, 'underline')
	return info
endfunc


"----------------------------------------------------------------------
" add colors
"----------------------------------------------------------------------
function! quickui#highlight#grant_color(info, colors)
	for key in keys(a:colors)
		let a:info[key] = a:colors[key]
	endfor
	return a:info
endfunc


"----------------------------------------------------------------------
" add underline feature
"----------------------------------------------------------------------
function! quickui#highlight#make_underline(newname, name)
	let hr = quickui#highlight#get(a:name, 1)
	if len(hr) == 0
		return -1
	endif
	let info = (len(hr) == 0)? {} : hr[0]
	call quickui#highlight#term_add(info, 'underline')
	call quickui#highlight#cterm_add(info, 'underline')
	call quickui#highlight#gui_add(info, 'underline')
	if has_key(info, 'id')
		unlet info['id']
	endif
	let info.name = a:newname
	let info.force = v:true
	call quickui#highlight#set([info])
	return info
endfunc



"----------------------------------------------------------------------
" combine foreground and background colors
"----------------------------------------------------------------------
function! quickui#highlight#overlay(newname, background, foreground)
	let hr1 = quickui#highlight#get(a:background, 1)
	let hr2 = quickui#highlight#get(a:foreground, 1)
	let info1 = empty(hr1)? {} : hr1[0]
	let info2 = empty(hr2)? {} : hr2[0]
	for key in ['ctermfg', 'guifg']
		if has_key(info2, key)
			let info1[key] = info2[key]
		endif
	endfor
	let info1.name = a:newname
	let info1.force = v:true
	call quickui#highlight#set([info1])
endfunc


