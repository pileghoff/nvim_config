return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mollerhoj/telescope-recent-files.nvim",
		"nvim-telescope/telescope-fzy-native.nvim",
	},
	config = function()
		require("telescope").load_extension("fzy_native")
		require("telescope").load_extension("recent-files")
	end,
}
