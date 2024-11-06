return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true,
		config = function()
			-- load the colorscheme here
			vim.cmd("colorscheme gruvbox")
			vim.o.background = "dark"
		end,
		opts = {
			dim_inactive = true,
		},
	},
}
