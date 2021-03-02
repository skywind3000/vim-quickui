let s:themes = map(glob(expand('<sfile>:p:h:h:h') . '/colors/quickui/*.vim', 0, 1), {_, v -> fnamemodify(v, ':t:r')})

function! leaderf#quickui_themes#source(args) abort "{{{
	return s:themes
endfunction "}}}

function! leaderf#quickui_themes#accept(line, args) abort "{{{
	if !exists('*QuickThemeChange')
		echohl WarningMsg
		echo 'Please install quickui.vim firstly!'
		echohl None
	else
		call QuickThemeChange(a:line)
	endif
endfunction "}}}
