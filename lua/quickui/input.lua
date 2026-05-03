----------------------------------------------------------------------
-- quickui.input: Lua interface for vim-quickui single-line input box.
--
-- Usage:
--   local input = require('quickui.input')
--   local name = input.open('Enter your name:')
--   if name ~= '' then
--       print('Hello, ' .. name)
--   end
--
--   -- With initial value and history:
--   local query = input.open('Search:', 'default text', 'search_history')
----------------------------------------------------------------------


---@class quickui.input
local M = {}


--- Open a single-line input box (blocking).
--- Returns the entered text, or empty string '' if cancelled (Esc).
---@param prompt string|string[] Prompt text (string or list of strings)
---@param text? string Initial input text (default: '')
---@param history? string History namespace key for cross-call browsing
---@return string text Entered text, '' if cancelled
function M.open(prompt, text, history)
	local args = { prompt }
	if text ~= nil then
		args[#args + 1] = text
		if history ~= nil then
			args[#args + 1] = history
		end
	end
	return vim.fn['quickui#input#open'](unpack(args))
end


return M
