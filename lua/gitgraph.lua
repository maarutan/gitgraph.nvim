local log = require('gitgraph.log')
local config = require('gitgraph.config')
local highlights = require('gitgraph.highlights')
local core = require('gitgraph.core')

local M = {
  config = config.defaults,

  buf = nil, ---@type integer?
  graph = {}, ---@type I.Row[]
}

--- Setup
---@param user_config I.GGConfig
function M.setup(user_config)
  M.config = vim.tbl_deep_extend('force', M.config, user_config)

  highlights.set_highlights()

  math.randomseed(os.time())

  log.set_level(M.config.log_level)

  -- Set the keymap for toggling GitGraph
  vim.keymap.set('n', M.config.toggle_keymap, function()
    core.toggleGitGraph(M.config)
  end, { desc = 'Toggle GitGraph window' })

  vim.keymap.set('n', M.config.close_key, function()
    core.closeGitGraph(M.config)
  end, { desc = 'quit gitgraph' })

  vim.api.nvim_create_user_command('GitGraph', function()
    core.toggleGitGraph(M.config)
  end, { desc = 'Toggle GitGraph window' })

  -- Register the CloseGitGraph command
  vim.api.nvim_create_user_command('GitGraphClose', function()
    core.closeGitGraph()
  end, { desc = 'Close GitGraph window or buffer' })
end

--- Draws the gitgraph in buffer
---@param options I.DrawOptions
---@param args I.GitLogArgs
---@return nil
function M.draw(options, args)
  return require('gitgraph.draw').draw(M.config, options, args)
end

--- Tests the gitgraph plugin
function M.test()
  local lines, _failure = require('gitgraph.tests').run_tests(M.config.symbols, M.config.format.fields)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)

  local cursor_line = #lines
  vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
end

--- Draws a random gitgraph
function M.random()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  local lines = require('gitgraph.tests').run_random(M.config.symbols, M.config.format.fields)

  vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)

  local cursor_line = 1
  vim.api.nvim_win_set_cursor(0, { cursor_line, 0 })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
end

return M
