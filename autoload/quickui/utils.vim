"======================================================================
"
" utils.vim - 
"
" Created by skywind on 2019/12/19
" Last Modified: 2019/12/19 15:31:17
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" parse description into item object
"----------------------------------------------------------------------
function! quickui#utils#item_parse(description)
	let obj = {'text':'', 'key_pos':-1, 'key_char':'', 'is_sep':0, 'help':''}
	let obj.info = []
	let text = ''
	if type(a:description) == v:t_string
		let text = a:description
		let obj.help = ''
		let obj.cmd = ''
		let obj.info = [ text ]
	elseif type(a:description) == v:t_list
		let size = len(a:description)
		let text = (size >= 1)? a:description[0] : ''
		let obj.cmd = (size >= 2)? a:description[1] : ''
		let obj.help = (size >= 3)? a:description[2] : ''
		let obj.info = deepcopy(a:description)
	endif
	if text =~ '^-\+$'
		let obj.is_sep = 1
		let obj.text = ""
		let obj.desc = ""
		let obj.text_width = 0
		let obj.desc_width = 0
		let obj.enable = 0
	else
		let text = quickui#core#expand_text(text)
		let obj.enable = 1
		if strpart(text, 0, 1) == '~'
			let text = strpart(text, 1)
			let obj.enable = 0
		endif
		let pos = stridx(text, "\t")
		if pos < 0 
			let obj.text = text
			let obj.desc = ""
		else
			let obj.text = strpart(text, 0, pos)
			let obj.desc = strpart(text, pos + 1)
			let obj.desc = substitute(obj.desc, "\t", " ", "g")
		endif
		let text = obj.text
		let rest = ''
		let start = 0
		while 1
			let pos = stridx(text, "&", start)
			if pos < 0 
				let rest .= strpart(text, start)
				break
			end
			let rest .= strpart(text, start, pos - start)
			let key = strpart(text, pos + 1, 1)
			let start = pos + 2
			if key == '&'
				let rest .= '&'
			elseif key == '~'
				let rest .= '~'
			else
				let obj.key_char = key
				let obj.key_pos = strwidth(rest)
				let rest .= key
			endif
		endwhile
		let obj.text = rest
		let obj.text_width = strwidth(obj.text)
		let obj.desc_width = strwidth(obj.desc)
	end
	return obj
endfunc


"----------------------------------------------------------------------
" alignment
"----------------------------------------------------------------------
function! quickui#utils#context_align(item, left_size, right_size)
	let obj = a:item
	let middle = (a:right_size > 0)? 2 : 0
	let size = a:left_size + a:right_size + middle
	if obj.is_sep
		let obj.content = repeat('-', size)
	else
		if obj.text_width < a:left_size
			let delta = a:left_size - obj.text_width
			let obj.text_left = obj.text . repeat(' ', delta)
		else
			let obj.text_left = obj.text
		endif
		if obj.desc_width < a:right_size
			let delta = a:right_size - obj.desc_width
			let obj.text_right = repeat(' ', delta) . obj.desc
		else
			let obj.text_right = obj.desc
		endif
		if a:right_size > 0
			let obj.content = obj.text_left . '  ' . obj.text_right
		else
			let obj.content = obj.text_left
		endif
	endif
	return obj
endfunc



"----------------------------------------------------------------------
" highlighting
"----------------------------------------------------------------------
function! s:hilink(name, target)
	if !hlexists(a:name)
		exec 'hi! link ' . a:name . ' ' . a:target
	endif
endfunc

call s:hilink('QuickBG', 'Pmenu')
call s:hilink('QuickKey', 'Keyword')
call s:hilink('QuickOff', 'Comment')
call s:hilink('QuickSel', 'PmenuSel')
call s:hilink('QuickHelp', 'Title')


"----------------------------------------------------------------------
" style: default
"----------------------------------------------------------------------
function! quickui#utils#highlight(style)
	let style = (type(a:style) == v:t_number)? (''. a:style) : a:style
	let style = tolower(style)
	if style == '' || style == '0' || style == 'default' || style == 'Pmenu'
		hi! link TVisionBG Pmenu
		hi! link TVisionKey Keyword
		hi! link TVisionOff Comment
		hi! link TVisionSel PmenuSel
		hi! link TVisionHelp Title
	elseif style == 'borland'
	endif
endfunc



"----------------------------------------------------------------------
" build map
"----------------------------------------------------------------------
let s:maps = {}
let s:maps["\<ESC>"] = 'ESC'
let s:maps["\<CR>"] = 'ENTER'
let s:maps["\<SPACE>"] = 'ENTER'
let s:maps["\<UP>"] = 'UP'
let s:maps["\<DOWN>"] = 'DOWN'
let s:maps["\<LEFT>"] = 'LEFT'
let s:maps["\<RIGHT>"] = 'RIGHT'
let s:maps["\<HOME>"] = 'HOME'
let s:maps["\<END>"] = 'END'
let s:maps["\<c-j>"] = 'DOWN'
let s:maps["\<c-k>"] = 'UP'
let s:maps["\<c-h>"] = 'LEFT'
let s:maps["\<c-l>"] = 'RIGHT'
let s:maps["\<c-n>"] = 'DOWN'
let s:maps["\<c-p>"] = 'UP'
let s:maps["\<c-b>"] = 'PAGEUP'
let s:maps["\<c-f>"] = 'PAGEDOWN'
let s:maps["\<c-u>"] = 'HALFUP'
let s:maps["\<c-d>"] = 'HALFDOWN'
let s:maps["\<PageUp>"] = 'PAGEUP'
let s:maps["\<PageDown>"] = 'PAGEDOWN'
let s:maps['j'] = 'DOWN'
let s:maps['k'] = 'UP'
let s:maps['h'] = 'LEFT'
let s:maps['l'] = 'RIGHT'
let s:maps['J'] = 'HALFDOWN'
let s:maps['K'] = 'HALFUP'
let s:maps['H'] = 'PAGEUP'
let s:maps['L'] = 'PAGEDOWN'
let s:maps["g"] = 'TOP'
let s:maps["G"] = 'BOTTOM'
let s:maps['q'] = 'ESC'


function! quickui#utils#keymap()
	return deepcopy(s:maps)
endfunc


"----------------------------------------------------------------------
" max height
"----------------------------------------------------------------------
function! quickui#utils#max_height(percentage)
	return (&lines) * a:percentage / 100
endfunc



