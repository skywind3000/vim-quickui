"======================================================================
"
" menu.vim - main menu bar
"
" Created by skywind on 2019/12/24
" Last Modified: 2019/12/24 10:41:13
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" global
"----------------------------------------------------------------------
let s:menucfg = {}


"----------------------------------------------------------------------
" register entry: (section='File', entry='&Save', command='w')
"----------------------------------------------------------------------
function! quickui#menu#register(section, entry, command, help)
	if !has_key(s:menucfg, a:section)
		let index = 0
		let maximum = 0
		for name in keys(s:menucfg)
			let w = s:menucfg[name].weight
			let maximum = (index == 0)? w : ((maximum < w)? w : maximum)
			let index += 1
		endfor
		let s:menucfg[a:section] = {'name':a:section, 'weight':0, 'items':[]}
		let s:menucfg[a:section].weight = maximum + 100
	endif
	let menu = s:menucfg[a:section]
	let item = {'name':a:entry, 'command':a:command, 'help':a:help}
	let menu.items += [item]
endfunc


"----------------------------------------------------------------------
" remove entry:
"----------------------------------------------------------------------
function! quickui#menu#remove(section, index)
	if !has_key(s:menucfg, a:section)
		return -1
	endif
	let menu = s:menucfg[a:section]
	if type(a:index) == v:t_number
		let index = (a:index < 0)? (len(menu.items) + a:index) : a:index
		if index < 0 || index >= len(menu.items)
			return -1
		endif
		call remove(menu.items, index)
	elseif type(a:index) == v:t_string
		if a:index ==# '*'
			menu.items = []
		else
			let index = -1
			for ii in range(len(menu.items))
				if menu.items[ii].name ==# a:index
					let index = ii
					break
				endif
			endfor
			if index < 0 
				return -1
			endif
			call remove(menu.items, index)
		endif
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" return items key 
"----------------------------------------------------------------------
function! quickui#menu#section(section)
	return get(s:menucfg, a:section, v:null)
endfunc


"----------------------------------------------------------------------
" install a how section
"----------------------------------------------------------------------
function! quickui#menu#install(section, content)
	if type(a:content) == v:t_list
		for item in a:content
			if type(item) == v:t_dict
				call quickui#menu#register(a:section, item.name, item.command)
			elseif type(item) == v:t_list
				let help = (len(item) >= 3)? item[2] : ''
				call quickui#menu#register(a:section, item[0], item[1], help)
			endif
		endfor
	elseif type(a:content) == v:t_dict
		for name in keys(a:content)
			let cmd = a:content[name]
			call quickui#menu#register(a:section, name, cmd, '')
		endfor
	endif
endfunc


"----------------------------------------------------------------------
" change weight
"----------------------------------------------------------------------
function! quickui#menu#change_weight(section, weight)
	if has_key(s:menucfg, a:section)
		let s:menucfg[a:section].weight = a:weight
	endif
endfunc


"----------------------------------------------------------------------
" compare section
"----------------------------------------------------------------------
function! s:section_compare(s1, s2)
	if a:s1[0] == a:s2[0]
		return 0
	else
		return (a:s1[0] > a:s2[0])? 1 : -1
	endif
endfunc


"----------------------------------------------------------------------
" get section
"----------------------------------------------------------------------
function! quickui#menu#available()
	let menus = []
	for name in keys(s:menucfg)
		let menu = s:menucfg[name]
		if len(menu.items) > 0
			let menus += [[menu.weight, menu.name]]
		endif
	endfor
	call sort(menus, 's:section_compare')
	let result = []
	for obj in menus
		let result += [obj[1]]
	endfor
	return result
endfunc


"----------------------------------------------------------------------
" parse
"----------------------------------------------------------------------
function! s:parse_menu()
	let inst = {'items':[], 'text':'', 'width':0, 'hotkey':{}}
	let start = 0
	let split = '  '
	let names = quickui#menu#available()
	let index = 0
	let size = len(names)
	for section in names
		let menu = s:menucfg[section]
		let item = {'name':menu.name, 'text':''}
		let obj = quickui#utils#escape(menu.name)
		let item.text = ' ' . obj[0] . ' '
		let item.key_char = obj[1]
		let item.key_pos = (obj[3] < 0)? -1 : (obj[3] + 1)
		let item.x = start
		let item.w = strchars(item.text)
		let start += item.w + len(split)
		let inst.items += [item]
		let inst.text .= item.text . ((index + 1 < size)? split : '')
		let inst.width += item.w
		if item.key_pos >= 0
			let inst.hotkey[tolower(item.key_char)] = index
		endif
		let index += 1
	endfor
	return inst
endfunc


"----------------------------------------------------------------------
" internal
"----------------------------------------------------------------------
let s:cmenu = {'state':0, 'index':0, 'size':0, 'winid':-1, 'drop':-1}


"----------------------------------------------------------------------
" create popup ui
"----------------------------------------------------------------------
function! quickui#menu#create(opts)
	if s:cmenu.state != 0
		return -1
	endif
	let s:cmenu.inst = s:parse_menu()
	let s:cmenu.width = &columns
	let s:cmenu.size = len(s:cmenu.inst.items)
	let winid = popup_create([s:cmenu.inst.text], {'hidden':1, 'wrap':0})
	let bufnr = winbufnr(winid)
	let s:cmenu.winid = winid
	let s:cmenu.bufnr = bufnr
	let s:cmenu.cfg = deepcopy(a:opts)
	let w = s:cmenu.width
	let opts = {"minwidth":w, "maxwidth":w, "minheight":1, "maxheight":1}
	let opts.line = 1
	let opts.col = 1
	call popup_move(winid, opts)
	call setwinvar(winid, '&wincolor', get(a:opts, 'color', 'QuickBG'))
	let opts = {'mapping':0, 'cursorline':0, 'drag':0, 'zindex':31000}
	let opts.border = [0,0,0,0,0,0,0,0,0]
	let opts.padding = [0,0,0,0]
	let opts.filter = 'quickui#menu#filter'
	let opts.callback = 'quickui#menu#callback'
	if 1
		let keymap = quickui#utils#keymap()
		let s:cmenu.keymap = keymap
		let keymap['H'] = 'LEFT'
		let keymap['L'] = 'RIGHT'
	endif
	let s:cmenu.hotkey = s:cmenu.inst.hotkey
	let s:cmenu.drop = -1
	let s:cmenu.state = 1
	call popup_setoptions(winid, opts)
	call quickui#menu#update()
	call popup_show(winid)
	return 0
endfunc


"----------------------------------------------------------------------
" render menu
"----------------------------------------------------------------------
function! quickui#menu#update()
	let winid = s:cmenu.winid
	if s:cmenu.state == 0
		return -1
	endif
	let inst = s:cmenu.inst
	call win_execute(winid, "syn clear")
	let index = 0
	for item in inst.items
		if item.key_pos >= 0
			let x = item.key_pos + item.x + 1
			let cmd = quickui#core#high_region('QuickKey', 1, x, 1, x + 1, 0)
			call win_execute(winid, cmd)
		endif
		let index += 1
	endfor
	let index = s:cmenu.index
	if index >= 0 && index < s:cmenu.size
		let x = inst.items[index].x + 1
		let e = x + inst.items[index].w
		let cmd = quickui#core#high_region('QuickSel', 1, x, 1, e, 0)
		call win_execute(winid, cmd)
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" close menu
"----------------------------------------------------------------------
function! quickui#menu#close()
	if s:cmenu.state != 0
		call popup_close(s:cmenu.winid)
		let s:cmenu.winid = -1
		let s:cmenu.state = 0
	endif
endfunc



"----------------------------------------------------------------------
" exit callback
"----------------------------------------------------------------------
function! quickui#menu#callback(winid, code)
	let s:cmenu.state = 0
endfunc


"----------------------------------------------------------------------
" event handler
"----------------------------------------------------------------------
function! quickui#menu#filter(winid, key)
	let keymap = s:cmenu.keymap
	if a:key == "\<ESC>" || a:key == "\<c-c>"
		call popup_close(a:winid, -1)
		return 1
	elseif has_key(s:cmenu.hotkey, a:key)
		let index = s:cmenu.hotkey[a:key]
	elseif has_key(keymap, a:key)
		let key = keymap[a:key]
		call s:movement(key)
		redraw
		return 1
	endif
endfunc


"----------------------------------------------------------------------
" moving 
"----------------------------------------------------------------------
function! s:movement(key)
	if a:key == 'LEFT' || a:key == 'RIGHT'
		let index = s:cmenu.index
		if index < 0
			let index = 0
		elseif a:key == 'LEFT'
			let index -= 1
		elseif a:key == 'RIGHT'
			let index += 1
		endif
		let index = (index < 0)? (s:cmenu.size - 1) : index
		let index = (index >= s:cmenu.size)? 0 : index
		let s:cmenu.index = (s:cmenu.size == 0)? 0 : index
		call quickui#menu#update()
		echo "MOVE: " . index
	endif
endfunc


"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 1
	let s:menucfg = {}
	call quickui#menu#install('H&elp', [
				\ [ '&Content', 'echo 4' ],
				\ [ '&About', 'echo 5' ],
				\ ])
	call quickui#menu#install('&File', [
				\ [ '&Open', 'echo 1' ],
				\ [ '&Save', 'echo 2' ],
				\ [ '&Close', 'echo 3' ],
				\ ])
	call quickui#menu#install('&Edit', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])
	call quickui#menu#install('&Tools', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])

	call quickui#menu#install('&Window', [])
	call quickui#menu#change_weight('&Help', 1000)
	let inst = s:parse_menu()
	" echo '"' . inst.text . '"'
	let opts = {}
	let s:cmenu.index = -1
	call quickui#menu#create(opts)
	let keymap = quickui#utils#keymap()
	" echo keymap
endif



