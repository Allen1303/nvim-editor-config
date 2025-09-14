-- Simple floating terminal with code runner
local M = {}

-- State variables
local term_buf = nil      -- terminal buffer
local float_win = nil     -- floating window
local last_win = nil      -- window we came from

-- File runners for different languages
local runners = {
  python = "python3",
  lua = "lua",
  javascript = "node",
  go = "go run",
  ruby = "ruby",
  sh = "bash",
}

-- Create centered floating window (80% of screen)
local function make_float_config()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Terminal ",
    title_pos = "center",
  }
end

-- Send command to terminal
local function send_command(cmd)
  if not term_buf then return end
  local job_id = vim.b[term_buf].terminal_job_id
  if job_id then vim.fn.chansend(job_id, cmd .. "\n") end
end

-- Toggle terminal on/off
function M.toggle()
  -- Close if open
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    if last_win then vim.api.nvim_set_current_win(last_win) end
    return
  end

  -- Remember current window
  last_win = vim.api.nvim_get_current_win()

  -- Create terminal buffer if needed
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(term_buf, function()
      vim.fn.termopen(vim.o.shell)
    end)
  end

  -- Open floating window
  float_win = vim.api.nvim_open_win(term_buf, true, make_float_config())
  
  -- Set up terminal navigation keys
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = term_buf, desc = "Exit to normal mode" })
  vim.keymap.set("t", "<C-c>", function() M.toggle() end, { buffer = term_buf, desc = "Close terminal" })
  vim.keymap.set("n", "i", "i", { buffer = term_buf, desc = "Enter terminal mode" })
  vim.keymap.set("n", "a", "a", { buffer = term_buf, desc = "Enter terminal mode" })

  vim.cmd("startinsert")
end

-- Run current file
function M.run_file()
  vim.cmd("write")  -- save file first
  local file = vim.fn.expand("%")
  local filetype = vim.bo.filetype
  local runner = runners[filetype]
  
  if not runner then
    vim.notify("No runner for " .. filetype)
    return
  end
  
  M.toggle()  -- show terminal
  send_command(runner .. " " .. file)
end

-- Send current line or selection to terminal
function M.send_code()
  local mode = vim.fn.mode()
  local text
  
  if mode:match("[vV]") then
    -- Get visual selection
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    text = table.concat(vim.fn.getline(start_line, end_line), "\n")
  else
    -- Get current line
    text = vim.api.nvim_get_current_line()
  end
  
  M.toggle()  -- show terminal
  send_command(text)
end

-- Key mappings
vim.keymap.set("n", "<leader>t", M.toggle, { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>r", M.send_code, { desc = "Send line to terminal" })
vim.keymap.set("v", "<leader>r", M.send_code, { desc = "Send selection to terminal" })
vim.keymap.set("n", "<leader>R", M.run_file, { desc = "Run current file" })

-- Keep terminal centered when window resizes
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    if float_win and vim.api.nvim_win_is_valid(float_win) then
      vim.api.nvim_win_set_config(float_win, make_float_config())
    end
  end,
})

return M
