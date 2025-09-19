-- ╭──────────────────────────────────────────────╮
-- │                 init.lua                     │
-- │ WHAT: Entry point for your config            │
-- │ WHY : Keep core clean; plugins modular       │
-- │ HOW : Bootstrap lazy, load core modules      │
-- ╰──────────────────────────────────────────────╯

pcall(function() vim.loader.enable() end)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Core
require("editor.options")
require("editor.keymaps")
require("editor.plugins")
require("editor.autocmds")

