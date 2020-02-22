
hi! QuickDefaultBackground ctermfg=251 ctermbg=236 guifg=#c6c6c6 guibg=#303030
hi! QuickDefaultSel ctermfg=236 ctermbg=251 guifg=#303030 guibg=#c6c6c6
hi! QuickDefaultKey term=bold ctermfg=179 gui=bold guifg=#d7af5f
hi! QuickDefaultDisable ctermfg=11 guifg=#808080
hi! QuickDefaultHelp ctermfg=7 ctermbg=8 guifg=#585858 guibg=#1c1c1c
hi! QuickDefaultBorder ctermfg=66 ctermbg=236 guifg=#5f8787 guibg=#303030
hi! QuickDefaultTermBorder ctermfg=66 ctermbg=236 guifg=#5f8787 guibg=#303030

if &background == 'dark'
	hi! QuickDefaultPreview ctermbg=237 guibg=#4c4846
else
	hi! QuickDefaultPreview ctermbg=12 guibg=#dddddd
endif
