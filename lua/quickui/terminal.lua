----------------------------------------------------------------------
-- quickui.terminal: Lua interface for vim-quickui terminal in popup.
--
-- Usage:
--   local terminal = require('quickui.terminal')
--   terminal.open('python3', { title = 'Python REPL', w = 80, h = 24 })
--
--   -- With macro expansion and output capture:
--   terminal.dialog('gcc -o <cfile:r> <cfile> && ./<cfile:r>', {
--       title = 'Build & Run',
--       capture = 1,
--   })
----------------------------------------------------------------------


--- Options for terminal.
---@class quickui.TerminalOpts
---@field w? integer|string Terminal width (number, '%' string, or '*' for screen ratio)
---@field h? integer|string Terminal height
---@field col? integer Screen column, 1-based (auto-centered if omitted)
---@field line? integer Screen line, 1-based (auto-centered if omitted)
---@field border? integer Border style (default: 1)
---@field title? string Window title
---@field color? string Highlight group (default: 'QuickTermBorder')
---@field callback? function Callback: fn(code) called on termination with exit code
---@field drag? integer Allow drag if 1 (default: 1)
---@field resize? integer Allow resize if 1 (default: 0)
---@field close? string Set to 'button' for close button
---@field cwd? string Working directory for command
---@field term_kill? string How to close terminal (Vim only, default: 'term')
---@field term_finish? string Behavior on finish (Vim only, default: 'close')
---@field input? string[] Input file lines (written to $VIM_INPUT)
---@field capture? integer If 1, capture output to $VIM_CAPTURE (default: 0)
---@field prepare? function Called before execution: fn(opts)
---@field pause? integer If 1, pause terminal on exit (default: 0)

---@class quickui.terminal
local M = {}


--- Open a terminal in a popup window.
---@param cmd string|string[] Shell command (string or list)
---@param opts? quickui.TerminalOpts Options
---@return table hwnd Window handle object
function M.open(cmd, opts)
	return vim.fn['quickui#terminal#open'](cmd, opts or {})
end

--- Open a terminal with macro expansion and optional output capture.
--- Supports macros like $(KEY), <cwd>, <cfile>, etc.
---@param cmd string Command string (macros will be expanded)
---@param opts? quickui.TerminalOpts Options
---@return table hwnd Window handle object
function M.dialog(cmd, opts)
	return vim.fn['quickui#terminal#dialog'](cmd, opts or {})
end


return M
