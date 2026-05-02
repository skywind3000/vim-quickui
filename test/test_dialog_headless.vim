" headless integration test for separator + dropdown
" vim: set ts=4 sw=4 tw=78 noet :

set rtp+=.
runtime autoload/quickui/core.vim
runtime autoload/quickui/utils.vim
runtime autoload/quickui/style.vim
runtime autoload/quickui/highlight.vim
runtime autoload/quickui/window.vim
runtime autoload/quickui/readline.vim
runtime autoload/quickui/dialog.vim

let s:pass = 0
let s:fail = 0

function! s:assert(msg, cond)
	if a:cond
		let s:pass += 1
	else
		let s:fail += 1
		echoerr 'FAIL: ' . a:msg
	endif
endfunc

" Test 1: separator + dropdown parse & ESC cancel
let items = [
	\ {'type': 'label', 'text': 'Test'},
	\ {'type': 'separator'},
	\ {'type': 'dropdown', 'name': 'lang', 'prompt': 'Lang:',
	\  'items': ['Python', 'C++', 'Rust'], 'value': 1},
	\ {'type': 'button', 'name': 'ok', 'items': [' OK ']},
	\ ]
call feedkeys("\<ESC>", 't')
let result = quickui#dialog#open(items, {'title': 'Test'})
call s:assert('ESC cancels: button_index=-1', result.button_index == -1)
call s:assert('dropdown value preserved on cancel', result.lang == 1)

" Test 2: Tab to dropdown, then ESC
let items2 = [
	\ {'type': 'input', 'name': 'name', 'prompt': 'Name:', 'value': 'hi'},
	\ {'type': 'dropdown', 'name': 'enc', 'prompt': 'Enc:',
	\  'items': ['UTF-8', 'GBK', 'Latin-1'], 'value': 0},
	\ {'type': 'separator'},
	\ {'type': 'check', 'name': 'flag', 'text': 'Enable'},
	\ {'type': 'button', 'name': 'ok', 'items': [' &OK ']},
	\ ]
call feedkeys("\<ESC>", 't')
let result2 = quickui#dialog#open(items2, {'title': 'Test2'})
call s:assert('dropdown default value=0', result2.enc == 0)
call s:assert('input value preserved', result2.name ==# 'hi')

" Test 3: dropdown value clamping
let items3 = [
	\ {'type': 'dropdown', 'name': 'd', 'prompt': 'X:',
	\  'items': ['A', 'B'], 'value': 99},
	\ {'type': 'button', 'name': 'ok', 'items': [' OK ']},
	\ ]
call feedkeys("\<ESC>", 't')
let result3 = quickui#dialog#open(items3, {'title': 'Clamp'})
call s:assert('dropdown value clamped to max', result3.d == 1)

" Test 4: multiple separators
let items4 = [
	\ {'type': 'separator'},
	\ {'type': 'label', 'text': 'Hello'},
	\ {'type': 'separator'},
	\ {'type': 'separator'},
	\ {'type': 'button', 'name': 'ok', 'items': [' OK ']},
	\ ]
call feedkeys("\<ESC>", 't')
let result4 = quickui#dialog#open(items4, {'title': 'Multi Sep'})
call s:assert('multiple separators OK', result4.button_index == -1)

echo printf('Results: %d passed, %d failed', s:pass, s:fail)
call writefile([printf('Results: %d passed, %d failed', s:pass, s:fail)], 'tools/test/_headless_result.txt')
if s:fail > 0
	cquit!
endif
qall!
