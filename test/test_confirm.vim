let choices = "&OK\nDis&card\n&Quit"
let question = "Make your choice:"

if 0
	let hwnd = quickui#confirm#init(question, choices, -1, 'Confirm')

	for text in hwnd.content
		echo text 
	endfor
endif

let accept = quickui#confirm#open(question, choices, 1, 'Confirm')

echo accept

