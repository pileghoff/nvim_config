-- Set leader
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-- Disable netrw, since we use nvimtree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Configure clipboard to work with system
vim.opt.clipboard = "unnamedplus"

-- Configure sessionopts
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Set tabs to a reasonable 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Line numbers + relative
vim.opt.number = true
vim.opt.relativenumber = true

-- Set COQ settings now, before loading lazy
vim.g.coq_settings = {
	auto_start = "shut-up",
	clients = {
		snippets = {
			warn = {},
		},
	},
}
-- keep current content top + left when splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Remap parte, so it wont yank what it relpaces
vim.keymap.set("x", "p", function()
	return 'pgv"' .. vim.v.register .. "y"
end, { remap = false, expr = true })

-- infinite undo!
-- NOTE: ends up in ~/.local/state/nvim/undo/
vim.opt.undofile = true

-- case-insensitive search/replace
vim.opt.ignorecase = true
-- unless uppercase in search term
vim.opt.smartcase = true

-- more useful diffs (nvim -d)
--- by ignoring whitespace
vim.opt.diffopt:append("iwhite")
--- and using a smarter algorithm
--- https://vimways.org/2018/the-power-of-diff/
--- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
--- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("indent-heuristic")

-- Esc stops search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- always center search results
vim.keymap.set("n", "n", "nzz", { silent = true })
vim.keymap.set("n", "N", "Nzz", { silent = true })
vim.keymap.set("n", "*", "*zz", { silent = true })
vim.keymap.set("n", "#", "#zz", { silent = true })
vim.keymap.set("n", "g*", "g*zz", { silent = true })

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = "silent! lua vim.highlight.on_yank({ timeout = 500 })",
})
--
-- jump to last edit position on opening file
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function(ev)
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			-- except for in git commit messages
			-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
			if not vim.fn.expand("%:p"):find(".git", 1, true) then
				vim.cmd('exe "normal! g\'\\""')
			end
		end
	end,
})

require("config.lazy")
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "rust", "markdown", "markdown_inline" },
	auto_install = true,
	highlight = {
		enable = true,
	},
})

-- Git
local neogit = require("neogit")
neogit.setup({})

-- Formatter
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

local wk = require("which-key")
local wk_extra = require("which-key.extras")
local ts_builtin = require("telescope.builtin")
local renamer = require("renamer")
renamer.setup({
	show_refs = true,
})

-- Spell
wk.add({
	{ "<leader>s", group = "Spell checker" },
	{ "<leader>ss", ts_builtin.spell_suggest, desc = "Spell checker" },
	{ "<leader>sa", "zg", desc = "Add word to dict" },
	{ "<leader>sr", "zw", desc = "Remove word from dict" },
})

-- Buffer group
wk.add({
	{ "<leader>b", group = "Buffers" },
	{ "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Search buffers" },
	{ "<leader>bd", "<cmd>bp<bar>bd#<cr>", desc = "Delete buffers" },
})

-- Files group
wk.add({
	{ "<leader>f", group = "Files" },
	{ "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Open file tree", mode = "n" },
	{ "<leader>ff", "<cmd>NvimTreeFocus<cr>", desc = "Find File", mode = "n" },
	{ "<leader>fe", "<cmd>NvimTreeFindFile<cr>", desc = "Find current file in explorer", mode = "n" },
	{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old files" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep File", mode = "n" },
})

-- Windows group
wk.add({
	{ "<leader>w", group = "window" },
	{ "<leader>w+", "+", desc = "Increase height" },
	{ "<leader>w-", "<c-w>-", desc = "Decrease height" },
	{ "<leader>w<", "<c-w><", desc = "Decrease width" },
	{ "<leader>w=", "<c-w>=", desc = "Equally high and wide" },
	{ "<leader>w>", "<c-w>>", desc = "Increase width" },
	{ "<leader>wT", "<c-w>T", desc = "Break out into a new tab" },
	{ "<leader>w_", "<c-w>_", desc = "Max out the height" },
	{ "w<Left>", "<c-w>h", desc = "Go to the left window" },
	{ "w<Down>", "<c-w>j", desc = "Go to the down window" },
	{ "w<Up>", "<c-w>k", desc = "Go to the up window" },
	{ "w<Right>", "<c-w>l", desc = "Go to the right window" },
	{ "<leader>w<Left>", "<c-w>h", desc = "Go to the left window" },
	{ "<leader>w<Down>", "<c-w>j", desc = "Go to the down window" },
	{ "<leader>w<Up>", "<c-w>k", desc = "Go to the up window" },
	{ "<leader>w<Right>", "<c-w>l", desc = "Go to the right window" },
	{ "<leader>wo", "<c-w>o", desc = "Close all other windows" },
	{ "<leader>wd", "<c-w>q", desc = "Quit a window" },
	{ "<leader>ws", "<c-w>s", desc = "Split window" },
	{ "<leader>wv", "<c-w>v", desc = "Split window vertically" },
	{ "<leader>ww", "<c-w>w", desc = "Switch windows" },
	{ "<leader>wx", "<c-w>x", desc = "Swap current with next" },
	{ "<leader>w|", "<c-w>|", desc = "Max out the width" },
})

-- Code group
wk.add({
	{ "<leader>c", group = "code" },
	{ "<leader>cc", ts_builtin.lsp_document_symbols, desc = "Navigate code", mode = "n" },
	{ "<leader>cn", renamer.rename, desc = "Rename", mode = "n" },
	{ "<leader>cw", ts_builtin.lsp_dynamic_workspace_symbols, desc = "Navigate code in workspace", mode = "n" },
	{ "<leader>cd", ts_builtin.lsp_definitions, desc = "Definition", mode = "n" },
	{ "<leader>ci", ts_builtin.lsp_implementations, desc = "Implementation", mode = "n" },
	{ "<leader>cr", ts_builtin.lsp_references, desc = "References", mode = "n" },
	{ "<leader>cj", ts_builtin.jumplist, desc = "Jumplist", mode = "n" },
	{ "<leader>ce", vim.diagnostic.open_float, desc = "Diagnostic", mode = "n" },
})

-- Git
wk.add({
	{ "<leader>g", "<cmd>Neogit kind=replace<cr>", desc = "Git" },
})

-- Coq setup
local coq = require("coq")

-- LSP setup
local lsp = require("lspconfig")
lsp.clangd.setup(coq.lsp_ensure_capabilities())
lsp.pyright.setup(coq.lsp_ensure_capabilities())
lsp.zls.setup(coq.lsp_ensure_capabilities())

-- Other plugins
require("leap")
require("nvim-tree").setup({
	git = {
		enable = false,
	},
	actions = {
		change_dir = {
			enable = false,
		},
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	filters = {
		enable = true,
		git_ignored = false,
		dotfiles = false,
	},
})
