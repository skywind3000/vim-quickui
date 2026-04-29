"======================================================================
"
" test_dialog_dropdown.vim - test dropdown and separator controls
"
" Usage: :source tools/test/test_dialog_dropdown.vim
"        :call Test_dropdown_basic()
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" basic dropdown test
"----------------------------------------------------------------------
function! Test_dropdown_basic()
	let items = [
		\ {'type': 'label', 'text': 'Select a programming language:'},
		\ {'type': 'dropdown', 'name': 'lang', 'prompt': 'Language:',
		\  'items': ['Python', 'C++', 'Rust', 'Go', 'Java',
		\            'JavaScript', 'TypeScript', 'Ruby'],
		\  'value': 0},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Dropdown Test'})
	echo result
endfunc


"----------------------------------------------------------------------
" separator test
"----------------------------------------------------------------------
function! Test_separator_basic()
	let items = [
		\ {'type': 'label', 'text': 'Group 1: User Info'},
		\ {'type': 'input', 'name': 'name', 'prompt': 'Name:',
		\  'value': 'skywind'},
		\ {'type': 'input', 'name': 'email', 'prompt': 'Email:'},
		\ {'type': 'separator'},
		\ {'type': 'label', 'text': 'Group 2: Settings'},
		\ {'type': 'check', 'name': 'notify', 'text': 'Send notification',
		\  'value': 1},
		\ {'type': 'check', 'name': 'admin', 'text': 'Administrator'},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Separator Test'})
	echo result
endfunc


"----------------------------------------------------------------------
" combined test: dropdown + separator + other controls
"----------------------------------------------------------------------
function! Test_dropdown_full()
	let items = [
		\ {'type': 'label', 'text': 'Project Configuration'},
		\ {'type': 'separator'},
		\ {'type': 'input', 'name': 'project', 'prompt': 'Project:',
		\  'value': 'my-app'},
		\ {'type': 'dropdown', 'name': 'lang', 'prompt': 'Language:',
		\  'items': ['Python', 'C++', 'Rust', 'Go', 'Java'],
		\  'value': 2},
		\ {'type': 'dropdown', 'name': 'build', 'prompt': 'Build:',
		\  'items': ['Debug', 'Release', 'RelWithDebInfo', 'MinSizeRel'],
		\  'value': 1},
		\ {'type': 'separator'},
		\ {'type': 'radio', 'name': 'vcs', 'prompt': 'VCS:',
		\  'items': ['&Git', '&SVN', '&None'], 'value': 0},
		\ {'type': 'check', 'name': 'tests', 'text': 'Enable tests',
		\  'value': 1},
		\ {'type': 'check', 'name': 'lint', 'text': 'Enable linter'},
		\ {'type': 'separator'},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Apply ', ' &Cancel ']},
		\ ]
	let opts = {'title': 'Project Setup', 'w': 50}
	let result = quickui#dialog#open(items, opts)
	if result.button_index > 0
		echo 'Project: ' . result.project
		echo 'Language: ' . result.lang . ' (' .
			\ ['Python','C++','Rust','Go','Java'][result.lang] . ')'
		echo 'Build: ' . result.build
		echo 'VCS: ' . result.vcs
		echo 'Tests: ' . result.tests
		echo 'Lint: ' . result.lint
	else
		echo 'Cancelled'
	endif
endfunc


"----------------------------------------------------------------------
" dropdown with default index test
"----------------------------------------------------------------------
function! Test_dropdown_index()
	let items = [
		\ {'type': 'dropdown', 'name': 'encoding', 'prompt': 'Encoding:',
		\  'items': ['UTF-8', 'GBK', 'Latin-1', 'Shift-JIS', 'EUC-KR'],
		\  'value': 0},
		\ {'type': 'dropdown', 'name': 'format', 'prompt': 'Format:',
		\  'items': ['Unix (LF)', 'DOS (CRLF)', 'Mac (CR)'],
		\  'value': 1},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'File Settings'})
	echo result
endfunc


"----------------------------------------------------------------------
" dropdown with many items (scroll test)
"----------------------------------------------------------------------
function! Test_dropdown_scroll()
	let langs = []
	for name in ['Ada', 'Assembly', 'BASIC', 'C', 'C++', 'C#', 'COBOL',
		\ 'Dart', 'Elixir', 'Erlang', 'Fortran', 'Go', 'Groovy',
		\ 'Haskell', 'Java', 'JavaScript', 'Julia', 'Kotlin', 'Lisp',
		\ 'Lua', 'MATLAB', 'Nim', 'OCaml', 'Pascal', 'Perl',
		\ 'PHP', 'Python', 'R', 'Ruby', 'Rust', 'Scala', 'Scheme',
		\ 'Shell', 'Swift', 'TypeScript', 'Vala', 'VimL', 'Zig']
		let langs += [name]
	endfor
	let items = [
		\ {'type': 'label', 'text': 'Many items dropdown (scroll test):'},
		\ {'type': 'dropdown', 'name': 'lang',
		\  'prompt': 'Language:', 'items': langs, 'value': 26},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Scroll Test'})
	if result.button_index > 0
		echo 'Selected index: ' . result.lang .
			\ ' (' . langs[result.lang] . ')'
	else
		echo 'Cancelled'
	endif
endfunc
