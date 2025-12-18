local M = {}
local bufnr = nil
local win_id = nil
local api = vim.api

M.move_input_prompt_buf = function()
  if not win_id or not api.nvim_win_is_valid(win_id) then
    return
  end

  api.nvim_win_set_config(win_id, {
    relative = "cursor",
    row = 1,
    col = 0,
  })
end

M.close_input_prompt_buf = function()
  if win_id and api.nvim_win_is_valid(win_id) then
    api.nvim_win_close(win_id, true)
  end
  if bufnr and api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
  win_id = nil
  bufnr = nil
end

M.get_input_prompt_text_content = function()
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return unpack(lines)
end

M.is_current_buffer = function()
  return api.nvim_get_current_buf() == bufnr
end

M.create_input_prompt_buf = function()
  if win_id and api.nvim_win_is_valid(win_id) then
    return
  end
  bufnr = api.nvim_create_buf(false, true)
  local PLACEHOLDER = "Enter your prompt"
  api.nvim_buf_set_lines(bufnr, 0, -1, false, { PLACEHOLDER })
  win_id = api.nvim_open_win(bufnr, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = 30,
    height = 1,
    style = "minimal",
    border = "rounded"
  })
  vim.cmd("startinsert")
  api.nvim_set_hl(0, "PopupPlaceholder", {
    fg = "#6a737d",
    italic = true,
  })

  api.nvim_buf_add_highlight(bufnr, -1, "PopupPlaceholder", 0, 0, -1)
  local cleared = false
  api.nvim_create_autocmd("InsertCharPre", {
    buffer = bufnr,
    once = true,
    callback = function()
      local char = vim.v.char
      if cleared then return end
      cleared = true
      vim.schedule(function()
        api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
        api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
      end)
    end
  })
end

return M
