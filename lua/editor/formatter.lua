-- ╭──────────────────────────────────────────────╮
-- │               Formatter.lua                  │
-- ╰──────────────────────────────────────────────╯
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    javascript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    jsonc = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    scss = { "prettierd", "prettier" },
    less = { "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    lua = { "stylua" },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    require("conform").format({ bufnr = args.buf, lsp_fallback = true, quiet = true })
  end,
  desc = "Format on save (conform)",
})

