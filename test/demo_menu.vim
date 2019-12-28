
if has('patch-8.2.1') == 0 || has('nvim')
	finish
endif

call quickui#menu#reset()

" install a 'File' menu, each item comprises its name and command to execute
call quickui#menu#install('&File', [
            \ [ "&New File\tCtrl+n", 'new' ],
            \ [ "&Open File\t(F3)", 'call feedkeys(":edit ")' ],
            \ [ "&Close", 'close' ],
            \ [ "--", '' ],
            \ [ "&Save\tCtrl+s", 'w'],
            \ [ "Save &As", 'call feedkey(":saveas ")' ],
            \ [ "Save All", 'wa' ],
            \ [ "--", '' ],
            \ [ "E&xit\tAlt+x", 'q' ],
            \ ])

" items contains tips, tips will display in the bottom of screen
call quickui#menu#install('&Plugin', [
			\ ["&NERDTree\t<space>tn", 'NERDTreeToggle', 'toggle nerdtree'],
			\ ['&Tagbar', '', 'toggle tagbar'],
			\ ["&Choose Window/Tab\tAlt+e", "ChooseWin", "fast switch win/tab with vim-choosewin"],
			\ ["-"],
			\ ["&Browse in github", "Gbrowse", "using tpope's rhubarb to open browse and view the file"],
			\ ["&Startify", "Startify", "using tpope's rhubarb to open browse and view the file"],
			\ ["&Gist", "Gist", "open gist with mattn/gist-vim"],
			\ ["&Edit Note", "Note", "edit note with vim-notes"],
			\ ["&Display Calendar", "Calendar", "display a calender"],
			\ ["-"],
			\ ["Plugin &List", "PlugList", 'list available plugins'],
			\ ["Plugin &Update", "PlugUpdate", 'update plugins'],
			\ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Tools", [
			\ ["Switch &Buffer", 'call quickui#tools#kit_buffers("e")'],
			\ ["-"],
			\ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!', 'Toggle spell check %{&spell? "off" : "on"}'],
			\ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!', 'Toggle cursor line %{&cursorline? "off" : "on"}'],
			\ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!', 'Toggle paste mode %{&paste? "off" : "on"}'],
			\ ])

call quickui#menu#install('H&elp', [
			\ ["&Cheatsheet", 'help index', ''],
			\ ['T&ips', 'help tips', ''],
			\ ['--',''],
			\ ["&Tutorial", 'help tutor', ''],
			\ ['&Quick Reference', 'help quickref', ''],
			\ ['&Summary', 'help summary', ''],
			\ ['--',''],
			\ ['&Vim Script', 'help eval', ''],
			\ ['&Function List', 'help function-list', ''],
			\ ], 10000)

" display tips in the cmdline
let g:quickui_show_tip = 1

" press <space> twice to open menu
nnoremap <silent><space><space> :call quickui#menu#open()<cr>

