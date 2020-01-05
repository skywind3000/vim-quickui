
if 1
	let lines = []
	for i in range(2000)
		let lines += ['printf("%d\n", ' . (i + 1) . ');']
	endfor
	let opts = {'close':'button'}
	let opts.index = 1
	let opts.resize = 1
	let opts.title = "title"
	let opts.syntax = "cpp"
	" let opts.color = "QuickBox"
	" let opts.bordercolor = "QuickBG"
	" let opts.cursor = 38
	" let opts.number = 1
	" let opts.exit_on_click = 0
	" let winid = quickui#textbox#open(lines, opts)
	" call getchar()
	" call quickui#textbox#close(winid)
	call quickui#textbox#create(lines, opts)
endif


