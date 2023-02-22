local oatjump = {}
local config = {
    separators = { ' ', '_', "-", "/", "\\" },
    keymaps = {
        forward = "<C-l>",
        backward = "<C-h>",
    },
}

local function forward (str, pos)
  local rest_of_line = string.sub(str, pos, string.len(str))
  local min_val = vim.fn.strdisplaywidth(rest_of_line)
  for _, c in pairs(config['separators']) do
    if string.find(rest_of_line, c) then
      min_val = math.min(min_val, string.find(rest_of_line, c))
    end
  end
  return pos + min_val - 1
end

local function backward (str, pos)
  local start_of_line = string.reverse(string.sub(str, 1, pos))
  local min_val = pos
  for _, c in pairs(config['separators']) do
    if string.find(start_of_line, c) then
      min_val = math.min(min_val, string.find(start_of_line, c))
    end
  end
  return pos - min_val
end

function oatjump.locate_next()
    local new_pos_x
    local new_pos_y
    local current_buf = vim.api.nvim_get_current_buf()
    local window = vim.api.nvim_get_current_window()
    local pos = vim.api.nvim_win_get_cursor(window)
    local current_line = vim.api.nvim_buf_get_lines(current_buf, pos[2], pos[2] + 1, false)[1]
    if pos[1] >= string.length(current_line) then
        new_pos_x = 1
        new_pos_y = pos[2] + 1
    else
        new_pos_x = forward(current_line, pos[1])
        new_pos_y = pos[2]
    end
    return new_pos_x, new_pos_y
end

function oatjump.locate_prev()
    local new_pos_x
    local new_pos_y
    local current_buf = vim.api.nvim_get_current_buf()
    local window = vim.api.nvim_get_current_window()
    local pos = vim.api.nvim_win_get_cursor(window)
    local current_line = vim.api.nvim_buf_get_lines(current_buf, pos[2], pos[2] + 1, false)[1]
    if pos[1] <= 1 then
        local previous_line = vim.api.nvim_buf_get_lines(current_buf, pos[2] - 1, pos[2], false)[1]
        new_pos_x = vim.fn.strdisplaywidth(previous_line)
        new_pos_y = pos[2] - 1
    else
        new_pos_x = backward(current_line, pos[1])
        new_pos_y = pos[2]
    end
    return new_pos_x, new_pos_y
end

function oatjump.setup(user_config)
    user_config = user_config or {}
    for option, value in pairs(user_config) do
        config[option] = value
    end

    vim.keymap.set({"n", "v"}, config["forward"], "<Cmd>lua require('oatjump').locate_next()<CR>", {})
    vim.keymap.set({"n", "v"}, config["backward"], "<Cmd>lua require('oatjump').locate_prev()<CR>", {})
end

return oatjump
