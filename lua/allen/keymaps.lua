-- ===========================================================================
-- WHAT: Leader + foundational key mappings (Areas 10–11).
-- WHY : Consistent, fast navigation & edits using Neovim's built-ins first.
-- HOW : Define <Space> as leader, add clear, readable maps with descriptions.
-- ===========================================================================

-- 10) Leader key definition
-- WHAT: Make Space the global/local leader.
-- WHY : Feels natural; many community examples assume it.
-- HOW : Set *before* other mappings.
-- Set Variable g to represent vim.g global variable
-- Helper: concise set_keymaps function with descriptions
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function set_keymaps(mode, lhs, rhs, opts)
  if type(opts) == "string" then opts = {desc = opts} end
  -- Call set_keymaps helper function with either a plain description string or a full options table.
  vim.keymap.set( mode, lhs, rhs, vim.tbl_extend("force",  { noremap = true, silent = true }, opts or {}))
end
-- Prevent accidental <space> in normal/visual mode from triggering anything
set_keymaps({"n", "v"}, "<Space>", "<Nop>", "No-op for space in normal/visual modes")

-- ╭──────────────────────────────╮
-- │ 11a) Quality-of-life basics  │
-- ╰──────────────────────────────╯
-- WHAT: Clear highlights; quick save/quit; better Y; disable Ex mode.
-- WHY : Common actions at your fingertips; avoid footguns.
-- HOW : Mappings with explicit descriptions.
set_keymaps("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
set_keymaps("n", "<leader>w", "<cmd>update<CR>",   "File save (only if change)")
set_keymaps("n", "<leader>q", "<cmd>quit<CR>",     "Window: quit")
set_keymaps("n", "<leader>Q", "<cmd>qall!<CR>",    "Session: quit all (force)")
set_keymaps("n", "Y", "y$", "Yank to end of line (Like D/C)")
set_keymaps("n", "Q", "<Nop>", "Disable EX mode")

-- ╭───────────────────────-───────────────────╮
-- │ 11b) Centered navigation for search/jumps │
-- ╰────────────────────────-──────────────────╯
-- WHAT: Keep the cursor centered after next/prev search and big jumps.
-- WHY : Preserves context so your eyes don't hunt the screen.
-- HOW : Append 'zzzv' to recenter & open folds around cursor.
set_keymaps({"n","x","o"}, "n", "nzzzv", " Next match centered")
set_keymaps({"n","x","o"}, "N", "Nzzzv", " Prev match centered")
set_keymaps("n", "gg", "ggzz", "Goto top centered")

-- Additional centered navigation (NEW)
set_keymaps("n", "*", "*zzzv", "Search word forward (centered)")
set_keymaps("n", "#", "#zzzv", "Search word backward (centered)")
set_keymaps("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
set_keymaps("n", "<C-u>", "<C-u>zz", "Half page up (centered)")
set_keymaps("n", "G", "Gzz", "Goto end (centered)")

-- ╭──────────────────────────────╮
-- │ 11c) Move lines up/down      │
-- ╰──────────────────────────────╯
-- WHAT: Reorder code quickly.
-- WHY : Common refactors become trivial.
-- HOW : Alt-j/k in normal/insert/visual; keep selection when visual.
set_keymaps("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
set_keymaps("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")
set_keymaps("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", "Move line down (insert)")
set_keymaps("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", "Move line up (insert)")
set_keymaps("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down")
set_keymaps("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up")
-- Keep visual selection when indenting
set_keymaps("v", "<", "<gv", "Indent left (keep selection)")
set_keymaps("v", ">", ">gv", "Indent right (keep selection)")

-- Better paste in visual mode (NEW)
set_keymaps("x", "<leader>p", [["_dP]], "Paste without yanking")

-- ╭──────────────────────────────╮
-- │ 11d) Windows & splits        │
-- ╰──────────────────────────────╯
-- WHAT: Navigate and manage splits fluidly.
-- WHY : Muscle memory that mirrors tmux/IDE behavior.
-- HOW : Ctrl-h/j/k/l to move; leader+s* to split; leader+= to equalize.
set_keymaps("n", "<C-h>", "<C-w>h", "Focus left window")
set_keymaps("n", "<C-j>" , "<C-w>j", "Focus lower window")
set_keymaps("n", "<C-k>" , "<C-w>k", "Focus upper window")
set_keymaps("n", "<C-l>" , "<C-w>l", "Focus right window")
set_keymaps("n", "<leader>sv" , "<cmd>vsplit<CR>", "Vertical split")
set_keymaps("n", "<leader>sh" , "<cmd>split<CR>", "Horizontal split")
set_keymaps("n", "<leader>se" , "<C-w>=", "Equalize splits")
set_keymaps("n", "<leader>sx" , "<cmd>close<CR>", "Close split")

-- Window resizing (NEW)
set_keymaps("n", "<C-Up>", "<cmd>resize +2<CR>", "Increase window height")
set_keymaps("n", "<C-Down>", "<cmd>resize -2<CR>", "Decrease window height")
set_keymaps("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
set_keymaps("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

-- ╭──────────────────────────────╮
-- │ 11e) Buffer navigation (NEW) │
-- ╰──────────────────────────────╯
-- WHAT: Navigate between open files/buffers efficiently.
-- WHY : Essential for multi-file editing workflow.
-- HOW : Leader+b* for buffer operations.
set_keymaps("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
set_keymaps("n", "<leader>bp", "<cmd>bprevious<CR>", "Previous buffer")
set_keymaps("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")
set_keymaps("n", "<leader>ba", "<cmd>bufdo bd<CR>", "Delete all buffers")
set_keymaps("n", "<leader>bl", "<cmd>ls<CR>", "List buffers")

-- ╭─────-────────────────────────────────────────╮
-- │ 11f) Built-in file explorer (netrw) on right │
-- ╰─────-────────────────────────────────────────╯
-- WHAT: Toggle a minimal tree using netrw (built-in).
-- WHY : Built-in-first approach before adding a file explorer plugin.
-- HOW : Use :Vexplore and set netrw to open splits on the right.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30
vim.g.netrw_browse_split = 0
vim.g.netrw_altv = 1

-- function to toggle the NETwork Read/Write: Neovim built-in file explorer + remote file reader/writer.
local function toggle_file_explorer()
  -- If current buffer is netrw, close it; otherwise open a right-side explorer.
  local is_netrw = vim.bo.filetype == "netrw"
  if is_netrw then
    vim.cmd("quit")
  else
    vim.cmd("Vexplore")
  end
end
set_keymaps("n", "<leader>e", toggle_file_explorer, "Toggle file explorer (right)")

-- ╭──────────────────────────────╮
-- │ 11g) Search & Replace (NEW)  │
-- ╰──────────────────────────────╯
-- WHAT: Enhanced search and replace operations.
-- WHY : More efficient text editing and refactoring.
-- HOW : Smart search/replace with visual feedback.

-- Clear search highlighting (alternative to Esc)
set_keymaps("n", "<leader>nh", "<cmd>nohlsearch<CR>", "Clear search highlights")

-- Search and replace word under cursor
set_keymaps("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], 
    "Search and replace word under cursor")

-- Search and replace in visual selection
set_keymaps("v", "<leader>s", [[:s/\%V]], "Search and replace in selection")

-- ╭──────────────────────────────╮
-- │ 11h) Quickfix & Location (NEW) │
-- ╰──────────────────────────────╯
-- WHAT: Navigate quickfix and location lists efficiently.
-- WHY : Essential for error navigation, grep results, etc.
-- HOW : Consistent bracket-based navigation.

-- Quickfix navigation
set_keymaps("n", "<leader>qo", "<cmd>copen<CR>", "Open quickfix list")
set_keymaps("n", "<leader>qc", "<cmd>cclose<CR>", "Close quickfix list")
set_keymaps("n", "[q", "<cmd>cprevious<CR>", "Previous quickfix item")
set_keymaps("n", "]q", "<cmd>cnext<CR>", "Next quickfix item")

-- Location list navigation
set_keymaps("n", "<leader>lo", "<cmd>lopen<CR>", "Open location list")
set_keymaps("n", "<leader>lc", "<cmd>lclose<CR>", "Close location list")
set_keymaps("n", "[l", "<cmd>lprevious<CR>", "Previous location item")
set_keymaps("n", "]l", "<cmd>lnext<CR>", "Next location item")

-- ╭──────────────────────────────╮
-- │ 11i) File Path Utilities (NEW) │
-- ╰──────────────────────────────╯
-- WHAT: Quick ways to copy file paths to clipboard.
-- WHY : Useful for sharing, documentation, debugging.
-- HOW : Leader+c* for copy operations.

-- Copy file paths to clipboard
set_keymaps("n", "<leader>cf", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify("Copied full path: " .. path)
end, "Copy full file path")

set_keymaps("n", "<leader>cr", function()
    local path = vim.fn.expand("%:.")
    vim.fn.setreg("+", path)
    vim.notify("Copied relative path: " .. path)
end, "Copy relative file path")

set_keymaps("n", "<leader>cn", function()
    local name = vim.fn.expand("%:t")
    vim.fn.setreg("+", name)
    vim.notify("Copied filename: " .. name)
end, "Copy filename only")

set_keymaps("n", "<leader>cd", function()
    local dir = vim.fn.expand("%:p:h")
    vim.fn.setreg("+", dir)
    vim.notify("Copied directory: " .. dir)
end, "Copy file directory")

-- ╭──────────────────────────────╮
-- │ 11j) Misc ergonomics         │
-- ╰──────────────────────────────╯
-- WHAT: Make j/k respect wrapped lines when no count; keep cursor steady on joins.
-- WHY : Natural movement in long lines; preserve visual focus.
-- HOW : expr maps for j/k; use marks around J.
set_keymaps("n", "j", [[v:count == 0 ? 'gj' : 'j']], {expr = true, desc = "Move Down (respect wraps)" })
set_keymaps("n", "k", [[v:count == 0 ? 'gk' : 'k']], {expr = true, desc = "Move Up (respect wraps)" }) 
vim.o.whichwrap = "b,s,<,>,[,]" -- allow left/right to wrap to prev/next line
set_keymaps("n", "J", "mzJ`z", "Join lines (keep cursor position)")

-- Additional quality of life (NEW)
set_keymaps("n", "<leader>a", "ggVG", "Select all")

-- Return truthy for module load check
return true
