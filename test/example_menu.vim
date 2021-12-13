
"----------------------------------------------------------------------
" testing suit
"----------------------------------------------------------------------
if 1
	call quickui#menu#switch('test')
	call quickui#menu#reset()
	call quickui#menu#install('H&elp', [
				\ [ '&Content', 'echo 4' ],
				\ [ '&About', 'echo 5' ],
				\ ])
	call quickui#menu#install('&File', [
				\ [ "&New File\tCtrl+n", 'echo 0' ],
				\ [ "&Open File\t(F3)", 'echo 1' ],
				\ [ "&Close", 'echo 2' ],
				\ [ "--", '' ],
				\ [ "&Save\tCtrl+s", 'echo 3'],
				\ [ "Save &As", 'echo 4' ],
				\ [ "Save All", 'echo 5' ],
				\ [ "--", '' ],
				\ [ "E&xit\tAlt+x", 'echo 6' ],
				\ ])
	call quickui#menu#install('&Edit', [
				\ [ '&Copy', 'echo 1'],
				\ [ '&Paste', 'echo 2'],
				\ [ '&Find', 'echo 3'],
				\ ])
	call quickui#menu#install('&Tools', [
				\ [ '&Copy', 'echo 1'],
				\ [ '&Paste', 'echo 2'],
				\ [ '&Find', 'echo 3'],
				\ ])

	call quickui#menu#install('&Window', [])
	call quickui#menu#change_weight('H&elp', 1000)
	call quickui#menu#switch('system')
	call quickui#menu#open('test')
endif



