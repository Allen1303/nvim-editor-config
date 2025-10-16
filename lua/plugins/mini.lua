return {
	-- ╭──────────────────────────────────────────────────────────╮
	-- │ Mini.Icons — adds UI icons for plugins and files         │
	-- ╰──────────────────────────────────────────────────────────╯
	{
		"nvim-mini/mini.nvim",
		main = "mini.icons",
		version = false,
		lazy = false,
		opts = {}, -- defaults
		-- config only to perform the extra side-effect (mock devicons)
		config = function(_, opts)
			local icons = require("mini.icons")
			icons.setup(opts) -- still honor opts
			icons.mock_nvim_web_devicons() -- side-effect beyond setup
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
			windows = { preview = true, width_focus = 50, width_nofocus = 25, width_preview = 60 },
		},
		config = function(_, opts)
			local mf = require("mini.files")
			mf.setup(opts)

			-- Transparent highlight groups (one-time)
			vim.api.nvim_set_hl(0, "MiniFilesNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "MiniFilesBorder", { bg = "none" })

			local grp = vim.api.nvim_create_augroup("mini_files_transparent_min", { clear = true })

			local function apply_transparent_winhl(win)
				if not win or not vim.api.nvim_win_is_valid(win) then
					return
				end

				-- Map BOTH Normal and NormalFloat, plus a few noisy groups, to a transparent bg
				vim.api.nvim_set_option_value(
					"winhighlight",
					table.concat({
						"Normal:MiniFilesNormal",
						"NormalNC:MiniFilesNormal",
						"NormalFloat:MiniFilesNormal",
						"FloatBorder:MiniFilesBorder",
						"SignColumn:MiniFilesNormal",
						"EndOfBuffer:MiniFilesNormal",
						"CursorLine:MiniFilesNormal",
						"CursorColumn:MiniFilesNormal",
					}, ","),
					{ win = win }
				)

				-- Kill EOB tildes; avoid blend “darkening”
				vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })
				vim.api.nvim_set_option_value("winblend", 0, { win = win })
			end

			-- Cover both initial open and later layout updates
			vim.api.nvim_create_autocmd("User", {
				group = grp,
				pattern = { "MiniFilesWindowOpen", "MiniFilesWindowUpdate" },
				callback = function(ev)
					apply_transparent_winhl(ev.data.win_id)
				end,
				desc = "Keep Mini.Files windows transparent",
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
