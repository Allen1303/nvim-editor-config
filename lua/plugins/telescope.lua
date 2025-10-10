 -- ╭───────────────────────-──────────────────────────╮
 -- │        Telescope for fuzzy finding files         │
 -- ╰────────────────────────-─────────────────────────╯
return {
"nvim-telescope/telescope.nvim", tag = '0.1.8',
dependecies = {"nvim-lua/plenary.nvim"},
main = "telescope",
keys = {
    { '<leader>ff', function() require("telescope.builtin").find_files() end,  desc = 'Telescope find files' },
    { '<leader>fg', function() require("telescope.builtin").live_grep() end,  desc = 'Telescope live grep' },
    { '<leader>fb', function() require("telescope.builtin").buffers() end,  desc = 'Telescope buffers' },
    { '<leader>fh', function() require("telescope.builtin").help_tags() end,  desc = 'Telescope help tags' },
}, ---- keymaps end here 
--This table is passed to telescope.setup(opts) automatically when main is set.
opts = {
    defaults = {
        sorting = "assending",
        layout_config = {prompt_position = "top"},
    }
}




} -- End of return code config------------------------------------------------

