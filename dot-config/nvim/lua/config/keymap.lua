vim.g.mapleader = ' '

local opts = { noremap = true, silent = true };

vim.keymap.set('n', '<TAB>', vim.cmd.bnext, opts)
vim.keymap.set('n', '<S-TAB>', vim.cmd.bprev, opts)
vim.keymap.set('n', 'zs', ':w<CR>')

vim.keymap.set('n', '<M-x>', ':')
vim.keymap.set('n', '<leader>fjq', ':%!jq<CR>')

vim.keymap.set('n', '<leader>j', vim.cmd.cnext, opts)
vim.keymap.set('n', '<leader>k', vim.cmd.cprev, opts)
