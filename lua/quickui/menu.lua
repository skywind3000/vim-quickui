----------------------------------------------------------------------
-- quickui.menu: Lua interface for vim-quickui menu bar.
--
-- Usage:
--   local menu = require('quickui.menu')
--   menu.reset()
--   menu.install('&File', {
--       { '&New\tCtrl+n', 'enew' },
--       { '&Open\t(F3)', function() vim.cmd('browse e') end },
--       { '--' },
--       { '&Save\tCtrl+s', 'w' },
--   })
--   vim.keymap.set('n', '<F2>', menu.open)
----------------------------------------------------------------------

local bridge = require('quickui._bridge')


--- Menu item: { text, command, help }
--- - text: display text (supports `&` hotkeys, `\t` right-aligned hints)
--- - command: Ex command string or Lua function callback
--- - help: tip text shown in the command line
---@class quickui.MenuItem
---@field [1] string Display text
---@field [2]? string|function Ex command or Lua callback
---@field [3]? string Help tip text

---@class quickui.menu
local M = {}


----------------------------------------------------------------------
-- namespace management
----------------------------------------------------------------------

--- Reset current namespace: clear all menu entries and release
--- associated Lua callbacks.
function M.reset()
	bridge.release_group('menu')
	vim.fn['quickui#menu#reset']()
end

--- Switch to a named namespace.
---@param name string Namespace name (default namespace is 'system')
function M.switch(name)
	vim.fn['quickui#menu#switch'](name)
end


----------------------------------------------------------------------
-- item registration
----------------------------------------------------------------------

--- Install menu items into a section.
---@param section string Section name (e.g., '&File')
---@param items (string|quickui.MenuItem)[] Menu items
---@param weight? integer Sort weight (lower = more left)
---@param ft? string Comma-separated filetype filter
function M.install(section, items, weight, ft)
	local content = bridge.convert_items(items, true, 'menu')
	local args = { section, content }
	if weight ~= nil then
		args[#args + 1] = weight
		if ft ~= nil then
			args[#args + 1] = ft
		end
	end
	vim.fn['quickui#menu#install'](unpack(args))
end

--- Register a single menu entry.
---@param section string Section name
---@param entry string Entry text (supports `&` hotkey)
---@param command string|function Ex command or Lua callback
---@param help? string Help tip text
function M.register(section, entry, command, help)
	local cmd = bridge.to_cmd(command, true, 'menu')
	vim.fn['quickui#menu#register'](section, entry, cmd, help or '')
end

--- Remove a menu entry by index or name.
---@param section string Section name
---@param index integer|string 0-based index, entry name, or '*' for all
---@return integer status 0 on success, -1 on failure
function M.remove(section, index)
	return vim.fn['quickui#menu#remove'](section, index)
end

--- Clear all entries in a section.
---@param section string Section name
function M.clear(section)
	vim.fn['quickui#menu#clear'](section)
end


----------------------------------------------------------------------
-- section metadata
----------------------------------------------------------------------

--- Get section metadata.
---@param section string Section name
---@return table|nil section Section data or nil if not found
function M.section(section)
	local result = vim.fn['quickui#menu#section'](section)
	if result == vim.NIL then return nil end
	return result
end

--- Change section display weight.
---@param section string Section name
---@param weight integer Sort weight
function M.change_weight(section, weight)
	vim.fn['quickui#menu#change_weight'](section, weight)
end

--- Change section filetype filter.
---@param section string Section name
---@param ft string Comma-separated filetypes
function M.change_ft(section, ft)
	vim.fn['quickui#menu#change_ft'](section, ft)
end

--- Preset menu items: install items while preserving existing entries.
--- Existing entries are appended after the new items with a separator.
---@param section string Section name
---@param items (string|quickui.MenuItem)[] Menu items
---@param weight? integer Sort weight
function M.preset(section, items, weight)
	local content = bridge.convert_items(items, true, 'menu')
	local args = { section, content }
	if weight ~= nil then
		args[#args + 1] = weight
	end
	vim.fn['quickui#menu#preset'](unpack(args))
end

--- Get available sections for a namespace (filtered by current filetype).
---@param name string Namespace name
---@return table[] sections List of { weight, name, menu } tuples
function M.available(name)
	return vim.fn['quickui#menu#available'](name)
end


----------------------------------------------------------------------
-- display
----------------------------------------------------------------------

--- Open the menu bar.
---@param namespace? string Namespace name (default: current namespace)
function M.open(namespace)
	if namespace then
		vim.fn['quickui#menu#open'](namespace)
	else
		vim.fn['quickui#menu#open']()
	end
end


return M
