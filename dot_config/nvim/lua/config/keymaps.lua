--------------------------------------------------------------------------------
--- GENERAL
--------------------------------------------------------------------------------
-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')


--------------------------------------------------------------------------------
--- NAVIGATION
--------------------------------------------------------------------------------
vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "Go to Left Split" })
vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "Go to Down Split" })
vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "Go to Up Split" })
vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "Go to Right Split" })


vim.keymap.set("n", "<C-h>", "<C-w>H", { desc = "Move Split Left" })
vim.keymap.set("n", "<C-j>", "<C-w>J", { desc = "Move Split Down" })
vim.keymap.set("n", "<C-k>", "<C-w>K", { desc = "Move Split Up" })
vim.keymap.set("n", "<C-l>", "<C-w>L", { desc = "Move Split Right" })

-- Navigate quickfix items easily
vim.keymap.set("n", "<leader>n", ":cnext<CR>", { desc = "Next selected file" })
vim.keymap.set("n", "<leader>p", ":cprev<CR>", { desc = "Previous selected file" })
vim.keymap.set("n", "<leader>x", ":bp | sp | bn | bd<CR>:cnext<CR>", { desc = "Close and open next file" })

--------------------------------------------------------------------------------
--- CODE
--------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

