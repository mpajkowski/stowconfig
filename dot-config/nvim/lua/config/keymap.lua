vim.g.mapleader = ' '

local opts = { noremap = true, silent = true };

vim.keymap.set('n', '<TAB>', vim.cmd.bnext, opts)
vim.keymap.set('n', '<S-TAB>', vim.cmd.bprev, opts)
vim.keymap.set('n', 'zs', ':w<CR>')

vim.keymap.set('n', '<M-x>', ':')
vim.keymap.set('n', '<leader>fjq', ':%!jq<CR>')

vim.keymap.set('n', '<leader>h', '<C-w>h', opts)
vim.keymap.set('n', '<leader>j', '<C-w>j', opts)
vim.keymap.set('n', '<leader>k', '<C-w>k', opts)
vim.keymap.set('n', '<leader>l', '<C-w>l', opts)

vim.keymap.set('n', '<leader>q', ':copen<CR>', opts)
vim.keymap.set('n', ']q', ':cnext<CR>', opts)
vim.keymap.set('n', '[q', ':cprev<CR>', opts)

