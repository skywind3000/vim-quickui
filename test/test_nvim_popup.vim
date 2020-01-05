
let buf = nvim_create_buf(v:false, v:true)
call nvim_buf_set_lines(buf, 0, -1, v:true, ["test1", "text2", "line3"])
let opts = {'relative': 'editor', 'width': 10, 'height': 3, 'col': 0,
	\ 'row': -1, 'anchor': 'NW', 'style': 'minimal'}
let win = nvim_open_win(buf, 0, opts)
" optional: change highlight, otherwise Pmenu is used
" call nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')

redraw
echo buf
call getchar()
call nvim_win_close(win, 0)
call nvim_buf_set_lines(buf, 0, -1, v:true, ["suck" ])
" exec "bd! ". buf
