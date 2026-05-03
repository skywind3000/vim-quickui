----------------------------------------------------------------------
-- quickui._bridge: Internal callback bridge between Lua and VimScript.
-- Converts Lua functions to VimScript-executable Ex command strings.
-- NOT part of the public API.
----------------------------------------------------------------------

---@class quickui._bridge
local M = {}

---@type table<integer, {fn: function, persistent: boolean}>
local _cbs = {}
local _next_id = 1

--- Callback group registry for batch cleanup.
---@type table<string, integer[]>
local _groups = {}


----------------------------------------------------------------------
-- Convert a command argument: string passes through, function gets
-- registered as a callback and returns a "lua require(...)._invoke(N)"
-- command string that VimScript can execute.
----------------------------------------------------------------------

--- Convert a command to a VimScript Ex command string.
--- String commands pass through unchanged; Lua functions are registered
--- and converted to a `lua require('quickui._bridge')._invoke(N)` string.
---@param cmd string|function Command string or Lua callback
---@param persistent? boolean Keep callback alive after invocation (default: false)
---@param group? string Group name for batch cleanup via release_group()
---@return string cmd VimScript Ex command string
---@return integer? id Callback ID (nil if cmd was already a string)
function M.to_cmd(cmd, persistent, group)
	if cmd == nil or cmd == '' then
		return '', nil
	end
	if type(cmd) == 'string' then
		return cmd, nil
	end
	if type(cmd) ~= 'function' then
		error('quickui._bridge.to_cmd: expected string|function, got ' .. type(cmd))
	end
	local id = _next_id
	_next_id = _next_id + 1
	_cbs[id] = { fn = cmd, persistent = persistent or false }
	if group then
		if not _groups[group] then _groups[group] = {} end
		table.insert(_groups[group], id)
	end
	return string.format("lua require('quickui._bridge')._invoke(%d)", id), id
end


----------------------------------------------------------------------
-- Convert a list of menu/context/listbox items to VimScript format.
-- Each item can be:
--   'string'             -> separator or simple text
--   { text, cmd, help }  -> positional table (cmd can be string|function)
----------------------------------------------------------------------

--- Convert a list of items to VimScript-compatible content format.
---@param items (string|table)[] Item list
---@param persistent? boolean Whether callbacks should survive multiple invocations
---@param group? string Callback group name for batch cleanup
---@return table[] content Converted content list for VimScript
function M.convert_items(items, persistent, group)
	local content = {}
	for _, item in ipairs(items) do
		if type(item) == 'string' then
			table.insert(content, { item, '', '' })
		elseif type(item) == 'table' then
			local text = item[1] or ''
			local cmd = item[2] or ''
			local help = item[3] or ''
			if type(cmd) == 'function' then
				cmd = M.to_cmd(cmd, persistent, group)
			end
			table.insert(content, { text, cmd, help })
		end
	end
	return content
end


----------------------------------------------------------------------
-- Internal: invoked from VimScript via the command string produced
-- by to_cmd(). Do not call directly.
----------------------------------------------------------------------

--- @param id integer Callback ID
function M._invoke(id)
	local entry = _cbs[id]
	if not entry then return end
	entry.fn()
	if not entry.persistent then
		_cbs[id] = nil
	end
end


----------------------------------------------------------------------
-- Group lifecycle management
----------------------------------------------------------------------

--- Release all callbacks belonging to a named group.
---@param group string Group name
function M.release_group(group)
	local ids = _groups[group]
	if not ids then return end
	for _, id in ipairs(ids) do
		_cbs[id] = nil
	end
	_groups[group] = nil
end


return M
