local api = vim.api

vim.ui.input = function(opts, on_confirm)
  opts = opts or {}
  local prompt = opts.prompt
  local default = opts.default
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, { default })
  api.nvim_buf_set_option(buf, "modifiable", true)
  local win = api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 0,
    col = 1,
    width = 40,
    height = 1,
    style = "minimal",
    border = "rounded",
    title = prompt,
    title_pos = "left"
  })
  vim.keymap.set("i", "<CR>", function()
    local text = table.concat(
      api.nvim_buf_get_lines(buf, 0, -1, false),
      "\n"
    )
    api.nvim_win_close(win, true)
    on_confirm(text ~= "" and text or nil)
  end, { buffer = buf })
  vim.keymap.set("i", "<Esc>", function()
    api.nvim_win_close(win, true)
    on_confirm(nil)
  end, { buffer = buf })
  vim.cmd("startinsert")
end
