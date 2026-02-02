require 'paq' {
    'savq/paq-nvim',
    'neovim/nvim-lspconfig',
    'BurntSushi/ripgrep', -- telescope
    'nvim-lua/plenary.nvim', -- telescope
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8' },
    'nvim-tree/nvim-tree.lua',
    { 'nvim-treesitter/nvim-treesitter', dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' }, build = ':TSUpdate' },
    'FabijanZulj/blame.nvim',
    'ojroques/nvim-bufdel',
    'nvim-tree/nvim-web-devicons',
    'nvim-lualine/lualine.nvim',
    'linrongbin16/lsp-progress.nvim',
    'kristijanhusak/vim-hybrid-material',
    { 'Saghen/blink.cmp', build = "cargo build --release", tag = 'v1.7.0' },
    { 'rafamadriz/friendly-snippets' },
}

-- theme
vim.opt.termguicolors = true
vim.opt.background = dark
vim.cmd.colorscheme 'hybrid_reverse'

-- bufdel
require 'bufdel'.setup {
    next = 'tabs',
    quit = false
}

vim.keymap.set('n', '<C-x>k', vim.cmd.BufDel, { noremap = true })

-- tree
require 'nvim-tree'.setup {}
vim.keymap.set('n', '<leader>nn', vim.cmd.NvimTreeToggle, { noremap = true })

-- telescope
local telescope = require 'telescope';
local builtin = require 'telescope.builtin';

local find_files = function()
    return builtin.find_files {
        hidden = true,
        file_ignore_patterns = { 'node_modules', '.git', 'target' }
    }
end

local live_grep = function()
    return builtin.live_grep {
        hidden = true,
        file_ignore_patterns = { 'node_modules', '.git', 'target' }
    }
end

vim.keymap.set('n', '<leader>pf', find_files, {})
vim.keymap.set('n', '<leader>rg', live_grep, {})
vim.keymap.set('n', '<leader>rr', builtin.resume, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})

telescope.setup {
    wrap_results = true,
}

-- treesitter
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { 'c', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'rust', 'bash', 'lua', 'javascript', 'typescript' },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}


-- lualine
local lualine = require 'lualine'
local lsp_progress = require 'lsp-progress'

lualine.setup {
    options = {
        theme = 'onedark',
        always_show_tabline = true,
    },
    sections = {
        lualine_c = { lsp_progress.progress }
    },
    tabline = {
        lualine_a = { 'buffers' }
    },
}

vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup('lualine_augroup', { clear = true }),
    pattern = "LspProgressStatusUpdated",
    callback = lualine.refresh,
})

vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})

lsp_progress.setup {
    series_format = function(title, message, percentage, done)
        local has_title = (type(title) == "string" and string.len(title) > 0)
        local has_message = (type(message) == "string" and string.len(message) > 0)

        if not(has_title or has_message) then
            return nil
        end

        local builder = {}

        if percentage then
            table.insert(builder, string.format("(%.0f%%)", percentage))
        end

        if has_title then
            table.insert(builder, title)
        end

        if has_message then
            table.insert(builder, message)
        end

        if done then
            table.insert(builder, "- done")
        end

        return table.concat(builder, " ")
    end,
}

-- blink.cmp
require 'blink.cmp'.setup {
  keymap = { preset = "enter" },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  }
}

-- blame
require 'blame'.setup {
    blame_options = { '-w' },
}
