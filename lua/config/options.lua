-- lua/config/options.lua
-- WHY: sane, fast, native defaults; no plugin assumptions.
-- HOW: set core options once; leave UI/highlights to config.ui.

-- visuals & UI
vim.opt.termguicolors = true           -- WHY: true 24-bit color everywhere
vim.opt.number = true                  -- HOW: show absolute line numbers
vim.opt.relativenumber = true          -- HOW: relative jump hints
vim.opt.cursorline = true              -- HOW: highlight current line
vim.opt.wrap = false                   -- HOW: no soft wrapping
vim.opt.signcolumn = "yes"             -- HOW: keep signs from shifting text
vim.opt.colorcolumn = "80"             -- HOW: soft ruler at 100 cols
vim.opt.showmatch = true               -- HOW: briefly highlight matching pair
vim.opt.matchtime = 2                  -- HOW: match highlight duration
vim.opt.cmdheight = 1                  -- HOW: compact cmdline
vim.opt.pumheight = 10                 -- HOW: completion menu height
vim.opt.pumblend = 10                  -- HOW: light popup fade
vim.opt.winblend = 10                  -- HOW: light float fade
vim.opt.conceallevel = 0               -- HOW: show markup by default
vim.opt.concealcursor = ""             -- HOW: do not conceal cursor line
vim.opt.lazyredraw = true              -- WHY: faster macros/scrolling
vim.opt.synmaxcol = 300                -- WHY: speed up large lines
vim.opt.virtualedit = "block"          -- WHY: Better visual editing for visual block mode

--Vim Native Status line opts
--vim.opt.laststatus = 3                 -- enable one global statusline across all windows
--vim.opt.statusline = "%F"             -- displays the full path to the current file.
--vim.opt.statusline = "%#UserStatusLineFilename# %F %#UserStatusLineMisc# %l:%c "
vim.opt.showmode = false               -- HOW: statusline should show mode later

-- movement & scrolling
vim.opt.scrolloff = 10                 -- HOW: keep context above/below
vim.opt.sidescrolloff = 10             -- HOW: keep context left/right
vim.opt.splitbelow = true              -- HOW: horizontal splits below
vim.opt.splitright = true              -- HOW: vertical splits right
-- movement / navigation
vim.o.whichwrap = "b,s,<,>,[,]"  -- allow arrow/[] to wrap to prev/next line

-- indent & tabs (project-agnostic;  autocmds can override)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- search
vim.opt.ignorecase = true              -- HOW: case-insensitive by default
vim.opt.smartcase = true               -- HOW: smart if pattern has capitals
vim.opt.hlsearch = false               -- HOW: no lingering highlights
vim.opt.incsearch = true               -- HOW: live matches while typing

-- files, backups, undo
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
local undo_dir = vim.fn.stdpath("state") .. "/undo"    -- WHY: portable path
if vim.fn.isdirectory(undo_dir) == 0 then vim.fn.mkdir(undo_dir, "p") end
vim.opt.undodir = undo_dir
vim.opt.updatetime = 300               -- HOW: faster CursorHold/diagnostics
vim.opt.timeoutlen = 500               -- HOW: snappy mappings
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true                -- HOW: reload changed files
vim.opt.autowrite = false              -- HOW: explicit saves

-- behavior
vim.opt.hidden = true                  -- HOW: switch buffers without saving
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")          -- HOW: treat dash-words as one
vim.opt.path:append("**")              -- HOW: :find traverses subdirs
vim.opt.selection = "exclusive"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- folding (native-only)
vim.opt.foldmethod = "syntax"          -- WHY: no Treesitter dependency
vim.opt.foldexpr = nil
vim.opt.foldlevel = 99                 -- HOW: start unfolded

-- wildmenu / diff / perf
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

