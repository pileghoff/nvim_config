return {
	"mhartington/formatter.nvim",
	version = "*",
	config = function(_)
		require("formatter").setup({
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.INFO,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				cpp = {
					require("formatter.filetypes.c").clangformat,
				},
				c = {
					require("formatter.filetypes.c").clangformat,
				},
				python = {
					require("formatter.filetypes.python").isort,
					require("formatter.filetypes.python").black,
				},
				["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
			},
		})
	end,
}
