--[[
  A Neovim function to copy a visual selection and its associated
  LSP diagnostics to a new scratch buffer.
--]]

local M = {}

local severity_map = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARNING",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

--- Copies the current visual selection and its diagnostics to a new scratch buffer.
function M.copy_selection_with_diagnostics()
  -- Get the start and end line numbers of the visual selection.
  -- getpos() returns 1-based line numbers.
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Check if there is a valid selection.
  if start_line == 0 or end_line == 0 then
    vim.notify("No visual selection found.", vim.log.levels.WARN)
    return
  end

  -- We use the current buffer, which is buffer 0.
  local bufnr = 0

  -- Get the lines of text from the visual selection.
  -- nvim_buf_get_lines uses 0-based indexing, so we subtract 1.
  local selected_text = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  -- Get all diagnostics for the current buffer.
  local diagnostics = vim.diagnostic.get(bufnr)
  local relevant_diagnostics = {}

  -- Filter diagnostics to include only those within the selected lines.
  for _, diag in ipairs(diagnostics) do
    -- diag.lnum is 0-based.
    if diag.lnum >= start_line - 1 and diag.lnum <= end_line - 1 then
      table.insert(relevant_diagnostics, diag)
    end
  end

  -- Prepare the content for the new buffer.
  local new_buffer_content = {}
  vim.list_extend(new_buffer_content, selected_text)

  -- If we found any diagnostics, format them and add them to the content.
  if #relevant_diagnostics > 0 then
    table.insert(new_buffer_content, "") -- Add a blank line for separation.
    table.insert(new_buffer_content, "--- LSP Diagnostics ---")

    for _, diag in ipairs(relevant_diagnostics) do
      local severity_str = severity_map[diag.severity] or "UNKNOWN"
      -- Format the diagnostic message. Add 1 to diag.lnum for 1-based display.
      local formatted_diag = string.format(
        "[%s] Line %d: %s (%s)",
        severity_str,
        diag.lnum + 1,
        diag.message,
        diag.source or "lsp"
      )
      table.insert(new_buffer_content, formatted_diag)
    end
  end

  -- Create a new vertical split for our scratch buffer.
  vim.cmd('vnew')

  -- Configure the new buffer to be a scratch buffer.
  vim.api.nvim_buf_set_option(0, 'buftype', 'nofile') -- Not associated with a file.
  vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe') -- Wipe it when hidden.
  vim.api.nvim_buf_set_option(0, 'swapfile', false)  -- No swap file.
  vim.api.nvim_buf_set_option(0, 'filetype', vim.bo[bufnr].filetype) -- Inherit filetype for syntax highlighting.

  -- Set the content of the new scratch buffer.
  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_buffer_content)

  vim.notify("Copied selection with diagnostics to new scratch buffer.", vim.log.levels.INFO)
end

--- Sets up the command and keymap for the functionality.
function M.setup()
  -- Create a user command.
  vim.api.nvim_create_user_command(
    'Prompt',
    M.copy_selection_with_diagnostics,
    { range = true } -- The range allows it to work on visual selections.
  )
end

return M
