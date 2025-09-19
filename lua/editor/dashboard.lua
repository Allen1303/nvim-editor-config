-- ╭──────────────────────────────────────────────╮
-- │              Dashboard.lua                   │
-- ╰──────────────────────────────────────────────╯
local M = {}

function M.setup()
	local alpha = require("alpha")
	local dashboard = require("alpha.themes.dashboard")

	-- Larger Apple-style ASCII + Neovim line
	dashboard.section.header.val = {
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
		[[                   Do one thing, and do it well!                       ]],
	}

	dashboard.section.buttons.val = {
		dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
		dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
		dashboard.button("g", "  Live grep", ":Telescope live_grep<CR>"),
		dashboard.button("n", "  New file", ":ene | startinsert<CR>"),
		dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
		dashboard.button("q", "  Quit", ":qa<CR>"),
	}

	local function footer()
		local ok, lazy = pcall(require, "lazy")
		if ok then
			local stats = lazy.stats()
			return ("⚡ %d plugins loaded in %.2fms"):format(stats.loaded, stats.startuptime)
		end
		return "happy hacking"
	end
	dashboard.section.footer.val = footer()

	alpha.setup(dashboard.opts)

	for _, g in ipairs({ "AlphaHeader", "AlphaButtons", "AlphaShortcut", "AlphaFooter" }) do
		pcall(vim.api.nvim_set_hl, 0, g, { bg = "none" })
	end
end

return M
