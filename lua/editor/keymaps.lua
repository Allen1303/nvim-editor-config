-- ╭──────────────────────────────────────────────╮
-- │                Keymaps.lua                   │
-- ╰──────────────────────────────────────────────╯
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, opts)
  if type(opts) == "string" then opts = { desc = opts } end
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force",
    { noremap = true, silent = true }, opts or {}))
end

-- No-op space
map({ "n","v" }, "<Space>", "<Nop>", "No-op")

-- QoL
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>w", "<cmd>update<CR>", "Save if changed")
map("n", "<leader>q", "<cmd>quit<CR>", "Quit window")
map("n", "<leader>Q", "<cmd>qall!<CR>", "Quit all (force)")
map("n", "Y", "y$", "Yank to end of line")
map("n", "Q", "<Nop>", "Disable Ex mode")

-- Centered motions
map({ "n","x","o" }, "n", "nzzzv", "Next centered")
map({ "n","x","o" }, "N", "Nzzzv", "Prev centered")
map("n", "*", "*zzzv", "Word forward")
map("n", "#", "#zzzv", "Word backward")
map("n", "<C-d>", "<C-d>zz", "Page down centered")
map("n", "<C-u>", "<C-u>zz", "Page up centered")
map("n", "gg", "ggzz", "Top centered")
map("n", "G", "Gzz", "Bottom centered")

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
map("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", "Move line down (insert)")
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", "Move line up (insert)")
map("v", "<A-j>", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "<A-k>", ":m '<-2<CR>gv=gv", "Move selection up")
map("v", "<", "<gv", "Indent left (keep selection)")
map("v", ">", ">gv", "Indent right (keep selection)")
map("x", "<leader>p", [["_dP]], "Paste without yanking")

-- Windows & splits
map("n", "<C-h>", "<C-w>h", "Left window")
map("n", "<C-j>", "<C-w>j", "Down window")
map("n", "<C-k>", "<C-w>k", "Up window")
map("n", "<C-l>", "<C-w>l", "Right window")
map("n", "<leader>sv", "<cmd>vsplit<CR>", "Vertical split")
map("n", "<leader>sh", "<cmd>split<CR>", "Horizontal split")
map("n", "<leader>se", "<C-w>=", "Equalize splits")
map("n", "<leader>sx", "<cmd>close<CR>", "Close split")
map("n", "<C-Up>", "<cmd>resize +2<CR>", "Taller")
map("n", "<C-Down>", "<cmd>resize -2<CR>", "Shorter")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Narrower")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Wider")

-- Buffers
map("n", "<leader>bn", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bp", "<cmd>bprevious<CR>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")
map("n", "<leader>bl", "<cmd>ls<CR>", "List buffers")

-- Paths → clipboard
map("n", "<leader>cf", function() vim.fn.setreg("+", vim.fn.expand("%:p")); vim.notify("Copied full path") end, "Copy full path")
map("n", "<leader>cr", function() vim.fn.setreg("+", vim.fn.expand("%:."));  vim.notify("Copied relative path") end, "Copy relative path")
map("n", "<leader>cn", function() vim.fn.setreg("+", vim.fn.expand("%:t"));  vim.notify("Copied filename") end, "Copy filename")
map("n", "<leader>cd", function() vim.fn.setreg("+", vim.fn.expand("%:p:h"));vim.notify("Copied directory") end, "Copy directory")

-- Floating terminal (robust)
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Terminal (float)" })
vim.keymap.set("t", "<leader>tt", [[<C-\><C-n>:ToggleTerm<CR>]], { desc = "Toggle Terminal (float)" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", "Files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", "Grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", "Buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", "Help")
map("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>", "Explorer (toggle)")

