
hi! QuickDefaultBackground ctermfg=0 ctermbg=7 guifg=black guibg=#c0c0c0
hi! QuickDefaultSel cterm=bold ctermfg=0 ctermbg=2 gui=bold guibg=brown guifg=#c0c0c0
hi! QuickDefaultKey term=bold ctermfg=9 gui=bold guifg=#f92772
hi! QuickDefaultDisable ctermfg=59 guifg=#75715e
hi! QuickDefaultHelp ctermfg=247 guifg=#959173
hi! QuickDefaultBorder ctermfg=0 ctermbg=7 guifg=black guibg=#c0c0c0
hi! QuickDefaultTermBorder ctermfg=0 ctermbg=7 guifg=black guibg=#c0c0c0

if &background == 'dark'
	hi! QuickDefaultPreview ctermbg=237 guibg=#4c4846
else
	hi! QuickDefaultPreview ctermbg=12 guibg=#dddddd
endif
