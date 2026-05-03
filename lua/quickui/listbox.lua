----------------------------------------------------------------------
-- quickui.listbox: Lua interface for vim-quickui scrollable listbox.
--
-- Usage (synchronous):
--   local listbox = require('quickui.listbox')
--   local index = listbox.inputlist({
--       { '&Alpha', 'echo 1' },
--       { '&Beta',  'echo 2' },
--       { '&Gamma', 'echo 3' },
--   }, { title = 'Choose one' })
--
-- Usage (async with callback):
--   listbox.open({
--       { 'Item 1', function() print('one') end },
--       { 'Item 2', function() print('two') end },
--   }, { title = 'Async', callback = function(code) print(code) end })
----------------------------------------------------------------------

local bridge = require('quickui._bridge')


--- Listbox item: { text, command }
--- - text: display text (supports `&` hotkeys, `\t` column separator)
--- - command: Ex command string or Lua function callback
---@class quickui.ListboxItem
---@field [1] string Display text
---@field [2]? string|function Ex command or Lua callback

--- Options for listbox.
---@class quickui.ListboxOpts
---@field title? string Window title
---@field index? integer Initial cursor position, 0-based (default: 0)
---@field w? integer Window width (auto-calculated if omitted)
---@field h? integer Window height (default: item count)
---@field col? integer Screen column, 1-based (auto-centered if omitted)
---@field line? integer Screen line, 1-based (auto-centered if omitted)
---@field color? string Background highlight group (default: 'QuickBG')
---@field border? integer Border style (default: g:quickui#style#border)
---@field bordercolor? string Border highlight group (default: 'QuickBorder')
---@field syntax? string Filetype for syntax highlighting
---@field callback? function Callback: fn(code) called on selection
---@field manual? integer If 1, don't auto-execute command (default: 0)
---@field context? table User context data
---@field keymap? table<string, string> Custom key bindings

---@class quickui.listbox
local M = {}

--- Last selected cursor position (0-based, -1 if cancelled).
M.cursor = -1

local _group_seq = 0

local function make_group()
	_group_seq = _group_seq + 1
	return 'lbox_' .. _group_seq
end


--- Open an async listbox with callback.
---@param items (string|quickui.ListboxItem)[] Listbox items
---@param opts? quickui.ListboxOpts Options
---@return any hwnd Platform-dependent window handle
function M.open(items, opts)
	local group = make_group()
	local content = bridge.convert_items(items, false, group)
	local result = vim.fn['quickui#listbox#open'](content, opts or {})
	M.cursor = vim.g['quickui#listbox#cursor'] or -1
	bridge.release_group(group)
	return result
end

--- Open a blocking listbox and return the selected index.
---@param items (string|quickui.ListboxItem)[] Listbox items
---@param opts? quickui.ListboxOpts Options (callback is ignored)
---@return integer index Selected item index (0-based), -1 if cancelled
function M.inputlist(items, opts)
	local group = make_group()
	local content = bridge.convert_items(items, false, group)
	local result = vim.fn['quickui#listbox#inputlist'](content, opts or {})
	M.cursor = vim.g['quickui#listbox#cursor'] or -1
	bridge.release_group(group)
	return result
end

--- Close an open listbox.
---@param hwnd table Window handle returned by open()
function M.close(hwnd)
	vim.fn['quickui#listbox#close'](hwnd)
end


return M
