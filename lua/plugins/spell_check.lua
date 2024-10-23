return {
{
    "psliwka/vim-dirtytalk",
    build = ":DirtytalkUpdate",
    config = function()
        vim.opt.spelllang = { "en", "programming" }
				vim.opt.spell = true
    end,
		lazy = false
}
}
