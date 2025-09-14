-- =============================================================================
-- WHAT: UI bootstrap + themes + transparency + modern statusline (lualine)
-- WHY : Readable editor + resilient theme fallback; no re-source warnings.
-- HOW : Guard lazy.nvim bootstrap/setup; configure themes; apply scheme;
--       unify transparency (but keep statusline opaque); set up lualine.
-- =============================================================================

-- ╭───────────────────────-────────────────────────────╮
-- │ Bootstrap & guard lazy.nvim (safe to :luafile)     │
-- ╰────────────────────────-───────────────────────────╯
-- WHAT: Only add to rtp & call setup() once per session.
-- WHY : Avoid “Re-sourcing your config…” warnings from lazy.nvim.
-- HOW : Use vim.g flags to skip repeated work on reload.

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazy_path
  })
end
if not vim.g.__allen_lazy_rtp then
  vim.opt.rtp:prepend(lazy_path)
  vim.g.__allen_lazy_rtp = true
end

if not vim.g.__allen_lazy_setup then
  require("lazy").setup({
    { "navarasu/onedark.nvim", priority = 1000, lazy = false },
    { "folke/tokyonight.nvim", priority = 1000, lazy = true  },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, lazy = true },
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, lazy = false },
  }, {
    ui = { border = "rounded" },
  })
  vim.g.__allen_lazy_setup = true
end

-- ╭───────────────────────-────────────────────────────╮
-- │ Configure themes                                    │
-- ╰────────────────────────-───────────────────────────╯
-- WHAT: Apply native options (incl. transparency toggles).
-- WHY : Consistent look across schemes & future reloads.
-- HOW : pcall(require, ...) so first-run installs don’t error.

if pcall(require, "onedark") then
  require("onedark").setup({
    style = "dark",
    transparent = true,            -- editor background transparent
  })
end

if pcall(require, "tokyonight") then
  require("tokyonight").setup({
    style = "storm",
    transparent = true,
    styles = { sidebars = "transparent", floats = "transparent" },
  })
end

if pcall(require, "catppuccin") then
  require("catppuccin").setup({
    flavour = "macchiato",
    transparent_background = true,
    integrations = { lualine = true },
  })
end

-- ╭───────────────────────-────────────────────────────╮
-- │ Apply preferred colorscheme (with fallbacks)       │
-- ╰────────────────────────-───────────────────────────╯
-- WHAT: Try onedark → catppuccin → tokyonight-storm.
-- WHY : Guarantee a valid scheme even during first install.
-- HOW : pcall(vim.cmd, "colorscheme …") to avoid errors.

if not pcall(vim.cmd, "colorscheme onedark") then
  if not pcall(vim.cmd, "colorscheme catppuccin") then
    pcall(vim.cmd, "colorscheme tokyonight-storm")
  end
end

-- ╭───────────────────────-────────────────────────────╮
-- │ Transparency pass (keep statusline opaque)         │
-- ╰────────────────────────-───────────────────────────╯
-- WHAT: Force common UI groups to be transparent, but
--       DO NOT touch StatusLine/StatusLineNC.
-- WHY : You asked for a non-transparent status bar/line.
-- HOW : Clear backgrounds to NONE for panels; skip statusline.

vim.g.pde_transparent = true
if vim.g.pde_transparent then
  local clear = function(group) vim.api.nvim_set_hl(0, group, { bg = "NONE" }) end
  clear("Normal")
  clear("NormalNC")
  clear("NormalFloat")
  clear("FloatBorder")
  clear("SignColumn")
  clear("LineNr")
  clear("CursorLine")
  clear("CursorLineNr")
  -- DO NOT clear StatusLine/StatusLineNC here (keep theme colors)
  clear("TabLine")
  clear("TabLineFill")
  clear("TabLineSel")
  clear("Pmenu")
  clear("PmenuSel")
  clear("PmenuSbar")
  clear("PmenuThumb")
  clear("EndOfBuffer")
  clear("WinSeparator")
  -- If you previously forced statusline transparent in an old run, reset it:
  vim.api.nvim_set_hl(0, "StatusLine", {})
  vim.api.nvim_set_hl(0, "StatusLineNC", {})
end

-- ╭───────────────────────-────────────────────────────╮
-- │ LuaLine statusline (modern look, opaque bar)       │
-- ╰────────────────────────-───────────────────────────╯
-- WHAT: Configure lualine and keep its background opaque.
-- WHY : Better readability & contrast with transparent editor.
-- HOW : Choose theme by current colorscheme; don’t zero out bg colors.

vim.opt.laststatus = 3   -- global statusline

local colorscheme_name = vim.g.colors_name or ""
local lualine_theme = "auto"
if colorscheme_name == "onedark" then
  lualine_theme = "onedark"
elseif colorscheme_name:match("^tokyonight") then
  lualine_theme = "tokyonight"
elseif colorscheme_name == "catppuccin" then
  lualine_theme = "catppuccin"
end

local lualine_opts = {
  options = {
    theme = lualine_theme,          -- keep theme-provided bg (opaque)
    icons_enabled = true,
    globalstatus = true,
    component_separators = { left = "", right = "" },
    section_separators   = { left = "", right = "" },
  },
  sections = {
    lualine_a = { { "mode" } },
    lualine_b = { { "branch" }, { "diff" }, { "diagnostics" } },
    lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
    lualine_x = { { "encoding" }, { "fileformat" }, { "filetype" } },
    lualine_y = { { "progress" } },
    lualine_z = { { "location" } },
  },
}
require("lualine").setup(lualine_opts)
-- =============================================================================
-- UI POLISH ADDITIONS - Add these to the END of your existing ui.lua
-- =============================================================================

-- ╭───────────────────────-─────────────────────────────╮
-- │ LSP Diagnostic Signs with Icons                     │
-- ╰───────────────────────-─────────────────────────────╯
local signs = {
  Error = " ",
  Warn = " ", 
  Info = " ",
  Hint = "󰌵 ",
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ╭───────────────────────-─────────────────────────────╮
-- │ Rounded Borders for LSP Floating Windows            │
-- ╰───────────────────────-─────────────────────────────╯
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  opts.max_width = opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
