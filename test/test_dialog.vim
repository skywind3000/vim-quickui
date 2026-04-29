"======================================================================
"
" test_dialog.vim - interactive test for quickui#dialog
"
" Usage: :source tools/test/test_dialog.vim | call Test_dialog_basic()
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" basic test: all control types
"----------------------------------------------------------------------
function! Test_dialog_basic()
	let items = [
		\ {'type': 'label', 'text': 'Test all controls:'},
		\ {'type': 'input', 'name': 'name', 'prompt': 'Name:',
		\  'value': 'test'},
		\ {'type': 'radio', 'name': 'choice', 'prompt': 'Pick:',
		\  'items': ['A', 'B', 'C']},
		\ {'type': 'check', 'name': 'flag', 'text': 'Enable'},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Test'})
	echo result
endfunc


"----------------------------------------------------------------------
" multi button rows test
"----------------------------------------------------------------------
function! Test_dialog_multi_button()
	let items = [
		\ {'type': 'label', 'text': 'Multiple button rows:'},
		\ {'type': 'button', 'name': 'action',
		\  'items': [' &Apply ', ' &Reset ']},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Multi Button'})
	echo result
endfunc


"----------------------------------------------------------------------
" full form test (from design doc example)
"----------------------------------------------------------------------
function! Test_dialog_form()
	let items = [
		\ {'type': 'label', 'text': 'Please fill in the user form:'},
		\ {'type': 'input', 'name': 'username', 'prompt': 'Name:',
		\  'value': 'skywind'},
		\ {'type': 'input', 'name': 'email', 'prompt': 'Email:'},
		\ {'type': 'radio', 'name': 'role', 'prompt': 'Role:',
		\  'items': ['&Dev', '&QA', '&PM'], 'value': 0},
		\ {'type': 'check', 'name': 'admin', 'text': 'Administrator'},
		\ {'type': 'check', 'name': 'notify', 'text': 'Send notification',
		\  'value': 1},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let opts = {'title': 'User Form', 'w': 50}
	let result = quickui#dialog#open(items, opts)
	if result.button_index >= 0
		echo 'User: ' . result.username
		echo 'Email: ' . result.email
		echo 'Role: ' . result.role
		echo 'Admin: ' . result.admin
	else
		echo 'Cancelled'
	endif
endfunc


"----------------------------------------------------------------------
" label only test
"----------------------------------------------------------------------
function! Test_dialog_label_only()
	let items = [
		\ {'type': 'label', 'text': "This dialog has no interactive\ncontrols. Press ESC to close."},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Info'})
	echo result
endfunc


"----------------------------------------------------------------------
" radio vertical test
"----------------------------------------------------------------------
function! Test_dialog_radio_vertical()
	let items = [
		\ {'type': 'label', 'text': 'Pick a very long option:'},
		\ {'type': 'radio', 'name': 'lang', 'prompt': 'Language:',
		\  'items': ['&Python', '&JavaScript', '&TypeScript', '&Rust', '&Go'],
		\  'vertical': 1},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Vertical Radio'})
	echo result
endfunc


"----------------------------------------------------------------------
" input with history test
"----------------------------------------------------------------------
function! Test_dialog_history()
	let items = [
		\ {'type': 'input', 'name': 'search', 'prompt': 'Search:',
		\  'history': 'dialog_test_search'},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &OK ', ' &Cancel ']},
		\ ]
	let result = quickui#dialog#open(items, {'title': 'Search'})
	echo result
endfunc


"----------------------------------------------------------------------
" form with dropdown + validator
"----------------------------------------------------------------------
function! s:validate_project(result) abort
	if a:result.project_name =~# '^\s*$'
		return 'Project name cannot be empty'
	endif
	if a:result.project_name =~# '[^a-zA-Z0-9_\-]'
		return 'Project name: only letters, digits, _ and - are allowed'
	endif
	if a:result.email =~# '^\s*$'
		return 'Email cannot be empty'
	endif
	if a:result.email !~# '@'
		return 'Email must contain @'
	endif
	return ''
endfunc

function! Test_dialog_project_form()
	let items = [
		\ {'type': 'label', 'text': 'Create New Project:'},
		\ {'type': 'input', 'name': 'project_name', 'prompt': 'Project:',
		\  'value': 'my-app'},
		\ {'type': 'input', 'name': 'email', 'prompt': 'Email:',
		\  'value': 'dev@example.com'},
		\ {'type': 'dropdown', 'name': 'language', 'prompt': 'Language:',
		\  'items': ['Python', 'JavaScript', 'Go', 'Rust', 'C++'], 'value': 0},
		\ {'type': 'dropdown', 'name': 'build', 'prompt': 'Build:',
		\  'items': ['Make', 'CMake', 'Cargo', 'npm', 'pip'], 'value': 0},
		\ {'type': 'radio', 'name': 'license', 'prompt': 'License:',
		\  'items': ['&MIT', '&Apache', '&GPL', '&Proprietary'], 'value': 0},
		\ {'type': 'check', 'name': 'git_init', 'text': 'Initialize git repo',
		\  'value': 1},
		\ {'type': 'check', 'name': 'ci', 'text': 'Add CI config',
		\  'value': 0},
		\ {'type': 'separator'},
		\ {'type': 'button', 'name': 'confirm',
		\  'items': [' &Create ', '  Cancel  ']},
		\ ]
	let opts = {'title': 'New Project', 'w': 50,
		\ 'validator': function('s:validate_project'),
		\ 'focus': 'project_name'}
	let result = quickui#dialog#open(items, opts)
	if result.button_index >= 0
		echo 'Project:  ' . result.project_name
		echo 'Email:    ' . result.email
		echo 'Language: ' . items[3].items[result.language]
		echo 'Build:    ' . items[4].items[result.build]
		echo 'License:  ' . items[5].items[result.license]
		echo 'Git:      ' . (result.git_init ? 'yes' : 'no')
		echo 'CI:       ' . (result.ci ? 'yes' : 'no')
	else
		echo 'Cancelled'
	endif
endfunc
