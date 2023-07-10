let g:quickui_confirm_border = 'double'

let question = "What do you want ?"
let choices = "&Apples\n&Oranges\n&Bananas"

let choice = quickui#confirm#open(question, choices, 1, 'Confirm')

if choice == 0
	echo "make up your mind!"
elseif choice == 3
	echo "tasteful"
else
	echo "I prefer bananas myself."
endif


