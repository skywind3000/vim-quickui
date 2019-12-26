# Preface

Well designed and carefully colored Borland/Turbo C++ flavor ui for vim. Uses both `hjkl` and mouse to move around.

## Installation

    Plug 'skywind3000/vim-quickui'

## Available Widgets

### Menu

Display a dropdown menubar at top of the screen:

![](images/mainmenu.png)

APIS:

```VimL
call quickui#menu#install(section, items)
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
            \ [ '&Copy', 'echo 1', 'help1' ],
            \ [ '&Paste', 'echo 2', 'help2' ],
            \ [ '&Find', 'echo 3', 'help3' ],
            \ ])
call quickui#menu#install('&Tools', [
            \ [ '&Copy', 'echo 1', 'help1' ],
            \ [ '&Paste', 'echo 2', 'help2' ],
            \ [ '&Find', 'echo 3', 'help3' ],
            \ ])
call quickui#menu#install('H&elp', [
            \ [ '&Content', 'echo 4' ],
            \ [ '&About', 'echo 5' ],
            \ ])
call quickui#menu#install('&Window', [])
call quickui#menu#open()
```

## Credit

TODO

