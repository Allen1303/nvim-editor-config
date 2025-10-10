
-- ╭───────────────────-───────────────────╮
-- │         Autocmd Config File           │
-- ╰────────────────────-──────────────────╯

-- one augroup for all general autocmds (clears on reload)
local autocmds_grp = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- ╭──────────────────────────────╮
-- │  Highlight on yank           │
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("TextYankPost", {
  group = autocmds_grp,
  desc = "Flash yanked region briefly",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
  end,
})

-- ╭──────────────────────────────╮
-- │  Restore last cursor location│
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("BufReadPost", {
  group = autocmds_grp,
  desc = "Jump to last edit position",
  callback = function()
    local last = vim.api.nvim_buf_get_mark(0, '"')
    local lines = vim.api.nvim_buf_line_count(0)
    if last[1] > 0 and last[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, last)
    end
  end,
})

-- ╭──────────────────────────────╮
-- │  Filetype-specific indents   │
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("FileType", {
  group = autocmds_grp,
  pattern = { "lua", "python" },
  desc = "Indent: 4 spaces for Lua/Python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = autocmds_grp,
  pattern = { "javascript", "typescript", "json", "html", "css", "markdown" },
  desc = "Indent: 2 spaces for web files",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ╭──────────────────────────────╮
-- │  Auto-create parent dirs     │
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("BufWritePre", {
  group = autocmds_grp,
  desc = "Create missing directories before saving",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- ╭──────────────────────────────╮
-- │  Equalize splits on resize   │
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("VimResized", {
  group = autocmds_grp,
  desc = "Equalize splits after terminal resize",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ╭──────────────────────────────╮
-- │  Terminal behavior           │
-- ╰──────────────────────────────╯
vim.api.nvim_create_autocmd("TermOpen", {
  group = autocmds_grp,
  desc = "Cleaner terminal buffer (no line numbers/signcolumn)",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  group = autocmds_grp,
  desc = "Close terminal buffer after successful exit",
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, { force = false })
    end
  end,
})

-- ╭──────────────────────────────╮
-- │  Keep UI tweaks on theme set │
-- ╰──────────────────────────────╯
-- WinSeparator/borders from config.ui (if present)
do
  local ok_ui, ui = pcall(require, "config.ui")
  if ok_ui and type(ui.apply_split_border_highlight) == "function" then
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = autocmds_grp,
      desc = "Keep bold, heavy split borders",
      callback = ui.apply_split_border_highlight,
    })
  end
end

-- Keep statusline opaque & themed after :colorscheme (if present)
vim.api.nvim_create_autocmd("ColorScheme", {
  group = autocmds_grp,
  desc = "Keep statusline opaque & themed after :colorscheme",
  callback = function()
    local ok, sl = pcall(require, "config.statusline")
    if ok and type(sl.refresh) == "function" then
      sl.refresh()
    end
  end,
})
