local jishiben = require("jishiben")

vim.api.nvim_create_user_command("JishibenOpen", function()
  jishiben.open()
end, {})

vim.api.nvim_create_user_command("JishibenNote", function(opts)
  jishiben.add_note(opts.args)
  vim.notify("Jishiben: note captured")
end, { nargs = "*" })

vim.api.nvim_create_user_command("JishibenTodo", function(opts)
  jishiben.add_todo(opts.args)
  vim.notify("Jishiben: todo added")
end, { nargs = "*" })

vim.api.nvim_create_user_command("JishibenClear", function()
  jishiben.clear_all()
  vim.notify("Jishiben: all notes cleared")
end, {})
