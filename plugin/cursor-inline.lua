if vim.g.loaded_ai_companion then
  return
end

vim.g.loaded_ai_companion = true

local ok, ai_companion = pcall(require, "cursor-inline")
if not ok then
  return
end

ai_companion.setup()
