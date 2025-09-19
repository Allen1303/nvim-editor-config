-- ╭──────────────────────────────────────────────╮
-- │               Autocmds.lua                   │
-- ╰──────────────────────────────────────────────╯
local grp = vim.api.nvim_create_augroup("allen_auto_cmd", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = grp,
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 }) end,
  desc = "Flash yanked text",
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = grp,
  callback = function()
    if vim.bo.filetype ~= "gitcommit"
      and vim.fn.line([['"]]) > 1
      and vim.fn.line([['"]]) <= vim.fn.line([[$]]) then
      vim.cmd([[silent! normal! g`"]])
      vim.cmd([[normal! zv]])
    end
  end,
  desc = "Restore last position",
})

-- Create parent dirs on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = grp,
  callback = function()
    local dir = vim.fn.expand([[%:p:h]])
    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
  end,
  desc = "Auto-create parent dirs",
})

-- Equalize splits on resize
vim.api.nvim_create_autocmd("VimResized", {
  group = grp,
  callback = function() vim.cmd([[tabdo wincmd =]]) end,
  desc = "Rebalance splits",
})

-- Re-read changed files on focus
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = grp,
  callback = function() if vim.bo.buftype == "" then vim.cmd("checktime") end end,
  desc = "Check time on focus",
})

-- Per-filetype indentation
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "javascript","javascriptreact","typescript","typescriptreact","json","jsonc","html","css","scss","less","lua","yaml","yml" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    vim.wo.wrap = false
  end,
  desc = "Indent: 4 spaces (web/lua/yaml)",
})

-- Python guide
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = "python",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    vim.wo.colorcolumn = "88"
    vim.wo.wrap = false
  end,
  desc = "Python: 4-space, 88 columns",
})

-- Markdown / Git
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "markdown", "gitcommit" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.spell = true
    vim.wo.conceallevel = 4
  end,
  desc = "Markdown/Git: wrap, spell",
})

-- JSON: show everything
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "json", "jsonc" },
  callback = function() vim.wo.conceallevel = 0 end,
  desc = "JSON: no conceal",
})

