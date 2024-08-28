"======================================================================
"
" quickui.vim -
"
" Created by skywind on 2019/12/26
" Last Modified: 2021/12/08 23:01
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


" require vim 8.2+
if has('patch-8.2.1') == 0 || has('nvim')
	" finish
endif


"----------------------------------------------------------------------
" exports
"----------------------------------------------------------------------
let g:quickui_version = '1.4.3'


"----------------------------------------------------------------------
" internals
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:rtp = fnamemodify(s:home, ':h')


"----------------------------------------------------------------------
" QuickUI command
"----------------------------------------------------------------------
command! -bang -nargs=* -complete=customlist,quickui#command#complete
			\ QuickUI  call quickui#command#run('<bang>', <q-args>)


"----------------------------------------------------------------------
" setup variables
"----------------------------------------------------------------------
if exists('g:quickui_border_style')
	let g:quickui#style#border = get(g:, 'quickui_border_style', 1)
endif

function! s:set_quickui_hi()
	" hi! QuickDefaultSel ctermbg=
	hi! link QuickBG QuickDefaultBackground
	hi! link QuickSel QuickDefaultSel
	hi! link QuickKey QuickDefaultKey
	hi! link QuickOff QuickDefaultDisable
	hi! link QuickHelp QuickDefaultHelp
	hi! link QuickBorder QuickDefaultBorder
	hi! link QuickTermBorder QuickDefaultTermBorder
	hi! link QuickPreview QuickDefaultPreview

	" for input box
	hi! link QuickInput QuickDefaultInput
	hi! link QuickCursor QuickDefaultCursor
	hi! link QuickVisual QuickDefaultVisual
endfunc

function! QuickThemeChange(theme)
	let theme = 'default'
	if a:theme == ''
		let theme = 'default'
	elseif a:theme == 'default' || a:theme == 'ansi'
		let theme = 'default'
	elseif a:theme == 'borland' || a:theme == 'turboc'
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
	call s:set_quickui_hi()
endfunc

let s:scheme = get(g:, 'quickui_color_scheme', '')
call QuickThemeChange(s:scheme)

augroup quickui "{{{
	autocmd!
	autocmd Colorscheme * call QuickThemeChange(get(g:, 'quickui_color_scheme', ''))
augroup END "}}}

call s:set_quickui_hi()


