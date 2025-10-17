-- lua/config/dashboard.lua

local M = {}

-- Your provided ASCII art
local ascii_art = {
	[[          Neovim PDE                                                  ]],
	[[                                                                     ]],
	[[       ████ ██████           █████      ██                     ]],
	[[      ███████████             █████                             ]],
	[[      █████████ ███████████████████ ███   ███████████   ]],
	[[     █████████  ███    █████████████ █████ ██████████████   ]],
	[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
	[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
	[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
	[[                                                                       ]],
}

-- Your footer text
local footer_text = "Do one thing, and do it well!"

-- Dashboard menu items configuration
-- Each entry is { icon, display_text, key_binding, command_to_execute }
local dashboard_menu_items = {
	{ "", "Find file", "f", ":Telescope find_files<CR>" },
	{ "", "New file", "n", ":enew<CR>" }, -- Or your preferred new file command
	{ "", "Recent files", "r", ":Telescope oldfiles<CR>" },
	{ "󰭃", "Find text", "g", ":Telescope live_grep<CR>" },
	{
		"",
		"Config",
		"c",
		":Telescope find_files cwd=" .. vim.fn.expand("$HOME") .. "/.config/nvim/<CR>",
	},
	{ "", "Restore Session", "s", ":lua require('session_manager').load_current_dir_session()<CR>" }, -- Requires a session manager plugin
	{ "󰒓", "Lazy Extras", "x", ":LazyExtras<CR>" }, -- Requires lazy.nvim extras
	{ "󰒓", "Lazy", "l", ":Lazy<CR>" }, -- Opens lazy.nvim UI
	{ "", "Quit", "q", ":qa<CR>" },
}

-- Function to get the display width of a string, accounting for Neovim's rendering
local function get_display_width(str)
	return vim.fn.strdisplaywidth(str)
end

function M.setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("MyDashboard", { clear = true }),
		callback = function()
			if vim.fn.argc() == 0 then
				vim.cmd("enew")
				vim.cmd("setlocal buftype=nofile nofoldenable nospell nonu norelativenumber")
				vim.cmd("setlocal bufhidden=wipe")
				vim.cmd("file Dashboard")

				local screen_width = vim.fn.winwidth(0)

				-- --- Render ASCII Art ---
				local max_art_line_len = 0
				for _, line in ipairs(ascii_art) do
					max_art_line_len = math.max(max_art_line_len, get_display_width(line))
				end

				local art_pad_left = math.floor((screen_width - max_art_line_len) / 2)
				if art_pad_left < 0 then
					art_pad_left = 0
				end

				local centered_art = {}
				for _, line in ipairs(ascii_art) do
					table.insert(centered_art, string.rep(" ", art_pad_left) .. line)
				end
				vim.api.nvim_buf_set_lines(0, 0, -1, false, centered_art)

				-- Add some vertical spacing after ASCII art
				vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "" })

				-- --- Render Menu Items in Two Columns ---
				local menu_lines = {}
				local total_items = #dashboard_menu_items
				local max_item_text_width = 0

				-- First, determine the maximum width of the text part (Icon + Display Text)
				for _, item in ipairs(dashboard_menu_items) do
					local item_text = string.format("%s  %s", item[1], item[2]) -- Icon + 2 spaces + Text
					max_item_text_width = math.max(max_item_text_width, get_display_width(item_text))
				end

				-- Determine ideal padding for the entire block
				local block_width = max_item_text_width + 4 -- For ' [key]' on the right
				local block_pad_left = math.floor((screen_width - block_width) / 2)
				if block_pad_left < 0 then
					block_pad_left = 0
				end

				for _, item in ipairs(dashboard_menu_items) do
					local icon = item[1]
					local text = item[2]
					local key = item[3]

					local formatted_text = string.format("%s  %s", icon, text)
					local text_pad = string.rep(" ", max_item_text_width - get_display_width(formatted_text))

					local line = string.rep(" ", block_pad_left) .. formatted_text .. text_pad .. "  " .. key
					table.insert(menu_lines, line)
				end

				vim.api.nvim_buf_set_lines(0, -1, -1, false, menu_lines)

				-- Add spacing between menu and footer
				vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "" })

				-- --- Render Footer ---
				local footer_pad_left = math.floor((screen_width - get_display_width(footer_text)) / 2)
				if footer_pad_left < 0 then
					footer_pad_left = 0
				end
				vim.api.nvim_buf_set_lines(0, -1, -1, false, { string.rep(" ", footer_pad_left) .. footer_text })

				-- --- Set Keymaps for Menu Items ---
				for _, item in ipairs(dashboard_menu_items) do
					local key = item[3]
					local command = item[4]
					vim.api.nvim_buf_set_keymap(0, "n", key, command, { noremap = true, silent = true })
				end

				-- Add the "plugins loaded" message if you want it
				local plugins_msg = string.format(
					"⚡ Neovim loaded %d/%d plugins in %s",
					#require("lazy").plugins(),
					#require("lazy").plugins(),
					vim.fn.split(vim.fn.stdpath("data") .. "/lazy/log.txt", "\n")[1] or "..."
				) -- Crude timing
				-- A better way to get timing might be through lazy.nvim's internal API if exposed,
				-- or just hardcode a placeholder like "Xms" if precise timing isn't crucial.
				-- For a simple timing, we can grab the first line of the lazy log.

				-- Ensure plugins_msg is properly padded and centered at the bottom
				local plugins_msg_pad_left = math.floor((screen_width - get_display_width(plugins_msg)) / 2)
				if plugins_msg_pad_left < 0 then
					plugins_msg_pad_left = 0
				end
				vim.api.nvim_buf_set_lines(
					0,
					-1,
					-1,
					false,
					{ "", string.rep(" ", plugins_msg_pad_left) .. plugins_msg }
				)

				-- Go to the top of the buffer
				vim.cmd("normal! gg")
			end
		end,
	})
end

return M
