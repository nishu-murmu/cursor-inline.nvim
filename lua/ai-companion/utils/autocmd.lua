local api = vim.api
local command = require("ai-companion.ui.command")
require("ai-companion.ui.input")
local utils = require("ai-companion.utils")
local api_service = require("lua.ai-companion.utils.api")
local ns = api.nvim_create_namespace("key-listener")
local selected_text = ""

api.nvim_create_autocmd("ModeChanged", {
  pattern = "n:[vV\22]",
  callback = function()
    command.create_command_buf()
  end,
})

api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV\22]:n",
  callback = function()
    command.close_command_buf()
    local lines = utils.get_visual_selection()
    selected_text = table.concat(lines, "\n")
  end
})

api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    if vim.fn.mode():match("[vV\22]") then
      command.move_floating_buf()
    end
  end,
})


vim.on_key(function(key)
  if key == "\v" then
    command.close_command_buf()
    vim.ui.input({ prompt = "Enter prompt:" }, function(input)
      if input then
        api_service.get_response(selected_text, input)
        vim.cmd("stopinsert")
      end
    end)
  end
end, ns)
