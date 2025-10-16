-- ╭───────────--------------────────────-───────────────────╮
-- │   Keymaps : Leader + Functional Navigation & Editing    │
-- ╰───────────────────────--─-────────────────------------──╯
-- Helper function--------------------------------------------
local function set_keymaps(mode, key, action, opts)
	if type(opts) == "string" then
		opts = { desc = opts }
	end -- checks if the value passed to the opts param is a Lua string data type.
	local defaults = { noremap = true, silent = true } -- noremap prevents recursive mappings; silent hides command echoes.
	opts = vim.tbl_extend("force", defaults, opts or {}) -- merge user options with defaults without mutating either.
	vim.keymap.set(mode, key, action, opts)
end
-- set_keymaps("n", "<leader>zz", function() print("keymap worked") end, "Test keymap")
-- Prevent accidental <space> in normal/visual mode from triggering anything
set_keymaps({ "n", "v" }, "<Space>", "<Nop>", "No-op for space in normal/visual modes")
-- ╭──────────────────────────────╮
-- │  Quality-of-life basics      │
-- ╰──────────────────────────────╯
set_keymaps("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlights")
set_keymaps("n", "<leader>w", "<cmd>update<CR>", "File save (only if change)")
set_keymaps("n", "<leader>q", "<cmd>quit<CR>", "Window: quit")
set_keymaps("n", "<leader>Q", "<cmd>qall!<CR>", "Session: quit all (force)")
set_keymaps("n", "<leader>Y", "y$", "Yank to end of line (like D/C)")
set_keymaps("n", "<leader>Q", "<Nop>", "Disable EX mode")
-- Additional quality of life )
set_keymaps("n", "<leader>a", "ggVG", "Select all")
-- ╭───────────────────────-───────────────────╮
-- │  Centered navigation for search/jumps     │
-- ╰────────────────────────-──────────────────╯
-- HOW : Append 'zzzv' to recenter & open folds around cursor.
set_keymaps({ "n", "x", "o" }, "n", "nzzzv", " Next match centered")
set_keymaps({ "n", "x", "o" }, "N", "Nzzzv", " Prev match centered")
set_keymaps("n", "gg", "ggzz", "Goto top centered")

-- Additional centered navigation (NEW)
set_keymaps("n", "*", "*zzzv", "Search word forward (centered)")
set_keymaps("n", "#", "#zzzv", "Search word backward (centered)")
set_keymaps("n", "<C-d>", "<C-d>zz", "Half page down (centered)")
set_keymaps("n", "<C-u>", "<C-u>zz", "Half page up (centered)")
set_keymaps("n", "G", "Gzz", "Goto end (centered)")

-- ╭──────────────────────────────╮
-- │ Move lines up/down           │
-- ╰──────────────────────────────╯
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
-- │ Windows & splits             │
-- ╰──────────────────────────────╯
-- WHY : Muscle memory that mirrors IDE behavior.
-- HOW : Ctrl-h/j/k/l to move; leader+s* to split; leader+= to equalize.
set_keymaps("n", "<C-h>", "<C-w>h", "Focus left window")
set_keymaps("n", "<C-j>", "<C-w>j", "Focus lower window")
set_keymaps("n", "<C-k>", "<C-w>k", "Focus upper window")
set_keymaps("n", "<C-l>", "<C-w>l", "Focus right window")
set_keymaps("n", "<leader>sv", "<cmd>vsplit<CR>", "Vertical split")
set_keymaps("n", "<leader>sh", "<cmd>split<CR>", "Horizontal split")
set_keymaps("n", "<leader>se", "<C-w>=", "Equalize splits")
set_keymaps("n", "<leader>sx", "<cmd>close<CR>", "Close split")

-- Window resizing (NEW)
set_keymaps("n", "<C-Up>", "<cmd>resize +2<CR>", "Increase window height")
set_keymaps("n", "<C-Down>", "<cmd>resize -2<CR>", "Decrease window height")
set_keymaps("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Decrease window width")
set_keymaps("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Increase window width")

-- ╭──────────────────────────────╮
-- │  Buffer navigation           │
-- ╰──────────────────────────────╯
-- WHY : Essential for multi-file editing workflow.
-- HOW : Leader+b* for buffer operations.
set_keymaps("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
set_keymaps("n", "<leader>bp", "<cmd>bprevious<CR>", "Previous buffer")
-- ╭──────────────────────────────╮
-- │  Search & Replace (NEW)      │
-- ╰──────────────────────────────╯
-- WHY : More efficient text editing and refactoring.
-- HOW : Smart search/replace with visual feedback.

-- Clear search highlighting (alternative to Esc)
set_keymaps("n", "<leader>nh", "<cmd>nohlsearch<CR>", "Clear search highlights")

-- Search and replace word under cursor
set_keymaps(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	"Search and replace word under cursor"
)

-- Search and replace in visual selection
set_keymaps("v", "<leader>s", [[:s/\%V]], "Search and replace in selection")

-- ╭──────────────────────────────╮
-- │ Quickfix & Location          │
-- ╰──────────────────────────────╯
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
-- │  Misc ergonomics             │
-- ╰──────────────────────────────╯
-- WHY : Natural movement in long lines; preserve visual focus.
-- HOW : expr maps for j/k; use marks around J.
set_keymaps("n", "j", [[v:count == 0 ? 'gj' : 'j']], { expr = true, desc = "Move Down (respect wraps)" })
set_keymaps("n", "k", [[v:count == 0 ? 'gk' : 'k']], { expr = true, desc = "Move Up (respect wraps)" })
set_keymaps("n", "J", "mzJ`z", "Join lines (keep cursor position)")
