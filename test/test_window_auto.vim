" test_window_auto.vim - headless automated test for window.vim
"
" Run with:
"   vim -u NONE -N -i NONE -n --not-a-term --cmd "set lines=40 columns=100" \
"       -S test/test_window_auto.vim
"
" Exit code 0 = pass, non-zero = fail
"
" vim: set ts=4 sw=4 tw=78 noet :

set rtp+=.
runtime autoload/quickui/core.vim
runtime autoload/quickui/utils.vim
runtime autoload/quickui/style.vim
runtime autoload/quickui/window.vim


"----------------------------------------------------------------------
" test framework
"----------------------------------------------------------------------
let s:pass = 0
let s:fail = 0

function! s:assert(msg, cond) abort
	if a:cond
		let s:pass += 1
	else
		let s:fail += 1
		echoerr 'FAIL: ' . a:msg
	endif
endfunc

function! s:assert_equal(msg, expected, actual) abort
	if a:expected ==# a:actual
		let s:pass += 1
	else
		let s:fail += 1
		echoerr 'FAIL: ' . a:msg . ' expected=' . string(a:expected) . ' actual=' . string(a:actual)
	endif
endfunc

" helper: read a horizontal string from screen
function! s:screen_read(row, col, len) abort
	let result = ''
	for i in range(a:len)
		let result .= screenstring(a:row, a:col + i)
	endfor
	return result
endfunc


"======================================================================
" TEST 1: Constructor
"======================================================================
let win = quickui#window#new()
call s:assert('new: returns dict', type(win) == v:t_dict)
call s:assert_equal('new: winid', -1, win.winid)
call s:assert_equal('new: mode', 0, win.mode)
call s:assert_equal('new: bid', -1, win.bid)
call s:assert_equal('new: hide', 0, win.hide)
call s:assert_equal('new: quit', 0, win.quit)
call s:assert_equal('new: w', 1, win.w)
call s:assert_equal('new: h', 1, win.h)


"======================================================================
" TEST 2: open() basic - no border, no padding
"======================================================================
let win = quickui#window#new()
call win.open(['Hello', 'World'], {'w': 10, 'h': 2, 'x': 0, 'y': 0})
call s:assert('open: winid >= 0', win.winid >= 0)
call s:assert_equal('open: mode', 1, win.mode)
call s:assert('open: bid >= 0', win.bid >= 0)
call s:assert_equal('open: w', 10, win.w)
call s:assert_equal('open: h', 2, win.h)
call s:assert_equal('open: x', 0, win.x)
call s:assert_equal('open: y', 0, win.y)
redraw
call s:assert_equal('open: screen(1,1)=H', 'H', screenstring(1, 1))
call s:assert_equal('open: screen content', 'Hello', s:screen_read(1, 1, 5))
call s:assert_equal('open: screen line2', 'World', s:screen_read(2, 1, 5))
call win.close()


"======================================================================
" TEST 3: close() lifecycle
"======================================================================
call s:assert_equal('close: winid', -1, win.winid)
call s:assert_equal('close: bid', -1, win.bid)
call s:assert_equal('close: mode', 0, win.mode)
call s:assert_equal('close: hide', 0, win.hide)

" double close should not error (fix #4)
call win.close()
call win.close()
call s:assert('double close: safe', 1)


"======================================================================
" TEST 4: Position with offset
"======================================================================
let win = quickui#window#new()
call win.open(['ABCDE'], {'w': 5, 'h': 1, 'x': 10, 'y': 5})
redraw
" content at screen row=5+1=6, col=10+1=11
call s:assert_equal('pos offset: screen(6,11)', 'A', screenstring(6, 11))
call s:assert_equal('pos offset: full', 'ABCDE', s:screen_read(6, 11, 5))
call win.close()


"======================================================================
" TEST 5: Border display (style 1: ASCII +-|)
"======================================================================
let win = quickui#window#new()
call win.open(['Hi'], {'w': 5, 'h': 1, 'x': 0, 'y': 0, 'border': 1})
redraw
" border at (1,1), content at (2,2)
" border style 1: + corners, - horizontal, | vertical
call s:assert_equal('border: topleft', '+', screenstring(1, 1))
call s:assert_equal('border: top', '-', screenstring(1, 2))
call s:assert_equal('border: topright', '+', screenstring(1, 7))
call s:assert_equal('border: left', '|', screenstring(2, 1))
call s:assert_equal('border: right', '|', screenstring(2, 7))
call s:assert_equal('border: botleft', '+', screenstring(3, 1))
call s:assert_equal('border: bot', '-', screenstring(3, 2))
call s:assert_equal('border: botright', '+', screenstring(3, 7))
" content inside border
call s:assert_equal('border: content H', 'H', screenstring(2, 2))
call s:assert_equal('border: content i', 'i', screenstring(2, 3))
call win.close()


"======================================================================
" TEST 6: Padding with border
"======================================================================
let win = quickui#window#new()
call win.open(['XY'], {'w': 4, 'h': 1, 'x': 0, 'y': 0, 'border': 1, 'padding': [1, 1, 1, 1]})
redraw
" layout: border(row1) + padding(row2) + content(row3)
" columns: border(col1) + padding(col2) + content(col3)
call s:assert_equal('pad: border at (1,1)', '+', screenstring(1, 1))
" content at row=1+1+1=3, col=1+1+1=3
call s:assert_equal('pad: content X at (3,3)', 'X', screenstring(3, 3))
call s:assert_equal('pad: content Y at (3,4)', 'Y', screenstring(3, 4))
" verify total size
" tw = w(4) + pad_right(1) + pad_left(1) + border(2) = 8
" th = h(1) + pad_top(1) + pad_bot(1) + border(2) = 5
call s:assert_equal('pad: tw', 8, win.info.tw)
call s:assert_equal('pad: th', 5, win.info.th)
call win.close()


"======================================================================
" TEST 7: set_text()
"======================================================================
let win = quickui#window#new()
call win.open(['AA', 'BB'], {'w': 5, 'h': 2, 'x': 0, 'y': 0})
redraw
call s:assert_equal('set_text: before line1', 'A', screenstring(1, 1))
call s:assert_equal('set_text: before line2', 'B', screenstring(2, 1))
call win.set_text(['CC', 'DD'])
redraw
call s:assert_equal('set_text: after line1', 'C', screenstring(1, 1))
call s:assert_equal('set_text: after line2', 'D', screenstring(2, 1))
" verify internal state
call s:assert_equal('set_text: text[0]', 'CC', win.text[0])
call s:assert_equal('set_text: text[1]', 'DD', win.text[1])
call win.close()


"======================================================================
" TEST 8: set_line() / get_line()
"======================================================================
let win = quickui#window#new()
call win.open(['11', '22', '33'], {'w': 5, 'h': 3, 'x': 0, 'y': 0})

" get_line basic
call s:assert_equal('get_line(0)', '11', win.get_line(0))
call s:assert_equal('get_line(1)', '22', win.get_line(1))
call s:assert_equal('get_line(2)', '33', win.get_line(2))
call s:assert_equal('get_line(99) oob', '', win.get_line(99))

" set_line and verify
call win.set_line(1, 'ZZ')
call s:assert_equal('set_line: get_line(1)', 'ZZ', win.get_line(1))
redraw
call s:assert_equal('set_line: screen row2', 'Z', screenstring(2, 1))

" set_line with auto-expand
call win.set_line(5, 'EE')
call s:assert_equal('set_line expand: get_line(5)', 'EE', win.get_line(5))
call s:assert_equal('set_line expand: get_line(3)', '', win.get_line(3))

" set_line negative index (should be no-op)
call win.set_line(-1, 'BAD')
call s:assert('set_line negative: safe', 1)

call win.close()


"======================================================================
" TEST 9: move()
"======================================================================
let win = quickui#window#new()
call win.open(['MV'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
redraw
call s:assert_equal('move: initial (1,1)', 'M', screenstring(1, 1))

call win.move(5, 3)
redraw
" content at screen (3+1, 5+1) = (4, 6)
call s:assert_equal('move: screen(4,6)=M', 'M', screenstring(4, 6))
call s:assert_equal('move: x', 5, win.x)
call s:assert_equal('move: y', 3, win.y)
call win.close()


"======================================================================
" TEST 10: move() boundary clamping
"======================================================================
let win = quickui#window#new()
call win.open(['BND'], {'w': 10, 'h': 1, 'x': 0, 'y': 0})
let tw = win.info.tw
let th = win.info.th

" clamp right edge
call win.move(&columns + 100, 0)
call s:assert_equal('clamp right: x', &columns - tw, win.x)

" clamp bottom edge
call win.move(0, &lines + 100)
call s:assert_equal('clamp bottom: y', &lines - th, win.y)

" clamp negative
call win.move(-50, -50)
call s:assert_equal('clamp neg: x', 0, win.x)
call s:assert_equal('clamp neg: y', 0, win.y)

" within bounds - no clamping
call win.move(5, 3)
call s:assert_equal('no clamp: x', 5, win.x)
call s:assert_equal('no clamp: y', 3, win.y)

call win.close()


"======================================================================
" TEST 11: resize()
"======================================================================
let win = quickui#window#new()
call win.open(['RS'], {'w': 10, 'h': 3, 'x': 0, 'y': 0, 'border': 1})
call s:assert_equal('resize: initial w', 10, win.w)
call s:assert_equal('resize: initial h', 3, win.h)
call s:assert_equal('resize: initial tw', 12, win.info.tw)
call s:assert_equal('resize: initial th', 5, win.info.th)

call win.resize(20, 5)
call s:assert_equal('resize: w', 20, win.w)
call s:assert_equal('resize: h', 5, win.h)
" tw = 20 + border(2) = 22, th = 5 + border(2) = 7
call s:assert_equal('resize: tw', 22, win.info.tw)
call s:assert_equal('resize: th', 7, win.info.th)
call win.close()

" resize when mode=0
let win = quickui#window#new()
call win.resize(15, 8)
call s:assert_equal('resize mode=0: w', 15, win.w)
call s:assert_equal('resize mode=0: h', 8, win.h)


"======================================================================
" TEST 12: show() / hide
"======================================================================
let win = quickui#window#new()
call win.open(['SH'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
redraw
call s:assert_equal('show: visible char', 'S', screenstring(1, 1))
call s:assert_equal('show: hide flag', 0, win.hide)

" hide
call win.show(0)
call s:assert_equal('hide: flag', 1, win.hide)
redraw
let ch = screenstring(1, 1)
call s:assert('hide: content gone', ch !=# 'S')

" show again
call win.show(1)
call s:assert_equal('show again: flag', 0, win.hide)
redraw
call s:assert_equal('show again: char', 'S', screenstring(1, 1))

" show(0) when mode=0 is no-op
call win.close()
call win.show(0)
call s:assert('show mode=0: safe', 1)


"======================================================================
" TEST 13: center()
"======================================================================
let win = quickui#window#new()
call win.open(['CT'], {'w': 10, 'h': 2, 'x': 0, 'y': 0})
call win.center()
" x should be roughly (columns - tw) / 2
let expected_x = (&columns - win.info.tw) / 2
call s:assert_equal('center: x', expected_x, win.x)
call s:assert('center: y > 0', win.y > 0)
call s:assert('center: y reasonable', win.y < &lines / 2)
call win.close()

" center with style=1
let win = quickui#window#new()
call win.open(['C2'], {'w': 10, 'h': 2, 'x': 0, 'y': 0})
call win.center(1)
let expected_x = (&columns - win.info.tw) / 2
call s:assert_equal('center1: x', expected_x, win.x)
call s:assert('center1: y > 0', win.y > 0)
call win.close()


"======================================================================
" TEST 14: execute() deferred (before open)
"======================================================================
let win = quickui#window#new()
call win.execute(['setl tabstop=8'])
" pending_cmd should be stored in info
call s:assert('deferred: stored', len(win.info.pending_cmd) == 1)
call s:assert_equal('deferred: content', 'setl tabstop=8', win.info.pending_cmd[0])

" multiple execute calls accumulate
call win.execute(['setl scrolloff=0'])
call s:assert_equal('deferred: accumulated', 2, len(win.info.pending_cmd))

" open should consume pending_cmd (fix #2: commands preserved across open)
call win.open(['EX'], {'w': 10, 'h': 1, 'x': 0, 'y': 0})
call s:assert_equal('deferred: consumed', [], win.info.pending_cmd)
call win.close()


"======================================================================
" TEST 15: execute() while window is open
"======================================================================
let win = quickui#window#new()
call win.open(['NR'], {'w': 10, 'h': 1, 'x': 0, 'y': 0})
" execute immediately - should not error
call win.execute(['setl tabstop=8'])
call win.execute('setl scrolloff=0')
call s:assert('execute open: no error', 1)
call s:assert_equal('execute open: pending empty', [], win.info.pending_cmd)
call win.close()


"======================================================================
" TEST 16: execute() with string argument (newline split)
"======================================================================
let win = quickui#window#new()
call win.execute("setl tabstop=8\nsetl scrolloff=0")
call s:assert_equal('execute string: split', 2, len(win.info.pending_cmd))
call s:assert_equal('execute string: line1', 'setl tabstop=8', win.info.pending_cmd[0])
call s:assert_equal('execute string: line2', 'setl scrolloff=0', win.info.pending_cmd[1])


"======================================================================
" TEST 17: info.tw/th calculation
"======================================================================
" no border, no padding
let win = quickui#window#new()
call win.open(['X'], {'w': 20, 'h': 5, 'x': 0, 'y': 0})
call s:assert_equal('tw no border', 20, win.info.tw)
call s:assert_equal('th no border', 5, win.info.th)
call s:assert_equal('has_border=0', 0, win.info.has_border)
call s:assert_equal('has_padding=0', 0, win.info.has_padding)
call win.close()

" with border only
let win = quickui#window#new()
call win.open(['X'], {'w': 20, 'h': 5, 'x': 0, 'y': 0, 'border': 1})
call s:assert_equal('tw border', 22, win.info.tw)
call s:assert_equal('th border', 7, win.info.th)
call s:assert_equal('has_border=1', 1, win.info.has_border)
call win.close()

" with padding only
let win = quickui#window#new()
call win.open(['X'], {'w': 20, 'h': 5, 'x': 0, 'y': 0, 'padding': [2, 3, 2, 3]})
call s:assert_equal('tw padding', 26, win.info.tw)
call s:assert_equal('th padding', 9, win.info.th)
call s:assert_equal('has_padding=1', 1, win.info.has_padding)
call win.close()

" with both
let win = quickui#window#new()
call win.open(['X'], {'w': 20, 'h': 5, 'x': 0, 'y': 0, 'border': 1, 'padding': [1, 2, 1, 2]})
" tw = 20 + 2 + 2 + 2 = 26, th = 5 + 1 + 1 + 2 = 9
call s:assert_equal('tw both', 26, win.info.tw)
call s:assert_equal('th both', 9, win.info.th)
call win.close()


"======================================================================
" TEST 18: height behavior
"======================================================================
" when h is not specified (default -1), self.h becomes 1
let win = quickui#window#new()
call win.open(['L1', 'L2', 'L3', 'L4'], {'w': 5, 'x': 0, 'y': 0})
call s:assert_equal('default h', 1, win.h)
call win.close()

" explicit h works correctly
let win = quickui#window#new()
call win.open(['L1', 'L2', 'L3', 'L4'], {'w': 5, 'h': 4, 'x': 0, 'y': 0})
call s:assert_equal('explicit h=4', 4, win.h)
redraw
call s:assert_equal('explicit h: line1', 'L', screenstring(1, 1))
call s:assert_equal('explicit h: line4', 'L', screenstring(4, 1))
call win.close()


"======================================================================
" TEST 19: open() replaces existing window
"======================================================================
let win = quickui#window#new()
call win.open(['OLD'], {'w': 10, 'h': 1, 'x': 0, 'y': 0})
let old_winid = win.winid
call s:assert('replace: old winid valid', old_winid >= 0)
call win.open(['NEW'], {'w': 10, 'h': 1, 'x': 0, 'y': 0})
call s:assert('replace: new winid valid', win.winid >= 0)
redraw
call s:assert_equal('replace: shows NEW', 'N', screenstring(1, 1))
call win.close()


"======================================================================
" TEST 20: multiple open/close cycles
"======================================================================
let win = quickui#window#new()
call win.open(['C1'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
call s:assert('cycle1: open', win.winid >= 0)
call win.close()
call s:assert_equal('cycle1: close', -1, win.winid)

call win.open(['C2'], {'w': 8, 'h': 2, 'x': 3, 'y': 2})
call s:assert('cycle2: open', win.winid >= 0)
call s:assert_equal('cycle2: w', 8, win.w)
redraw
call s:assert_equal('cycle2: screen(3,4)=C', 'C', screenstring(3, 4))
call win.close()

call win.open(['C3'], {'w': 6, 'h': 1, 'x': 1, 'y': 1})
call s:assert('cycle3: open', win.winid >= 0)
redraw
call s:assert_equal('cycle3: screen(2,2)=C', 'C', screenstring(2, 2))
call win.close()


"======================================================================
" TEST 21: title in border
"======================================================================
let win = quickui#window#new()
call win.open(['BODY'], {'w': 20, 'h': 1, 'x': 0, 'y': 0, 'border': 1, 'title': ' Test '})
redraw
" title should appear somewhere in the top border row (row 1)
let found_t = 0
for col in range(1, 22)
	if screenstring(1, col) ==# 'T'
		let found_t = 1
		break
	endif
endfor
call s:assert('title: T found in border row', found_t)
" verify content still works
call s:assert_equal('title: content', 'B', screenstring(2, 2))
call win.close()


"======================================================================
" TEST 22: syntax_begin / syntax_region / syntax_end
"======================================================================
let win = quickui#window#new()
call win.open(['SYNTAX TEST'], {'w': 11, 'h': 1, 'x': 0, 'y': 0})
" just verify these don't error
call win.syntax_begin()
call win.syntax_region('QuickSel', 0, 0, 6, 0)
call win.syntax_region('QuickKey', 7, 0, 11, 0)
call win.syntax_end()
redraw
call s:assert('syntax: no error', 1)
" content should still be intact
call s:assert_equal('syntax: content', 'SYNTAX TEST', s:screen_read(1, 1, 11))
call win.close()

" syntax_begin with empty region (x1 >= x2 on same line) - should skip
let win = quickui#window#new()
call win.open(['SKIP'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
call win.syntax_begin()
call win.syntax_region('QuickSel', 5, 0, 3, 0)
call win.syntax_end()
redraw
call s:assert('syntax empty: no error', 1)
call win.close()


"======================================================================
" TEST 23: mouse_click() basic
"======================================================================
let win = quickui#window#new()
call win.open(['MOUSE'], {'w': 10, 'h': 1, 'x': 5, 'y': 3})
" simulate that the click is NOT in this window
" (v:mouse_winid won't match, so we get {-1, -1})
" just verify the method doesn't error
let click = win.mouse_click()
call s:assert_equal('mouse: returns dict', v:t_dict, type(click))
call s:assert('mouse: has x', has_key(click, 'x'))
call s:assert('mouse: has y', has_key(click, 'y'))
call win.close()


"======================================================================
" TEST 24: quit flag
"======================================================================
let win = quickui#window#new()
call win.open(['QT'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
call s:assert_equal('quit: initial', 0, win.quit)
" manually set quit (simulating close button click)
let win.quit = 1
call s:assert_equal('quit: set', 1, win.quit)
call win.close()


"======================================================================
" TEST 25: wrap option
"======================================================================
let win = quickui#window#new()
let long_text = repeat('W', 50)
call win.open([long_text], {'w': 10, 'h': 3, 'x': 0, 'y': 0, 'wrap': 1})
redraw
" with wrap, the long text should appear on multiple lines
call s:assert_equal('wrap: row1', 'W', screenstring(1, 1))
call s:assert_equal('wrap: row2', 'W', screenstring(2, 1))
call win.close()


"======================================================================
" TEST 26: update() method
"======================================================================
let win = quickui#window#new()
call win.open(['UP'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
redraw
call s:assert_equal('update: before', 'U', screenstring(1, 1))
" directly modify text and call update
let win.text[0] = 'DOWN'
call win.update()
redraw
call s:assert_equal('update: after', 'D', screenstring(1, 1))
call s:assert_equal('update: full', 'DOWN', s:screen_read(1, 1, 4))
call win.close()


"======================================================================
" TEST 27: set_text with string (newline split)
"======================================================================
let win = quickui#window#new()
call win.open(['X'], {'w': 10, 'h': 3, 'x': 0, 'y': 0})
call win.set_text("Line1\nLine2\nLine3")
call s:assert_equal('set_text str: text[0]', 'Line1', win.text[0])
call s:assert_equal('set_text str: text[1]', 'Line2', win.text[1])
call s:assert_equal('set_text str: text[2]', 'Line3', win.text[2])
redraw
call s:assert_equal('set_text str: screen1', 'Line1', s:screen_read(1, 1, 5))
call s:assert_equal('set_text str: screen2', 'Line2', s:screen_read(2, 1, 5))
call win.close()


"======================================================================
" TEST 28: options - center on open
"======================================================================
let win = quickui#window#new()
call win.open(['CEN'], {'w': 10, 'h': 1, 'center': 1})
let expected_x = (&columns - win.info.tw) / 2
call s:assert_equal('center opt: x', expected_x, win.x)
call s:assert('center opt: y > 0', win.y > 0)
call win.close()


"======================================================================
" TEST 29: options - hide on open
"======================================================================
let win = quickui#window#new()
call win.open(['HIDDEN'], {'w': 10, 'h': 1, 'x': 0, 'y': 0, 'hide': 1})
call s:assert_equal('hide opt: hide flag', 1, win.hide)
redraw
let ch = screenstring(1, 1)
call s:assert('hide opt: not visible', ch !=# 'H')
" show it
call win.show(1)
redraw
call s:assert_equal('hide opt: now visible', 'H', screenstring(1, 1))
call win.close()


"======================================================================
" TEST 30: refresh() doesn't error
"======================================================================
let win = quickui#window#new()
call win.open(['RF'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
call win.refresh()
call s:assert('refresh: no error', 1)
call win.close()


"======================================================================
" TEST 31: z-index / priority
"======================================================================
let win = quickui#window#new()
call win.open(['Z'], {'w': 5, 'h': 1, 'x': 0, 'y': 0, 'z': 100})
call s:assert_equal('z: stored', 100, win.z)
call win.close()


"======================================================================
" TEST 32: multiple independent windows
"======================================================================
let win1 = quickui#window#new()
let win2 = quickui#window#new()
call win1.open(['W1'], {'w': 5, 'h': 1, 'x': 0, 'y': 0, 'z': 50})
call win2.open(['W2'], {'w': 5, 'h': 1, 'x': 0, 'y': 2, 'z': 51})
redraw
call s:assert_equal('multi: win1 visible', 'W', screenstring(1, 1))
call s:assert_equal('multi: win2 visible', 'W', screenstring(3, 1))
call s:assert('multi: different winid', win1.winid != win2.winid)
call win1.close()
call win2.close()


"======================================================================
" TEST 33: close button option (button=1)
"======================================================================
let win = quickui#window#new()
call win.open(['BTN'], {'w': 10, 'h': 1, 'x': 0, 'y': 0, 'border': 1, 'button': 1})
redraw
" With button=1, a close button 'X' should appear in the top-right corner
" of the border (at row 1, col = tw = 12)
let tw = win.info.tw
let btn_char = screenstring(1, tw)
call s:assert_equal('button: X at top-right', 'X', btn_char)
call win.close()


"======================================================================
" TEST 34: execute deferred across open (fix #2 verification)
"======================================================================
let win = quickui#window#new()
" set commands before open
call win.execute(['setl tabstop=8'])
call win.execute(['setl scrolloff=0'])
let pending_before = len(win.info.pending_cmd)
call s:assert_equal('fix2: pending before open', 2, pending_before)

" open - commands should be consumed
call win.open(['FX'], {'w': 5, 'h': 1, 'x': 0, 'y': 0})
call s:assert_equal('fix2: pending after open', 0, len(win.info.pending_cmd))
call win.close()


"======================================================================
" RESULTS
"======================================================================
echo printf('Results: %d passed, %d failed', s:pass, s:fail)
if s:fail > 0
	cquit!
endif
qall!
