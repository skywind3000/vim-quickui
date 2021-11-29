
hi! link QuickDefaultBackground Pmenu
hi! link QuickDefaultSel PmenuSel
hi! link QuickDefaultKey Title
hi! link QuickDefaultDisable Comment
hi! link QuickDefaultHelp Conceal
hi! link QuickDefaultBorder Pmenu
hi! link QuickDefaultTermBorder Pmenu

if &background == 'dark'
	hi! QuickDefaultPreview ctermbg=237 guibg=#4c4846
else
	hi! QuickDefaultPreview ctermbg=12 guibg=#dddddd
endif


hi! link QuickDefaultInput NonText
hi! link QuickDefaultCursor Cursor
hi! link QuickDefaultVisual Visual


