-- ╭──────────────────────────────────────────────╮
-- │                 Noice.lua                    │
-- ╰──────────────────────────────────────────────╯
local M = {}

function M.setup()
  local ok_notify, notify = pcall(require, "notify")
  if ok_notify then
    notify.setup({ stages = "fade", timeout = 2000, background_colour = "#000000", render = "compact" })
    vim.notify = notify
  end

  local ok, noice = pcall(require, "noice")
  if not ok then return end

  noice.setup({
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      progress = { enabled = true },
      signature = { enabled = true },
      hover = { enabled = true },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    routes = {
      { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "", find = "fewer lines" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "", find = "more lines"  }, opts = { skip = true } },
    },
    views = {
      cmdline_popup = { border = { style = "rounded" }, win_options = { winblend = 0 } },
      popupmenu     = { border = { style = "rounded" }, win_options = { winblend = 0 } },
    },
  })

  for _, g in ipairs({
    "NoiceCmdlinePopup","NoiceCmdlinePopupBorder",
    "NoicePopupmenu","NoicePopupmenuBorder",
    "NoiceConfirm","NoiceConfirmBorder",
    "NoiceMini",
  }) do pcall(vim.api.nvim_set_hl, 0, g, { bg = "none" }) end
end

return M

