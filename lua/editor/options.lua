-- ╭──────────────────────────────────────────────╮
-- │                Options.lua                   │
-- ╰──────────────────────────────────────────────╯
local opt = vim.opt

-- UI & layout
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.wrap = false
opt.linebreak = true
opt.cmdheight = 1
opt.pumheight = 10
opt.showmode = false
opt.scrolloff = 10
opt.sidescrolloff = 10

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.equalalways = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Indent (default 4)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- Files & undo
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
opt.autoread = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion UX
opt.completeopt = { "menu", "menuone", "noselect" }

-- System clipboard (copy → browser)
opt.clipboard = "unnamedplus"

-- Optional mouse
opt.mouse = "a"

