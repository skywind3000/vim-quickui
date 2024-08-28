"======================================================================
"
" tags.vim - 
"
" Created by skywind on 2020/01/07
" Last Modified: 2024/03/23 21:14
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :

"----------------------------------------------------------------------
" wrapping of vim's taglist()
"----------------------------------------------------------------------
function! quickui#tags#taglist(pattern)
    let ftags = []
    try
        let ftags = taglist(a:pattern)
    catch /^Vim\%((\a\+)\)\=:E/
        " if error occured, reset tagbsearch option and try again.
        let bak = &tagbsearch
        set notagbsearch
        let ftags = taglist(a:pattern)
        let &tagbsearch = bak
    endtry
	" take care ctags windows filename bug
	let win = has('win32') || has('win64') || has('win95') || has('win16')
	for item in ftags
		let name = get(item, 'filename', '')
		let item.baditem = 0
		if win != 0
			if stridx(name, '\\') >= 0
				let part = split(name, '\\', 1)
				let elem = []
				for n in part
					if n != ''
						let elem += [n]
					endif
				endfor
				let name = join(elem, '\')
				let item.filename = name
				if has_key(item, 'line') == 0
					if has_key(item, 'signature') == 0
						let kind = get(item, 'kind', '')
						if kind != 'p' && kind != 'f'
							let item.baditem = 1
						endif
					endif
				endif
			end
		endif
	endfor
    return ftags
endfunc


"----------------------------------------------------------------------
" easy tagname
"----------------------------------------------------------------------
function! quickui#tags#tagfind(tagname)
	let pattern = escape(a:tagname, '[\*~^')
	let result = quickui#tags#taglist("^". pattern . "$")
	if type(result) == 0 || (type(result) == 3 && result == [])
		if pattern !~ '^\(catch\|if\|for\|while\|switch\)$'
			let result = quickui#tags#taglist('::'. pattern .'$')
		endif
	endif
	if type(result) == 0 || (type(result) == 3 && result == [])
		return []
	endif
	let final = []
	let check = {}
	for item in result
		if item.baditem != 0
			continue
		endif
		" remove duplicated tags
		let signature = get(item, 'name', '') . ':'
		let signature .= get(item, 'cmd', '') . ':'
		let signature .= get(item, 'kind', '') . ':'
		let signature .= get(item, 'line', '') . ':'
		let signature .= get(item, 'filename', '')
		if !has_key(check, signature)
			let final += [item]
			let check[signature] = 1
		endif
	endfor
	return final
endfunc


"----------------------------------------------------------------------
" function signature
"----------------------------------------------------------------------
function! quickui#tags#signature(funname, fn_only, filetype)
	let tags = quickui#tags#tagfind(a:funname)
    let funpat = escape(a:funname, '[\*~^')
	let fill_tag = []
	let ft = (a:filetype == '')? &filetype : a:filetype
	for i in tags
		if !has_key(i, 'name')
			continue
		endif
		if has_key(i, 'language')
		endif
		if has_key(i, 'filename') && ft != '*'
			let ename = tolower(fnamemodify(i.filename, ':e'))
			let c = ['c', 'cpp', 'cc', 'cxx', 'h', 'hpp', 'hh', 'm', 'mm']
			if index(['c', 'cpp', 'objc', 'objcpp'], ft) >= 0
				if index(c, ename) < 0
					continue
				endif
			elseif ft == 'python'
				if index(['py', 'pyw'], ename) < 0
					continue
				endif
			elseif ft == 'java' && ename != 'java'
				continue
			elseif ft == 'ruby' && ename != 'rb'
				continue
			elseif ft == 'vim' && ename != 'vim'
				continue
			elseif ft == 'cs' && ename != 'cs'
				continue
			elseif ft == 'php' 
				if index(['php', 'php4', 'php5', 'php6'], ename) < 0
					continue
				endif
			elseif ft == 'javascript'
				if index(['html', 'js', 'html5', 'xhtml', 'php'], ename) < 0
					continue
				endif
			endif
		endif
		if has_key(i, 'kind')
			" p: prototype/procedure; f: function; m: member
			if (a:fn_only == 0 || (i.kind == 'p' || i.kind == 'f') ||
						\ (i.kind == 'm' && has_key(i, 'cmd') &&
						\		match(i.cmd, '(') != -1)) &&
						\ i.name =~ funpat
				if ft != 'cpp' || !has_key(i, 'class') ||
							\ i.name !~ '::' || i.name =~ i.class
					let fill_tag += [i]
				endif
			endif
		else
			if a:fn_only == 0 && i.name == a:funname
				let fill_tag += [i]
			endif
		endif
	endfor
	let res = []
	let check = {}
	for i in fill_tag
		if has_key(i, 'kind') && has_key(i, 'signature')
			if i.cmd[:1] == '/^' && i.cmd[-2:] == '$/'
				let tmppat = substitute(escape(i.name,'[\*~^'),
							\ '^.*::','','')
				if ft == 'cpp'
					let tmppat = substitute(tmppat,'\<operator ',
								\ 'operator\\s*','')
					let tmppat=tmppat . '\s*(.*'
					let tmppat='\([A-Za-z_][A-Za-z_0-9]*::\)*'.tmppat
				else
					let tmppat=tmppat . '\>.*'
				endif
				let name = substitute(i.cmd[2:-3],tmppat,'','').
							\ i.name . i.signature
				if i.kind == 'm'
					if has_key(i, 'class')
						let name = name . ' <-- class ' . i.class
					elseif has_key(i, 'struct')
						let name = name . ' <-- struct ' . i.struct
					elseif has_key(i, 'union')
						let name = name . ' <-- union ' . i.union
					endif
				endif
			else
				let name = i.name . i.signature
				if has_key(i, 'kind') && match('fm', i.kind) >= 0
					let sep = (ft == 'cpp' || ft == 'c')? '::' : '.'
					if has_key(i, 'class')
						let name = i.class . sep . name
					elseif has_key(i, 'struct')
						let name = i.struct . sep. name
					elseif has_key(i, 'union')
						let name = i.struct . sep. name
					endif
				endif
			endif
		elseif has_key(i, 'kind')
			if i.kind == 'd'
				let name = 'macro '. i.name
			elseif i.kind == 'c'
				let name = ((ft == 'vim')? 'command ' : 'class '). i.name
			elseif i.kind == 's'
				let name = 'struct '. i.name
			elseif i.kind == 'u'
				let name = 'union '. i.name
			elseif (match('fpmvt', i.kind) != -1) &&
						\(has_key(i, 'cmd') && i.cmd[0] == '/')
				let tmppat = '\(\<'.i.name.'\>.\{-}\)'
				if index(['c', 'cpp', 'cs', 'java', 'javascript'], ft) >= 0
					" let tmppat = tmppat . ';.*'
				elseif ft == 'python' && (i.kind == 'm' || i.kind == 'f')
					let tmppat = tmppat . ':.*'
				elseif ft == 'tcl' && (i.kind == 'm' || i.kind == 'p')
					let tmppat = tmppat . '\({\)\?$'
				endif
				if i.kind == 'm' && &filetype == 'cpp'
					let tmppat=substitute(tmppat,'^\(.*::\)','\\(\1\\)\\?','')
				endif
				if match(i.cmd[2:-3], tmppat) != -1
					let name=substitute(i.cmd[2:-3], tmppat, '\1', '')
					if i.kind == 't' && name !~ '^\s*typedef\>'
						let name = 'typedef ' . i.name
					endif
				elseif i.kind == 't'
					let name = 'typedef ' . i.name
				elseif i.kind == 'v'
					let name = 'var ' . i.name
				else
					let name = i.name
				endif
				if i.kind == 'm'
					if has_key(i, 'class')
						let name = name . ' <-- class ' . i.class
					elseif has_key(i, 'struct')
						let name = name . ' <-- struct ' . i.struct
					elseif has_key(i, 'union')
						let name = name . ' <-- union ' . i.union
					endif
				endif
				let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
				if name[-1:] == ';'
					let name = name[0:-2]
				endif
			else
				let name = i.name
			endif
		else
			let name = i.name
		endif
		let name = substitute(name, '^\s\+', '', '')
		let name = substitute(name, '\s\+$', '', '')
		let name = substitute(name, '\s\+', ' ', 'g')
		let i.func_prototype = name
		let file_line = ''
		if has_key(i, 'filename')
			let file_line = fnamemodify(i.filename, ':t')
			if has_key(i, 'line')
				let file_line .= ':'. i.line
			elseif i.cmd > 0
				let file_line .= ':'. i.cmd
				if i.cmd =~ '^\s*\d\+\s*$'
					let i.line = str2nr(i.cmd)
				endif
			endif
		endif
		let i.file_line = file_line
		let res += [i]
	endfor
	let index = 1
	for i in res
		let name = i.func_prototype
		let file_line = i.file_line
		let desc = name. ' ('.index.'/'.len(res).') '.file_line
		let i.func_desc = desc
		let index += 1
	endfor
	return res
endfunc


"----------------------------------------------------------------------
" get function list
"----------------------------------------------------------------------
function! quickui#tags#ctags_function(bid, ft)
	let parameters = {
			\ "aspvbs": "--asp-kinds=f",
			\ "awk": "--awk-kinds=f",
			\ "c": "--c-kinds=fp --language-force=C",
			\ "cpp": "--c++-kinds=fp --language-force=C++",
			\ "cs": "--c#-kinds=m",
			\ "erlang": "--erlang-kinds=f",
			\ "fortran": "--fortran-kinds=f",
			\ "java": "--java-kinds=m",
			\ "javascript": "--javascript-kinds=f",
			\ "lisp": "--lisp-kinds=f",
			\ "lua": "--lua-kinds=f",
			\ "matla": "--matlab-kinds=f",
			\ "pascal": "--pascal-kinds=f",
			\ "php": "--php-kinds=f",
			\ "python": "--python-kinds=fm --language-force=Python",
			\ "ruby": "--ruby-kinds=fF",
			\ "scheme": "--scheme-kinds=f",
			\ "sh": "--sh-kinds=f",
			\ "sql": "--sql-kinds=f",
			\ "tcl": "--tcl-kinds=m",
			\ "verilog": "--verilog-kinds=f",
			\ "vim": "--vim-kinds=f --language-force=Vim",
			\ "go": "--go-kinds=f --language-force=Go",  
			\ "rust": "--rust-kinds=fPM",
			\ "ocaml": "--ocaml-kinds=mf", 
			\ "dosini": "--iniconf-kinds=s --language-force=iniconf",
			\ "taskini": "--iniconf-kinds=s --language-force=iniconf",
			\ "ini": "--iniconf-kinds=s --language-force=iniconf",
			\ }
	let ft = (a:ft != '')? a:ft : getbufvar(a:bid, '&ft')
	let modified = getbufvar(a:bid, '&modified')
	let ctags = get(g:, 'quickui_ctags_exe', 'ctags')
	let filename = bufname(a:bid)
	let extname = fnamemodify(filename, ':e')
	let extras  = get(get(g:, 'quickui_ctags_opts', {}), ft, get(parameters, ft, ''))
	let srcname = fnamemodify(filename, ':p')
	if modified || filename == ''
		if filename == '' || extname == ''
			let srcname = tempname()
		else
			let srcname = tempname() . '.' . extname
		endif
		let content = getbufline(a:bid, 1, '$')
		call writefile(content, srcname)
		unlet content
	endif
	if exists('g:quickui_tags_list')
		let extras = get(g:quickui_tags_list, ft, extras)
	endif
	let cmd = ctags . ' -n -u --fields=k ' . extras . ' -f- '
	let output = quickui#utils#system(cmd . '"' . srcname . '"')
	if modified
		call delete(srcname)
	endif
	let items = []
	for line in split(output, "\n")
		let line = substitute(line, '[\t\r\n ]*$', '', '')
		let item = split(line, "\t")
		if len(item) >= 4
			let ni = {}
			let ni.tag = item[0]    " tagname
			let ni.line = str2nr(substitute(item[2], '[;"\s]', '', 'g'))
			let ni.mode = substitute(item[3], '[\r\n\t ]*$', '', 'g')
			let ni.text = ''
			let code = getbufline(a:bid, ni.line)
			if len(code) == 1
				let x = code[0]
				let ni.text = substitute(x, '^\s*\(.\{-}\)\s*$', '\1', '')
			endif
			let items += [ni]
		endif
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" ctags vim help file
"----------------------------------------------------------------------
function! quickui#tags#ctags_vim_help(bid)
	let content = getbufline(a:bid, 1, '$')
	let tags = []
	let lnum = 0
	for text in content
		let lnum += 1
		let p1 = stridx(text, '*')
		if p1 < 0
			continue
		endif
		let p = matchstr(text, '\*\(\S\+\)\*')
		if p == ''
			continue
		endif
		let tag = {}
		let tag.tag = p
		let tag.line = lnum
		let sp = substitute(text, '^\s*\(.\{-}\)\s*$', '\1', '')
		let tag.text = tr(sp, "\t", ' ')
		let tag.mode = 't'
		call add(tags, tag)
	endfor
	return tags
endfunc


"----------------------------------------------------------------------
" query function list
"----------------------------------------------------------------------
function! quickui#tags#function_list(bid, ft)
	let changedtick = getbufvar(a:bid, 'changedtick')
	let currenttick = getbufvar(a:bid, '__quickui_tags_tick', -100)
	let start = reltime()
	if currenttick != changedtick
		if &ft != 'help'
			let items = quickui#tags#ctags_function(a:bid, a:ft)
		else
			let items = quickui#tags#ctags_vim_help(a:bid)
		endif
		call setbufvar(a:bid, '__quickui_tags_func', items)
		call setbufvar(a:bid, '__quickui_tags_tick', changedtick)
	endif
	let items = getbufvar(a:bid, '__quickui_tags_func')
	if type(items) == v:t_string
		let items = quickui#tags#ctags_function(a:bid, a:ft)
		call setbufvar(a:bid, '__quickui_tags_func', items)
		call setbufvar(a:bid, '__quickui_tags_tick', changedtick)
	endif
	let g:quickui#tags#elapse = reltimestr(reltime(start))
	" echo g:quickui#tags#elapse
	if a:ft == 'python'
		let output = []
		for ni in items
			if ni.mode == 'f'
				if ni.text =~ '\v<lambda>\s.*\:\s*\S+'
					continue
				endif
			endif
			let output += [ni]
		endfor
		return output
	endif
	return items
endfunc



