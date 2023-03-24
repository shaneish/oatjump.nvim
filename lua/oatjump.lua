local M = {}

local config = {
    separators = {' ', '-', '_', '.', '/', '\t', '\\'},
    keymaps = {
        forward = "<C-l>",
        backward = "<C-h>",
    },
}

local function char_is_in_array(char, array)
    for _, value in ipairs(array) do
        if char == value then
            return true
        end
    end
    return false
end

local function get_separator_pattern()
    local adjusted_separators = {}
    local special_chars = {'-', '%', '^', '$', '.', '[', ']', '*', '+', '?', '(', ')', '{', '}'}
    for _, separator in ipairs(M.separators) do
        if char_is_in_array(separator, special_chars) then
            table.insert(adjusted_separators, "%"..separator)
        else
            table.insert(adjusted_separators, separator)
        end
    end
    local separator_pattern = "[^"..table.concat(adjusted_separators, "").."]["..table.concat(adjusted_separators, "").."]"
    return separator_pattern
end

function M.jump_to_next()
    local current_line = vim.api.nvim_get_current_line()
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor_position[1], cursor_position[2]
    local line_length = vim.fn.strdisplaywidth(current_line) - 1
    if col >= line_length then
        if row < vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, {row + 1, 0})
        end
    else
        local search_pattern = get_separator_pattern()
        local next_pos = string.find(current_line, search_pattern, col + 1)

        if next_pos then
            vim.api.nvim_win_set_cursor(0, {row, next_pos})
        else
            vim.api.nvim_win_set_cursor(0, {row, line_length})
        end
    end
end

function M.jump_to_prev()
    local current_line = vim.api.nvim_get_current_line()
    local cursor_position = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor_position[1], cursor_position[2]
    if col == 0 then
        if row > 1 then
            local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
            local prev_line_length = vim.fn.strdisplaywidth(prev_line)
            vim.api.nvim_win_set_cursor(0, {row - 1, prev_line_length})
        end
    else
        local search_pattern = get_separator_pattern()
        local search_index = col - 1
        local prev_pos = nil

        while search_index > 0 do
            if string.sub(current_line, search_index, search_index + 1):match(search_pattern) then
                prev_pos = search_index
                break
            end
            search_index = search_index - 1
        end

        if prev_pos then
            vim.api.nvim_win_set_cursor(0, {row, prev_pos})
        else
            vim.api.nvim_win_set_cursor(0, {row, 0})
        end
    end
end

function M.setup(user_config)
    user_config = user_config or {}
    for option, value in pairs(user_config) do
        config[option] = value
    end

    M.separators = config['separators']
    vim.keymap.set({"n", "v"}, config["keymaps"]["forward"], function() M.jump_to_next() end, {})
    vim.keymap.set({"n", "v"}, config["keymaps"]["backward"], function() M.jump_to_prev() end, {})
end

return M
