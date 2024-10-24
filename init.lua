vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.coq_settings = {
	auto_start = "shut-up",
	clients = {
		snippets = {
			warn = {},
		},
	},
}
vim.keymap.set("x", "p", function()
	return 'pgv"' .. vim.v.register .. "y"
end, { remap = false, expr = true })
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
	{ "<leader>bd", "<cmd>bd<cr>", desc = "Delete buffers" },
})

-- Files group
wk.add({
	{ "<leader>f", group = "Files" },
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
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
	{ "<leader>cw", ts_builtin.lsp_dynamic_workspace_symbols, desc = "Navigate code in workspace", mode = "n" },
	{ "<leader>cd", ts_builtin.lsp_definitions, desc = "Definition", mode = "n" },
	{ "<leader>ci", ts_builtin.lsp_implementations, desc = "Implementation", mode = "n" },
	{ "<leader>cr", ts_builtin.lsp_references, desc = "References", mode = "n" },
	{ "<leader>cj", ts_builtin.jumplist, desc = "Jumplist", mode = "n" },
})

-- Coq setup
local coq = require("coq")

-- LSP setup
local lsp = require("lspconfig")
lsp.pyright.setup({})
lsp.clangd.setup({})
lsp.clangd.setup(coq.lsp_ensure_capabilities())
lsp.pyright.setup(coq.lsp_ensure_capabilities())

-- Other plugins
require("leap")
require("nvim-tree").setup()
