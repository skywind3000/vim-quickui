

if 1
	call quickui#menu#switch('test')
	call quickui#menu#reset()
	call quickui#menu#install('H&elp', [
				\ [ '&Content', 'echo 4' ],
				\ [ '&About', 'echo 5' ],
				\ ])
	call quickui#menu#install('&File', [
				\ [ "&New File\tCtrl+n", '' ],
				\ [ "&Open File\t(F3)", 'echo 1' ],
				\ [ "&Close", 'echo 3' ],
				\ [ "--", '' ],
				\ [ "&Save\tCtrl+s", ''],
				\ [ "Save &As", '' ],
				\ [ "Save All", '' ],
				\ [ "--", '' ],
				\ [ "E&xit\tAlt+x", '' ],
				\ ])
	call quickui#menu#install('&Edit', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])
	call quickui#menu#install('&Tools', [
				\ [ '&Copy', 'echo 1', 'help1' ],
				\ [ '&Paste', 'echo 2', 'help2' ],
				\ [ '&Find', 'echo 3', 'help3' ],
				\ ])

	call quickui#menu#install('&Window', [])
	call quickui#menu#change_weight('H&elp', 1000)
	call quickui#menu#switch('system')
	let opts = {'name':'test'}
	call quickui#menu#nvim_open_menu(opts)
	" call quickui#menu#open('test')
endif



