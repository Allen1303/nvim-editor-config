-- ╭──────────────────────────────────────────────╮
-- │                 Mini.lua                     │
-- ╰──────────────────────────────────────────────╯
local M = {}

function M.setup_ai()
  local ai = require("mini.ai")
  ai.setup({
    n_lines = 500,
    custom_textobjects = {
      F = ai.gen_spec.treesitter({ a = { "@function.outer" }, i = { "@function.inner" } }),
      C = ai.gen_spec.treesitter({ a = { "@class.outer"    }, i = { "@class.inner"    } }),
      A = ai.gen_spec.treesitter({ a = { "@parameter.outer"}, i = { "@parameter.inner"} }),
      b = function()
        local last = vim.api.nvim_buf_line_count(0)
        return { from = { line = 1, col = 1 }, to = { line = last, col = math.max(vim.fn.getline(last):len(), 1) } }
      end,
    },
  })
end

function M.setup_surround()
  require("mini.surround").setup() -- sa/sd/sr
end

return M

