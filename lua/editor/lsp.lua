-- ╭──────────────────────────────────────────────╮
-- │                 LSP (native)                 │
-- │ WHAT: vim.lsp.config + vim.lsp.enable        │
-- ╰──────────────────────────────────────────────╯

-- Mason + bridge
local has_mason, mason = pcall(require, "mason")
if has_mason then mason.setup() end

local has_bridge, mlsp = pcall(require, "mason-lspconfig")
if has_bridge then
  mlsp.setup({
    ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", "emmet_ls" }, -- tsserver → ts_ls
    automatic_enable = false, -- we enable manually after configs
  })
end

-- cmp capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- on_attach keymaps
local on_attach = function(_, bufnr)
  local m = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end
  m("n","gd",vim.lsp.buf.definition,"Definition")
  m("n","gD",vim.lsp.buf.declaration,"Declaration")
  m("n","gr",vim.lsp.buf.references,"References")
  m("n","gi",vim.lsp.buf.implementation,"Implementation")
  m("n","K", vim.lsp.buf.hover,"Hover")
  m("n","<leader>rn",vim.lsp.buf.rename,"Rename")
  m({"n","v"},"<leader>ca",vim.lsp.buf.code_action,"Code action")
  m("n","[d",vim.diagnostic.goto_prev,"Prev diagnostic")
  m("n","]d",vim.diagnostic.goto_next,"Next diagnostic")
  m("n","<leader>e",vim.diagnostic.open_float,"Line diagnostics")
end

-- Server configs
vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("ts_ls",   { on_attach = on_attach, capabilities = capabilities })
vim.lsp.config("html",    { on_attach = on_attach, capabilities = capabilities })
vim.lsp.config("cssls",   { on_attach = on_attach, capabilities = capabilities })
vim.lsp.config("emmet_ls",{
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "html","css","scss","less",
    "javascriptreact","typescriptreact","svelte","vue","astro","pug","eruby",
  },
})

-- Enable servers
vim.lsp.enable({ "lua_ls","ts_ls","html","cssls","emmet_ls" })

-- Borders & diagnostics UX
local h = vim.lsp.handlers
h["textDocument/hover"]         = vim.lsp.with(h.hover,          { border = "rounded" })
h["textDocument/signatureHelp"] = vim.lsp.with(h.signature_help, { border = "rounded" })
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded" },
})

