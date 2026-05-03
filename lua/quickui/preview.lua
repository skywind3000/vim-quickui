----------------------------------------------------------------------
-- quickui.preview: Lua interface for vim-quickui preview window.
--
-- Usage:
--   local preview = require('quickui.preview')
--   preview.open('README.md', { title = 'README', cursor = 10 })
--
--   -- Preview with syntax highlighting:
--   preview.open({ 'local x = 1', 'print(x)' }, { syntax = 'lua' })
--
--   -- Scroll and close:
--   preview.scroll(5)    -- scroll down 5 lines
--   preview.close()
----------------------------------------------------------------------


--- Options for preview window.
---@class quickui.PreviewOpts
---@field w? integer Window width (default: g:quickui_preview_w or 85)
---@field h? integer Window height (default: g:quickui_preview_h or 10)
---@field col? integer Screen column, 1-based (auto-positioned if omitted)
---@field line? integer Screen line, 1-based (auto-positioned if omitted)
---@field title? string Window title (auto-generated if omitted)
---@field number? integer Show line numbers if 1 (default: 1)
---@field cursor? integer Highlight line if >= 1 (default: -1)
---@field syntax? string Filetype for syntax highlighting
---@field color? string Background highlight group (default: 'QuickPreview')
---@field bordercolor? string Border highlight group
---@field border? integer Border style (default: g:quickui#style#border)
---@field persist? integer Don't auto-close on CursorMoved if 1 (default: 0)
---@field focusable? integer Make window focusable (default: 1)
---@field close? string Set to 'button' for close button
---@field callback? function Callback: fn(topline) called on close

---@class quickui.preview
local M = {}


--- Open a preview window near the cursor.
--- Auto-closes on CursorMoved unless persist=1.
---@param content string|integer|string[] File path, buffer number, or list of text lines
---@param opts? quickui.PreviewOpts Options
---@return integer winid Window ID, or -1 on error
function M.open(content, opts)
	return vim.fn['quickui#preview#open'](content, opts or {})
end

--- Close the preview window.
function M.close()
	vim.fn['quickui#preview#close']()
end

--- Check if the preview window is visible.
---@return boolean visible
function M.visible()
	return vim.fn['quickui#preview#visible']() == 1
end

--- Scroll the preview window.
---@param offset integer Lines to scroll (positive=down, negative=up)
function M.scroll(offset)
	vim.fn['quickui#preview#scroll'](offset)
end


return M
