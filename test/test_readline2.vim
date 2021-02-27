

"----------------------------------------------------------------------
" cli test
"----------------------------------------------------------------------
function! s:test(prompt)
	let rl = quickui#readline#new()
	let index = 0
	let accept = ''
	let pos = 0
	while 1
		noautocmd redraw
		echohl Question
		echon a:prompt
		let ts = float2nr(reltimefloat(reltime()) * 1000)
		if 0
			call rl.echo(rl.blink(ts))
		else
			let size = 15
			let pos = rl.slide(pos, size)
			echohl Title
			echon "<"
			call rl.echo(rl.blink(ts), pos, size)
			echohl Title
			echon ">"
			echon " cursor=" . rl.cursor
			echon " pos=". pos
		endif
		" echon rl.display()
		try
			let code = getchar(0)
		catch /^Vim:Interrupt$/
			let code = "\<c-c>"
		endtry
		if type(code) == v:t_number && code == 0
			try
				exec 'sleep 15m'
				continue
			catch /^Vim:Interrupt$/
				let code = "\<c-c>"
			endtry
		endif
		let ch = (type(code) == v:t_number)? nr2char(code) : code
		if ch == ""
			continue
		elseif ch == "\<ESC>"
			break
		elseif ch == "\<cr>"
			let accept = rl.update()
			break
		else
			call rl.feed(ch)
		endif
	endwhile
	echohl None
	noautocmd redraw
	echo ""
	return accept
endfunc

call s:test('>>> ')


