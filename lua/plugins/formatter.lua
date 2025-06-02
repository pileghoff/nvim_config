return {
	"mhartington/formatter.nvim",
	version = "*",
	config = function(_)
		require("formatter").setup({
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.INFO,
			filetype = {
				["wgsl"] = {
					function()
						return {
							exe = "wgslfmt",
						}
					end,
				},
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				cpp = {
					require("formatter.filetypes.c").clangformat,
				},
				c = {
					require("formatter.filetypes.c").clangformat,
				},
				cuda = {
					require("formatter.filetypes.c").clangformat,
				},
				dart = {
					require("formatter.filetypes.dart").dartformat,
				},
				python = {
					require("formatter.filetypes.python").isort,
					require("formatter.filetypes.python").black,
				},
				rust = {
					require("formatter.filetypes.rust").rustfmt,
				},
				zig = {
					require("formatter.filetypes.zig").zigfmt,
				},
				["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
			},
		})
	end,
}
