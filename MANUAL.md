# User Manual

QuickUI is fully customizable, and can be easily configurated.

# Content

<!-- TOC -->

- [User Manual](#user-manual)
- [Content](#content)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Available Widgets](#available-widgets)
    - [Menu](#menu)
    - [Listbox](#listbox)
    - [Inputbox](#inputbox)
    - [Context menu](#context-menu)
    - [Textbox](#textbox)
    - [Preview window](#preview-window)
    - [Terminal](#terminal)
    - [Confirm dialog](#confirm-dialog)
  - [Tools](#tools)
    - [Buffer switcher](#buffer-switcher)
    - [Function list](#function-list)
    - [Help viewer](#help-viewer)
    - [Preview tag](#preview-tag)
    - [Preview quickfix](#preview-quickfix)
  - [Customize](#customize)
    - [How to change border style](#how-to-change-border-style)
    - [How to change the color scheme](#how-to-change-the-color-scheme)
    - [How to change preview window size](#how-to-change-preview-window-size)
    - [Specify color group precisely](#specify-color-group-precisely)
  - [Who Am I ?](#who-am-i-)
  - [Credit](#credit)

<!-- /TOC -->

## Requirements

- Vim: 8.2 or later.
- NeoVim: 0.4.0 or later.

## Installation

    Plug 'skywind3000/vim-quickui'

## Available Widgets

### Menu

Display a dropdown menubar at top of the screen:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

**Usage**:

- `h` / `CTRL+h` / `LEFT`: move left.
- `l` / `CTRL+l` / `RIGHT`: move right.
- `j` / `CTRL+j` / `DOWN`: move down.
- `k` / `CTRL+k` / `UP`: move up.
- `SPACE` / `ENTER`: confirm.
- `ESC` / `CTRL+[`: cancel.
- `H`: move to the left-most menu.
- `L`: move to the right-most menu.
- `J`: move to the last item.
- `K`: move to the first item.

Note: `hjkl` may be overried by user hotkeys, so `CTRL`+`hjkl` or arrow keys can be used at all time.

**APIs**:

register menu entries:

```VimL
call quickui#menu#install(section, items [, weight [, filetypes]])
```

display the menu:

```VimL
call quickui#menu#open()
```

**Sample code**:

```VimL
" clear all the menus
call quickui#menu#reset()

" install a 'File' menu, use [text, command] to represent an item.
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

" items containing tips, tips will display in the cmdline
call quickui#menu#install('&Edit', [
            \ [ '&Copy', 'echo 1', 'help 1' ],
            \ [ '&Paste', 'echo 2', 'help 2' ],
            \ [ '&Find', 'echo 3', 'help 3' ],
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
			\ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
			\ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
			\ ])

" register HELP menu with weight 10000
call quickui#menu#install('H&elp', [
			\ ["&Cheatsheet", 'help index', ''],
			\ ['T&ips', 'help tips', ''],
			\ ['--',''],
			\ ["&Tutorial", 'help tutor', ''],
			\ ['&Quick Reference', 'help quickref', ''],
			\ ['&Summary', 'help summary', ''],
			\ ], 10000)

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" hit space twice to open menu
noremap <space><space> :call quickui#menu#open()<cr>
```

Then you can open the menu by pressing space twice. If the 4th parameter `filetypes` is provided as a comma separated list, the menu will display only if the current file type can be matched in the list.

```VimL
call quickui#menu#install('&C/C++', [
            \ [ '&Compile', 'echo 1' ],
            \ [ '&Run', 'echo 2' ],
            \ ], '<auto>', 'c,cpp')
```

This `C/C++` menu will be visible only if the `filetype` of current buffer is `c` or `cpp`.

As we are living in multiverse, and menus can be separated in [multiple namespaces](https://github.com/skywind3000/vim-quickui/wiki/Menu-Namespaces) too. The `quickui#menu#open` function can actually take one more argument like:

```VimL
call quickui#menu#open('abc')
```

If it is invoked with an argument "abc", menus in the namespace "abc" will display immediately. If this argument is omitted, the default namespace "system" will be used.

### Listbox

When you have hundres of items to deal with, menu is not enough to hold them. Then you will need a listbox.

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

**Features**:

- Listbox can used to pick up a item from thousands items.
- Columns separated by `"\t"` will be aligned.
- A scroll bar will display if there are too many items.
- Mouse wheel can be used to scroll the content.
- Character starting with `&` can be used as a shortcut.
- It has a title, and can be dragged by mouse.
- Search item with `/` or `?` command.
- Jump to line with `:` command.

**Usage**:

- `j` / `CTRL+j` / `UP`: move up.
- `k` / `CTRL+k` / `DOWN`: move down.
- `J` / `CTRL+d`: half page down.
- `K` / `CTRL+u`: half page up.
- `H` / `CTRL+b` / `PageUp`: page up.
- `L` / `CTRL+f` / `PageDown`: page down.
- `SPACE` / `ENTER`: confirm.
- `ESC` / `CTRL+[`: cancel.
- `g`: go to the first item.
- `G`: go to the last item.
- `/`: search forwards.
- `?`: search backwards.
- `:`: go to line number.
- `n` / `CTRL+n`: next match.
- `N` / `CTRL+p`: previous match.

Note: `hjkl` or `n` may be overried by user hotkeys, so `CTRL`+`hjkl` or `CTRL`+`n` can always be used at all time.

**APIs**:

Open the listbox:

```VimL
quickui#listbox#open(content, opts)
```

Parameter `content` is a list of `[text, command]` items. `opts` is a dictionary of options, available options are:

- `title`: title of the listbox.
- `index`: initial cursor position, starts from 0.
- `w`: listbox width.
- `h`: listbox height.
- `col`: screen position in columns, starts from 1.
- `line`: screen position in lines, starts from 1.
- `color`: background color, default to `QuickBG`.
- `syntax`: the `filetype` apply to the `listbox`.
- `callback`: a function (`"fn(code)"` form) which will be called after listbox closed (press Enter or ESC).

All options are not compulsorily required and can be omitted. The `callback` function will be invoked with a parameter `code` which represent the selected item index. If you quit (`ESC`/`CTRL+[`) without making your selection, `code` will be `-1`.

There is an internal variable `g:quickui#listbox#cursor` which stores the last cursor position (index) in the listbox. It can be used to restore previous location.

**Sample code**:

```VimL
let content = [
            \ [ 'echo 1', 'echo 100' ],
            \ [ 'echo 2', 'echo 200' ],
            \ [ 'echo 3', 'echo 300' ],
            \ [ 'echo 4' ],
            \ [ 'echo 5', 'echo 500' ],
            \]
let opts = {'title': 'select one'}
call quickui#listbox#open(content, opts)
```

It can also work like `inputlist()` function by using `quickui#listbox#inputlist`, it will return the index you select immediatedly instead of executing a vim command:

```VimL
let linelist = [
            \ "line &1",
            \ "line &2",
            \ "line &3",
            \ ]
" restore last position in previous listbox
let opts = {'index':g:quickui#listbox#cursor, 'title': 'select'}
echo quickui#listbox#inputlist(linelist, opts)
```

The key difference between `open` and `inputlist` is `open` will return immediately to vim's event loop while `inputlist` won't return until you select an item or press `ESC`.

### Inputbox

Prompt user to input a string in a TUI box:

![](https://skywind3000.github.io/images/p/quickui/input1.png)

Could be used as a drop-in replacement of `input()` function:

**APIs**:

```VimL
quickui#input#open(prompt [, text [, history_key]])
```

**Sample code**

```VimL
echo quickui#input#open('Enter your name:', 'nobody')
```

**Usage**:

- `Left` / `Ctrl+B`: move cursor left.
- `Right` / `Ctrl+F`: move cursor right.
- `Shift+Left`: select left.
- `Shift+Right`: select right.
- `Ctrl+g`: select all.
- `Up` / `Ctrl+P`: previous history.
- `Down` / `Ctrl+N`: next history.
- `Ctrl+Insert`: copy to register `*`.
- `Shift+Insert`: paste from register `*`.
- `Ctrl+K`: kill all characters on and after cursor.
- `Ctrl+D`: delete character under cursor.
- `Ctrl+W`: delete word before cursor.
- `Home` / `Ctrl+A`: rewind cursor.
- `End` / `Ctrl+E`: move cursor to the line end. 
- `Ctrl+R Ctrl+W`: read current word.
- `Ctrl+R =`: read evaluation.
- `Ctrl+R {reg}`: read register.

**Another Sample**

```VimL
function! SearchBox()
	let cword = expand('<cword>')
	let title = 'Enter text to search:'
	let text = quickui#input#open(title, cword, 'search')
	if text != ''
		let text = escape(text, '[\/*~^')
		call feedkeys("\<ESC>/" . text . "\<cr>", 'n')
	endif
endfunc
```

You can search text with this function without dealing with special character escaping.

### Context menu

Context menu imitates Windows context menu (triggered by your mouse right button), which will display around the cursor:

![](https://skywind3000.github.io/images/p/quickui/context.png)

It is usually used to present some commands that will do something with source code in the current line.

**APIs**:

open the context menu:

```VimL
quickui#context#open(content, opts)
```

Parameter `content` is a list of `[text, command]` items. `opts` is a dictionary of options, has similar options in `listbox` but an additional option:

- `ignore_case`: ignore case of the keyword, default 1.

**Sample code**:

```VimL
let content = [
            \ ["&Help Keyword\t\\ch", 'echo 100' ],
            \ ["&Signature\t\\cs", 'echo 101'],
            \ ['-'],
            \ ["Find in &File\t\\cx", 'echo 200' ],
            \ ["Find in &Project\t\\cp", 'echo 300' ],
            \ ["Find in &Defintion\t\\cd", 'echo 400' ],
            \ ["Search &References\t\\cr", 'echo 500'],
            \ ['-'],
            \ ["&Documentation\t\\cm", 'echo 600'],
            \ ]
" set cursor to the last position
let opts = {'index':g:quickui#context#cursor}
call quickui#context#open(content, opts)
```

You can define your own context menu and map it to `K` (override the original `keywordprg` command). And you will get a much more powerful `K` command then before.

### Textbox

Textbox is used to display arbitrary text in a popup window.

![](https://skywind3000.github.io/images/p/quickui/textbox.png)

**Features**:

- HJKL to scroll up/down, ESC to quit
- Support syntax highlighting

**APIs**:

open textbox:

```VimL
quickui#textbox#open(textlist, opts)
```

Run a shell command and display the output in the textbox:

```VimL
quickui#textbox#command(command, opts)
```

**Sample code**:

```VimL
" display vim messages in the textbox
function! DisplayMessages()
    let x = ''
    redir => x
    silent! messages
    redir END
    let x = substitute(x, '[\n\r]\+\%$', '', 'g')
    let content = filter(split(x, "\n"), 'v:key != ""')
    let opts = {"close":"button", "title":"Vim Messages"}
    call quickui#textbox#open(content, opts)
endfunc
```

This function can display vim error messages (`:messages`) in the text window:

![](https://skywind3000.github.io/images/p/quickui/messages.png)

Navigating the messages with `HJKL` or `PageUp/PageDown` is much handy than list them in the command line by `:messages`.

### Preview window

Preview window is used to replace traditional `pedit` command and can be used to display certain file in a small popup window around your cursor:

![](https://skywind3000.github.io/images/p/quickui/preview.png)

You can open the preview window by:

```VimL
quickui#preview#open(filename, opts)
```

It will not interfere your work, and will immediately close if you move your cursor around. The second parameter `opts` is a dictionary with options, available options are:

| Option | Type | Default | Description |
|-|-|-|-|
| cursor | Number | -1 | if you set it above zero, the certain line  will be highlighted (use cursorline). |
| number | Number | 1 | set to zero to disable line number |
| syntax | String | `unset` | additional syntax file type, eg: `cpp` or `python` |
| title | String | `unset` | additional title for preview window |
| persist | Number | 0 | By default the preview window will be closed automatically when `CursorMove` happens, set to 1 to close it manually by `quickui#preview#close()` |
| col | Number | `unset` | specify window position by column |
| line | Number | `unset` | specify window position by line number |
| w | Number | `unset` | specify window size by width |
| h | Number | `unset` | specify window size by height |

Usually the syntax highlighting and cursorline will help you when you are using it to peek symbol definitions.

The `filename` argument can be provided as a list of strings, if so, preview window will display the content of the list, and `syntax` filed in the `opts` argument can be used for highlighting.

User can scroll the content in the preview window by:

```VimL
quickui#preview#scroll(offset)
```

Parameter `offset` is an integer, above zero to scroll down and below zero to scroll up.

### Terminal

The `terminal` widget can allow you open a terminal in the popup window:

```VimL
quickui#terminal#open(cmd, opts)
```

Parameter `cmd` can be a string or a list, and `opts` is a dictionary of options, available options are:

| Option | Type | Default | Description |
|-|-|-|-|
| w | Number | 80 | terminal window width |
| h | Number | 24 | terminal window height |
| col | Number | `unset` | window horizontal position |
| line | Number | `unset` | window vertical position |
| border | Number | 1 | use `0` for no border |
| title | String | `unset` | window title |
| callback | String/Function | `unset` | a function with one argument to receive exit code when terminal exit |

e.g.

```VimL
function! TermExit(code)
    echom "terminal exit code: ". a:code
endfunc

let opts = {'w':60, 'h':8, 'callback':'TermExit'}
let opts.title = 'Terminal Popup'
call quickui#terminal#open('python', opts)
```

When you run it, it will run `python` in a popup window:

![](https://skywind3000.github.io/images/p/quickui/terminal.png)

This feature require vim `8.2.200` (nvim `0.4.0`) or later, it enables you to run various tui programs in a dialog window.

### Confirm dialog

This widget offers user a dialog, from which a choice can be made. It returns the number of the choice. For the first choice, this is 1.

```VimL
quickui#confirm#open(msg, [choices, [default, [title]]])
```

e.g.

```VimL
let question = "What do you want ?"
let choices = "&Apples\n&Oranges\n&Bananas"

let choice = quickui#confirm#open(question, choices, 1, 'Confirm')

if choice == 0
	echo "make up your mind!"
elseif choice == 3
	echo "tasteful"
else
	echo "I prefer bananas myself."
endif
```

Result:

![](https://skywind3000.github.io/images/p/quickui/confirm1.png)

Use `h` and `l` to move cursor, `<space>` or `<cr>` to confirm and `<ESC>` to give up. Mouse is also supported.

## Tools

Tools are build upon basic widgets.

### Buffer switcher

There is a builtin buffer switcher using `listbox`, open it by:

    call quickui#tools#list_buffer('e')

or

    call quickui#tools#list_buffer('tabedit')

Then `hjkl` to navigate, `enter`/`space` to switch buffer and `ESC`/`CTRL+[` to quit:

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

If there are many buffers listed, you can use `/` or `?` to search, and `n` or `N` to jump to the next / previous match.

Usage:

- `j`/`k`: navigate.
- `ESC`/`CTRL+[`: quit
- `Enter`: open with `switchbuf` rules (override with `g:quickui_switch_enter`).
- `Space`: open with `switchbuf` rules (override with `g:quickui_switch_space`).
- `CTRL+e`: edit in current window.
- `CTRL+x`: open in a new split.
- `CTRL+]`: open in a new vertical split.
- `CTRL+t`: open in a new tab.
- `CTRL+g`: open with `:drop` command.
- `/`: search.
- `?`: search backwards.

If you want to open file in current window when pressing `Space`, you can either change `switchbuf` option or change `g:quickui_switch_space` manually:

```VimL
let g:quickui_switch_space = ''
```

Once it has been defined, it will overshadow `switchbuf` option, and an empty string means edit in the current window. 

    :h switchbuf

For more information, please see the help of `switchbuf`.



### Function list

Function list can be actived by:

    call quickui#tools#list_function()

The cursor will stay in the current function initially:

![](https://skywind3000.github.io/images/p/quickui/list-function.png)

Navigate and press enter to jump to the selected function. This feature requires `ctags` in you `$PATH`.

### Help viewer

Use `textbox` to display vim help in a popup window:

    call quickui#tools#display_help('index')

See the screenshot:

![](https://skywind3000.github.io/images/p/quickui/display-help.png)

The only one argument in `display_help` is the help tag name. With this tool, you can read the help text anytime, without creating a new split window.

### Preview tag

Sometimes I just want a glimpse to the definition of the current word under cursor without actually open that file. So, the tag previewer was made for this:

![](https://skywind3000.github.io/images/p/quickui/preview_tag.png)

use it like:

```VimL
nnoremap <F3> :call quickui#tools#preview_tag('')<cr>
```

When you move the cursor around and press `<F3>`, the definition of current `<cword>` under cursor will display in the preview window. If there are multiple definitions, press `<F3>` again will circularly display the next one, and in the command line, you will see the details about how many definitions and source file name.

Don't forget to use `quickui#preview#scroll` to scroll the content in the preview window if you want to see more.

This feature requires ctags databases are loaded correctly in vim. A plugin [gutentags](https://github.com/ludovicchabant/vim-gutentags) can do it for you nicely in the background.

### Preview quickfix

If you have many items in the quickfix window, instead of open them one by one, you are able to press `p` in the quickfix window and preview them in the popup:

```VimL
augroup MyQuickfixPreview
  au!
  au FileType qf noremap <silent><buffer> p :call quickui#tools#preview_quickfix()<cr>
augroup END
```

This piece of code setup a `p` keymap in your quickfix window to preview items, and press `p` again to close the preview window.

## Customize

### How to change border style

Change border characters.


    let g:quickui_border_style = 1   (default)

![](https://skywind3000.github.io/images/p/quickui/border1.png)


    let g:quickui_border_style = 2

![](https://skywind3000.github.io/images/p/quickui/border2.png)

    let g:quickui_border_style = 3

![](https://skywind3000.github.io/images/p/quickui/border3.png)

### How to change the color scheme

To change the color scheme, you can set the option below:

    let g:quickui_color_scheme = 'borland'

And the default color scheme `"borland"` will be used.

Avaliables color schemes:

![](https://skywind3000.github.io/images/p/quickui/colors.png)

### How to change preview window size

The default width of preview window is 85 and the height is 10, you can change it like this:

    let g:quickui_preview_w = 100
    let g:quickui_preview_h = 15

### Specify color group precisely

If none of the builtin color schemes satisfy your need, you can define the color groups your self in your `.vimrc` before enter vim (`VimEnter` event).

| Group | Meaning |
|-|-|
| QuickBG | Background color |
| QuickSel | Selector (or cursor) color |
| QuickKey | Hotkey (or shortcut-key) color |
| QuickOff | Disabled item color |
| QuickHelp | Tip text color |

Default color `"borland"` is defined as:

```VimL
hi! QuickBG ctermfg=0 ctermbg=7 guifg=black guibg=gray
hi! QuickSel cterm=bold ctermfg=0 ctermbg=2 gui=bold guibg=brown guifg=gray
hi! QuickKey term=bold ctermfg=9 gui=bold guifg=#f92772
hi! QuickOff ctermfg=59 guifg=#75715e
hi! QuickHelp ctermfg=247 guifg=#959173
```

## Who Am I ?

My name is Lin Wei, an open source believer and vim enthusiast. I started learning programming in early 1990s. Borland's Turbo Pascal/C++ was the most popular IDE at that time and I really enjoyed the old days, back home from school, powered on my computer, started Turbo c++ 3.1 and studied how to make a game in MS-DOS.

I even imitated Turbo C++ and made my own editor when I moved to Watcom C++:

![](https://skywind3000.github.io/images/p/quickui/editor.png)

Because I didn't own a proper editor/IDE for Watcom C++ at that time.

After coming to windows, I tried a lot of GUI-editors, from UltraEdit, editplus to NotePad++, from gedit to geany, none of them could fully satisfy me. Every day I was busy, tired to learn new IDEs/editors or new frameworks, I even forgot the true joy of programming. Eventually I met vim, and soon fell in love with it.

As Vim is evolving nowadays, due to the effort of Bram, 8.2 released. Finally I realise, maybe, it is possible to bring some cool things from 25 years ago to vim now. Maybe I can have a Borland/Turbo C++ flavor vim in my everyday work just like I was learning making PC games in the golden 1990s as a middle school student.

It is time for me to bring these ideas to reality, just start from this plugin.

## Credit

like vim-quickui? Follow the repository on [GitHub](https://github.com/skywind3000/vim-quickui) and vote for it on [vim.org](https://www.vim.org/scripts/script.php?script_id=5845). And if you're feeling especially charitable, follow skywind3000 on [Twitter](https://twitter.com/skywind3000) and [GitHub](https://github.com/skywind3000).
