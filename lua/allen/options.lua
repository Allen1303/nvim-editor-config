-- ── Core Options: WHAT / WHY / HOW ───────────────────────────────────────────
-- WHAT: Create a short alias to Neovim’s option API.
-- WHY : Typing 'vim.opt' repeatedly is noisy.
-- HOW : 'o' now points to vim.opt so 'o.number = true' works.

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 12 
opt.sidescrolloff = 12
opt.updatetime = 200
opt.clipboard = "unnamedplus"
opt.termguicolors = true
