-- NEOVIM AUTOPAIR
-- A basic implementation of an auto-closing pair plugin for Neovim.
-- When a user inputs the opening character of a pair, i.e. (, {, ', ", <, [,
-- it will be automatically closed with it's matching pair.
-- Features:
--     - Automatically deletes the pair if the cursor is between the pair.
--     - Formats a <CR> input for (, {, and [ to put the closing character on
--     	 a separate line and auto-indents your cursor.
-- Future features:
--     - Ignores the closing character input if you accidentally type it.

local autopairs = {
	["("] = ")",
	["{"] = "}",
	["\""] = "\"",
	["'"] = "'",
	["<"] = ">",
	["["] = "]"
}

local cr_autopairs = {
	["("] = ")",
	["{"] = "}",
	["["] = "]"
}

local M = {}

M.setup = function()
	vim.api.nvim_create_autocmd("InsertCharPre", {
		callback = function()
			if autopairs[vim.v.char]
			then
				vim.v.char = vim.v.char .. autopairs[vim.v.char]
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Left>', true, false, true), 'n', false)
			end
		end
	})


	-- Gets the surrounding characters from the cursor position.
	-- Returns a tuple of (prev, next)
	local function get_surrounding_characters()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local current_line_content = vim.api.nvim_get_current_line()
		if cursor[2] == 0
		then
			return nil
		end
		local previous_char = current_line_content:sub(cursor[2], cursor[2])
		local next_char = current_line_content:sub(cursor[2] + 1, cursor[2] + 1)
		return previous_char, next_char
	end

	-- Formats <CR> input when in-between an autopair.
	-- Adds an addition <CR> and auto indents your cursor.
	-- Returns a vim key mapping to set <CR> to.
	local function get_formatted_autopair_cr()
		local prev_char, next_char = get_surrounding_characters()
		for left, right in pairs(cr_autopairs) do
			if (left == prev_char and right == next_char)
			then
				return '<CR><CR>'
			end
		end
		return '<CR>'
	end

	-- Deletes a pair when cursor is in-between.
	local function delete_autopair()
		local prev_char, next_char = get_surrounding_characters()
		for left, right in pairs(autopairs) do
			if (left == prev_char and right == next_char)
			then
				return '<BS><Del>'
			end
		end
		return '<BS>'
	end

	vim.keymap.set('i', '<CR>', get_formatted_autopair_cr, {
		expr = true, noremap = true, desc = "Formats <CR> input in-between autopair."
	})

	vim.keymap.set('i', '<BS>', delete_autopair, {
		expr = true, noremap = true, desc = "Deletes an autopair if cursor is in-between."
	})
end

return M
