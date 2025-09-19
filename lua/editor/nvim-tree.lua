-- ╭──────────────────────────────────────────────╮
-- │               Nvim-tree.lua                  │
-- ╰──────────────────────────────────────────────╯
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = { side = "right", width = 36 },
  renderer = { highlight_git = true },
  filters = { dotfiles = false },
  git = { enable = true, ignore = false },
})

pcall(vim.api.nvim_set_hl, 0, "NvimTreeNormal",     { bg = "none" })
pcall(vim.api.nvim_set_hl, 0, "NvimTreeNormalNC",   { bg = "none" })
pcall(vim.api.nvim_set_hl, 0, "NvimTreeEndOfBuffer",{ bg = "none" })

