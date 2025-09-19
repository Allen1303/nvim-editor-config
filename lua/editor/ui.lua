-- ╭──────────────────────────────────────────────╮
-- │                   UI.lua                     │
-- ╰──────────────────────────────────────────────╯
local M = {}

local function transparent_ui()
  local groups = {
    "Normal","NormalNC","NormalFloat","FloatBorder",
    "SignColumn","EndOfBuffer","LineNr","CursorLine","CursorLineNr",
    "WinSeparator","Pmenu","PmenuSel","PmenuSbar","PmenuThumb",
    "TabLine","TabLineFill","TabLineSel",
    "TelescopeNormal","TelescopeBorder",
    "NvimTreeNormal","NvimTreeNormalNC","NvimTreeEndOfBuffer",
  }
  for _, g in ipairs(groups) do pcall(vim.api.nvim_set_hl, 0, g, { bg = "none" }) end
end

local function tint_statusline()
  local cs = vim.g.colors_name or ""
  local bg =
    (cs == "onedark" and "#1f2329") or
    (cs:match("^tokyonight") and "#1a1b26") or
    (cs == "catppuccin" and "#1e1e2e") or
    "#141414"
  pcall(vim.api.nvim_set_hl, 0, "StatusLine",   { bg = bg })
  pcall(vim.api.nvim_set_hl, 0, "StatusLineNC", { bg = bg })
end

function M.apply_theme(name)
  if name == "onedark" then
    local ok, od = pcall(require, "onedark"); if ok then
      od.setup({ style = "dark", transparent = true, lualine = { transparent = true } })
      od.load()
    end
  elseif name == "tokyonight" then
    local ok, tk = pcall(require, "tokyonight"); if ok then
      tk.setup({ style = "storm", transparent = true, styles = { sidebars = "transparent", floats = "transparent" } })
      vim.cmd.colorscheme("tokyonight")
    end
  elseif name == "catppuccin" then
    local ok, cat = pcall(require, "catppuccin"); if ok then
      cat.setup({ flavour = "macchiato", transparent_background = true,
        integrations = { lualine = true, telescope = { enabled = true } } })
      vim.cmd.colorscheme("catppuccin")
    end
  end
  transparent_ui()
  tint_statusline()
end

function M.setup_lualine()
  pcall(function() require("nvim-web-devicons").setup() end)
  vim.opt.laststatus = 3
  require("lualine").setup({
    options = {
      theme = "auto",
      globalstatus = true,
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators   = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
      },
      lualine_x = {
        { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
        "encoding", "fileformat",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    extensions = { "nvim-tree", "quickfix", "toggleterm", "fugitive" },
  })
  tint_statusline()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ui_statusline_reapply", { clear = true }),
    callback = tint_statusline,
  })
end

vim.api.nvim_create_user_command("ThemeOnedark", function() M.apply_theme("onedark") end, {})
vim.api.nvim_create_user_command("ThemeTokyo",   function() M.apply_theme("tokyonight") end, {})
vim.api.nvim_create_user_command("ThemeCat",     function() M.apply_theme("catppuccin") end, {})

return M

