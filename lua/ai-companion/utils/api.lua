local M = {}
local api = vim.api
local prompts = require("lua.ai-companion.utils.prompts")

local function set_buffer_lines(lines)
  if api.nvim_buf_is_valid(0) then
    api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end
end

M.get_response = function(selected_text, input)
  local instruction = input
  local prompt_text = instruction .. "\n below is the selected code, \n```" .. selected_text .. "```"
  local api_key = os.getenv("OPENAI_API_KEY")
  if not api_key or api_key == "" then
    vim.notify("OPENAI API KEY is missing", vim.log.levels.ERROR)
    vim.ui.input({ prompt = "Enter openai API key:" }, function(key)
      if key and key ~= "" then
        vim.env.OPENAI_API_KEY = key
        M.get_response(selected_text, key)
      end
    end)
    return
  end

  local payload = vim.json.encode({
    model = "gpt-5-nano",
    input = {
      {
        role = "system",
        content = prompts.system_prompt
      },
      {
        role = "user",
        content = prompt_text
      }
    }
  })

  vim.system({
    "curl",
    "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer " .. api_key,
    "-d", payload,
    "https://api.openai.com/v1/responses"
  }, {
    text = true,
  }, function(res)
    local data = vim.json.decode(res.stdout)
    local response_code = data and data.output and data.output[2] and data.output[2].content and
        data.output[2].content[1] and data.output[2].content[1].text
    if not response_code then
      vim.schedule(function()
        vim.notify("Failed to parse OpenAI response", vim.log.levels.ERROR)
      end)
      return
    end
    local lines = vim.split(response_code, "\n", { plain = true })
    vim.schedule(function()
      set_buffer_lines(lines)
    end)
  end)
end

return M
