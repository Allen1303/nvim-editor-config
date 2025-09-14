-- =============================================================================
-- WHAT: Core autocommands (event-driven smarts).
-- WHY : Teach Neovim to react to events (yank, read file, save, resize).
-- HOW : Use vim.api.nvim_create_augroup + nvim_create_autocmd with callbacks.
-- =============================================================================
-- Create a named group so rules don’t duplicate on reload
 vim.api.nvim_create_augroup("allen_auto_cmd", {clear = true})
-- ╭───────────────────-───────────────────╮
-- │  Autocmd syntax (sample for learning) │
-- ╰────────────────────-──────────────────╯
-- WHY : Shows the building blocks (group, event, pattern, callback).
-- HOW : Replace Event/Pattern/Callback/Desc with your own.
-- vim.api.nvim_create_autocmd("Event", {
  --   group = "allen_core",
  --   pattern = "*",
  --   callback = function(args)
    --     -- your code here (args.buf, args.file, etc.)
    --   end,
    --   desc = "Short, clear description",
    -- })
    -- ╭───────────────────────-───────────────────╮
    -- │ 13a) Highlight on yank (visual feedback)  │
    -- ╰────────────────────────-──────────────────╯
    -- WHAT: Briefly highlight text you just yanked.
    -- WHY : Confirms the motion worked; builds muscle memory fast.
    -- HOW : TextYankPost → built-in highlighter with a short timeout.
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = "allen_auto_cmd" ,
      callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120})
      end,
      desc = "Show highlight color on yank text",
    })
    -- ╭───────────────────────-──────────────────╮
    -- │ 13b) Restore last edit position on open  │
    -- ╰────────────────────────-─────────────────╯
    -- WHAT: Jump to where you left off in the file.
    -- WHY : Saves time re-finding your place across sessions.
    -- HOW : On BufReadPost, go to the \" mark if it’s valid; open folds.
    vim.api.nvim_create_autocmd("BufReadPost", { group = "allen_auto_cmd",
    callback = function()
      if vim.bo.filetype ~= "gitcommit" 
        and vim.fn.line([['"]]) > 1
        and vim.fn.line([['"]]) <= vim.fn.line([[$]]) then 
        vim.cmd([[silent! normal! g`"]])
        vim.cmd([[normal! zv]])
      end
    end,
    desc = "Restore cursor to last position",
  })
  -- ╭-───────────────────────-────────────────────────╮
  -- │ 13c) Auto-create parent directories on save     │
  -- ╰-────────────────────────-───────────────────────╯
  -- WHAT: Make missing folders before writing a new file.
  -- WHY : Prevents “no such file or directory” save errors.
  -- HOW : BufWritePre → mkdir -p for the file’s parent directory.
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = "allen_auto_cmd",
    callback = function()
      -- %:p:h = current file’s absolute parent directory
      if vim.fn.isdirectory(vim.fn.expand([[%:p:h]])) == 0 then
        vim.fn.mkdir(vim.fn.expand([[%:p:h]]), "p")
      end
    end,
    desc = "Create parent directory on save",
  })
  -- ╭───────────────────────-────────────────────────────╮
  -- │ 13d) Equalize splits when terminal window resizes  │
  -- ╰────────────────────────-───────────────────────────╯
  -- WHAT: Keep window layout balanced after resize.
  -- WHY : Avoids one split becoming tiny when the terminal changes size.
  -- HOW : VimResized → run :tabdo wincmd =  (all tabs, equal widths/heights).
  vim.api.nvim_create_autocmd("VimResized", {
    group = "allen_auto_cmd",
    callback = function()
      vim.cmd([[tabdo wincmd =]])
    end,
    desc = "Auto-resize splits on UI resize",
  })
  -- ╭───────────────────────-────────────────────────────╮
  -- │ 13e) Autoread when files change on disk (optional) │
  -- ╰────────────────────────-───────────────────────────╯
  -- WHAT: Reload buffers if an external tool edits the file.
  -- WHY : Plays nice with Git, formatters, or generators touching files.
  -- HOW : On focus/terminal events, run :checktime to re-read changed files.
  vim.api.nvim_create_autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = "allen_auto_cmd",
    callback = function()
      if vim.o.buftype == "" then
        vim.cmd("checktime")
      end
    end,
    desc = "Auto-resize change files on focus/terminal events",
  })
  -- Return truthy so :lua print(package.loaded["allen.autocmds"]) shows true
  -- ╭──────────────────────────────────────╮
  -- │ FileType autocmd (syntax example)    │
  -- ╰────────────────────-─────────────────╯
  -- vim.api.nvim_create_autocmd("FileType", {
    --   group = "allen_core",
    --   pattern = { "language1", "language2" },
    --   callback = function()
      --     vim.bo.shiftwidth = 2      -- buffer-local
      --     vim.bo.tabstop = 2         -- buffer-local
      --     vim.bo.expandtab = true    -- buffer-local
      --     vim.wo.wrap = false        -- window-local
      --   end,
      --   desc = "Example per-language setup",
      -- })
      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14a) Web stack (2-space soft tabs, no wrap)      │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: Standardize web files to 2-space indents.
      -- WHY : Matches common JS/TS/HTML/CSS conventions; keeps diffs tight.
      -- HOW : Set shiftwidth/tabstop/expandtab per filetype.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = {
          "javascript", "javascriptreact",
          "typescript", "typescriptreact",
          "json", "jsonc",
          "html", "css", "scss", "less",
          "lua",
          "yaml", "yml",
        },
        callback = function()
          vim.bo.shiftwidth = 2
          vim.bo.tabstop = 2
          vim.bo.expandtab = true
          vim.wo.wrap = false
        end,
        desc = "Web/Lua/YAML: 2-space soft tabs",
      })
      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14b) Python (PEP-ish 4-space, guide at 88)       │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: 4-space soft tabs; visual guide at 88 cols.
      -- WHY : Matches common Python style; plays well with Black.
      -- HOW : Set indent to 4; set colorcolumn for this window only.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = { "python" },
        callback = function()
          vim.bo.shiftwidth = 4
          vim.bo.tabstop = 4
          vim.bo.expandtab = true
          vim.wo.colorcolumn = "88"
          vim.wo.wrap = false
        end,
        desc = "Python: 4-space indents, 88-col guide",
      })
      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14c) Markdown / Writing (soft wrap, linebreak)   │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: Writer-friendly view (no mid-word breaks, spell).
      -- WHY : Improves readability for prose and docs.
      -- HOW : Enable wrap+linebreak; turn on spell; gentle conceal.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = { "markdown", "gitcommit" },
        callback = function()
          vim.wo.wrap = true
          vim.wo.linebreak = true
          vim.wo.spell = true
          vim.wo.conceallevel = 2
          vim.bo.shiftwidth = 2
          vim.bo.tabstop = 2
          vim.bo.expandtab = true
        end,
        desc = "Markdown/Git: wrap, linebreak, spell",
      })

      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14d) Shell scripts (2-space, soft tabs)          │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: Keep shell script indents small and consistent.
      -- WHY : Improves readability without deep nesting noise.
      -- HOW : 2-space soft tabs for sh/bash/zsh.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = { "sh", "bash", "zsh" },
        callback = function()
          vim.bo.shiftwidth = 2
          vim.bo.tabstop = 2
          vim.bo.expandtab = true
          vim.wo.wrap = false
        end,
        desc = "Shell: 2-space indents",
      })

      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14e) Makefiles (HARD tabs, width 8)              │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: Use literal tab characters (Make requires tabs).
      -- WHY : Makefiles break if you replace tabs with spaces.
      -- HOW : noexpandtab + tabstop/shiftwidth=8 per tradition.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = { "make" },
        callback = function()
          vim.bo.expandtab = false
          vim.bo.tabstop = 8
          vim.bo.shiftwidth = 8
          vim.wo.wrap = false
        end,
        desc = "Makefile: hard tabs at width 8",
      })

      -- ╭───────────────────────-──────────────────────────╮
      -- │ 14f) JSON/JSONC (keep conceal off for clarity)   │
      -- ╰────────────────────────-─────────────────────────╯
      -- WHAT: Avoid hiding characters in data files.
      -- WHY : Makes commas/braces obvious while editing.
      -- HOW : Disable conceal in this window.
      vim.api.nvim_create_autocmd("FileType", {
        group = "allen_auto_cmd",
        pattern = { "json", "jsonc" },
        callback = function()
          vim.wo.conceallevel = 0
        end,
        desc = "JSON: no conceal",
      })
      return true
