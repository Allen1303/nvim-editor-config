-- ╭──────────────────────────────────────────────╮
-- │           editor/telescope.lua               │
-- │ WHAT: Kickstart’s exact Telescope setup      │
-- │ HOW : Called from plugins.lua config()       │
-- ╰──────────────────────────────────────────────╯
local M = {}

function M.setup_kickstart()
	-- [[ Configure Telescope ]]
	-- See :help telescope and :help telescope.setup()
	require("telescope").setup({
		-- pickers = {},
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		},
	})

	-- Enable Telescope extensions if installed
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	-- See :help telescope.builtin
	local builtin = require("telescope.builtin")

	-- Kickstart keymaps (use 's' prefix)
	vim.keymap.set("n", "sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
	vim.keymap.set("n", "sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })

	-- Slightly advanced example of overriding default behavior & theme
	vim.keymap.set("n", "/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- More example configs
	vim.keymap.set("n", "s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })

	-- Shortcut for searching your Neovim config files
	vim.keymap.set("n", "sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[S]earch [N]eovim files" })
end

return M
