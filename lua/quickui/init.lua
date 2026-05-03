----------------------------------------------------------------------
-- quickui: Lua interface for vim-quickui TUI component library.
--
-- Provides Lua-idiomatic wrappers for all vim-quickui widgets.
-- Requires Neovim 0.7+ for Lua function-to-funcref conversion.
--
-- Usage:
--   local qui = require('quickui')
--   qui.menu.open()
--   qui.context.open(items, opts)
--   qui.dialog.open(items, opts)
--   qui.listbox.inputlist(items, opts)
--   qui.textbox.open(lines, opts)
--   qui.input.open('prompt')
--   qui.terminal.open('bash', opts)
--   qui.confirm.open('Sure?', '&Yes\n&No')
--   qui.preview.open('file.txt', opts)
----------------------------------------------------------------------

---@class quickui
local M = {}

M.menu     = require('quickui.menu')
M.context  = require('quickui.context')
M.dialog   = require('quickui.dialog')
M.listbox  = require('quickui.listbox')
M.textbox  = require('quickui.textbox')
M.input    = require('quickui.input')
M.terminal = require('quickui.terminal')
M.confirm  = require('quickui.confirm')
M.preview  = require('quickui.preview')

return M
