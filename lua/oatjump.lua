local M = {}

local config = {
    keymaps = {
        forward = "<C-l>",
        backward = "<C-h>",
    },
    word_marker = "a-zA-Z0-9",
}

function M.next_word(col, line, initial)
  if (col ~= 1) or (string.find(string.sub(line, 1, 1), M.word_start, 1) == nil) or not initial then
    print(col, string.sub(line, 1, 1))
    local next_pos = string.find(line, M.word_pat, col)
    if next_pos then
      return next_pos
    end
  else
    return 0
  end
end

function M.prev_word(col, line, initial)
  local line_length = vim.fn.strdisplaywidth(line)
  if (col + 1 ~= line_length) or (string.find(string.sub(line, line_length, line_length), M.word_start, 1) == nil) or not initial then
    print(col, line_length, string.sub(line, line_length, line_length))
    local prev_word = string.find(string.reverse(string.sub(line, 1, col)), M.word_pat, 1)
    if prev_word then
      return col - prev_word - 1
    end
  else
    return col
  end
end

function M.jump_to_next(initial)
  local current_line = vim.api.nvim_get_current_line()
  local cursor_position = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor_position[1], cursor_position[2]
  local line_length = vim.fn.strdisplaywidth(current_line) - 1
  local next_pos = M.next_word(col + 1, current_line, initial)
  if next_pos then
    vim.api.nvim_win_set_cursor(0, {row, next_pos})
  else
    if row < vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, {row + 1, 0})
      M.jump_to_next(true)
    end
  end
end

function M.jump_to_prev(initial)
  local current_line = vim.api.nvim_get_current_line()
  local cursor_position = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor_position[1], cursor_position[2]
    local prev_pos = M.prev_word(col, current_line, initial)
    local other_prev_pos = M.prev_word(col + 1, current_line, initial)
    if prev_pos then
      if other_prev_pos then
        if prev_pos < other_prev_pos then
          prev_pos = other_prev_pos
        end
      end
    elseif other_prev_pos then
      prev_pos = other_prev_pos
    end
    if prev_pos then
      vim.api.nvim_win_set_cursor(0, {row, prev_pos})
    else
      if row > 1 then
        local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
        local prev_line_length = vim.fn.strdisplaywidth(prev_line)
          vim.api.nvim_win_set_cursor(0, {row - 1, prev_line_length})
          M.jump_to_prev(true)
      end
    end
end

function M.setup(user_config)
    user_config = user_config or {}
    for option, value in pairs(user_config) do
        config[option] = value
    end

    M.separators = config["separators"]
    M.word_pat = "[^" .. config['word_marker'] .. "][" .. config['word_marker'] .. "]"
    M.word_start = "[" .. config['word_marker'] .. "]"
    vim.keymap.set("n", config["keymaps"]["forward"], function() M.jump_to_next(false) end, {})
    vim.keymap.set("n", config["keymaps"]["backward"], function() M.jump_to_prev(false) end, {})
    vim.keymap.set("i", config["keymaps"]["forward"], function() M.jump_to_next(false) end, {})
    vim.keymap.set("i", config["keymaps"]["backward"], function() M.jump_to_prev(false) end, {})
end

return M
