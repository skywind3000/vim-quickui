# What Is It ?

There are many keymaps defined in my `.vimrc`. Getting tired from checking `.vimrc` time to time when I forget some, based on latest `+popup` feature (vim 8.2), I created this `vim-quickui` plugin to introduce some basic ui components to enrich vim's interactive experience:

- Well designed and carefully colored Borland/Turbo C++ flavor ui system combined with vim's productivity.
- Can be accessed by keyboard only while mouse is also supported.
- Navigate with the usual Vim keys like `h/j/k/l`, confirm with `ENTER/SPACE` and cancel with `ESC/Ctrl+[`.
- Pure vim-script, `+python` is not required.
- No longer have to be afraid to forget keymaps anymore.


## Installation

    Plug 'skywind3000/vim-quickui'

## Available Widgets



### Menu

Display a dropdown menubar at top of the screen:

![](images/mainmenu.png)

APIs:

register menu entries:

```VimL
call quickui#menu#install(section, items [, weight])
```

display the menu:

```VimL
call quickui#menu#open()
```

Sample code:

```VimL
call quickui#menu#reset()
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
call quickui#menu#install('&Edit', [
            \ [ '&Copy', 'echo 1' ],
            \ [ '&Paste', 'echo 2'],
            \ [ '&Find', 'echo 3' ],
            \ ])
call quickui#menu#install('&Tools', [
            \ [ '&Copy', 'echo 1'],
            \ [ '&Paste', 'echo 2'],
            \ [ '&Find', 'echo 3' ],
            \ ])
call quickui#menu#install('H&elp', [
            \ [ '&Content', 'echo 4' ],
            \ [ '&About', 'echo 5' ],
            \ ])
call quickui#menu#install('&Window', [])
noremap <space><space> quickui#menu#open()
```

Then you can open the menu by pressing space twice.

### Listbox

Can display an array of stirng items in the popup window and can be used to pick up an item.

TODO

## Credit

TODO

