"======================================================================
"
" test_replace.vim - interactive test: find and replace dialog
"
" Usage: :source test/test_replace.vim
"        :call Test_replace_basic()
"        :call Test_replace_full()
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" validator: search pattern must not be empty
"----------------------------------------------------------------------
function! s:validate_replace(result) abort
	if a:result.search =~# '^\s*$'
		return 'Search pattern cannot be empty'
	endif
	if a:result.regex && a:result.search != ''
		try
			call matchstr('', a:result.search)
		catch
			return 'Invalid regex: ' . v:exception
		endtry
	endif
	return ''
endfunc


"----------------------------------------------------------------------
" basic replace dialog
"----------------------------------------------------------------------
function! Test_replace_basic()
	let items = [
		\ {'type': 'input', 'name': 'search', 'prompt': 'Search:',
		\  'history': 'replace_search'},
		\ {'type': 'input', 'name': 'replace', 'prompt': 'Replace:',
		\  'history': 'replace_replace'},
		\ {'type': 'check', 'name': 'regex',
		\  'text': 'Use &regex'},
		\ {'type': 'check', 'name': 'case',
		\  'text': 'Case &sensitive'},
		\ {'type': 'check', 'name': 'whole',
		\  'text': '&Whole word'},
		\ {'type': 'check', 'name': 'confirm',
		\  'text': 'Con&firm each', 'value': 1},
		\ {'type': 'button', 'name': 'action',
		\  'items': [' Replace &All ', ' &Cancel ']},
		\ ]
	let opts = {
		\ 'title': 'Find and Replace',
		\ 'w': 45,
		\ 'validator': function('s:validate_replace'),
		\ }
	let result = quickui#dialog#open(items, opts)
	if result.button ==# 'action' && result.button_index == 0
		echo 'Search:    ' . result.search
		echo 'Replace:   ' . result.replace
		echo 'Regex:     ' . (result.regex ? 'yes' : 'no')
		echo 'Case:      ' . (result.case ? 'sensitive' : 'insensitive')
		echo 'Whole:     ' . (result.whole ? 'yes' : 'no')
		echo 'Confirm:   ' . (result.confirm ? 'yes' : 'no')
	else
		echo 'Cancelled'
	endif
endfunc


"----------------------------------------------------------------------
" full replace dialog with scope dropdown
"----------------------------------------------------------------------
function! Test_replace_full()
	let items = [
		\ {'type': 'input', 'name': 'search', 'prompt': 'Search:',
		\  'history': 'replace_search'},
		\ {'type': 'input', 'name': 'replace', 'prompt': 'Replace:',
		\  'history': 'replace_replace'},
		\ {'type': 'dropdown', 'name': 'scope', 'prompt': 'Scope:',
		\  'items': ['Current Buffer', 'All Buffers',
		\            'Visual Selection', 'Current Function'],
		\  'value': 0},
		\ {'type': 'check', 'name': 'regex',
		\  'text': 'Use &regex'},
		\ {'type': 'check', 'name': 'case',
		\  'text': 'Case &sensitive'},
		\ {'type': 'check', 'name': 'whole',
		\  'text': '&Whole word'},
		\ {'type': 'check', 'name': 'confirm',
		\  'text': 'Con&firm each', 'value': 1},
		\ {'type': 'button', 'name': 'action',
		\  'items': [' Replace &All ', ' &Cancel ']},
		\ ]
	let scopes = ['Current Buffer', 'All Buffers',
		\ 'Visual Selection', 'Current Function']
	let opts = {
		\ 'title': 'Find and Replace',
		\ 'w': 50,
		\ 'validator': function('s:validate_replace'),
		\ }
	let result = quickui#dialog#open(items, opts)
	if result.button ==# 'action' && result.button_index == 0
		echo 'Search:    ' . result.search
		echo 'Replace:   ' . result.replace
		echo 'Scope:     ' . scopes[result.scope]
		echo 'Regex:     ' . (result.regex ? 'yes' : 'no')
		echo 'Case:      ' . (result.case ? 'sensitive' : 'insensitive')
		echo 'Whole:     ' . (result.whole ? 'yes' : 'no')
		echo 'Confirm:   ' . (result.confirm ? 'yes' : 'no')
		call s:do_replace(result, scopes)
	else
		echo 'Cancelled'
	endif
endfunc


"----------------------------------------------------------------------
" execute replacement (demo: current buffer only)
"----------------------------------------------------------------------
function! s:do_replace(result, scopes) abort
	let pattern = a:result.search
	if !a:result.regex
		let pattern = escape(pattern, '\.*^$~[]')
	endif
	if a:result.whole
		let pattern = '\<' . pattern . '\>'
	endif
	let flags = 'g'
	if !a:result.case
		let flags .= 'i'
	endif
	if a:result.confirm
		let flags .= 'c'
	endif
	let cmd = '%s/' . escape(pattern, '/') . '/'
		\ . escape(a:result.replace, '/&') . '/' . flags
	echo 'Command: :' . cmd
	if a:result.scope == 0
		try
			execute cmd
		catch
			echohl ErrorMsg
			echo 'Replace error: ' . v:exception
			echohl None
		endtry
	else
		echo '(Scope "' . a:scopes[a:result.scope]
			\ . '" is a demo placeholder)'
	endif
endfunc
