-- ╭───────────────────────-───────────────────╮
-- │      Color Scheme Config File             │
-- ╰────────────────────────-──────────────────╯
return {
	{
		-- [ Spec 1 ] Catppuccin (your existing theme spec)
		"catppuccin/nvim",
		name = "catppuccin", -- this variable is used to refer to the plugin by a stable name
		lazy = false, -- this variable makes the plugin load at startup
		priority = 1000, -- this variable helps us load the theme very early
		main = "catppuccin", -- optional; tells lazy the main module
		opts = {
			flavour = "macchiato", -- this variable selects the Catppuccin flavour
			transparent_background = true, -- this variable enables theme-level transparency
		},
		config = function(_, opts)
			require("catppuccin").setup(opts) -- this function applies flavour/options + access the theme module
			vim.cmd.colorscheme("catppuccin-macchiato") -- this function is used to switch the colorscheme
		end,
	},
	{
		-- [ Spec 2 ] OneDark (your existing theme spec)
		"navarasu/onedark.nvim",
		main = "onedark", -- this variable tells lazy which module to setup
		priority = 900, -- this variable helps us load the theme very early
		opts = { style = "dark", transparent = true },
	},
	-- [ Spec 3 ]  ⟵ start the “local plugin” spec for commands here
	{
		{
			dir = vim.fn.stdpath("config"),
			init = function()
				-- 1) helper goes here
				local function apply_colorscheme_safe(name)
					if not pcall(vim.cmd.colorscheme, name) then
						pcall(vim.cmd.colorscheme, "habamax") -- fallback built-in
					end
				end

				-- 2) commands use the helper function to switch themes
				vim.api.nvim_create_user_command("Onedark", function()
					apply_colorscheme_safe("onedark")
				end, { desc = "Switch to OneDark" })

				vim.api.nvim_create_user_command("Catp", function()
					apply_colorscheme_safe("catppuccin-macchiato")
				end, { desc = "Switch to Catppuccin Macchiato" })

				vim.api.nvim_create_user_command("ThemeReset", function()
					apply_colorscheme_safe("habamax")
				end, { desc = "Switch to fallback (habamax)" })

				-- 3) pick a startup theme safely (optional)
				apply_colorscheme_safe("onedark")
			end,
		},
	},
} -- Return config code block ends here----------------------------------------
