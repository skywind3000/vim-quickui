"======================================================================
"
" test_dialog_auto.vim - automated (non-interactive) test for dialog
"
" Usage (recommended — ex silent mode with rtp pre-set):
"   vim -u NONE -N -i NONE -n --not-a-term -es
"       -c "set rtp+=c:/Share/vim"
"       -c "source c:/Share/vim/tools/test/test_dialog_auto.vim"
"   echo Exit code: %ERRORLEVEL%
"   type c:\Share\vim\test_dialog_result.log
"
" Also works via -S when <sfile> resolves correctly:
"   vim -u NONE -N -i NONE -n --not-a-term -es
"       -S tools/test/test_dialog_auto.vim
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


" ── 0. load dependencies ──────────────────────────────────
" Try <sfile> first (works with -S), fall back to rtp scan.
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h')
if !isdirectory(s:home . '/autoload/quickui')
	let s:home = ''
	for s:p in split(&rtp, ',')
		if isdirectory(s:p . '/autoload/quickui')
			let s:home = s:p
			break
		endif
	endfor
endif
if s:home != ''
	exec 'set rtp+=' . fnameescape(s:home)
endif
let s:logfile = (s:home != '' ? s:home : '.') . '/test_dialog_result.log'


" ── 1. test helpers ───────────────────────────────────────
let s:errors = []
let s:passed = 0

function! s:assert_equal(expected, actual, msg) abort
	if a:expected != a:actual
		call add(s:errors, a:msg . ': expected ' .
			\ string(a:expected) . ', got ' . string(a:actual))
	else
		let s:passed += 1
	endif
endfunc


" ── 2. test: empty items ─────────────────────────────────
let r = quickui#dialog#open([], {})
call s:assert_equal('', r.button, 'empty: button')
call s:assert_equal(-1, r.button_index, 'empty: index')


" ── 3. test: ESC cancel preserves values ─────────────────
call feedkeys("\<ESC>", 't')
let r = quickui#dialog#open([
	\ {'type': 'input', 'name': 'name', 'prompt': 'Name:',
	\  'value': 'test_value'},
	\ {'type': 'check', 'name': 'flag', 'text': 'Enable', 'value': 1},
	\ {'type': 'button', 'name': 'confirm',
	\  'items': [' &OK ', ' &Cancel ']},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'ESC: button')
call s:assert_equal(-1, r.button_index, 'ESC: index')
call s:assert_equal('test_value', r.name, 'ESC: preserves input')
call s:assert_equal(1, r.flag, 'ESC: preserves check')


" ── 4. test: type in input then Enter confirms ───────────
call feedkeys("hello\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'input', 'name': 'x', 'prompt': 'X:'},
	\ {'type': 'button', 'name': 'ok',
	\  'items': [' &OK ', ' &Cancel ']},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'input+Enter: button')
call s:assert_equal(0, r.button_index, 'input+Enter: index')
call s:assert_equal('hello', r.x, 'input+Enter: value')


" ── 5. test: type in input, Tab to button, Enter ─────────
call feedkeys("world\<Tab>\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'input', 'name': 'x', 'prompt': 'X:'},
	\ {'type': 'button', 'name': 'ok',
	\  'items': [' &OK ', ' &Cancel ']},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('ok', r.button, 'Tab+Enter: button')
call s:assert_equal(0, r.button_index, 'Tab+Enter: index')
call s:assert_equal('world', r.x, 'Tab+Enter: value')


" ── 6. test: radio Right navigation ──────────────────────
" Right moves cursor, Space commits selection
call feedkeys("\<Right>\<Right>\<Space>\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'radio', 'name': 'r',
	\  'items': ['A', 'B', 'C'], 'value': 0},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'radio: button')
call s:assert_equal(2, r.r, 'radio: value after Right x2 + Space')


" ── 7. test: check Space toggle ──────────────────────────
call feedkeys("\<Space>\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'check', 'name': 'c', 'text': 'Flag', 'value': 0},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal(1, r.c, 'check: toggled on')


" ── 8. test: button hotkey from non-input control ────────
" Initial focus on check (first focusable), press 'c' for &Cancel
call feedkeys("c", 't')
let r = quickui#dialog#open([
	\ {'type': 'check', 'name': 'f', 'text': 'Flag', 'value': 0},
	\ {'type': 'button', 'name': 'ok',
	\  'items': [' &OK ', ' &Cancel ']},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('ok', r.button, 'hotkey: button')
call s:assert_equal(1, r.button_index, 'hotkey: Cancel index')


" ── 9. test: Enter from check confirms ───────────────────
call feedkeys("\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'check', 'name': 'c', 'text': 'Flag', 'value': 0},
	\ {'type': 'button', 'name': 'ok',
	\  'items': [' &OK ']},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'check+Enter: button')
call s:assert_equal(0, r.button_index, 'check+Enter: index')


" ── 10. test: label only (no focusable controls) ─────────
call feedkeys("\<ESC>", 't')
let r = quickui#dialog#open([
	\ {'type': 'label', 'text': 'Just a label'},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'label only: button')
call s:assert_equal(-1, r.button_index, 'label only: index')


" ── 11. test: prompt alignment ────────────────────────────
" Two inputs with different prompt lengths should align
call feedkeys("\<ESC>", 't')
let r = quickui#dialog#open([
	\ {'type': 'input', 'name': 'a', 'prompt': 'Name:'},
	\ {'type': 'input', 'name': 'b', 'prompt': 'Email Address:'},
	\ ], {'title': 'Test', 'w': 50})
call s:assert_equal('', r.button, 'align: button')
call s:assert_equal('', r.a, 'align: a default')
call s:assert_equal('', r.b, 'align: b default')


" ── 12. test: no button control — Enter from radio ───────
call feedkeys("\<CR>", 't')
let r = quickui#dialog#open([
	\ {'type': 'radio', 'name': 'r',
	\  'items': ['X', 'Y'], 'value': 1},
	\ ], {'title': 'Test', 'w': 40})
call s:assert_equal('', r.button, 'no-btn: button')
call s:assert_equal(0, r.button_index, 'no-btn: index')
call s:assert_equal(1, r.r, 'no-btn: radio value unchanged')


" ── 13. test: prompt alignment inflates width for check ───
" A check with short prompt + wide text should not overflow when
" aligned to an input with a long prompt.
call feedkeys("\<ESC>", 't')
let r = quickui#dialog#open([
	\ {'type': 'input', 'name': 'a', 'prompt': 'Very Long Prompt:',
	\  'value': ''},
	\ {'type': 'check', 'name': 'b', 'prompt': 'P:',
	\  'text': 'A checkbox label text here', 'value': 0},
	\ ], {'title': 'Test'})
" The dialog should have opened and closed without error.
" Verify that the width is at least prompt_width(aligned) + 4 + text_width.
" 'Very Long Prompt:' display width = 17, aligned prompt_width = 17+2 = 19
" check text 'A checkbox label text here' display width = 26
" minimum width = 19 + 4 + 26 = 49
" If the old code ran, w might be as small as 40 (min_w), causing overflow.
call s:assert_equal('', r.button, 'align-inflate: button')
call s:assert_equal(0, r.b, 'align-inflate: check value')
call s:assert_equal('', r.a, 'align-inflate: input value')


" ── report results ────────────────────────────────────────
let total = s:passed + len(s:errors)
if len(s:errors) == 0
	call writefile(['ALL PASSED (' . total . ' assertions)'], s:logfile)
	qa!
else
	let report = ['FAILED: ' . len(s:errors) . '/' . total] + s:errors
	call writefile(report, s:logfile)
	cq 1
endif
