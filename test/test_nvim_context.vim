
if 1
	call quickui#utils#highlight('default')
	let lines = [
				\ "&New File\tCtrl+n",
				\ "&Open File\tCtrl+o", 
				\ ["&Close", 'echo "test"'],
				\ "--",
				\ "&Save\tCtrl+s",
				\ "Save &As",
				\ "Save All",
				\ "-",
				\ "&User Menu\tF9",
				\ "&Dos Shell",
				\ "~&Time %{&undolevels? '+':'-'}",
				\ "--",
				\ "E&xit\tAlt+x",
				\ "&Help",
				\ ]
	" echo quickui#core#pattern_ascii
	" let menu = quickui#context#menu_compile(lines, 1)
	let opts = {'cursor': -1, 'line2':'cursor+1', 'col2': 'cursor', 'horizon':1}
	" let opts.index = 2
	let opts.callback = 'MyCallback'
	function! MyCallback(code)
		echo "callback: " . a:code
	endfunc
	let menu = quickui#context#open(lines, opts)
endif



