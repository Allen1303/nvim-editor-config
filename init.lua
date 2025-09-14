-- =============================================================================
-- WHAT: Single entrypoint that wires up a modular Neovim config.
-- WHY : Keeps concerns separated (options, keymaps, autocmds, UI), so you learn
--       each piece in isolation without side-effects.
-- HOW : Require each module in a deliberate order; use pcall to avoid errors
--       while files are still being created during the step-by-step build.
-- =============================================================================
-- for faster Lua module loads on Neovim ≥0.9
if vim.loader and vim.loader.enable then vim.loader.enable() end
-- Helper: protected require (doesn't crash if file doesn't exist yet)
local function prequire(mod)
 local ok, result = pcall(require, mod)
  if not ok then
-- Defer the notice so startup isn't blocked
vim.schedule(function()
 vim.notify(("Skipped %s: %s"):format(mod, result), vim.log.levels.WARN, { title = "init.lua"})
 end)
 end
 return ok and result or nil
 end
 -- Load order matters:
 -- 1) options  → core editor behavior (Areas 2–9)
-- 2) keymaps  → fundamental mappings (Areas 10–12)
-- 3) autocmds → smart defaults that react to events (Areas 13–14)
-- 4) ui       → visual polish & components (Areas 1 & 15)
prequire("allen.options")
prequire("allen.keymaps")
prequire("allen.autocmds")
prequire("allen.ui")
prequire("allen.floating_terminal")





