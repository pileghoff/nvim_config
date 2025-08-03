return {
	"saghen/blink.cmp",
	dependencies = { "ribru17/blink-cmp-spell" },

	-- use a release tag to download pre-built binaries
	version = "*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = "cargo build --release",
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' for mappings similar to built-in completion
		-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
		-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
		-- See the full "keymap" documentation for information on defining your own keymap.
		keymap = { preset = "enter" },

		appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- Will be removed in a future release
			use_nvim_cmp_as_default = true,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lsp", "path", "buffer", "spell" },
			providers = {
				spell = {
					name = "Spell",
					module = "blink-cmp-spell",
					opts = {
						-- EXAMPLE: Only enable source in `@spell` captures, and disable it
						-- in `@nospell` captures.
						enable_in_context = function()
							local curpos = vim.api.nvim_win_get_cursor(0)
							local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
							local in_spell_capture = false
							for _, cap in ipairs(captures) do
								if cap.capture == "spell" then
									in_spell_capture = true
								elseif cap.capture == "nospell" then
									return false
								end
							end
							return in_spell_capture
						end,
					},
				},
			},
		},
		completion = {
			list = { selection = { preselect = false, auto_insert = true } },
			keyword = { range = "full" },
		},
		signature = { enabled = true },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		cmdline = {
			keymap = { preset = "enter" },
			completion = {
				menu = { auto_show = true },
				ghost_text = { enabled = false },

				list = {
					selection = {
						-- When `true`, will automatically select the first item in the completion list
						preselect = false,
						-- When `true`, inserts the completion item automatically when selecting it
						auto_insert = true,
					},
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
