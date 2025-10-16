-- ╭───────────────────────-────────────────────────────╮
-- │  Statusline (native, powerline-style, themed)      │
-- ╰────────────────────────-───────────────────────────╯

-- Friendly mode label (maps raw mode → word)
local function display_mode_name()
  local mode = vim.fn.mode(1)
  local map = {
    n="Normal",no="Normal",nov="Normal",noV="Normal",["no\22"]="Normal",
    niI="Normal",niR="Normal",niV="Normal",
    v="Visual",V="V-Line",["\22"]="V-Block",
    s="Select",S="S-Line",["\19"]="S-Block",
    i="Insert",ic="Insert",ix="Insert",
    R="Replace",Rv="Replace",
    c="Command",cv="Ex",ce="Ex",
    r="Prompt",rm="More",["r?"]="Confirm",
    t="Terminal",
  }
  return map[mode] or "Normal"
end

-- Highlight helpers
local function set_hl(name, spec) vim.api.nvim_set_hl(0, name, spec or {}) end
local function get_hl(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end
local function to_hex(num) return num and string.format("#%06x", num) or nil end

-- Dynamic mode chip (changes color per mode)
local function update_mode_hl()
  local m = vim.fn.mode(1)
  local bg_map = {
    n="#89b4fa", i="#a6e3a1",
    v="#f9e2af", V="#f9e2af", ["\22"]="#f9e2af",
    s="#f9e2af", S="#f9e2af", ["\19"]="#f9e2af",
    c="#f5c2e7", R="#f38ba8", t="#94e2d5",
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

  set_hl("SLMode", { fg = "#11111b", bg = bg, bold = true })

  local bar_bg = to_hex(get_hl("StatusLine").bg) or "#373d52"
  set_hl("SLModeSep",  { fg = bg, bg = bar_bg })              -- chip → bar
  set_hl("SLRight",    { fg = "#11111b", bg = bg, bold = true }) -- RIGHT: now bold
  set_hl("SLRightSep", { fg = bg, bg = bar_bg })              -- bar → right block
end

-- Opaque bar (readable even with transparent themes)
local function apply_statusline_opacity()
  local fg, bg, bg_nc = "#cdd6f4", "#373d52", "#181825"
  set_hl("StatusLine",   { fg = fg, bg = bg })
  set_hl("StatusLineNC", { fg = fg, bg = bg_nc })
  set_hl("WinSeparator", { fg = "#313244", bg = "NONE" })
end

-- Theme-aware segment colors
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

  set_hl("SLMode",     { fg = mode_fg, bg = mode_bg, bold = true })
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

  -- RIGHT block seeded; mode recolors it later. Keep bold to match left.
  local bar_bg = to_hex(get_hl("StatusLine").bg) or "#373d52"
  set_hl("SLRight",    { fg = mode_fg, bg = mode_bg, bold = true })
  set_hl("SLRightSep", { fg = mode_bg, bg = bar_bg })
  set_hl("SLModeSep",  { fg = mode_bg, bg = bar_bg })
end

-- Icons (Nerd Font)
local icons = {
  sep_left   = "",  -- powerline triangle (left)
  sep_right   = "",  -- powerline triangle (right)
  thin_left  = "",  -- thin divider (left-facing)
  thin_right  = "",  -- thin divider (right-facing)
  branch  = "",
  modified= "●",
  readonly= "",
  ellipsis= "…",
  diag    = { error="", warn="", info="", hint="" },
}

-- Active/width helpers
local function win_is_active()
  local owner = vim.g.statusline_winid or 0
  return owner ~= 0 and owner == vim.api.nvim_get_current_win()
end
local function fits(min_cols) return vim.api.nvim_win_get_width(0) >= (min_cols or 0) end


-- Diff summary (gitsigns)
local function diff_summary()
  local gs = vim.b.gitsigns_status_dict
  if not gs then return "" end
  local parts = {}
  if (gs.added   or 0) > 0 then table.insert(parts, "+" .. gs.added) end
  if (gs.changed or 0) > 0 then table.insert(parts, "~" .. gs.changed) end
  if (gs.removed or 0) > 0 then table.insert(parts, "-" .. gs.removed) end
  return #parts > 0 and (" " .. table.concat(parts, " ")) or ""
end

-- OS icon (simple)
local function os_icon()
    local os_name = (vim.loop and vim.loop.os_uname and vim.loop.os_uname().sysname) or ""
    os_name = os_name:lower()
    if os_name:find("darwin") then return "  "
    elseif os_name:find("windows") or os_name:find("mingw") then return "  "
    elseif os_name:find("linux") then return "  "
    else return "  " end
end

-- Encoding / filetype / fileformat
local function enc_ft_ff()
  local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
  local ft  = (vim.bo.ft  ~= "" and vim.bo.ft)  or "text"
  local ff  = vim.bo.ff
  return string.format("%s %s %s", enc, ft, ff)
end

-- Search count (like lualine)
local function search_count()
  if vim.v.hlsearch == 0 then return "" end
  local ok, sc = pcall(vim.fn.searchcount, { recompute = 1, maxcount = 9999 })
  if not ok or not sc or sc.total == 0 then return "" end
  return string.format(" /%s [%d/%d] ", vim.fn.getreg("/"), sc.current or 0, sc.total or 0)
end

-- Git branch (gitsigns fast-path, shell fallback)
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

-- Clickable git segment
_G.SL_on_git_click = function(minwid, clicks, button, mods)
  local ok, tb = pcall(require, "telescope.builtin")
  if ok and tb.git_branches then tb.git_branches(); return end
  if vim.fn.exists(":Git") == 2 then vim.cmd("Git"); return end
  vim.notify("No git UI found (install telescope or fugitive).", vim.log.levels.INFO)
end
local function git_branch_clickable()
  local s = git_branch_name()
  if s == "" then return "" end
  return "%@v:lua.SL_on_git_click@" .. s .. "%T"
end

-- File icon / label
local function file_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then return " " end
  local name = vim.fn.expand("%:t")
  local ext  = vim.fn.expand("%:e")
  local icon = devicons.get_icon(name, ext, { default = true })
  return icon and (" " .. icon .. " ") or " "
end
local function file_label()
  local name = vim.fn.expand("%:t")
  if name == "" then return "[No Name]" end
  local parent = vim.fn.fnamemodify(vim.fn.expand("%:h"), ":t")
  return (parent ~= "" and parent ~= ".") and (parent .. "/" .. name) or name
end

-- Diagnostics summary
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

-- Tiny helper: thin separator inside the RIGHT block
local function rsep() return " " .. (icons.thin_right or "") .. " " end

-- Renderer
local M = {}

function M.statusline_ui()
  local seg = {}

  -- Inactive: minimal
  if not win_is_active() then
    table.insert(seg, "%#StatusLineNC#  ")
    table.insert(seg, "%#SLFile#" .. (file_icon() or " ") .. "%#StatusLineNC#")
    table.insert(seg, "%#SLFile#%<" .. file_label() .. "%#StatusLineNC#")
    table.insert(seg, "%=")
    table.insert(seg, "%#StatusLineNC# %l:%c %p%% ")
    return table.concat(seg)
  end

  -- Active left chip + divider
  table.insert(seg, "%#SLMode# " .. display_mode_name() .. " ")
  table.insert(seg, "%#SLModeSep#" .. (icons.sep_left or "") .. "%#StatusLine# ")

  -- File info
  table.insert(seg, "%#SLFile#" .. file_icon() .. "%#StatusLine#")
  table.insert(seg, "%#SLFile#%<" .. file_label() .. "%#StatusLine#")
  table.insert(seg, "%{&modified?'%#SLModified# " .. icons.modified .. " %#StatusLine#':''}")
  table.insert(seg, "%{&readonly?'%#SLReadOnly# " .. icons.readonly .. " %#StatusLine#':''}")

  table.insert(seg, " ")
  table.insert(seg, "%=")

  -- RIGHT: triangle + bold band, then thin sharp separators
  table.insert(seg, "%#SLRightSep#" .. (icons.sep_right or "") .. "%#SLRight# ")

  -- diff (if space)
  local diff = (fits(80) and diff_summary()) or ""
  if diff ~= "" then table.insert(seg, diff) end

  -- diags
  local diags = diag_summary()
  if diags ~= "" then
    if diff ~= "" then table.insert(seg, rsep()) end
    table.insert(seg, diags)
  end

  -- branch (clickable)
  local gb = git_branch_clickable()
  if gb ~= "" then
    if diff ~= "" or diags ~= "" then table.insert(seg, rsep()) end
    table.insert(seg, gb)
  end

  -- encoding/filetype/fileformat (if wide)
  if fits(100) then
    if (diff ~= "" or diags ~= "" or gb ~= "") then table.insert(seg, rsep()) end
    table.insert(seg, enc_ft_ff())
  end

  -- search count (if wide)
  local sc = (fits(110) and search_count()) or ""
  if sc ~= "" then
    table.insert(seg, rsep())
    table.insert(seg, sc)
  end

  -- OS glyph
  table.insert(seg, rsep())
  table.insert(seg, os_icon())

  -- cursor / percent
  table.insert(seg, rsep())
  table.insert(seg, "%l:%c")
  table.insert(seg, rsep())
  table.insert(seg, "%p%% ")

  -- back to base bar
  table.insert(seg, "%#StatusLine#")

  return table.concat(seg)
end

function M.enable()
  vim.opt.laststatus = 3
  vim.o.statusline = "%!v:lua.require'config.statusline'.statusline_ui()"
  apply_statusline_opacity()
  apply_statusline_theme()
  update_mode_hl()
end

function M.refresh()
  apply_statusline_opacity()
  apply_statusline_theme()
  update_mode_hl()
end

-- Autocmds
local sl_grp = vim.api.nvim_create_augroup("user_statusline", { clear = true })
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter", "WinEnter" }, {
  group = sl_grp,
  desc = "Recolor mode chip/bands on mode/window change",
  callback = function() pcall(update_mode_hl) end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "DirChanged", "VimResized" }, {
  group = sl_grp,
  desc = "Redraw statusline on file/context changes",
  callback = function() vim.cmd("redrawstatus") end,
})

return M

