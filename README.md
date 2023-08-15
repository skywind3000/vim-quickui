# What Is It ?

There are many keymaps defined in my `.vimrc`. Getting tired from checking `.vimrc` time to time when I forget some, based on the latest `+popup` feature (vim 8.2), I created this `vim-quickui` plugin to introduce some basic UI components to enrich vim's interactive experience:

- Well designed and carefully colored Borland/Turbo C++ flavor ui system combined with vim's productivity.
- Can be accessed by keyboard only while mouse is also supported.
- Navigate with the usual Vim keys like `h/j/k/l`, confirm with `ENTER/SPACE` and cancel with `ESC/Ctrl+[`.
- `Tip` for each entry can display in the cmdline when you are moving the cursor around.
- Available widgets: [menu](#menu), [listbox](#listbox), [inputbox](#inputbox), [textbox](#textbox).. (coming soon)
- Fully customizable, including color scheme and borders.
- Corresponding experience in both `Vim` and `NeoVim`.
- Pure vim-script, `+python` is not required.
- No longer have to be afraid to forget keymaps anymore.

Just see this GIF demonstration below:

![](https://skywind3000.github.io/images/p/quickui/screenshot.gif)

Trying to share my configuration to my friends, I found that they did't have patience to remember all the keymaps in my vimrc, but text ui is quite acceptable for them.

# Content 

<!-- TOC -->

- [What Is It ?](#what-is-it-)
- [Content](#content)
  - [Relative Projects](#relative-projects)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Gallery Screenshot](#gallery-screenshot)
    - [Menu](#menu)
    - [Listbox](#listbox)
    - [Inputbox](#inputbox)
    - [Context menu](#context-menu)
    - [Textbox](#textbox)
    - [Preview window](#preview-window)
    - [Terminal](#terminal)
    - [Confirm dialog](#confirm-dialog)
  - [User Manual](#user-manual)
  - [Who Am I ?](#who-am-i-)
  - [Credit](#credit)

<!-- /TOC -->

## Relative Projects

Plugins powered by QuickUI:

- [vim-navigator](https://github.com/skywind3000/vim-navigator): Navigate your commands easily.

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

Customizable border style:

![](https://skywind3000.github.io/images/p/quickui/border2.png)

Menu color schemes:

![](https://skywind3000.github.io/images/p/quickui/colors.png)

See: [Menu help](MANUAL.md#menu).

### Listbox

When you have hundres of items to deal with, menu is not enough to hold them. Then you will need a listbox.

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

It has scroll bar, content can be scrolled by keyboard or mouse wheel. You can search items with `/` or `?` command.

It can be used to select buffers or functions in current file:

![](https://skywind3000.github.io/images/p/quickui/list-function.png)

The cursor will stay in the current function initially. Navigate and press enter to jump to the selected function. 

See: [Listbox help](MANUAL.md#listbox).

### Inputbox

Prompt user to input a string in a TUI box:

![](https://skywind3000.github.io/images/p/quickui/input1.png)

Could be used as a drop-in replacement of `input()` function.

See: [Input box help](MANUAL.md#inputbox).

### Context menu

Context menu imitates Windows context menu (triggered by your mouse right button), which will display around the cursor:

![](https://skywind3000.github.io/images/p/quickui/context.png)

It is usually used to present some commands that will do something with source code in the current line.

The border can be changed too:

![](https://skywind3000.github.io/images/p/quickui/context2.png)

Because some terminals or fonts cannot display unicode borders correctly, so QuickUI choose ascii border characters by default. But you can change it as you like.

See: [Context menu help](MANUAL.md#context-menu).

### Textbox

Textbox is used to display arbitrary text in a popup window.

![](https://skywind3000.github.io/images/p/quickui/textbox.png)

Display vim help with syntax highlighting in the `textbox`:

![](https://skywind3000.github.io/images/p/quickui/display-help.png)

With `textbox`, you can read the help text at anytime in a popup, without creating a new split window.

Display vim messages:

![](https://skywind3000.github.io/images/p/quickui/messages.png)

Navigating the messages with `HJKL` or `PageUp/PageDown` is much more convenient than using `:messages`.

See: [Text box help](MANUAL.md#textbox).

### Preview window

Preview window is used to replace traditional `pedit` command and can be used to display certain file in a small popup window around your cursor:

![](https://skywind3000.github.io/images/p/quickui/preview.png)

Sometimes I just want a glimpse to the definition of the current word under cursor without actually open that file, the `preview` window is much helpful for this. 

Use it to preview quickfix result:

![](https://skywind3000.github.io/images/p/quickui/quickfix.png)

If you have many items in the quickfix window, instead of open them one by one, you are able to press `p` in the quickfix window and preview them in the popup.

See: [Preview window help](MANUAL.md#preview-window).

### Terminal

The `terminal` widget can allow you open a terminal in the popup window:

![](https://skywind3000.github.io/images/p/quickui/terminal.png)

This feature require vim `8.2.200` (nvim `0.4.0`) or later, it enables you to run various tui programs in a dialog window.

See: [Terminal help](MANUAL.md#terminal).

### Confirm dialog

This widget offers user a dialog, from which a choice can be made:

![](https://skywind3000.github.io/images/p/quickui/confirm1.png)

It returns the number of the choice. For the first choice, this is 1.

See: [Confirm dialog help](MANUAL.md#confirm-dialog).


## User Manual

To get started, please visit:

- [User Manual](MANUAL.md)

For more examples, see [my config](test/menu_example.vim).


## Who Am I ?

My name is Lin Wei, and I am a strong advocate of open source and a passionate vim user. I embarked on my programming journey in the early 1990s. During that time, Borland’s Turbo Pascal/C++ served as the prevailing IDE, and I fondly reminisce about those days. After returning home from school, I would eagerly power on my computer, launch Turbo C++ 3.1, and delve into the world of creating games in MS-DOS.

I even imitated Turbo C++ and made my own editor when I moved to Watcom C++:

![](https://skywind3000.github.io/images/p/quickui/editor.png)

Because I didn't own a proper editor/IDE for Watcom C++ at that time.

During my transition to Windows, I encountered a multitude of GUI editors, ranging from UltraEdit and EditPlus to Notepad++ and even gedit and geany. However, none of them managed to fulfill my requirements completely. Each day, I found myself grappling with the constant need to learn new IDEs, editors, or frameworks, which left me exhausted and disconnected from the true joy of programming. It was not until I discovered vim that everything changed. Instantly, I became enamored with its capabilities and found my passion for programming reignited.

With the continuous evolution of Vim, thanks to Bram’s unwavering efforts, the release of version 8.2 has brought forth exciting possibilities. It dawned on me that perhaps I can now incorporate some of the cool features from 25 years ago into Vim. Just like my experiences as a middle school student, learning to create PC games during the golden era of the 1990s, I can now infuse my everyday work with a nostalgic Borland/Turbo C++ flavor, courtesy of Vim.

The time has come for me to transform these ideas into reality, and it all begins with this plugin.

## Credit

like vim-quickui? Follow the repository on [GitHub](https://github.com/skywind3000/vim-quickui) and vote for it on [vim.org](https://www.vim.org/scripts/script.php?script_id=5845). And if you're feeling especially charitable, follow skywind3000 on [Twitter](https://twitter.com/skywind3000) and [GitHub](https://github.com/skywind3000).

