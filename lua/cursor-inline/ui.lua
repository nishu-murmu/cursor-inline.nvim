local M = {}

local api = vim.api
local config = require("cursor-inline.config")

local bufnr, win_id
local input_overridden

local function override_vim_input()
  if input_overridden then return end
  input_overridden = true
  vim.ui.input = function(opts, on_confirm)
    opts = opts or {}
    local prompt = opts.prompt
    local default = opts.default or ""
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(buf, 0, -1, false, { default })
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

    local win_opts = {
      relative = "cursor",
      row = 0,
      col = 1,
      width = 40,
      height = 1,
      style = "minimal",
      border = "rounded",
      title = prompt,
      title_pos = "left",
    }

    local win = api.nvim_open_win(buf, true, win_opts)


    local function confirm()
      local text = table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      api.nvim_win_close(win, true)
      on_confirm(text ~= "" and text or nil)
    end

    vim.keymap.set("i", "<CR>", confirm, { buffer = buf })
    vim.keymap.set("i", "<Esc>", function()
      api.nvim_win_close(win, true)
      on_confirm(nil)
      vim.cmd("stopinsert")
    end, { buffer = buf })
    vim.cmd("startinsert")
  end
end

function M.open_inline_command()
  if win_id and api.nvim_win_is_valid(win_id) then return end

  bufnr = api.nvim_create_buf(false, true)
  local open_input = config.mappings.open_input or ""
  api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Quick Edit (" .. open_input .. ")" })

  win_id = api.nvim_open_win(bufnr, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = 24,
    height = 1,
    style = "minimal",
  })
end

function M.move_inline_command()
  if not (win_id and api.nvim_win_is_valid(win_id)) then return end

  api.nvim_win_set_config(win_id, {
    relative = "cursor",
    row = 1,
    col = 0,
  })
end

function M.close_inline_command()
  if win_id and api.nvim_win_is_valid(win_id) then
    api.nvim_win_close(win_id, true)
  end
  if bufnr and api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
  win_id, bufnr = nil, nil
end

function M.open_post_response_commands(row, lines, width, zindex, existing_bufnr)
  local buf = existing_bufnr or api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, { lines })
  local win = api.nvim_open_win(buf, false, {
    relative = "editor",
    row = row,
    col = vim.o.columns - width,
    width = width,
    height = 1,
    style = "minimal",
    zindex = zindex,
    focusable = false,
    noautocmd = true,
  })
  local ns = api.nvim_create_namespace('')
  api.nvim_win_set_hl_ns(win, ns)
  return win, buf
end

function M.close_post_response_commands(win)
  if win and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
end

function M.setup()
  override_vim_input()
end

return M
