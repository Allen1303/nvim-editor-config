 --lua/allen/options.lua
-- Basic editing and UI options

local opt = vim.opt

-- Numbers and line display
opt.number = true           -- Show line numbers
opt.relativenumber = true   -- Show relative line numbers
opt.cursorline = true      -- Highlight current line
opt.signcolumn = "yes"     -- Always show sign column (prevents text shifting)

-- Text wrapping and display
opt.wrap = false           -- Don't wrap lines by default
opt.linebreak = true       -- If wrap is on, break at word boundaries
opt.scrolloff = 10          -- Keep 10 lines above/below cursor when scrolling
opt.sidescrolloff = 10      -- Keep 10 columns left/right of cursor

-- Search behavior
opt.ignorecase = true      -- Ignore case when searching
opt.smartcase = true       -- Override ignorecase if search has uppercase
opt.incsearch = true       -- Show search matches as you type
opt.hlsearch = true        -- Highlight all search matches

-- Indentation (you already have this, but here for completeness)
opt.expandtab = true       -- Use spaces instead of tabs
opt.shiftwidth = 4         -- Size of an indent
opt.tabstop = 4            -- Number of spaces tabs count for
opt.softtabstop = 4        -- Number of spaces tabs count for in insert mode
opt.autoindent = true      -- Copy indent from current line when starting new line
opt.smartindent = true     -- Smart autoindenting when starting new line

-- Clipboard integration
opt.clipboard = "unnamedplus"  -- Use system clipboard

-- File handling
opt.undofile = true        -- Save undo history to file
opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")  -- Where to save undo files
opt.swapfile = false       -- Don't create swap files
opt.backup = false         -- Don't create backup files
opt.writebackup = false    -- Don't create backup before overwriting file
opt.autoread = true        -- Automatically read file when changed outside vim

-- Window splitting behavior  
opt.splitright = true      -- Vertical splits go to the right
opt.splitbelow = true      -- Horizontal splits go below
opt.equalalways = true     -- Always make splits equal size

-- Visual and UI
opt.termguicolors = true   -- Enable 24-bit RGB colors
opt.showmode = false       -- Don't show mode in command line (lualine shows it)
opt.cmdheight = 1          -- Command line height
opt.pumheight = 10         -- Popup menu height

-- Cursor and folding
opt.foldmethod = "manual"  -- Start with manual folding (we'll upgrade to treesitter later)
opt.foldlevelstart = 99    -- Start with all folds open

-- Performance
opt.updatetime = 250       -- Faster completion and diagnostics
opt.timeoutlen = 300       -- Time to wait for mapped sequence to complete

-- Better completion experience
opt.completeopt = { "menu", "menuone", "noselect" }  -- Better autocompletion

-- Mouse support (optional - remove if you don't want mouse)
opt.mouse = "a"            -- Enable mouse support in all modes
