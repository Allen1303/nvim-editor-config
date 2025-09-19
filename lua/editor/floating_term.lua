-- ╭──────────────────────────────────────────────╮
-- │            Floating_Term.lua                 │
-- ╰──────────────────────────────────────────────╯
local toggleterm = require("toggleterm")

toggleterm.setup({
  direction = "float",
  float_opts = { border = "rounded", width = 0.8, height = 0.8 },
  shade_terminals = false,
  start_in_insert = true,
})

local M = {}
function M.toggle()
  if not package.loaded["toggleterm"] then pcall(require, "toggleterm") end
  vim.cmd("ToggleTerm direction=float")
end

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function(args)
    local buf = args.buf
    local tmap = function(lhs, rhs, desc)
      vim.keymap.set("t", lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end
    tmap("<Esc>", [[<C-\><C-n>]], "Terminal: normal mode")
    tmap("<C-h>", [[<C-\><C-n><C-w>h]], "Window left")
    tmap("<C-j>", [[<C-\><C-n><C-w>j]], "Window down")
    tmap("<C-k>", [[<C-\><C-n><C-w>k]], "Window up")
    tmap("<C-l>", [[<C-\><C-n><C-w>l]], "Window right")
  end,
  desc = "Terminal UX mappings",
})

return M

