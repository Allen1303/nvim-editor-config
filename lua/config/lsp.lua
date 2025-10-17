-- lua/config/lsp.lua

local M = {}

-- small helper: buffer-local keymap with a description
local function keymap(buf, mode, key, action, desc)
  vim.keymap.set(mode, key, action, { buffer = buf, silent = true, desc = desc })
end

-- nicer diagnostics: icons + virtual text + floating borders
-- Nicer diagnostics (no deprecated sign_define)
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    -- Neovim 0.11+ supports setting sign text directly here
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
})

-- Rounded borders for LSP popups
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- Helper: does any attached client support a method?
local function buf_supports(bufnr, method)
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local list = get_clients({ bufnr = bufnr }) or {}
  for _, client in ipairs(list) do
    if client.supports_method and client.supports_method(method) then
      return true
    end
    -- (older Neovim) fallback check
    if client.server_capabilities then
      if method == "textDocument/declaration" and client.server_capabilities.declarationProvider then
        return true
      end
    end
  end
  return false
end

-- Jump: declaration if supported, otherwise definition
local function goto_decl_or_def()
  local bufnr = vim.api.nvim_get_current_buf()
  if buf_supports(bufnr, "textDocument/declaration") then
    vim.lsp.buf.declaration()
  else
    vim.notify("Declaration not supported by this server → using definition", vim.log.levels.INFO, { title = "LSP" })
    vim.lsp.buf.definition()
  end
end

--  One  on_attach function() for all servers, (keys + features)
local function on_attach(client, bufnr)
  -- basic navigation
  keymap(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP: Go to Definition")
  keymap(bufnr, "n", "gD", goto_decl_or_def,        "LSP: Declaration/Definition (fallback)")
  keymap(bufnr, "n", "gr", vim.lsp.buf.references,  "LSP: References")
  keymap(bufnr, "n", "gI", vim.lsp.buf.implementation, "LSP: Implementation")
  keymap(bufnr, "n", "K",  vim.lsp.buf.hover,       "LSP: Hover")
  keymap(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
  keymap(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
  keymap(bufnr, "n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format")
  keymap(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Diag: Prev")
  keymap(bufnr, "n", "]d", vim.diagnostic.goto_next, "Diag: Next")
  keymap(bufnr, "n", "gl", vim.diagnostic.open_float, "Diag: Line Float")

  -- document highlights (if server supports it)
  if client.server_capabilities.documentHighlightProvider then
    local grp = vim.api.nvim_create_augroup("user_lsp_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight,
      desc = "LSP: highlight references",
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references,
      desc = "LSP: clear references",
    })
  end
end

-- basic capabilities (good defaults; add cmp later if you want)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- find project root by markers; falls back to file dir
local function root_dir(markers)
  local f = vim.api.nvim_buf_get_name(0)
  local cwd = (vim.uv or vim.loop).cwd()
  local found = vim.fs.root(f ~= "" and f or cwd, markers or { ".git" })
  return found or cwd
end

-- start helper: merge defaults + start one server
local function start_server(cfg)
  if not cfg or not cfg.cmd then return end
  cfg.name         = cfg.name or cfg.cmd[1]
  cfg.capabilities = vim.tbl_deep_extend("force", capabilities, cfg.capabilities or {})
  cfg.on_attach    = (function(old)
    return function(client, bufnr)
      if old then pcall(old, client, bufnr) end
      on_attach(client, bufnr)
    end
  end)(cfg.on_attach)

  cfg.root_dir = cfg.root_dir or root_dir(cfg.root_markers or { ".git" })

  -- avoid duplicate clients per root+name (works on 0.9 and 0.10)
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  for _, c in ipairs(get_clients({ name = cfg.name })) do
    if c.config and c.config.root_dir == cfg.root_dir then
      vim.lsp.buf_attach_client(0, c.id)
      return
    end
  end

  vim.lsp.start(cfg)
end

-- Lua (Neovim config/dev)
local function setup_lua_ls()
  start_server({
    name = "lua_ls",
    cmd  = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git", "lua", "stylua.toml" },
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  })
end

-- TypeScript / JavaScript (vtsls)
local function setup_vtsls()
  start_server({
    name = "vtsls",
    cmd  = { "vtsls", "--stdio" },
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
    root_markers = { "tsconfig.json", "package.json", ".git" },
    settings = {
      typescript = {
        updateImportsOnFileMove = { enabled = "always" },
        suggest = { completeFunctionCalls = true },
        inlayHints = {
          functionLikeReturnTypes = { enabled = true },
          parameterTypes = { enabled = true },
          parameterNames = { enabled = "literals" },
          enumMemberValues = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
        },
      },
      javascript = {
        inlayHints = {
          functionLikeReturnTypes = { enabled = true },
          parameterTypes = { enabled = true },
          parameterNames = { enabled = "literals" },
          enumMemberValues = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
        },
      },
    },
  })
end

-- HTML
local function setup_html()
  start_server({
    name = "html",
    cmd  = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    root_markers = { "package.json", ".git" },
    settings = { html = { format = { wrapLineLength = 120, wrapAttributes = "auto" } } },
  })
end

-- CSS
local function setup_css()
  start_server({
    name = "cssls",
    cmd  = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
    settings = { css = { validate = true }, scss = { validate = true }, less = { validate = true } },
  })
end

-- JSON
local function setup_json()
  start_server({
    name = "jsonls",
    cmd  = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { "package.json", ".git" },
    settings = { json = { validate = { enable = true } } },
  })
end

-- TailwindCSS
local function setup_tailwind()
  start_server({
    name = "tailwindcss",
    cmd  = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    root_markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts", "postcss.config.js", "package.json", ".git" },
    init_options = { userLanguages = { eel = "html" } }, -- harmless example; remove if unused
    settings = { tailwindCSS = { validate = true } },
  })
end

-- ESLint
local function setup_eslint()
  start_server({
    name = "eslint",
    cmd  = { "vscode-eslint-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue", "svelte" },
    root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", "package.json", ".git" },
    settings = {
      eslint = {
        run = "onType",
        workingDirectory = { mode = "auto" },
        nodePath = "", -- let it resolve automatically
      },
    },
  })
end

-- auto-start when editing Lua (and once at startup if current buf is Lua)
local grp = vim.api.nvim_create_augroup("user_lsp_autostart", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "lua" },
  callback = setup_lua_ls,
  desc = "Start lua_ls on Lua buffers",
})
if vim.bo.filetype == "lua" then setup_lua_ls() end

vim.api.nvim_create_autocmd("FileType", {
  group = grp, pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = setup_vtsls, desc = "Start vtsls",
})
vim.api.nvim_create_autocmd("FileType", {
  group = grp, pattern = { "html" }, callback = setup_html, desc = "Start html LS",
})
vim.api.nvim_create_autocmd("FileType", {
  group = grp, pattern = { "css", "scss", "less" }, callback = setup_css, desc = "Start css LS",
})
vim.api.nvim_create_autocmd("FileType", {
  group = grp, pattern = { "json", "jsonc" }, callback = setup_json, desc = "Start json LS",
})
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  callback = setup_tailwind, desc = "Start tailwindcss LS",
})
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  callback = setup_eslint, desc = "Start ESLint LS",
})
return M

