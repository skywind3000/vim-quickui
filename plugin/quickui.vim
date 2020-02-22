"======================================================================
"
" quickui.vim - 
"
" Created by skywind on 2019/12/26
" Last Modified: 2019/12/26 18:20:52
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


" require vim 8.2+
if has('patch-8.2.1') == 0 || has('nvim')
	" finish
endif


"----------------------------------------------------------------------
" Script Home
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:rtp = fnamemodify(s:home, ':h')



"----------------------------------------------------------------------
" setup variables
"----------------------------------------------------------------------
let g:quickui#style#border = get(g:, 'quickui_border_style', 1)


"----------------------------------------------------------------------
" default highlighting
"----------------------------------------------------------------------
function! s:hilink(name, target)
	if !hlexists(a:name)
		exec 'hi! link ' . a:name . ' ' . a:target
	endif
endfunc


function! QuickThemeChange(theme)
	let theme = 'borland'
	if a:theme == 'default'
		let theme = 'borland'
	elseif a:theme == '' || a:theme == 'borland' || a:theme == 'turboc'
		let theme = 'borland'
	elseif a:theme == 'colorscheme' || a:theme == 'system' || a:theme == 'vim'
		let theme = 'system'
	elseif a:theme == 'gruvbox'
		let theme = 'gruvbox'
	elseif a:theme == 'solarized'
		let theme = 'solarized'
	elseif a:theme == 'papercol' || a:theme == 'papercol-dark' 
		let theme = 'papercol_dark'
	elseif a:theme == 'papercol dark'
		let theme = 'papercol_dark'
	elseif a:theme == 'papercol-light' || a:theme == 'papercol light'
		let theme = 'papercol_light'
	else
		let theme = a:theme
	endif
	let s:fname = s:rtp . '/colors/quickui/' . theme . '.vim'
	if !filereadable(s:fname)
		let s:fname = s:rtp . '/colors/quickui/borland.vim'
	endif
	if filereadable(s:fname)
		exec "source " . fnameescape(s:fname)
	endif
endfunc

let s:scheme = get(g:, 'quickui_color_scheme', '')
call QuickThemeChange(s:scheme)


" hi! QuickDefaultSel ctermbg=
call s:hilink('QuickBG', 'QuickDefaultBackground')
call s:hilink('QuickSel', 'QuickDefaultSel')
call s:hilink('QuickKey', 'QuickDefaultKey')
call s:hilink('QuickOff', 'QuickDefaultDisable')
call s:hilink('QuickHelp', 'QuickDefaultHelp')
call s:hilink('QuickBorder', 'QuickDefaultBorder')
call s:hilink('QuickTermBorder', 'QuickDefaultTermBorder')
call s:hilink('QuickPreview', 'QuickDefaultPreview')


