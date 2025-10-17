
-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "lua", "vim", "vimdoc",
      "javascript", "typescript", "tsx", "json", "html", "css",
      "bash", "markdown", "markdown_inline", "regex", "yaml"
    },
    highlight = { enable = true },
    indent = { enable = true },       -- better than stock for most langs
    incremental_selection = {         -- super handy
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    -- Treesitter folds (optional):
    -- vim.o.foldmethod = "expr"
    -- vim.o.foldexpr   = "nvim_treesitter#foldexpr()"
  end,
}
