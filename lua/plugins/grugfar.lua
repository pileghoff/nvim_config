return {
	"pileghoff/grug-far.nvim",
	branch = "dont_show_preview",
	--dir = "~/grug-far.nvim/",
	opts = {
		headerMaxWidth = 80,
		wrap = false,
	},
	config = function()
		require("grug-far").setup({
			wrap = false,
		})
	end,
}
