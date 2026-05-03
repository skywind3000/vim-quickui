----------------------------------------------------------------------
-- quickui.dialog: Lua interface for vim-quickui data-driven dialog.
--
-- Usage:
--   local dialog = require('quickui.dialog')
--   local result = dialog.open({
--       { type = 'label', text = 'Please fill in:' },
--       { type = 'input', name = 'username', prompt = 'Name:', value = 'skywind' },
--       { type = 'input', name = 'email', prompt = 'Email:' },
--       { type = 'check', name = 'admin', text = '&Administrator' },
--       { type = 'button', name = 'confirm', items = { ' &OK ', ' &Cancel ' } },
--   }, { title = 'User Info', center = 1 })
--
--   if result.button == 'confirm' and result.button_index == 0 then
--       print('Name: ' .. result.username)
--   end
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Dialog control types:
--   label     - static text (string or list of strings)
--   input     - single-line text input with readline editing
--   radio     - radio button group (horizontal or vertical)
--   check     - checkbox toggle
--   button    - button row (activating closes dialog)
--   separator - horizontal divider line
--   dropdown  - collapsed selection with popup list
----------------------------------------------------------------------

--- Label control.
---@class quickui.DialogLabel
---@field type 'label'
---@field text string|string[] Display text (string or list of lines)

--- Input control.
---@class quickui.DialogInput
---@field type 'input'
---@field name string Unique name (used as key in result dict)
---@field prompt? string Label displayed before the input field
---@field value? string Initial text
---@field history? string History namespace for cross-call browsing
---@field focus? integer Set to 1 to give initial focus

--- Radio button control.
---@class quickui.DialogRadio
---@field type 'radio'
---@field name string Unique name
---@field prompt? string Label displayed before the options
---@field items string[] Option labels (support `&` hotkeys)
---@field value? integer Initially selected index, 0-based (default: 0)
---@field vertical? integer 0=horizontal, 1=vertical, -1=auto (default: -1)

--- Checkbox control.
---@class quickui.DialogCheck
---@field type 'check'
---@field name string Unique name
---@field text string Label text (supports `&` hotkey)
---@field value? integer 0=unchecked, 1=checked (default: 0)

--- Button row control.
---@class quickui.DialogButton
---@field type 'button'
---@field name? string Button group name
---@field items string[] Button labels (support `&` hotkeys)
---@field value? integer Initially focused button index, 0-based
---@field focus? integer Set to focus a specific button

--- Separator control.
---@class quickui.DialogSeparator
---@field type 'separator'

--- Dropdown control.
---@class quickui.DialogDropdown
---@field type 'dropdown'
---@field name string Unique name
---@field prompt? string Label displayed before the dropdown
---@field items string[] Option labels
---@field value? integer Initially selected index, 0-based (default: 0)

---@alias quickui.DialogItem quickui.DialogLabel|quickui.DialogInput|quickui.DialogRadio|quickui.DialogCheck|quickui.DialogButton|quickui.DialogSeparator|quickui.DialogDropdown

--- Options for dialog.
---@class quickui.DialogOpts
---@field title? string Window title
---@field w? integer Content width (auto-calculated if omitted)
---@field min_w? integer Minimum auto width
---@field border? integer Border style
---@field center? integer Center on screen (default: 1)
---@field padding? integer[] { top, right, bottom, left }
---@field color? string Background highlight group
---@field bordercolor? string Border highlight group
---@field gap? integer Lines between control groups (default: 1)
---@field button? integer Show close button (default: 1)
---@field validator? function Validation callback: fn(result) -> '' or error_msg
---@field hide_system_cursor? integer Hide editor cursor during dialog

--- Dialog result.
---@class quickui.DialogResult
---@field button string Name of the activated button group ('' if Enter/Esc)
---@field button_index integer Button index within the group, 0-based (-1 if cancel)

---@class quickui.dialog
local M = {}


--- Open a data-driven dialog and return control values.
--- Blocks until the user closes the dialog.
---@param items quickui.DialogItem[] List of control definitions
---@param opts? quickui.DialogOpts Dialog options
---@return quickui.DialogResult result Dict containing all control values
function M.open(items, opts)
	return vim.fn['quickui#dialog#open'](items, opts or {})
end


return M
