----------------------------------------------------------------------
-- quickui.context: Lua interface for vim-quickui context menu.
--
-- Usage:
--   local context = require('quickui.context')
--   context.open({
--       { '&Help Keyword\t\\ch', 'echo 100' },
--       { '&Signature\t\\cs', function() print('sig') end },
--       { '-' },
--       { 'Find in &File\t\\cx', function() print('find') end },
--   }, { index = context.cursor })
----------------------------------------------------------------------

local bridge = require('quickui._bridge')


--- Context menu item: { text, command, help }
---@class quickui.ContextItem
---@field [1] string Display text (supports `&` hotkeys, `\t` right-aligned text)
---@field [2]? string|function Ex command or Lua callback
---@field [3]? string Help tip text

--- Options for context menu.
---@class quickui.ContextOpts
---@field border? integer Border style (default: g:quickui#style#border)
---@field color? string Background highlight group (default: 'QuickBG')
---@field index? integer Initial cursor position, 0-based (default: -1)
---@field callback? string|function Callback on selection
---@field col? integer Screen column (0-based)
---@field line? integer Screen line (0-based)
---@field x? integer Alias for col
---@field y? integer Alias for line
---@field keymap? table<string, string> Custom key bindings
---@field reserve? integer Reserve hjkl keys (default: 0)
---@field ignore_case? integer Case-insensitive hotkey matching (default: 1)
---@field horizon? integer Horizontal navigation mode (default: 0)
---@field lazyredraw? integer Skip redraw after close (default: 0)
---@field zindex? integer Window z-index (default: 31000)
---@field manual? integer Manual mode, no auto-execute (default: 0)
---@field hide_system_cursor? integer Hide editor cursor (default: 0)

---@class quickui.context
local M = {}

--- Last selected cursor position (0-based, -1 if cancelled).
M.cursor = -1


----------------------------------------------------------------------
-- internal: convert items and build opts
----------------------------------------------------------------------

local _group_seq = 0

local function make_group()
	_group_seq = _group_seq + 1
	return 'ctx_' .. _group_seq
end


----------------------------------------------------------------------
-- public API
----------------------------------------------------------------------

--- Open a context menu (async on Vim, sync on Neovim).
---@param items (string|quickui.ContextItem)[] Menu items
---@param opts? quickui.ContextOpts Options
---@return any result Platform-dependent return value
function M.open(items, opts)
	local group = make_group()
	local content = bridge.convert_items(items, false, group)
	local result = vim.fn['quickui#context#open'](content, opts or {})
	M.cursor = vim.g['quickui#context#cursor'] or -1
	bridge.release_group(group)
	return result
end

--- Open a context menu and wait for selection (blocking).
--- Returns the selected command string, or empty string if cancelled.
---@param items (string|quickui.ContextItem)[] Menu items
---@param opts? quickui.ContextOpts Options
---@return string cmd Selected command string, '' if cancelled
function M.wait(items, opts)
	local group = make_group()
	local content = bridge.convert_items(items, false, group)
	local result = vim.fn['quickui#context#wait'](content, opts or {})
	M.cursor = vim.g['quickui#context#cursor'] or -1
	bridge.release_group(group)
	return result
end

--- Open a context menu with nested support and execute the selected command.
---@param items (string|quickui.ContextItem)[] Menu items
---@param opts? quickui.ContextOpts Options
function M.open_nested(items, opts)
	local group = make_group()
	local content = bridge.convert_items(items, false, group)
	vim.fn['quickui#context#open_nested'](content, opts or {})
	M.cursor = vim.g['quickui#context#cursor'] or -1
	bridge.release_group(group)
end


return M
