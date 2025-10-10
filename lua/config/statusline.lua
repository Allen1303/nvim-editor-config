-- ╭───────────────────────-────────────────────────────╮
-- │  Statusline (native, powerline-style, themed)      │
-- ╰────────────────────────-───────────────────────────╯

-- ╭───────────────────────-────────────────────────────╮
-- │  Friendly mode label                               │
-- ╰────────────────────────-───────────────────────────╯
local function display_mode_name()
  local mode = vim.fn.mode(1)
  local map = {
    n   = "Normal", no   = "Normal", nov = "Normal", noV = "Normal", ["no\22"] = "Normal",
    niI = "Normal", niR  = "Normal", niV = "Normal",
    v   = "Visual", V    = "V-Line", ["\22"] = "V-Block",
    s   = "Select", S    = "S-Line", ["\19"] = "S-Block",
    i   = "Insert", ic   = "Insert", ix = "Insert",
    R   = "Replace", Rv  = "Replace",
    c   = "Command", cv  = "Ex",     ce = "Ex",
    r   = "Prompt",  rm  = "More",   ["r?"] = "Confirm",
    t   = "Terminal",
  }
  return map[mode] or "Normal"
end

-- ╭───────────────────────-────────────────────────────╮
-- │  Highlight helpers                                 │
-- ╰────────────────────────-───────────────────────────╯
local function set_hl(name, spec)
  vim.api.nvim_set_hl(0, name, spec or {})
end

local function get_hl(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end

local function to_hex(num)
  return num and string.format("#%06x", num) or nil
end

-- ╭───────────────────────-────────────────────────────╮
-- │  Mode → highlight updater (dynamic chip color)     │
-- ╰────────────────────────-───────────────────────────╯
local function update_mode_hl()
  local m = vim.fn.mode(1)
  local bg_map = {
    n  = "#89b4fa",  -- Normal
    i  = "#a6e3a1",  -- Insert
    v  = "#f9e2af", V = "#f9e2af", ["\22"] = "#f9e2af",
    s  = "#f9e2af", S = "#f9e2af", ["\19"] = "#f9e2af",
    c  = "#f5c2e7",  -- Command
    R  = "#f38ba8",  -- Replace
    t  = "#94e2d5",  -- Terminal
  }

  local bg = bg_map[m]
          or (m:match("^n") and bg_map.n)
          or (m:match("^i") and bg_map.i)
          or (m:match("^[vV\22]") and bg_map.v)
          or (m:match("^[sS\19]") and bg_map.s)
          or (m:match("^R") and bg_map.R)
          or (m:match("^c") and bg_map.c)
          or (m:match("^t") and bg_map.t)
          or "#89b4fa"

  -- Color the left "mode chip"
  set_hl("SLMode", { fg = "#11111b", bg = bg, bold = true })

  -- Also recolor the powerline divider to blend chip → bar
  local sl_bg = to_hex(get_hl("StatusLine").bg) or "#373d52"
  set_hl("SLModeSep", { fg = bg, bg = sl_bg })
end

-- ╭───────────────────────-────────────────────────────╮
-- │  Opaque statusline bar (readable with transparency)│
-- ╰────────────────────────-───────────────────────────╯
local function apply_statusline_opacity()
  local fg    = "#cdd6f4"
  local bg    = "#373d52"
  local bg_nc = "#181825"
  set_hl("StatusLine",   { fg = fg, bg = bg })
  set_hl("StatusLineNC", { fg = fg, bg = bg_nc })
  set_hl("WinSeparator", { fg = "#313244", bg = "NONE" })
end

-- ╭───────────────────────-────────────────────────────╮
-- │  Themed segment colors (file/git/diag/cursor)      │
-- ╰────────────────────────-───────────────────────────╯
local function apply_statusline_theme()
  local normal    = get_hl("Normal")
  local comment   = get_hl("Comment")
  local pmenu_sel = get_hl("PmenuSel")
  local ident     = get_hl("Identifier")

  local file_fg = to_hex(normal.fg)    or "#cdd6f4"
  local sep_fg  = to_hex(comment.fg)   or "#6c7086"
  local mode_bg = to_hex(pmenu_sel.bg) or to_hex(ident.fg) or "#89b4fa"
  local mode_fg = "#11111b"

  local err = to_hex(get_hl("DiagnosticError").fg) or "#f38ba8"
  local war = to_hex(get_hl("DiagnosticWarn").fg)  or "#f9e2af"
  local inf = to_hex(get_hl("DiagnosticInfo").fg)  or "#89b4fa"
  local hnt = to_hex(get_hl("DiagnosticHint").fg)  or "#94e2d5"
  local git = to_hex(get_hl("DiffAdd").fg)         or "#a6e3a1"

  -- base groups
  set_hl("SLMode",     { fg = mode_fg, bg = mode_bg, bold = true }) -- initial; update_mode_hl() will recolor
  set_hl("SLSep",      { fg = sep_fg })
  set_hl("SLFile",     { fg = file_fg })
  set_hl("SLReadOnly", { fg = err, bold = true })
  set_hl("SLModified", { fg = war, bold = true })
  set_hl("SLGit",      { fg = git })
  set_hl("SLError",    { fg = err })
  set_hl("SLWarn",     { fg = war })
  set_hl("SLInfo",     { fg = inf })
  set_hl("SLHint",     { fg = hnt })
  set_hl("SLCursor",   { fg = file_fg, bold = true })

-- bands (powerline backgrounds) – adjust to taste
-- set_hl("SLBandA", { bg = to_hex(get_hl("StatusLine").bg) or "#373d52" }) -- base
-- set_hl("SLBandB", { bg = to_hex(get_hl("Pmenu").bg) or "#2a2f3a" })
-- set_hl("SLBandC", { bg = to_hex(get_hl("CursorLine").bg) or "#232736" })

  -- make the powerline divider match chip→bar initially, then update_mode_hl() refines it
  local sl_bg = to_hex(get_hl("StatusLine").bg) or "#373d52"
  set_hl("SLModeSep", { fg = mode_bg, bg = sl_bg })
end

-- ╭───────────────────────-────────────────────────────╮
-- │                   Icons (Nerd Font)                │
-- ╰────────────────────────-───────────────────────────╯
local icons = {
  sep_l    = "",  -- powerline left (chip → bar)
  branch   = "",
  modified = "●",
  readonly = "",
  ellipsis = "…",
  diag = {
    error = "",
    warn  = "",
    info  = "",
    hint  = "",
  },
}

-- ╭───────────────────────-────────────────────────────╮
-- │          File icon (optional devicons)             │
-- ╰────────────────────────-───────────────────────────╯
local function file_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then return " " end
  local name = vim.fn.expand("%:t")
  local ext  = vim.fn.expand("%:e")
  local icon = devicons.get_icon(name, ext, { default = true })
  return icon and (" " .. icon .. " ") or " "
end

-- "parent/filename" or just "filename" if at project root
local function file_label()
  local name = vim.fn.expand("%:t")                    -- filename (tail)
  if name == "" then return "[No Name]" end
  local parent = vim.fn.fnamemodify(vim.fn.expand("%:h"), ":t") -- parent dir (tail)
  return (parent ~= "" and parent ~= ".") and (parent .. "/" .. name) or name
end
-- ╭───────────────────────-────────────────────────────╮
-- │       Git branch (plugin or native fallback)       │
-- ╰────────────────────────-───────────────────────────╯
local function git_branch_name()
  local head = vim.b.gitsigns_head
  if type(head) == "string" and head ~= "" then
    return " " .. icons.branch .. " " .. head .. " "
  end

  local out
  if vim.system then
    local ok, res = pcall(vim.system, { "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true })
    if ok and res.code == 0 then out = (res.stdout or ""):gsub("%s+", "") end
  else
    local lines = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "HEAD" })
    if vim.v.shell_error == 0 and lines and lines[1] then out = lines[1] end
  end

  if out and out ~= "" and out ~= "HEAD" then
    return " " .. icons.branch .. " " .. out .. " "
  end
  return ""
end
-- ╭───────────────────────-────────────────────────────╮
-- │         Diagnostics summary (current buffer)       │
-- ╰────────────────────────-───────────────────────────╯
local function diag_summary()
  local buf = 0
  local function count(sev) return #vim.diagnostic.get(buf, { severity = sev }) end
  local e = count(vim.diagnostic.severity.ERROR)
  local w = count(vim.diagnostic.severity.WARN)
  local i = count(vim.diagnostic.severity.INFO)
  local h = count(vim.diagnostic.severity.HINT)
  if (e + w + i + h) == 0 then return "" end

  local parts = {}
  if e > 0 then table.insert(parts, " " .. icons.diag.error .. e) end
  if w > 0 then table.insert(parts, " " .. icons.diag.warn  .. w) end
  if i > 0 then table.insert(parts, " " .. icons.diag.info  .. i) end
  if h > 0 then table.insert(parts, " " .. icons.diag.hint  .. h) end
  return table.concat(parts, "")
end

-- ╭───────────────────────-────────────────────────────╮
-- │            Module: renderer + controls             │
-- ╰────────────────────────-───────────────────────────╯

local M = {}

function M.statusline_ui()
  local seg = {}

  -- mode chip + powerline divider (chip→bar)
  table.insert(seg, "%#SLMode# " .. display_mode_name() .. " ")
  table.insert(seg, "%#SLModeSep#" .. icons.sep_l .. "%#StatusLine# ")

-- color icon like filename
table.insert(seg, "%#SLFile#" .. file_icon() .. " %#StatusLine#")
table.insert(seg, "%#SLFile#%<" .. file_label() .. "%#StatusLine#")
  table.insert(seg, "%{&modified?'%#SLModified# " .. icons.modified .. " %#StatusLine#':''}")
-- optional: consistent read-only lock (instead of %r)
table.insert(seg, "%{&readonly?'%#SLReadOnly# " .. icons.readonly .. " %#StatusLine#':''}")

  -- spacer → right
  table.insert(seg, "%=")
  -- diagnostics (colored as a block)
  table.insert(seg, " ")
  table.insert(seg, "%#SLError#" .. diag_summary() .. "%#StatusLine#")
  -- git (colored)
  table.insert(seg, " ")
  table.insert(seg, "%#SLGit#" .. git_branch_name() .. "%#StatusLine#")
  -- cursor / percent
  table.insert(seg, "%#SLCursor# %l:%c %#StatusLine# %p%% ")
  return table.concat(seg)
end

function M.enable()
  vim.opt.laststatus = 3
  vim.o.statusline = "%!v:lua.require'config.statusline'.statusline_ui()"
  apply_statusline_opacity()
  apply_statusline_theme()
  update_mode_hl() -- initial color for the chip & divider
end

function M.refresh()
  apply_statusline_opacity()
  apply_statusline_theme()
  update_mode_hl()
end

-- statusline-specific autocommands (self-contained)
local sl_grp = vim.api.nvim_create_augroup("user_statusline", { clear = true })
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter" }, {
  group = sl_grp,
  desc = "Recolor statusline mode chip on mode/window change",
  callback = function() pcall(update_mode_hl) end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "DirChanged", "VimResized" }, {
  group = sl_grp,
  desc = "Redraw statusline on file/context changes",
  callback = function() vim.cmd("redrawstatus") end,
})
return M

