return {
    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Mini.Icons — adds UI icons for plugins and files         │
    -- ╰──────────────────────────────────────────────────────────╯
{
  "nvim-mini/mini.nvim",
  main = "mini.icons",
  version = false,
  lazy = false,
  opts = {},  -- defaults
  -- config only to perform the extra side-effect (mock devicons)
  config = function(_, opts)
    local icons = require("mini.icons")
    icons.setup(opts)                 -- still honor opts
    icons.mock_nvim_web_devicons()    -- side-effect beyond setup
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
        local file_path = vim.api.nvim_buf_get_name(0)
        require("mini.files").open(file_path ~= "" and file_path or nil)
      end,
      desc = "MiniFiles: open or reveal current file",
    },
  },
  -- opts will be passed to require("mini.files").setup(opts) automatically
  opts = {
    options = { use_as_default_explorer = true, permanent_delete = true },
    windows = { preview = true, width_focus = 50, width_nofocus = 25, width_preview = 60 },
  },
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

{ "nvim-mini/mini.nvim", version = false, main = 'mini.operators', event = "VeryLazy", opts = {} },

} -- return config block closing curly braces----------------------------------

