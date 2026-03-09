return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		search = {
			mode = "fuzzy",
		},
		modes = {
			search = {
				enabled = true,
			},
		},
	},
	-- stylua: ignore
}
