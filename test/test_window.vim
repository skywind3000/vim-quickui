let opts = {}
let opts.w = 40
let opts.h = 5
let opts.x = 40
let opts.y = 2
let opts.title = ' Hello, World '
let opts.border = 'default'
let opts.padding = [0, 1, 0, 1]
let opts.button = 1
" let opts.center = 1
" let opts.hide = 1
let text = ['012345678901234567890123456789', 'abcdef']

let win = quickui#window#new()
call win.open(text, opts)
" call win.set_text(text)
" call win.execute('setl number')


redraw

" echo win.opts

call getchar()

call win.show(0)
redraw
call getchar()

call win.set_line(4, 'Hello, Vim World !!')
call win.move(50, 10)
call win.show(1)
call win.resize(30, 7)
call win.center()
redraw
echo win.quit
call getchar()

call win.close()

" echo [win.w, win.h, win.info.tw, win.info.th]

