
hi! QuickDefaultBackground ctermfg=187 ctermbg=239 guifg=#ebdbb2 guibg=#504945
hi! QuickDefaultSel cterm=bold ctermfg=239 ctermbg=108 gui=bold guifg=#504945 guibg=#83a598
hi! QuickDefaultKey term=bold ctermfg=208 guifg=#fd9720
hi! QuickDefaultDisable ctermfg=245 guifg=#928374
hi! QuickDefaultHelp ctermfg=109 guifg=#83a598
hi! QuickDefaultBorder ctermfg=187 ctermbg=239 guifg=#ebdbb2 guibg=#504945
hi! QuickDefaultTermBorder ctermfg=187 ctermbg=239 guifg=#ebdbb2 guibg=#504945

if &background == 'dark'
	hi! QuickDefaultPreview ctermbg=237 guibg=#4c4846
else
	hi! QuickDefaultPreview ctermbg=12 guibg=#dddddd
endif
