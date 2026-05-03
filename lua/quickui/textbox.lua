----------------------------------------------------------------------
-- quickui.textbox: Lua interface for vim-quickui multi-line text viewer.
--
-- Usage:
--   local textbox = require('quickui.textbox')
--   textbox.open({
--       'Line one',
--       'Line two',
--       'Line three',
--   }, { title = 'Preview', syntax = 'markdown' })
--
--   -- Display output of a shell command:
--   textbox.command('ls -la', { title = 'Directory Listing' })
----------------------------------------------------------------------


--- Options for textbox.
---@class quickui.TextboxOpts
---@field w? integer Window width (auto-calculated if omitted)
---@field h? integer Window height (auto-calculated if omitted)
---@field col? integer Screen column, 1-based (auto-centered if omitted)
---@field line? integer Screen line, 1-based (auto-centered if omitted)
---@field color? string Background highlight group (default: 'QuickBG')
---@field border? integer Border style (default: g:quickui#style#border)
---@field bordercolor? string Border highlight group (default: 'QuickBorder')
---@field title? string Window title
---@field syntax? string Filetype for syntax highlighting
---@field callback? function Callback: fn(topline) called on close
---@field index? integer Initial scroll position, 1-based line (default: -1)
---@field number? integer Show line numbers if 1 (default: 0)
---@field tabstop? integer Tab width
---@field cursor? integer Highlight cursor line if >= 0 (default: -1)
---@field command? string Ex command to execute in window after opening
---@field list? integer Show list characters if set
---@field resize? integer Allow window resize if 1 (default: 0)
---@field exit_on_click? integer Close on mouse click if 1 (default: 0)
---@field maxheight? integer Maximum height (default: 70% of screen)
---@field maxwidth? integer Maximum width (default: 80% of screen)

---@class quickui.textbox
local M = {}


--- Open a textbox to display text content.
---@param textlist string|string[] Text lines, single string, or buffer number
---@param opts? quickui.TextboxOpts Options
function M.open(textlist, opts)
	vim.fn['quickui#textbox#open'](textlist, opts or {})
end

--- Execute a shell command and display its output in a textbox.
---@param cmd string Shell command
---@param opts? quickui.TextboxOpts Options
function M.command(cmd, opts)
	vim.fn['quickui#textbox#command'](cmd, opts or {})
end

--- Close a textbox by window ID.
---@param winid integer Window ID
function M.close(winid)
	vim.fn['quickui#textbox#close'](winid)
end


return M
