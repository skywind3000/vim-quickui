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
	finish
endif


"----------------------------------------------------------------------
" Script Home
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')


"----------------------------------------------------------------------
" default highlighting
"----------------------------------------------------------------------
function! s:hilink(name, target)
	if !hlexists(a:name)
		exec 'hi! link ' . a:name . ' ' . a:target
	endif
endfunc


function! QuickThemeChange(theme)
	if a:theme == ''
		hi! QuickDefaultBackground ctermfg=0 ctermbg=7 guifg=black guibg=gray
		hi! QuickDefaultSel cterm=bold ctermfg=0 ctermbg=2 gui=bold guibg=brown guifg=gray
		hi! QuickDefaultKey term=bold ctermfg=9 gui=bold guifg=#f92772
		hi! QuickDefaultDisable ctermfg=59 guifg=#75715e
		hi! QuickDefaultHelp ctermfg=247 guifg=#959173
	elseif a:theme == 'colorscheme' || a:theme == 'system' || a:theme == 'vim'
		hi! link QuickDefaultBackground Pmenu
		hi! link QuickDefaultKey PmenuSel
		hi! link QuickDefaultKey Title
		hi! link QuickDefaultDisable Comment
		hi! link QuickDefaultHelp Conceal
	elseif a:theme == 'gruvbox'
		hi! QuickDefaultBackground ctermfg=223 ctermbg=239 guifg=#ebdbb2 guibg=#504945
		hi! QuickDefaultSel cterm=bold ctermfg=239 ctermbg=109 gui=bold guifg=#504945 guibg=#83a598
		hi! QuickDefaultKey term=bold ctermfg=12 guifg=#fd9720
		hi! QuickDefaultDisable ctermfg=245 guifg=#928374
		hi! QuickDefaultHelp ctermfg=109 guifg=#83a598
	elseif a:theme == 'solarized'
		hi! QuickDefaultBackground ctermfg=0 ctermbg=13 guifg=#073642 guibg=#839496
		hi! QuickDefaultSel ctermfg=8 ctermbg=0 guifg=#eee8d5 guibg=#586e75
		hi! QuickDefaultKey ctermfg=13 guifg=#cb4b16
		hi! QuickDefaultDisable ctermfg=11 guifg=#586e75
		hi! QuickDefaultHelp ctermfg=7 ctermbg=8 guifg=#268bd2
	elseif a:theme == 'papercol'
		if &background == 'dark'
			hi! QuickDefaultBackground ctermfg=0 ctermbg=13 guifg=#c6c6c6 guibg=#303030
			hi! QuickDefaultSel ctermfg=8 ctermbg=0 guifg=#303030 guibg=#c6c6c6
			hi! QuickDefaultKey term=bold ctermfg=10 gui=bold guifg=#d7af5f
			hi! QuickDefaultDisable ctermfg=11 guifg=#808080
			hi! QuickDefaultHelp ctermfg=7 ctermbg=8 guifg=#585858 guibg=#1c1c1c
		else
			hi! QuickDefaultBackground ctermfg=0 ctermbg=13 guifg=#444444 guibg=#d0d0d0
			hi! QuickDefaultSel ctermfg=0 ctermbg=7 guifg=#d0d0d0 guibg=#444444
			hi! QuickDefaultKey term=bold ctermfg=4 gui=bold guifg=#d70087
			hi! QuickDefaultDisable  term=bold ctermfg=1 guifg=#878787
			hi! QuickDefaultHelp ctermfg=7 ctermbg=8 guifg=#b2b2b2 guibg=#eeeeee
		endif
	else
		let s:fname = s:home . '/' . a:theme . '.vim'
		if filereadable(s:fname)
			exec "source " . fnameescape(s:fname)
		else
			call QuickThemeChange('')
		endif
	endif
endfunc

let s:theme = get(g:, 'quickui_color_theme', '')
call QuickThemeChange(s:theme)


" hi! QuickDefaultSel ctermbg=
call s:hilink('QuickBG', 'QuickDefaultBackground')
call s:hilink('QuickSel', 'QuickDefaultSel')
call s:hilink('QuickKey', 'QuickDefaultKey')
call s:hilink('QuickOff', 'QuickDefaultDisable')
call s:hilink('QuickHelp', 'QuickDefaultHelp')



