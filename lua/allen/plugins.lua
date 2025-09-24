--------------------------------------------------------------------------------
-- allen/plugins.lua
-- PURPOSE: bootstrap lazy.nvim and declare plugins (themes → dashboard → search)
--------------------------------------------------------------------------------

-- ➊ Bootstrap lazy.nvim (as before) ------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ➋ lazy.setup: keep THEME first, then Dashboard, then Plenary/Telescope -------
require("lazy").setup({

  -------------------------------------------------------------------------------
  -- THEMES (primary first so UI colors apply immediately)
  -------------------------------------------------------------------------------
  {
    "navarasu/onedark.nvim",
    priority = 1000,          -- ➌ Keep primary theme early
    lazy = false,             -- ➍ Load on startup (not lazily)
    config = function()
      require("onedark").setup({
        style = "darker",
        transparent = true,   -- ✅ your transparency requirement
      })
      require("onedark").load()
    end,
  },

  { -- Catppuccin fallback (Macchiato)
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "macchiato", transparent_background = true },
  },

  { -- TokyoNight fallback (Storm)
    "folke/tokyonight.nvim",
    opts = { style = "storm", transparent = true },
  },

  -------------------------------------------------------------------------------
  -- DASHBOARD (after themes so it inherits colors)
  -------------------------------------------------------------------------------
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",                                -- ➎ Load on VimEnter
    dependencies = { "nvim-tree/nvim-web-devicons" },  -- ➏ Put deps HERE (not inside config)
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            [[          Neovim PDE                                                   ]],
            [[                                                                      ]],
            [[       ████ ██████           █████      ██                      ]],
            [[      ███████████             █████                              ]],
            [[      █████████ ███████████████████ ███   ███████████    ]],
            [[     █████████  ███    █████████████ █████ ██████████████    ]],
            [[    █████████ ██████████ █████████ █████ █████ ████ █████    ]],
            [[  ███████████ ███    ███ █████████ █████ █████ ████ █████   ]],
            [[ ██████  █████████████████████ ████ █████ █████ ████ ██████  ]],
            [[                                                                        ]],
          },
          center = {
            { icon = "  ", desc = "New file",     key = "n", action = "enew | startinsert" },
            { icon = "  ", desc = "Recent files", key = "r", action = "browse oldfiles"    },
            { icon = "  ", desc = "Edit config",  key = "c", action = "edit ~/.config/nvim/init.lua" },
            { icon = "  ", desc = "Quit",         key = "q", action = "qa"                },
          },
          footer = { "Do one thing, and do it well!" },
          vertical_center = true,  -- optional; remove if your version errors on this
        },
      })
    end,
  },

  -------------------------------------------------------------------------------
  -- SEARCH (Plenary first declared or as dependency; lazy resolves either way)
  -------------------------------------------------------------------------------
  { "nvim-lua/plenary.nvim" },   -- ➐ Telescope dependency

  {
    "nvim-telescope/telescope.nvim",

    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          -- keep defaults minimal; we’ll tune later
        },
      })
      --  Test now via commands: :Telescope find_files / buffers / live_grep
    end,
  },

  -- (optional) Speed booster for sorting; add later if you want
   {
     "nvim-telescope/telescope-fzf-native.nvim",
     build = "make",  -- or cmake cmd per README
     cond = function() return vim.fn.executable("make") == 1 end,
   },

}, {
  -- ➑ lazy options (leave checker off for a quieter start, or enable)
  -- checker = { enabled = true },
})

-- ➒ Transparency: place AFTER lazy.setup and spell highlight groups exactly ----
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Force transparent backgrounds for common + dashboard groups",
  callback = function()
    local set = vim.api.nvim_set_hl
    set(0, "Normal",            { bg = "none" })
    set(0, "NormalFloat",       { bg = "none" })
    set(0, "SignColumn",        { bg = "none" })
    set(0, "DashboardHeader",   { bg = "none" })
    set(0, "DashboardCenter",   { bg = "none" })
    set(0, "DashboardFooter",   { bg = "none" })
    set(0, "DashboardShortCut", { bg = "none" }) 
  end,
})

