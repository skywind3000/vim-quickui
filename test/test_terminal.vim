function! TermExit(code)
	echom "terminal exit code: ". a:code
	echom "current win: ". winnr()
endfunc

let opts = {'w':80, 'h':24, 'callback':'TermExit'}
let opts.title = 'Terminal Popup'
call quickui#terminal#open('python', opts)


