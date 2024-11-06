return {
	"rmagatti/auto-session",
	lazy = false,

	init = function()
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
	end,
	opts = {
		auto_create = true,
		auto_session_suppress_dirs = {},
		session_lens = {
			-- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
			load_on_setup = true,
			theme_conf = { border = true },
			previewer = true,
		},
	},
}
