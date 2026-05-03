----------------------------------------------------------------------
-- test_dialog.lua - interactive test for quickui Lua dialog interface
--
-- Usage (inside Neovim):
--   :luafile test/test_dialog.lua
--   :lua Test_dialog_basic()
--   :lua Test_dialog_focus()
--   :lua Test_dialog_multi_button()
--   :lua Test_dialog_form()
--   :lua Test_dialog_label_only()
--   :lua Test_dialog_radio_vertical()
--   :lua Test_dialog_history()
--   :lua Test_dialog_project_form()
----------------------------------------------------------------------

local dialog = require('quickui.dialog')


----------------------------------------------------------------------
-- basic test: all control types
----------------------------------------------------------------------
function Test_dialog_basic()
	local items = {
		{ type = 'label', text = 'Test all controls:' },
		{ type = 'input', name = 'name', prompt = 'Name:',
		  value = 'test' },
		{ type = 'radio', name = 'choice', prompt = 'Pick:',
		  items = { 'A', 'B', 'C' } },
		{ type = 'check', name = 'flag', text = 'Enable' },
		{ type = 'button', name = 'confirm',
		  items = { ' &OK ', ' &Cancel ' } },
	}
	local result = dialog.open(items, { title = 'Test' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- focus test: control-level focus field
----------------------------------------------------------------------
function Test_dialog_focus()
	local items = {
		{ type = 'input', name = 'user', prompt = 'User:',
		  value = 'admin' },
		{ type = 'input', name = 'pass', prompt = 'Pass:' },
		{ type = 'button', name = 'confirm',
		  items = { ' &Login ', ' &Cancel ' }, focus = 0 },
	}
	local result = dialog.open(items, { title = 'Focus Test' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- multi button rows test
----------------------------------------------------------------------
function Test_dialog_multi_button()
	local items = {
		{ type = 'label', text = 'Multiple button rows:' },
		{ type = 'button', name = 'action',
		  items = { ' &Apply ', ' &Reset ' } },
		{ type = 'button', name = 'confirm',
		  items = { ' &OK ', ' &Cancel ' } },
	}
	local result = dialog.open(items, { title = 'Multi Button' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- full form test (from design doc example)
----------------------------------------------------------------------
function Test_dialog_form()
	local items = {
		{ type = 'label', text = 'Please fill in the user form:' },
		{ type = 'input', name = 'username', prompt = 'Name:',
		  value = 'skywind' },
		{ type = 'input', name = 'email', prompt = 'Email:' },
		{ type = 'radio', name = 'role', prompt = 'Role:',
		  items = { '&Dev', '&QA', '&PM' }, value = 0 },
		{ type = 'check', name = 'admin', text = 'Administrator' },
		{ type = 'check', name = 'notify', text = 'Send notification',
		  value = 1 },
		{ type = 'button', name = 'confirm',
		  items = { ' &OK ', ' &Cancel ' } },
	}
	local opts = { title = 'User Form', w = 50 }
	local result = dialog.open(items, opts)
	if result.button_index >= 0 then
		print('User: ' .. result.username)
		print('Email: ' .. result.email)
		print('Role: ' .. result.role)
		print('Admin: ' .. result.admin)
	else
		print('Cancelled')
	end
end


----------------------------------------------------------------------
-- label only test
----------------------------------------------------------------------
function Test_dialog_label_only()
	local items = {
		{ type = 'label', text = 'This dialog has no interactive\ncontrols. Press ESC to close.' },
	}
	local result = dialog.open(items, { title = 'Info' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- radio vertical test
----------------------------------------------------------------------
function Test_dialog_radio_vertical()
	local items = {
		{ type = 'label', text = 'Pick a very long option:' },
		{ type = 'radio', name = 'lang', prompt = 'Language:',
		  items = { '&Python', '&JavaScript', '&TypeScript', '&Rust', '&Go' },
		  vertical = 1 },
		{ type = 'button', name = 'confirm',
		  items = { ' &OK ', ' &Cancel ' } },
	}
	local result = dialog.open(items, { title = 'Vertical Radio' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- input with history test
----------------------------------------------------------------------
function Test_dialog_history()
	local items = {
		{ type = 'input', name = 'search', prompt = 'Search:',
		  history = 'dialog_test_search' },
		{ type = 'button', name = 'confirm',
		  items = { ' &OK ', ' &Cancel ' } },
	}
	local result = dialog.open(items, { title = 'Search' })
	print(vim.inspect(result))
end


----------------------------------------------------------------------
-- form with dropdown + validator
----------------------------------------------------------------------
function Test_dialog_project_form()
	local languages = { 'Python', 'JavaScript', 'Go', 'Rust', 'C++' }
	local builds = { 'Make', 'CMake', 'Cargo', 'npm', 'pip' }
	local licenses = { '&MIT', '&Apache', '&GPL', '&Proprietary' }

	local items = {
		{ type = 'label', text = 'Create New Project:' },
		{ type = 'input', name = 'project_name', prompt = 'Project:',
		  value = 'my-app', focus = 0 },
		{ type = 'input', name = 'email', prompt = 'Email:',
		  value = 'dev@example.com' },
		{ type = 'dropdown', name = 'language', prompt = 'Language:',
		  items = languages, value = 0 },
		{ type = 'dropdown', name = 'build', prompt = 'Build:',
		  items = builds, value = 0 },
		{ type = 'radio', name = 'license', prompt = 'License:',
		  items = licenses, value = 0 },
		{ type = 'check', name = 'git_init', text = 'Initialize git repo',
		  value = 1 },
		{ type = 'check', name = 'ci', text = 'Add CI config',
		  value = 0 },
		{ type = 'button', name = 'confirm',
		  items = { ' &Create ', '  Cancel  ' } },
	}

	local function validate(result)
		if result.project_name:match('^%s*$') then
			return 'Project name cannot be empty'
		end
		if result.project_name:match('[^%w_%-]') then
			return 'Project name: only letters, digits, _ and - are allowed'
		end
		if result.email:match('^%s*$') then
			return 'Email cannot be empty'
		end
		if not result.email:match('@') then
			return 'Email must contain @'
		end
		return ''
	end

	local opts = { title = 'New Project', w = 50, validator = validate }
	local result = dialog.open(items, opts)
	if result.button_index >= 0 then
		print('Project:  ' .. result.project_name)
		print('Email:    ' .. result.email)
		print('Language: ' .. languages[result.language + 1])
		print('Build:    ' .. builds[result.build + 1])
		print('License:  ' .. licenses[result.license + 1])
		print('Git:      ' .. (result.git_init ~= 0 and 'yes' or 'no'))
		print('CI:       ' .. (result.ci ~= 0 and 'yes' or 'no'))
	else
		print('Cancelled')
	end
end
