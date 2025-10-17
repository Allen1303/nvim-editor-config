-- ╭───────────────────────-────────────────────────────╮
-- │                  Core bootstrap                    │
-- ╰────────────────────────-───────────────────────────╯

-- leaders first (plugins read these during init)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- faster module loader (nvim 0.9+)
pcall(function()
	vim.loader.enable()
end)

-- safe require helper
local function load_if_present(mod)
	local ok, m = pcall(require, mod)
	return ok and m or nil
end

-- core opts/UI before plugins (avoid flash)
load_if_present("config.options")
load_if_present("config.ui")

-- pcall(require, "config.dashboard") -- it self-registers on VimEnter
require("config.dashboard").setup()
-- ╭───────────────────────-────────────────────────────╮
-- │                   lazy.nvim setup                  │
-- ╰────────────────────────-───────────────────────────╯
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
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

require("lazy").setup({
	spec = { { import = "plugins" } },
	install = { colorscheme = { "onedark" } }, -- used on first install only
	checker = { enabled = true },
})
-- ╭───────────────────────-────────────────────────────╮
-- │                   Native modules                   │
-- ╰────────────────────────-───────────────────────────╯

-- keymaps & autocmds (lightweight, safe to load now)
load_if_present("config.keymaps")
load_if_present("config.autocmds")

-- statusline: enable after base UI so highlights exist
local statusline = load_if_present("config.statusline")
if statusline and statusline.enable then
	statusline.enable()
end

-- optional modules (safe if missing)
load_if_present("config.terminal")
-- LSP: loads its own autostart autocmds; safe last
load_if_present("config.lsp")

-- optional: defer anything heavy to VeryLazy
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "VeryLazy",
--   callback = function()
--     -- e.g. load_if_present("config.heavy_module")
--   end,
-- })
