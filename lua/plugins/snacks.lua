return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = false },
		quickfile = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = false },
		words = { enabled = true },
		explorer = { enabled = true },
		picker = {
			sources = {
				explorer = {
					auto_close = true,
					jump = { close = true },
					layout = { preset = "telescope", preview = true, reverse = false },
				},
			},
		},
	},
}
