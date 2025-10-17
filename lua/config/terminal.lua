-- ╭───────────────────────-─────────────────────────────╮
-- │ Floating Terminal (truly transparent, centered)     │
-- ╰───────────────────────-─────────────────────────────╯

local M = {}

-- state
local term_buf   ---@type integer|nil
local float_win  ---@type integer|nil
local last_win   ---@type integer|nil

-- per-filetype runners
local runners = {
  python = "python3",
  lua = "lua",
  javascript = "node",
  typescript = "ts-node",
  go = "go run",
  ruby = "ruby",
  sh = "bash",
}

-- 80% centered float
local function float_cfg()
  local w = math.floor(vim.o.columns * 0.8)
  local h = math.floor(vim.o.lines   * 0.8)
  return {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " Terminal ",
    title_pos = "center",
  }
end

-- per-window transparent highlights (bulletproof)
local function apply_transparent_hl(win)
  -- make a local highlight namespace for this window
  local ns = vim.api.nvim_create_namespace("float_term_ns")
  -- force bg = NONE for the groups a terminal float actually uses
  local clear_bg = { bg = "NONE" }
  vim.api.nvim_set_hl(ns, "Normal",       clear_bg)
  vim.api.nvim_set_hl(ns, "NormalFloat",  clear_bg)
  vim.api.nvim_set_hl(ns, "TermNormal",   clear_bg)
  vim.api.nvim_set_hl(ns, "TermFloat",    clear_bg)
  vim.api.nvim_set_hl(ns, "FloatBorder",  clear_bg)
  vim.api.nvim_set_hl(ns, "EndOfBuffer",  clear_bg)
  -- have this window render using our local (transparent) namespace
  vim.api.nvim_win_set_hl_ns(win, ns)
  -- no extra dimming — make it crisp like Telescope
  vim.wo[win].winblend = 0
end

-- send text to terminal
local function send(cmd)
  if not term_buf then return end
  local job = vim.b[term_buf] and vim.b[term_buf].terminal_job_id
  if job then vim.fn.chansend(job, cmd .. "\n") end
end

-- open float with transparent styling
local function open_float()
  float_win = vim.api.nvim_open_win(term_buf, true, float_cfg())

  -- apply real transparency inside this window only
  apply_transparent_hl(float_win)

  -- keep the terminal buffer tidy
  vim.bo[term_buf].bufhidden = "hide"
  vim.bo[term_buf].swapfile = false
  vim.bo[term_buf].filetype = "terminal"
  vim.bo[term_buf].scrollback = 10000

  -- minimal chrome
  vim.wo[float_win].number = false
  vim.wo[float_win].relativenumber = false
  vim.wo[float_win].signcolumn = "no"
  vim.wo[float_win].cursorline = false
  vim.wo[float_win].wrap = false

  -- terminal-mode convenience maps (buffer-local)
  vim.keymap.set("t", "<Esc>",  "<C-\\><C-n>", { buffer = term_buf, desc = "Terminal: normal mode" })
  vim.keymap.set("t", "<C-c>",  function() M.toggle() end, { buffer = term_buf, desc = "Terminal: close" })
  vim.keymap.set("n", "i", "i", { buffer = term_buf, desc = "Terminal: insert" })
  vim.keymap.set("n", "a", "a", { buffer = term_buf, desc = "Terminal: insert" })
end

-- toggle float on/off
function M.toggle()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    if last_win and vim.api.nvim_win_is_valid(last_win) then
      vim.api.nvim_set_current_win(last_win)
    end
    return
  end

  last_win = vim.api.nvim_get_current_win()

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true) -- scratch
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.termopen(vim.o.shell)
    end)
  end

  open_float()
  vim.cmd("startinsert")
end

-- run current file
function M.run_file()
  vim.cmd("write")
  local ft   = vim.bo.filetype
  local file = vim.fn.expand("%")
  local runner = runners[ft]
  if not runner then
    vim.notify("No runner for filetype: " .. (ft or "unknown"), vim.log.levels.WARN)
    return
  end
  if not (float_win and vim.api.nvim_win_is_valid(float_win)) then
    M.toggle()
  end
  send(runner .. " " .. file)
end

-- send current line or visual selection
function M.send_code()
  local mode = vim.fn.mode()
  local text
  if mode:match("[vV]") then
    local s = vim.fn.line("'<")
    local e = vim.fn.line("'>")
    text = table.concat(vim.fn.getline(s, e), "\n")
  else
    text = vim.api.nvim_get_current_line()
  end
  if not (float_win and vim.api.nvim_win_is_valid(float_win)) then
    M.toggle()
  end
  send(text)
end

-- keymaps
vim.keymap.set("n", "<leader>t", M.toggle,    { desc = "Terminal: toggle float" })
vim.keymap.set("n", "<leader>r", M.send_code, { desc = "Terminal: send line" })
vim.keymap.set("v", "<leader>r", M.send_code, { desc = "Terminal: send selection" })
vim.keymap.set("n", "<leader>R", M.run_file,  { desc = "Terminal: run current file" })

-- keep float centered and keep transparency on resize/colorscheme
local grp = vim.api.nvim_create_augroup("user_float_term", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
  group = grp,
  callback = function()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_set_config(float_win, float_cfg())
      apply_transparent_hl(float_win)
    end
  end,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  group = grp,
  callback = function()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      apply_transparent_hl(float_win)
    end
  end,
})

return M
