-- leaders first (so mappings from any module bind correctly)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--faster lua requires for (Neovim versions-> 0.9+)
if vim.loader and vim.loader.enable then vim.loader.enable() end
-- Safe require helper
local function load_if_present(modname) 
    local ok, mod  = pcall(require, modname)
    if ok then return mod end
    return nil
end
-- Load core native Config before plugins (Avoid UI flash)
load_if_present("config.options")
load_if_present("config.ui")


-- Bootstrap lazy.nvim
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


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "onedark" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- native config modules 
 load_if_present("config.keymaps")
 load_if_present("config.autocmds")
 -- activate the native statusline safely
 local statusline = load_if_present("config.statusline")
 if statusline then statusline.enable() end
-- load_if_present("config.terminal")

