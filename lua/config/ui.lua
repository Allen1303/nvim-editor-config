-- ui: themec tweaks (transparency)
local transparent_groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "LineNr",
    "FoldColumn",
    "EndOfBuffer",
    "NormalFloat",
    "FloatBorder",
    "Pmenu",
    "PmenuSel",
    "StatusLine",
    "StatusLineNC",
    "WinSeparator",
    "VertSplit",
    "TabLine",
    "TabLineFill",
    "TabLineSel",

}
-- WHY: force BG to be transparent regardless of color theme
-- HOW: clear `bg` on common UI highlight groups
local function apply_transparency()
    for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, {bg = "none"})
    end
end
local function remove_transparency()
    for _, group in ipairs(transparent_groups) do
        vim.api.nvim_set_hl(0, group, {}) -- theme takes over again
    end
end
apply_transparency() -- apply once on startup
-- User Commands---------------------
vim.api.nvim_create_user_command( "TransparentOn", apply_transparency, {desc = "Enable transparent bg"})
vim.api.nvim_create_user_command( "TransparentOff", remove_transparency, {desc = "Disable transparent bg"})

-- autocommands helpers
local grp = vim.api.nvim_create_augroup("user_transparent", {clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {group = grp, callback = apply_transparency, desc = "Keep transparency" })
-- Transparent Background config ends here---------------------------------------------------------
-- ╭───────────────────────-───────────────────╮
-- │     Thicker borders for windo splits      │
-- ╰────────────────────────-──────────────────╯
-- this line is used to append heavy glyphs for split borders
vim.opt.fillchars:append({
    vert      = "┃",  -- vertical split
    vertleft  = "┫",  -- ┫ junction on left
    vertright = "┣",  -- ┣ junction on right
    verthoriz = "╋",  -- ╋ T-crossing
    horiz     = "━",  -- horizontal split
    horizup   = "┻",  -- ┻ junction up
    horizdown = "┳",  -- ┳ junction down
})

-- Eexposed a function so other files (or sutocmds) can re-apply highlights.
local M = {}
function M.apply_split_border_hl()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#313244", bold = true, nocombine = true })
    -- invoke the function()
    end

    M.apply_split_border_hl()
    return M
