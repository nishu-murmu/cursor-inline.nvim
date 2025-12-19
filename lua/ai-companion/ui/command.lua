local M = {}
local bufnr = nil
local win_id = nil
local api = vim.api

M.create_command_buf = function()
  if win_id and api.nvim_win_is_valid(win_id) then
    return
  end
  bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Quick Edit (Ctrl+K)" })
  win_id = api.nvim_open_win(bufnr, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = 20,
    height = 1,
    style = "minimal",
  })
end

M.move_floating_buf = function()
  if not win_id or not api.nvim_win_is_valid(win_id) then
    return
  end

  api.nvim_win_set_config(win_id, {
    relative = "cursor",
    row = 1,
    col = 0,
  })
end

M.close_command_buf = function()
  if win_id and api.nvim_win_is_valid(win_id) then
    api.nvim_win_close(win_id, true)
  end
  if bufnr and api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
  win_id = nil
  bufnr = nil
end

M.create_input_prompt_buf = function()
  if win_id and api.nvim_win_is_valid(win_id) then
    return
  end
  bufnr = api.nvim_create_buf(false, true)
  win_id = api.nvim_open_win(bufnr, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = 30,
    height = 1,
    style = "minimal",
    border = "rounded"
  })
end

return M
