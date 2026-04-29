# What Is It ?

There are many keymaps defined in my `.vimrc`. Tired of checking it from time to time when I forget some, I built this `vim-quickui` plugin on top of the `+popup` feature (Vim 8.2) to bring basic UI components to Vim's interactive experience:

- Well-designed, Borland/Turbo C++ flavored UI system combined with Vim's productivity.
- Keyboard-driven, with full mouse support.
- Navigate with the usual Vim keys like `h/j/k/l`, confirm with `ENTER/SPACE` and cancel with `ESC/Ctrl+[`.
- A tip for each entry can be displayed in the cmdline as you move the cursor around.
- Available widgets: [menu](#menu), [listbox](#listbox), [inputbox](#inputbox), [textbox](#textbox).. (coming soon)
- Fully customizable, including color schemes and borders.
- Consistent experience across both `Vim` and `NeoVim`.
- Pure VimScript, no `+python` required.
- No more forgetting keymaps.

See the GIF demonstration below:

![](https://skywind3000.github.io/images/p/quickui/screenshot.gif)

Trying to share my configuration with my friends, I found that they didn't have the patience to remember all the keymaps in my vimrc, but a text UI was quite acceptable for them.

# Content 

<!-- TOC -->

- [What Is It ?](#what-is-it-)
- [Content](#content)
  - [Related Projects](#related-projects)
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

## Related Projects

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

Displays a dropdown menubar at the top of the screen. Use `hjkl` or mouse to navigate:

![](https://skywind3000.github.io/images/p/quickui/mainmenu.png)

Customizable border style:

![](https://skywind3000.github.io/images/p/quickui/border2.png)

Menu color schemes:

![](https://skywind3000.github.io/images/p/quickui/colors.png)

See: [Menu help](MANUAL.md#menu).

### Listbox

When you have hundreds of items to deal with, a menu cannot hold them all — use a listbox instead.

![](https://skywind3000.github.io/images/p/quickui/listbox.png)

It has a scroll bar and supports keyboard and mouse wheel scrolling. You can search items with `/` or `?`.

It can be used to select buffers or functions in the current file:

![](https://skywind3000.github.io/images/p/quickui/list-function.png)

The cursor starts at the current function. Navigate and press enter to jump to the selected function.

See: [Listbox help](MANUAL.md#listbox).

### Inputbox

Prompts the user to input a string in a TUI box:

![](https://skywind3000.github.io/images/p/quickui/input1.png)

Can serve as a drop-in replacement for the `input()` function.

See: [Input box help](MANUAL.md#inputbox).

### Context menu

Context menu imitates the Windows right-click menu and appears near the cursor:

![](https://skywind3000.github.io/images/p/quickui/context.png)

It is typically used to present commands relevant to the source code at the current line.

The border can be changed too:

![](https://skywind3000.github.io/images/p/quickui/context2.png)

Since some terminals or fonts cannot display Unicode borders correctly, QuickUI uses ASCII border characters by default. You can change this as you like.

See: [Context menu help](MANUAL.md#context-menu).

### Textbox

Textbox displays arbitrary text in a popup window.

![](https://skywind3000.github.io/images/p/quickui/textbox.png)

Display Vim help with syntax highlighting in the `textbox`:

![](https://skywind3000.github.io/images/p/quickui/display-help.png)

With `textbox`, you can read help text at any time in a popup, without creating a new split window.

Display Vim messages:

![](https://skywind3000.github.io/images/p/quickui/messages.png)

Navigating the messages with `HJKL` or `PageUp/PageDown` is much more convenient than using `:messages`.

See: [Text box help](MANUAL.md#textbox).

### Preview window

The preview window replaces the traditional `:pedit` command, displaying a file in a small popup window near your cursor:

![](https://skywind3000.github.io/images/p/quickui/preview.png)

Sometimes I just want to glimpse the definition of the word under cursor without actually opening that file — the `preview` window is very helpful for this.

Use it to preview quickfix results:

![](https://skywind3000.github.io/images/p/quickui/quickfix.png)

If you have many items in the quickfix window, instead of opening them one by one, you can press `p` in the quickfix window to preview them in a popup.

See: [Preview window help](MANUAL.md#preview-window).

### Terminal

The `terminal` widget lets you open a terminal in a popup window:

![](https://skywind3000.github.io/images/p/quickui/terminal.png)

This feature requires Vim `8.2.200` (NeoVim `0.4.0`) or later, enabling you to run various TUI programs in a popup window.

See: [Terminal help](MANUAL.md#terminal).

### Confirm dialog

This widget presents the user with a dialog from which a choice can be made:

![](https://skywind3000.github.io/images/p/quickui/confirm1.png)

It returns the number of the choice. For the first choice, this is 1.

See: [Confirm dialog help](MANUAL.md#confirm-dialog).


## User Manual

To get started, please visit:

- [User Manual](MANUAL.md)

For more examples, see [my config](test/menu_example.vim).


## Who Am I ?

My name is Lin Wei, an open source advocate and Vim enthusiast. I started learning programming in the early 1990s. Borland's Turbo Pascal/C++ was the most popular IDE at that time, and I really enjoyed those days — coming home from school, powering on my computer, launching Turbo C++ 3.1, and learning how to make games in MS-DOS.

I even imitated Turbo C++ and made my own editor when I moved to Watcom C++:

![](https://skywind3000.github.io/images/p/quickui/editor.png)

Because I didn't have a proper editor/IDE for Watcom C++ at that time.

After moving to Windows, I tried many GUI editors — from UltraEdit and EditPlus to Notepad++, from gedit to geany — but none fully satisfied me. Every day I was busy learning new IDEs, editors, or frameworks, and I had lost the true joy of programming. Then I discovered Vim and fell in love with it.

As Vim evolved, thanks to Bram's efforts, version 8.2 was released. I realized that maybe it was now possible to bring some of those cool things from 25 years ago into Vim. Maybe I could have a Borland/Turbo C++ flavored Vim in my everyday work, just like when I was a middle school student learning to make PC games in the golden 1990s.

It is time to bring these ideas to reality, starting with this plugin.

## Credit

Like vim-quickui? Follow the repository on [GitHub](https://github.com/skywind3000/vim-quickui) and vote for it on [vim.org](https://www.vim.org/scripts/script.php?script_id=5845). And if you're feeling especially charitable, follow skywind3000 on [Twitter](https://twitter.com/skywind3000) and [GitHub](https://github.com/skywind3000).
