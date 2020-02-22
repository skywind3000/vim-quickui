
hi! QuickDefaultBackground ctermfg=235 ctermbg=246 guifg=#073642 guibg=#839496
hi! QuickDefaultSel ctermfg=254 ctermbg=241 guifg=#eee8d5 guibg=#586e75
hi! QuickDefaultKey ctermfg=166 guifg=#cb4b16
hi! QuickDefaultDisable ctermfg=242 guifg=#586e75
hi! QuickDefaultHelp ctermfg=32 guifg=#268bd2
hi! QuickDefaultBorder ctermfg=235 ctermbg=246 guifg=#073642 guibg=#839496
hi! QuickDefaultTermBorder ctermfg=235 ctermbg=246 guifg=#073642 guibg=#839496

if &background == 'dark'
	hi! QuickDefaultPreview ctermbg=237 guibg=#4c4846
else
	hi! QuickDefaultPreview ctermbg=12 guibg=#dddddd
endif
