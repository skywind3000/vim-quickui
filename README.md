# What Is It ?

There are many keymaps defined in my `.vimrc`. Getting tired from checking `.vimrc` time to time when I forget some, based on latest `+popup` feature (vim 8.2), I created this `vim-quickui` plugin to introduce some basic ui components to enrich vim's interactive experience:

- Well designed and carefully colored Borland/Turbo C++ flavor ui system combined with vim's productivity.
- Can be accessed by keyboard only while mouse is also supported.
- Navigate with the usual Vim keys like `h/j/k/l`, confirm with `ENTER/SPACE` and cancel with `ESC/Ctrl+[`.
- `Tip` for each entry can display in the cmdline when you are moving the cursor around.
- Available widgets: [menu](#menu), [listbox](#listbox), [textbox](#textbox).. (coming soon)
- Fully customizable, including color scheme and borders.
- Corresponding experience in both `Vim` and `NeoVim`.
- Pure vim-script, `+python` is not required.
- No longer have to be afraid to forget keymaps anymore.

Just see this GIF demonstration below:

![](https://skywind3000.github.io/images/p/quickui/screenshot.gif)

Trying to share my configuration to my friends, I found that they did't have patience to remember all the keymaps in my vimrc, but text ui is quite acceptable for them.

# Content 

<!-- TOC -->

- [Requirements](#requirements)
- [Installation](#installation)
- [Gallery Screenshot](#gallery-screenshot)
    - [Menu](#menu)
    - [Listbox](#listbox)
    - [Context menu](#context-menu)
    - [Textbox](#textbox)
    - [Preview window](#preview-window)
    - [Terminal](#terminal)
- [User Manual](#user-manual)
- [Who Am I ?](#who-am-i-)
- [Credit](#credit)

<!-- /TOC -->

## Requirements

- Vim: 8.2 or later.
- NeoVim: 0.4.0 or later.

## Installation

    Plug 'skywind3000/vim-quickui'

For more information, please see the [User Manual](MANUAL.md).

## Gallery Screenshot

### Menu

Display a dropdown menubar at top of the screen, use `hjkl` or mouse to navigate:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

Border style 1:

![](https://skywind3000.github.io/images/p/quickui/border1.png)


Border style 2:

![](https://skywind3000.github.io/images/p/quickui/border2.png)

Menu color schemes:

![](https://skywind3000.github.io/images/p/quickui/colors.png)

### Listbox

When you have hundres of items to deal with, menu is not enough to hold them. Then you will need a listbox.

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

It has scroll bar, content can be scrolled by keyboard or mouse wheel. You can search items with `/` or `?` command.

It can be used to select buffers or functions in current file:

![](https://skywind3000.github.io/images/p/quickui/list-function.png)

The cursor will stay in the current function initially. Navigate and press enter to jump to the selected function. 

### Context menu

Context menu imitates Windows context menu (triggered by your mouse right button), which will display around the cursor:

![](https://skywind3000.github.io/images/p/quickui/context.png)

It is usually used to present some commands that will do something with source code in the current line.

The border can be changed too:

![](https://skywind3000.github.io/images/p/quickui/context2.png)

Because some terminals or fonts cannot display unicode borders correctly, so QuickUI choose ascii border characters by default. But you can change it as you like.

### Textbox

Textbox is used to display arbitrary text in a popup window.

![](https://skywind3000.github.io/images/p/quickui/textbox.png)

Display vim help with syntax highlighting in the `textbox`:

![](https://skywind3000.github.io/images/p/quickui/display-help.png)

With `textbox`, you can read the help text at anytime in a popup, without creating a new split window.

Display vim messages:

![](https://skywind3000.github.io/images/p/quickui/messages.png)

Navigating the messages with `HJKL` or `PageUp/PageDown` is much more convenient than using `:messages`.

### Preview window

Preview window is used to replace traditional `pedit` command and can be used to display certain file in a small popup window around your cursor:

![](https://skywind3000.github.io/images/p/quickui/preview.png)

Sometimes I just want a glimpse to the definition of the current word under cursor without actually open that file, the `preview` window is much helpful for this. 

Use it to preview quickfix result:

![](https://skywind3000.github.io/images/p/quickui/quickfix.png)

If you have many items in the quickfix window, instead of open them one by one, you are able to press `p` in the quickfix window and preview them in the popup.

### Terminal

The `terminal` widget can allow you open a terminal in the popup window:

![](https://skywind3000.github.io/images/p/quickui/terminal.png)

This feature require vim `8.2.200` (nvim `0.4.0`) or later, it enables you to run various tui programs in a dialog window.

## User Manual

To get started, please visit:

- [User Manual](MANUAL.md)

For more examples, see [my config](test/menu_example.vim).


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

