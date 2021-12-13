
if 1
	let lines = []
	for i in range(2000)
		let lines += ['printf("%d\n", ' . (i + 1) . ');']
	endfor
	let opts = {}
	let opts.index = 30
	let opts.resize = 1
	let opts.title = "title"
	let opts.syntax = "cpp"
	let opts.color = "QuickPreview"
	let opts.bordercolor = 'WildMenu'
	" let opts.bordercolor = "QuickBG"
	" let opts.title = ''
	" let opts.border = 0
	let opts.cursor = 38
	let opts.number = 1
	" let opts.exit_on_click = 0
	let winid = quickui#textbox#open(lines, opts)
	" call getchar()
	" call quickui#textbox#close(winid)
endif

