local M = {}
local config = require("ai-companion.utils.config")
require("ai-companion.utils.autocmd")

M.setup = function(user_config)
  vim.tbl_deep_extend("force", config, user_config)
end

return M
