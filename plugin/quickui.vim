"======================================================================
"
" quickui.vim - 
"
" Created by skywind on 2019/12/26
" Last Modified: 2019/12/26 18:20:52
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :



"----------------------------------------------------------------------
" default highlighting
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



