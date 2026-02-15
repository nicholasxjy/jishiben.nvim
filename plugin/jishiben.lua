local jishiben = require("jishiben")

vim.api.nvim_create_user_command("JishibenOpen", function()
  jishiben.open()
end, {})

vim.api.nvim_create_user_command("JishibenAdd", function(opts)
  local ok = jishiben.add_note(opts.args)
  if not ok then
    vim.notify("Jishiben: empty input, ignored", vim.log.levels.WARN)
  end
end, { nargs = "*" })

vim.api.nvim_create_user_command("JishibenToggle", function()
  local ok = jishiben.toggle_item()
  if not ok then
    vim.notify("Jishiben: not in a jishiben popup", vim.log.levels.WARN)
  end
end, {})

vim.api.nvim_create_user_command("JishibenPick", function()
  require("jishiben.picker").open()
end, {})

vim.api.nvim_create_user_command("JishibenClear", function()
  jishiben.clear_all()
  vim.notify("Jishiben: all notes cleared")
end, {})
