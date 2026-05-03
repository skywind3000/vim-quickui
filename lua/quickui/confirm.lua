----------------------------------------------------------------------
-- quickui.confirm: Lua interface for vim-quickui confirm dialog.
--
-- Usage:
--   local confirm = require('quickui.confirm')
--   local choice = confirm.open('Save changes?', '&Yes\n&No\n&Cancel')
--   if choice == 1 then
--       vim.cmd('w')
--   end
----------------------------------------------------------------------


---@class quickui.confirm
local M = {}


--- Open a confirm dialog (blocking).
--- Returns 1-based button index, or 0 if cancelled (Esc).
---@param text string|string[] Message text (string or list of strings)
---@param choices? string Button labels separated by '\n', with `&` hotkeys (default: ' &OK ')
---@param default? integer Default button index, 1-based (default: 1)
---@param title? string Dialog title (default: 'Confirm')
---@return integer choice Selected button index (1-based), 0 if cancelled
function M.open(text, choices, default, title)
	local args = { text }
	if choices ~= nil then
		args[#args + 1] = choices
		if default ~= nil then
			args[#args + 1] = default
			if title ~= nil then
				args[#args + 1] = title
			end
		end
	end
	return vim.fn['quickui#confirm#open'](unpack(args))
end


return M
