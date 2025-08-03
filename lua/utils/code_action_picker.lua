-- code-actions-picker.lua
-- A custom picker that combines LSP code actions with custom code actions

local M = {}

-- Define your custom code actions here

M.custom_actions = {
	{
		name = "Rename Variable",
		action = function()
			vim.lsp.buf.rename()
		end,
	},
	{
		name = "Go to Definition",
		action = function()
			vim.lsp.buf.definition()
		end,
	},
	{
		name = "List Symbols",
		action = function()
			-- Use Snacks.picker for LSP symbols
			if Snacks and Snacks.picker and Snacks.picker.lsp_symbols then
				Snacks.picker.lsp_symbols()
			else
				-- Fallback to built-in symbol picker
				vim.lsp.buf.document_symbol()
			end
		end,
	},
}

-- Function to get LSP code actions
local function get_lsp_code_actions(callback)
	-- Check if we have any LSP clients attached
	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
	if not clients or #clients == 0 then
		callback({})
		return
	end

	-- Use the built-in code action function to get actions
	local actions = {}
	local original_handler = vim.lsp.handlers["textDocument/codeAction"]

	-- Temporarily override the handler to capture actions
	vim.lsp.handlers["textDocument/codeAction"] = function(err, result, ctx, config)
		if err or not result then
			callback(actions)
			vim.lsp.handlers["textDocument/codeAction"] = original_handler
			return
		end

		local client = vim.lsp.get_client_by_id(ctx.client_id)
		local client_name = (client and client.name) or "unknown"

		for _, action in pairs(result) do
			local title = action.title or "Untitled Action"
			table.insert(actions, {
				name = string.format("[LSP:%s] %s", client_name, title),
				action = action,
				type = "lsp",
			})
		end

		callback(actions)
		-- Restore original handler
		vim.lsp.handlers["textDocument/codeAction"] = original_handler
	end

	-- Request code actions
	vim.lsp.buf.code_action({ apply = false })
end

-- Function to get LSP code actions using buf_request_all
local function get_lsp_code_actions_simple(callback)
	local bufnr = vim.api.nvim_get_current_buf()

	-- Check if we have any LSP clients attached (use newer API)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if not clients or #clients == 0 then
		callback({})
		return
	end

	-- Get the first client's offset encoding for make_range_params
	local offset_encoding = clients[1] and clients[1].offset_encoding or "utf-16"

	-- Create parameters for the code action request
	local params = vim.lsp.util.make_range_params(0, offset_encoding)
	params.context = {
		diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 }),
		triggerKind = 1, -- Manual trigger
	}

	-- Use buf_request_all to get actions from all clients
	vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
		local actions = {}

		if results then
			for client_id, result in pairs(results) do
				if result and result.result and type(result.result) == "table" then
					local client = vim.lsp.get_client_by_id(client_id)
					local client_name = (client and client.name) or "unknown"

					for _, action in ipairs(result.result) do
						if action and action.title then
							table.insert(actions, {
								name = string.format("[LSP:%s] %s", client_name, action.title),
								action = action,
								type = "lsp",
							})
						end
					end
				end
			end
		end

		callback(actions)
	end)
end

-- Main function to show the code actions picker
function M.show_code_actions()
	local all_items = {}

	-- Add custom actions first
	for idx, custom_action in ipairs(M.custom_actions) do
		table.insert(all_items, {
			idx = idx,
			name = custom_action.name,
			text = custom_action.name,
			action = custom_action.action,
			type = "custom",
		})
	end

	-- Get LSP actions and show picker
	get_lsp_code_actions_simple(function(lsp_actions)
		-- Add LSP actions
		for idx, lsp_action in ipairs(lsp_actions) do
			table.insert(all_items, {
				idx = #all_items + idx,
				name = lsp_action.name,
				text = lsp_action.name,
				action = lsp_action.action,
				type = "lsp",
				original_index = lsp_action.original_index,
			})
		end

		if #all_items == 0 then
			vim.notify("No code actions available", vim.log.levels.INFO)
			return
		end

		Snacks.picker({
			title = "Code Actions",
			layout = {
				preset = "dropdown",
				preview = false,
			},
			items = all_items,
			format = function(item, _)
				local hl_group = item.type == "custom" and "DiagnosticInfo" or "DiagnosticHint"
				return {
					{ item.text, hl_group },
				}
			end,
			confirm = function(picker, item)
				picker:close()

				if item.type == "custom" then
					-- Execute custom action
					return picker:norm(function()
						item.action()
					end)
				elseif item.type == "lsp" then
					-- Execute LSP code action
					return picker:norm(function()
						local action = item.action

						-- Function to apply a resolved action
						local function apply_action(resolved_action)
							if resolved_action.edit then
								vim.lsp.util.apply_workspace_edit(resolved_action.edit, "utf-8")
							end

							if resolved_action.command then
								local command = resolved_action.command
								if type(command) == "table" and command.command then
									vim.lsp.buf.execute_command(command)
								elseif type(command) == "string" then
									vim.cmd(command)
								end
							end
						end

						-- If action already has edit or command, apply directly
						if action.edit or action.command then
							apply_action(action)
						else
							-- Action needs to be resolved first
							local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
							local resolved = false

							for _, client in ipairs(clients) do
								if client.supports_method("codeAction/resolve") and not resolved then
									resolved = true
									client.request("codeAction/resolve", action, function(err, resolved_action)
										if err then
											vim.notify(
												"Error resolving code action: " .. tostring(err.message or err),
												vim.log.levels.ERROR
											)
											return
										end

										if resolved_action then
											apply_action(resolved_action)
										else
											vim.notify("Code action could not be resolved", vim.log.levels.WARN)
										end
									end)
									break
								end
							end

							-- Fallback if no client supports resolve
							if not resolved then
								vim.notify("No LSP client supports code action resolution", vim.log.levels.WARN)
							end
						end
					end)
				end
			end,
		})
	end)
end

-- Alternative version that shows actions in separate sections
function M.show_code_actions_sectioned()
	local all_items = {}

	-- Add section separator for custom actions
	if #M.custom_actions > 0 then
		table.insert(all_items, {
			idx = 0,
			name = "── Custom Actions ──",
			text = "── Custom Actions ──",
			type = "separator",
		})

		-- Add custom actions
		for idx, custom_action in ipairs(M.custom_actions) do
			table.insert(all_items, {
				idx = idx,
				name = custom_action.name,
				text = "  " .. custom_action.name, -- Indent for visual hierarchy
				action = custom_action.action,
				type = "custom",
			})
		end
	end

	-- Get LSP actions and show picker
	get_lsp_code_actions_simple(function(lsp_actions)
		-- Add section separator for LSP actions
		if #lsp_actions > 0 then
			table.insert(all_items, {
				idx = 0,
				name = "── LSP Actions ──",
				text = "── LSP Actions ──",
				type = "separator",
			})

			-- Add LSP actions
			for idx, lsp_action in ipairs(lsp_actions) do
				table.insert(all_items, {
					idx = #all_items + idx,
					name = lsp_action.name,
					text = "  " .. lsp_action.name:gsub("^%[LSP[^%]]*%] ", ""), -- Remove LSP prefix and indent
					action = lsp_action.action,
					type = "lsp",
					original_index = lsp_action.original_index,
				})
			end
		end

		if #all_items == 0 then
			vim.notify("No code actions available", vim.log.levels.INFO)
			return
		end

		Snacks.picker({
			title = "Code Actions",
			layout = {
				preset = "default",
				preview = false,
			},
			items = all_items,
			format = function(item, _)
				if item.type == "separator" then
					return {
						{ item.text, "Comment" },
					}
				end

				local hl_group = item.type == "custom" and "DiagnosticInfo" or "DiagnosticHint"
				return {
					{ item.text, hl_group },
				}
			end,
			confirm = function(picker, item)
				if item.type == "separator" then
					return -- Do nothing for separators
				end

				picker:close()

				if item.type == "custom" then
					-- Execute custom action
					return picker:norm(function()
						item.action()
					end)
				elseif item.type == "lsp" then
					-- Execute LSP code action
					return picker:norm(function()
						local action = item.action

						-- Function to apply a resolved action
						local function apply_action(resolved_action)
							if resolved_action.edit then
								vim.lsp.util.apply_workspace_edit(resolved_action.edit, "utf-8")
							end

							if resolved_action.command then
								local command = resolved_action.command
								if type(command) == "table" and command.command then
									vim.lsp.buf.execute_command(command)
								elseif type(command) == "string" then
									vim.cmd(command)
								end
							end
						end

						-- If action already has edit or command, apply directly
						if action.edit or action.command then
							apply_action(action)
						else
							-- Action needs to be resolved first
							local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
							local resolved = false

							for _, client in ipairs(clients) do
								if client.supports_method("codeAction/resolve") and not resolved then
									resolved = true
									client.request("codeAction/resolve", action, function(err, resolved_action)
										if err then
											vim.notify(
												"Error resolving code action: " .. tostring(err.message or err),
												vim.log.levels.ERROR
											)
											return
										end

										if resolved_action then
											apply_action(resolved_action)
										else
											vim.notify("Code action could not be resolved", vim.log.levels.WARN)
										end
									end)
									break
								end
							end

							-- Fallback if no client supports resolve
							if not resolved then
								vim.notify("No LSP client supports code action resolution", vim.log.levels.WARN)
							end
						end
					end)
				end
			end,
		})
	end)
end

return M
