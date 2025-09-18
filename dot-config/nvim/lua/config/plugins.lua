require 'paq' {
    'savq/paq-nvim',
    'neovim/nvim-lspconfig',
    'BurntSushi/ripgrep', -- telescope
    'nvim-lua/plenary.nvim', -- telescope
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8' },
    'nvim-tree/nvim-tree.lua',
    { 'nvim-treesitter/nvim-treesitter', dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' }, build = ':TSUpdate' },
    'FabijanZulj/blame.nvim',
    'rebelot/kanagawa.nvim',
    'ojroques/nvim-bufdel',
    'nvim-tree/nvim-web-devicons',
    { 'saghen/blink.cmp', tag = "1.*", build = "cargo build --release" },
    { 'folke/trouble.nvim' },
    { 'nvim-lualine/lualine.nvim' },
}


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

-- blink
require 'blink.cmp'.setup {
    keymap = { preset = 'enter' }
}

-- trouble
require 'trouble'.setup {}

-- theme
require 'kanagawa'.setup {
    colors = {
        theme = {
            all = {
                ui = {
                    bg_gutter = "none"
                }
            }
        }
    },
    overrides = function(colors)
        local theme = colors.theme
        return {
            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = theme.ui.bg_p1 },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
            TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
            TelescopePreviewNormal = { bg = theme.ui.bg_dim },
            TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
        }
    end,
}

vim.cmd.colorscheme 'kanagawa-dragon'

-- lualine

require('lualine').setup {
    theme = 'kanagawa-dragon',
    options = {
        always_show_tabline = true,
    },
    tabline = {
        lualine_a = { 'buffers' }
    },
}
