-- Set leader
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Disable netrw, since we use nvimtree vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Configure clipboard to work with system
vim.opt.clipboard = "unnamedplus"

-- Set tabs to a reasonable 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Line numbers + relative
vim.opt.number = true
-- vim.opt.relativenumber = true

-- Updatetime
vim.opt.updatetime = 1000

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

-- Remove signcolumn
vim.g.signcolumn = no

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

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

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
require("auto-session").setup({
	auto_save_enabled = true, -- Enables/disables auto saving
	auto_restore_enabled = true, --Enables/disables auto restoring
	auto_session_enabled = true, -- Enables/disables the plugin's auto save and restore features
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "rust", "markdown", "markdown_inline", "regex" },
	indent = { enable = true },
	auto_install = true,
	highlight = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			node_incremental = "v",
			node_decremental = "V",
		},
	},
})

require("treesitter-context").setup({
	enable = true,
})

-- Git
local neogit = require("neogit")
neogit.setup({})

-- Formatter
require("gruvbox").setup()
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})

-- Files
require("oil").setup({
	default_file_explorer = true,
	skip_confirm_for_simple_edits = true,
	lsp_file_methods = {
		autosave_changes = "unmodified",
	},
	watch_for_changes = true,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = true,
	},
	keymaps = {
		["h"] = { "actions.toggle_hidden", mode = "n" },
	},
})

-- Telescope setup
local ts_builtin = require("telescope.builtin")
local ts_recent = require("telescope").extensions["recent-files"].recent_files
local actions = require("telescope.actions")
require("telescope").setup({
	pickers = {
		buffers = {
			mappings = {
				n = {
					["d"] = actions.delete_buffer + actions.move_to_top,
				},
			},
		},
	},
	defaults = { path_display = { "truncate" } },
})
function ts_buffers()
	ts_builtin.buffers({
		sort_mru = true,
		ignore_current_buffer = true,
	})
end

-- LSP Renamer
local renamer = require("renamer")
renamer.setup({
	show_refs = true,
})

-- Grug setup
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "Grug FAR*",
	callback = function(ev)
		local win = vim.fn.bufwinid(ev.buf)
		if win > 0 then
			vim.api.nvim_win_set_width(win, 80)
			vim.api.nvim_win_call(win, function()
				vim.cmd([[normal! z0]])
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "Grug FAR*",
	callback = function(ev)
		local win = vim.fn.bufwinid(ev.buf)
		if win > 0 then
			vim.api.nvim_win_set_width(win, 20)
		end
	end,
})
function gruginator()
	grug = require("grug-far")
	if grug.has_instance("far") then
		grug.kill_instance("far")
	end
end

function grug_far()
	gruginator()
	require("grug-far").open({
		instanceName = "far",
		staticTitle = "Find and Replace",
		transient = true,
	})
end

function grug_far_local()
	gruginator()
	require("grug-far").open({
		instanceName = "far",
		staticTitle = "Find and Replace",
		transient = true,
		prefills = {
			paths = vim.fn.expand("%"),
			filesFilter = "!*.{json,html}",
		},
	})
end

function grug_far_visual()
	gruginator()
	require("grug-far").with_visual_selection({
		instanceName = "far",
		staticTitle = "Find and Replace",
		transient = true,
	})
end

function grug_far_local_visual()
	gruginator()
	require("grug-far").with_visual_selection({
		instanceName = "far",
		staticTitle = "Find and Replace",
		transient = true,
		prefills = {
			paths = vim.fn.expand("%"),
			filesFilter = "!*.{json,html}",
		},
	})
end

-- Which-key
local wk = require("which-key")
local wk_extra = require("which-key.extras")

wk.add({
	{ "<C-f>", grug_far_local, desc = "Find and replace", mode = "n" },
	{ "<s-f>", grug_far, desc = "Find and replace", mode = "n" },
	{ "<C-f>", grug_far_local_visual, desc = "Find and replace", mode = "v" },
	{ "<s-f>", grug_far_visual, desc = "Find and replace", mode = "v" },
	{ "<C-s>", ":w<cr>", desc = "Save" },
	{ "<C-p>", ts_recent },
	{ "<C-z>", "u" },
	{ "<C-r>", ":redo<cr>" },
	{ "<C-c>", "yiw" }, -- Yank word
	{ "<C-Up>", "6k", mode = "n" },
	{ "<C-Down>", "6j", mode = "n" },
	--{ "<C-Left>", "^" },
	--{ "<C-Right>", "$" },
	{ "<C-Down>", ":m '>+1<CR>gv=gv", mode = "v" },
	{ "<C-Up>", ":m '<-2<CR>gv=gv", mode = "v" },
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
	{ "<leader>b", ts_buffers, desc = "Search buffers" },
	{ "<leader>d", "<cmd>bp<bar>bd#<cr>", desc = "Delete buffer" },
	{ "<tab>", "<cmd>:bnext<cr>", mode = "n" },
	{ "<s-tab>", "<cmd>:bprev<cr>", mode = "n" },
})

-- Files groupst
function OpenOilCwd()
	require("oil").open(vim.fn["getcwd"]())
end
function OpenEdgy()
	require("edgy").toggle()
end
wk.add({
	{ "<leader>f", group = "Files" },
	{ "<leader><leader>", ts_recent, desc = "Open file tree", mode = "n" },
	{ "<leader>ff", OpenOilCwd, desc = "Find File", mode = "n" },
	{ "<leader>fe", "<cmd>Oil<cr>", desc = "Find current file in explorer", mode = "n" },
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
	{ "<leader><Left>", "<c-w>h", desc = "Go to the left window" },
	{ "<leader>w<Left>", "<c-w>h", desc = "Go to the left window" },
	{ "<leader>w<Down>", "<c-w>j", desc = "Go to the down window" },
	{ "<leader>w<Up>", "<c-w>k", desc = "Go to the up window" },
	{ "<leader>w<Right>", "<c-w>l", desc = "Go to the right window" },
	{ "<leader><Right>", "<c-w>l", desc = "Go to the right window" },
	{ "<leader>wo", "<c-w>o", desc = "Close all other windows" },
	{ "<leader>wd", "<c-w>q", desc = "Quit a window" },
	{ "<leader>ws", "<c-w>s", desc = "Split window" },
	{ "<leader>wv", "<c-w>v", desc = "Split window vertically" },
	{ "<leader>ww", "<c-w>w", desc = "Switch windows" },
	{ "<leader>wx", "<c-w>x", desc = "Swap current with next" },
	{ "<leader>w|", "<c-w>|", desc = "Max out the width" },
})
wk.add({
	{ "z=<Up>", "", hidden = true },
	{ "z=<Down>", "", hidden = true },
	{ "z=<Left>", "", hidden = true },
	{ "z=<Right>", "", hidden = true },
	{ "z=:", "", hidden = true },
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
	{ "<leader>ch", vim.lsp.buf.hover, desc = "Diagnostic", mode = "n" },
})

-- Git
wk.add({
	{ "<leader>g", "<cmd>Neogit kind=replace<cr>", desc = "Git" },
})

-- Spell check on cursorhold
--vim.api.nvim_create_autocmd("CursorHold", {
--	pattern = { "*" },
--	callback = function()
--		if require("cmp.config.context").in_treesitter_capture("spell") then
--			local word = vim.fn.expand("<cword>")
--			if table.getn(vim.spell.check(word)) > 0 then
--				local bad = vim.spell.check(word)
--				wk.show({ keys = "z=" })
--			end
--		end
--	end,
--})

-- Blink LSP setup
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- LSP setup
local lsp = require("lspconfig")
lsp.clangd.setup(capabilities)
lsp.pyright.setup(capabilities)
lsp.zls.setup(capabilities)
lsp.rust_analyzer.setup(capabilities)

-- Other plugins
require("flash").setup()

-- Noice
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hr shush/nvim-cmp
		},
		documentation = {
			view = "hover",
		},
	},

	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		inc_rename = true, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = true, -- add a border to hover docs and signature help
	},
	routes = {
		{
			filter = { find = "written" },
			opts = { skip = true },
		},

		{
			filter = {
				event = "notify",
				cond = function(message)
					return message.opts and message.opts.title == "Formatter" or message.opts.title == "lazy.nvim"
				end,
				warning = false,
				error = false,
			},
			opts = { skip = true },
		},
		{
			filter = {
				event = "notify",
				cond = function(message)
					return message.opts and message.opts.title == "Formatter" or message.opts.title == "lazy.nvim"
				end,
			},
			view = "mini",
		},
		{
			filter = {
				min_width = 100,
			},
			view = "mini",
		},
	},
})
require("lualine").setup()

-- Setup my prefered window settings every time i switch.
vim.api.nvim_create_autocmd({ "WinLeave" }, {
	pattern = { "*" },
	callback = function()
		vim.wo.relativenumber = false
		vim.wo.number = true
		vim.wo.numberwidth = 5
		vim.wo.cursorline = true
		vim.wo.cursorcolumn = false
		vim.o.signcolumn = "no"
	end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	pattern = { "*" },
	callback = function()
		vim.wo.relativenumber = false
		vim.wo.number = true
		vim.wo.numberwidth = 5
		vim.wo.cursorline = true
		vim.wo.cursorcolumn = false
		vim.o.signcolumn = "no"
	end,
})

-- Auto reload contents of a buffer
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_command("checktime")
	end,
})
