-- ╭──────────────────────────────────────────────╮
-- │               Plugins.lua (safe)             │
-- ╰──────────────────────────────────────────────╯
local ok, lazy = pcall(require, "lazy")
if not ok then
	return
end

lazy.setup({
	-- Core utility
	{ "nvim-lua/plenary.nvim" },

	-- THEMES
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			local okm, ui = pcall(require, "editor.ui")
			if okm and type(ui) == "table" and ui.apply_theme then
				ui.apply_theme("onedark")
			else
				-- fallback: at least load the scheme
				pcall(function()
					require("onedark").setup({ style = "dark", transparent = true })
					require("onedark").load()
				end)
			end
		end,
	},
	{ "folke/tokyonight.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },

	-- Icons
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local okm, ui = pcall(require, "editor.ui")
			if okm and type(ui) == "table" and ui.setup_lualine then
				ui.setup_lualine()
			else
				-- minimal fallback so startup never crashes
				require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
			end
		end,
	},

	-- File explorer (right)
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			pcall(require, "editor.nvim-tree")
		end,
	},

	-- Telescope
	{ -- Fuzzy Finder (files, LSP, etc.) — Kickstart style
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- Optional native sorter (fast). Requires `make`.
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			-- We already load devicons elsewhere in your config, so no need to add it here.
		},
		config = function()
			require("editor.telescope").setup_kickstart()
		end,
	},

	-- Treesitter + autotag
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			pcall(require, "editor.treesitter")
		end,
	},
	{ "windwp/nvim-ts-autotag", event = "InsertEnter" },

	-- LSP (native API lives in editor/lsp.lua)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			pcall(require, "editor.lsp")
		end,
	},

	-- Completion + snippets
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			pcall(require, "editor.cmp")
		end,
	},

	-- Formatting (Conform)
	{
		"stevearc/conform.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			pcall(require, "editor.formatter")
		end,
	},

	-- Floating terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			pcall(require, "editor.floating_term")
		end,
	},

	-- UX: Mini
	{
		"echasnovski/mini.ai",
		version = "*",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local okm, mini = pcall(require, "editor.mini")
			if okm and type(mini) == "table" and mini.setup_ai then
				mini.setup_ai()
			end
		end,
	},
	{
		"echasnovski/mini.surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			local okm, mini = pcall(require, "editor.mini")
			if okm and type(mini) == "table" and mini.setup_surround then
				mini.setup_surround()
			else
				pcall(function()
					require("mini.surround").setup()
				end)
			end
		end,
	},

	-- Dashboard
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local okm, dash = pcall(require, "editor.dashboard")
			if okm and type(dash) == "table" and dash.setup then
				dash.setup()
			else
				-- fallback to default layout
				local alpha = require("alpha")
				local theme = require("alpha.themes.dashboard")
				alpha.setup(theme.opts)
			end
		end,
	},

	-- Noice + notify
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		config = function()
			pcall(function()
				require("editor.noice").setup()
			end)
		end,
	},

	-- OPTIONAL: OSC52 clipboard for tmux/SSH
	{
		"ojroques/nvim-osc52",
		event = "VeryLazy",
		config = function()
			local okm, osc52 = pcall(require, "osc52")
			if not okm then
				return
			end
			osc52.setup({})
			vim.api.nvim_create_autocmd("TextYankPost", {
				callback = function()
					if vim.v.event.regname == "+" or vim.v.event.regname == "" then
						pcall(osc52.copy_register, "+")
					end
				end,
				desc = "OSC52: copy yanks to system clipboard",
			})
		end,
	},
}, {
	ui = { border = "rounded" },
	checker = { enabled = false },
})
