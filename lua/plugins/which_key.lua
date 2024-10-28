return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
	},
	-- better %
	{
		"andymass/vim-matchup",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			vim.cmd("colorscheme tokyonight-night")
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
	},

	{
		"folke/which-key.nvim",
		lazy = true,
	},

	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
