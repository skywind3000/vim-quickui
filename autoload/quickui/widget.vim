"======================================================================
"
" widget.vim - 
"
" Created by skywind on 2021/02/25
" Last Modified: 2021/02/25 17:51:00
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" widget class
"----------------------------------------------------------------------
let s:widget = {}
let s:widget.w = 1           " width in character
let s:widget.h = 1           " height in character
let s:widget.x = 0           " position x
let s:widget.y = 0           " position y
let s:widget.name = ''       " widget name
let s:widget.code = 0        " return code
let s:widget.tab_index = -1  " tab index
let s:widget.group = 0       " group
let s:widget.dirty = 0       " need update
let s:widget.visible = 1     " visibility
let s:widget.actived = 0     " is active
let s:widget.color = ''      " highlight group


function! s:widget.on_active() abort
	let self.visible = 1
endfunc

function! s:widget.on_deactive() abort
	let self.visible = 0
endfunc

function! s:widget.on_draw() abort
endfunc


"----------------------------------------------------------------------
" text label
"----------------------------------------------------------------------
let s:label = deepcopy(s:widget)
let s:label.text = ''


