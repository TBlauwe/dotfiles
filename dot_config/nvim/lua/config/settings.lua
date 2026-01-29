--------------------------------------------------------------------------------
--- GLOBAL SETTINGS
--------------------------------------------------------------------------------
vim.g.mapleader 	      = ' '
vim.g.maplocalleader    = "\\"
vim.g.have_nerd_font    = true

vim.opt.number 		      = true
vim.opt.relativenumber 	= true

vim.opt.tabstop 	      = 2       -- How many spaces are shown per Tab
vim.opt.softtabstop 	  = 2       -- How many spaces are applied per Tab
vim.opt.shiftwidth 	    = 2       -- Amount to indent with << and >>
vim.opt.expandtab 	    = true    -- Convert tabs to spaces
vim.opt.smarttab        = true
vim.opt.smartindent     = true
vim.opt.autoindent      = true

vim.opt.cursorline      = true    -- Show line under cursor
vim.opt.showmode        = false   -- Already show by the statusline
vim.opt.breakindent     = true

vim.opt.undofile        = true    -- Store undo between sessions

vim.opt.updatetime      = 250     -- Decrease update time
vim.opt.timeoutlen      = 300     -- Decrease mapped sequence wait time

vim.opt.signcolumn      = 'yes'   -- Always show signcolumn even if no icons.

vim.opt.ignorecase      = true    -- Case-insensitive searching unless \C
vim.opt.smartcase       = true    -- or one or more capitals letters

vim.opt.splitright      = true
vim.opt.splitbelow      = true

vim.opt.scrolloff       = 10      -- Minimal number of lines to keep above or
                                  -- below the cursor when scrolling

vim.o.inccommand        = 'split' -- Preview substitutions live, as you type!

vim.o.list = true                 -- Display whitespace characters in the editor.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }


--------------------------------------------------------------------------------
--- MISCELLENEAOUS
--------------------------------------------------------------------------------
vim.schedule(function()
  vim.o.clipboard = "unnamedplus" -- Sync clipboard between OS and NVim
end)


-- Highlight text for some time after yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", {clear = true}),
  pattern = "*",
  callback = function ()
    vim.highlight.on_yank();
  end,
  desc = "Highlight yank",
})


-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- syntax highlighting for dotenv files
vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})

-- show cursorline only in active window enable
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

-- show cursorline only in active window disable
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = "active_cursorline",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- ide like highlight when stopping cursor
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true }),
	desc = "Highlight references under cursor",
	callback = function()
		-- Only run if the cursor is not in insert mode
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true
					break -- Found a supporting client, no need to check others
				end
			end

			-- 3. Proceed only if an LSP is active AND supports the feature
			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})

-- ide like highlight when stopping cursor
vim.api.nvim_create_autocmd("CursorMovedI", {
	group = "LspReferenceHighlight",
	desc = "Clear highlights when entering insert mode",
	callback = function()
		vim.lsp.buf.clear_references()
	end,
})
