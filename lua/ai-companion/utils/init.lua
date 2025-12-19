local M = {}
local api = vim.api
M.get_visual_selection = function()
  local bufnr = 0
  local mode = vim.fn.visualmode()

  local start = api.nvim_buf_get_mark(bufnr, "<")
  local finish = api.nvim_buf_get_mark(bufnr, ">")

  local start_row, start_col = start[1], start[2]
  local end_row, end_col = finish[1], finish[2]

  -- Normalize order
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  local lines = api.nvim_buf_get_lines(
    bufnr,
    start_row - 1,
    end_row,
    false
  )

  if #lines == 0 then
    return {}
  end

  if mode == "v" then
    -- character-wise
    lines[1] = string.sub(lines[1], start_col + 1)
    lines[#lines] = string.sub(lines[#lines], 1, end_col + 1)

  elseif mode == "V" then
    -- line-wise (nothing to trim)
    return lines

  elseif mode == "\22" then
    -- block-wise (CTRL-V)
    for i, line in ipairs(lines) do
      lines[i] = string.sub(line, start_col + 1, end_col + 1)
    end
  end

  return lines
end

return M
