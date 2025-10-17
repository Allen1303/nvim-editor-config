return {
	-- ╭──────────────────────────────────────────────────────────╮
	-- │ Mini.Icons — adds UI icons for plugins and files         │
	-- ╰──────────────────────────────────────────────────────────╯

	-- Real devicons (ensure it’s available early)
	{ "nvim-tree/nvim-web-devicons", lazy = false, opts = { default = true } },
	{
		"nvim-mini/mini.nvim",
		main = "mini.icons",
		version = false,
		lazy = false,
		opts = {}, -- defaults
		-- config only to perform the extra side-effect (mock devicons)
		config = function(_, opts)
			require("mini.icons").setup(opts)
			-- icons.mock_nvim_web_devicons() -- side-effect beyond setup
		end,
	},
	-- ╭──────────────────────────────────────────────────────────╮
	-- │ Mini.Files — lightweight file explorer                   │
	-- ╰──────────────────────────────────────────────────────────╯
	{
		"nvim-mini/mini.nvim",
		main = "mini.files",
		version = false,
		keys = {
			{
				"<leader>e",
				function()
					local file = vim.api.nvim_buf_get_name(0)
					require("mini.files").open(file ~= "" and file or nil)
				end,
				desc = "MiniFiles: open or reveal current file",
			},
		},
		opts = {
			options = { use_as_default_explorer = true, permanent_delete = true },
			windows = { preview = true, width_focus = 50, width_nofocus = 35, width_preview = 75 },
		},
		config = function(_, opts)
			local mf = require("mini.files")
			mf.setup(opts)

			-- Get theme's Normal fg so icons/text remain visible on transparent bg
			local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
			local norm_fg = (ok and normal and normal.fg) or 0xffffff

			-- Transparent + visible foreground for Mini.Files windows
			vim.api.nvim_set_hl(0, "MiniFilesNormal", { bg = "NONE", fg = norm_fg })
			vim.api.nvim_set_hl(0, "MiniFilesBorder", { bg = "NONE", fg = norm_fg })

			local grp = vim.api.nvim_create_augroup("mini_files_transparent_min", { clear = true })

			local function apply_transparent_winhl(win)
				if not win or not vim.api.nvim_win_is_valid(win) then
					return
				end
				-- Keep it minimal: map only the core groups we need
				vim.api.nvim_set_option_value(
					"winhighlight",
					table.concat({
						"Normal:MiniFilesNormal",
						"FloatBorder:MiniFilesBorder",
					}, ","),
					{ win = win }
				)
				vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })
				vim.api.nvim_set_option_value("winblend", 0, { win = win }) -- true transparency (no fade)
			end

			vim.api.nvim_create_autocmd("User", {
				group = grp,
				pattern = { "MiniFilesWindowOpen", "MiniFilesWindowUpdate" },
				callback = function(ev)
					apply_transparent_winhl(ev.data.win_id)
				end,
				desc = "Keep Mini.Files windows transparent with visible foreground",
			})
		end,
	},
	-- ╭──────────────────────────────────────────────────────────╮
	-- │ Mini.Surround — edit brackets, quotes, tags              │
	-- ╰──────────────────────────────────────────────────────────╯
	{ "nvim-mini/mini.nvim", version = false, main = "mini.surround", event = "VeryLazy", opts = {} },

	-- ╭──────────────────────────────────────────────────────────╮
	-- │ Mini.AI — smarter text objects (functions, loops, etc.)  │
	-- ╰──────────────────────────────────────────────────────────╯
	{ "nvim-mini/mini.nvim", version = false, main = "mini.ai", event = "VeryLazy", opts = {} },

	-- ╭──────────────────────────────────────────────────────────╮
	-- │      Mini.operators — smarter text objects editign       │
	-- ╰──────────────────────────────────────────────────────────╯

	{ "nvim-mini/mini.nvim", version = false, main = "mini.operators", event = "VeryLazy", opts = {} },
} -- return config block closing curly braces----------------------------------
