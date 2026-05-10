local jishiben = require("jishiben")

vim.api.nvim_create_user_command("JishibenOpen", function()
  jishiben.open()
end, {})

vim.api.nvim_create_user_command("JishibenClear", function()
  jishiben.clear_all()
  vim.notify("Jishiben: all notes cleared")
end, {})
