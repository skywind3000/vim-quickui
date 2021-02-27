"----------------------------------------------------------------------
" test suit
"----------------------------------------------------------------------
function! s:test()
	let v:errors = []
	let obj = quickui#readline#new()
	call obj.set('0123456789')
	call assert_equal('0123456789', obj.update(), 'test set')
	call obj.insert('ABC')
	call assert_equal('ABC0123456789', obj.update(), 'test insert')
	call obj.delete(3)
	call assert_equal('ABC3456789', obj.update(), 'test delete')
	call obj.backspace(2)
	call assert_equal('A3456789', obj.update(), 'test backspace')
	call obj.delete(1000)
	call assert_equal('A', obj.update(), 'test kill right')
	call obj.insert('BCD')
	call assert_equal('ABCD', obj.update(), 'test append')
	call obj.delete(1000)
	call assert_equal('ABCD', obj.update(), 'test append')
	call obj.backspace(1000)
	call assert_equal('', obj.update(), 'test append')
	call obj.insert('0123456789')
	call assert_equal('0123456789', obj.update(), 'test reinit')
	call obj.move(3)
	call obj.replace('abcd')
	call assert_equal('012abcd789', obj.update(), 'test replace')
	let obj.select = obj.cursor
	call obj.seek(-2, 1)
	call obj.visual_delete()
	call assert_equal('012ab789', obj.update(), 'test visual delete')
	let obj.select = obj.cursor
	call obj.seek(2, 1)
	" echo obj.display()
	call assert_equal('78', obj.visual_text(), 'test visual selection')
	call obj.visual_delete()
	call assert_equal('012ab9', obj.update(), 'test visual delete2')
	call obj.seek(-2, 1)
	if len(v:errors) 
		for error in v:errors
			echoerr error
		endfor
	else
		echo "all passed"
	endif
	call obj.move(1)
	let obj.select = 4
	" echo obj.display()
	return obj.update()
endfunc

call s:test()

