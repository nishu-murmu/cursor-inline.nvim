local M = {}
local api = vim.api
local config = require("ai-companion.config")
local commandBuf = require("ai-companion.components.command")
local input_prompt_buf = require("ai-companion.components.input-prompt")

local ns = api.nvim_create_namespace("key-listener")

M.setup = function(user_config)
  vim.tbl_deep_extend("force", config, user_config)
end

api.nvim_create_autocmd("ModeChanged", {
  pattern = "n:[vV\22]",
  callback = function()
    commandBuf.create_command_buf()
  end,
})

api.nvim_create_autocmd("ModeChanged", {
  pattern = "[vV\22]:n",
  callback = commandBuf.close_command_buf,
})


api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    if vim.fn.mode():match("[vV\22]") then
      commandBuf.move_floating_buf()
    end
  end,
})

vim.on_key(function(key)
  if key == "\v" then
    commandBuf.close_command_buf()
    input_prompt_buf.create_input_prompt_buf()
  end
  if key == "\r" and input_prompt_buf.is_current_buffer() then
    P(input_prompt_buf.get_input_prompt_text_content())
    input_prompt_buf.close_input_prompt_buf()
  end
end, ns)

return M
