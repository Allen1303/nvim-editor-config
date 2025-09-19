-- ╭──────────────────────────────────────────────╮
-- │             Treesitter.lua                   │
-- ╰──────────────────────────────────────────────╯
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua","vim","vimdoc","bash","markdown","markdown_inline",
    "html","css","javascript","typescript","tsx","json","yaml","toml",
    "regex","query",
  },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent    = { enable = true },
  autotag   = { enable = true },
})

