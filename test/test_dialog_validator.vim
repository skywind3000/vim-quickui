" Test: validator parameter for quickui#dialog#open
" Usage: :source tools/test/test_dialog_validator.vim

" Test 1: validator rejects empty username
function! Test_validator_basic() abort
	function! s:my_validator(result) abort
		if get(a:result, 'username', '') ==# ''
			return 'Username cannot be empty!'
		endif
		return ''
	endfunction

	let items = [
		\ {'type': 'input', 'name': 'username', 'prompt': 'Name:'},
		\ {'type': 'button', 'name': 'confirm', 'items': [' &OK ', ' &Cancel ']},
		\ ]

	echo "Try pressing OK with empty name -- should show error."
	echo "Type a name then press OK -- should close normally."
	let result = quickui#dialog#open(items, {
		\ 'title': 'Validator Test',
		\ 'validator': function('s:my_validator'),
		\ })
	echo 'Result: ' . string(result)
endfunc

" Test 2: validator with number return (0 means pass)
function! Test_validator_number() abort
	function! s:num_validator(result) abort
		if get(a:result, 'email', '') ==# ''
			return 'Email is required!'
		endif
		if stridx(a:result.email, '@') < 0
			return 'Email must contain @'
		endif
		return 0
	endfunction

	let items = [
		\ {'type': 'input', 'name': 'email', 'prompt': 'Email:'},
		\ {'type': 'button', 'name': 'ok', 'items': [' &OK ']},
		\ ]

	echo "Try pressing OK with empty/invalid email -- should show error."
	echo "Enter a valid email (with @) then OK -- should close."
	let result = quickui#dialog#open(items, {
		\ 'title': 'Email Validator',
		\ 'validator': function('s:num_validator'),
		\ })
	echo 'Result: ' . string(result)
endfunc

" Test 3: validator does NOT trigger on cancel (ESC)
function! Test_validator_cancel() abort
	let g:validator_called = 0
	function! s:cancel_validator(result) abort
		let g:validator_called = 1
		return 'Should not see this'
	endfunction

	let items = [
		\ {'type': 'input', 'name': 'name', 'prompt': 'Name:'},
		\ {'type': 'button', 'name': 'ok', 'items': [' &OK ']},
		\ ]

	echo "Press ESC to cancel -- validator should NOT be called."
	let result = quickui#dialog#open(items, {
		\ 'title': 'Cancel Test',
		\ 'validator': function('s:cancel_validator'),
		\ })
	if g:validator_called == 0
		echo 'PASS: validator not called on cancel'
	else
		echo 'FAIL: validator was called on cancel'
	endif
	echo 'Result: ' . string(result)
endfunc

echo "Available tests:"
echo "  :call Test_validator_basic()"
echo "  :call Test_validator_number()"
echo "  :call Test_validator_cancel()"
