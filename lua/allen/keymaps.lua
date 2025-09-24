-- lua/allen/keymaps.lua file

-- Global leader key set to <Space>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper variable + silent defaults
local keymap = vim.keymap.set
local map_opts = { noremap = true, silent = true }

keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", vim.tbl_extend("force", map_opts, { desc = "find files"}))
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", vim.tbl_extend("force", map_opts, { desc = "live_grep"}))
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", vim.tbl_extend("force", map_opts, { desc = "buffers"}))
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", vim.tbl_extend("force", map_opts, { desc = "Hlep tags"}))
