-- lua/plugins/conform.lua
return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = function()
			local util = require("conform.util")

			-- Toggle (on by default): :FormatDisable / :FormatEnable
			vim.g.autoformat = true

			return {
				-- Choose formatter(s) per filetype (first available runs)
				formatters_by_ft = {
					lua = { "stylua" },
					sh = { "shfmt" },
					python = { "black" },
					json = { "biome", "prettier" },
					jsonc = { "biome", "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },

					-- JS/TS: prefer Biome, else Prettier; ESLint_d as a fallback formatter if present
					javascript = { "biome", "prettier", "eslint_d" },
					javascriptreact = { "biome", "prettier", "eslint_d" },
					typescript = { "biome", "prettier", "eslint_d" },
					typescriptreact = { "biome", "prettier", "eslint_d" },
					-- add others (vue, svelte) if you use them:
					-- vue = { "biome", "prettier" },
					-- svelte = { "biome", "prettier" },
				},

				-- Format on save (respects the toggle above)
				format_on_save = function(bufnr)
					if not vim.g.autoformat then
						return nil
					end
					return { timeout_ms = 1500, lsp_fallback = true }
				end,

				-- Small per-formatter tweaks + “use Biome only if a config exists”
				formatters = {
					biome = {
						condition = util.root_file({
							"biome.json",
							"biome.jsonc",
							"biome.toml",
						}),
					},
					eslint_d = {
						condition = util.root_file({
							".eslintrc",
							".eslintrc.js",
							".eslintrc.cjs",
							".eslintrc.json",
							"package.json",
						}),
					},
					shfmt = {
						prepend_args = { "-i", "2", "-ci" }, -- 2-space indents, indent switch cases
					},
				},
			}
		end,
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			-- :FormatDisable / :FormatEnable (per-session toggle)
			vim.api.nvim_create_user_command("FormatDisable", function()
				vim.g.autoformat = false
				vim.notify("Autoformat: disabled", vim.log.levels.INFO)
			end, {})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.g.autoformat = true
				vim.notify("Autoformat: enabled", vim.log.levels.INFO)
			end, {})

			-- <leader>cf → format now (async, with LSP fallback)
			vim.keymap.set("n", "<leader>cf", function()
				conform.format({ async = true, lsp_fallback = true })
			end, { desc = "Format buffer" })
		end,
	},
}
