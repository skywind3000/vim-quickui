function! TermExit(code)
	echom "terminal exit code: ". a:code
endfunc

let opts = {'w':60, 'h':8, 'callback':'TermExit'}
let opts.title = 'Terminal Popup'
call quickui#terminal#open('python', opts)


