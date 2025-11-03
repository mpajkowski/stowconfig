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
    'folke/trouble.nvim',
    'nvim-lualine/lualine.nvim',
    'linrongbin16/lsp-progress.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
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
local lualine = require 'lualine'
local lsp_progress = require 'lsp-progress'

lualine.setup {
    options = {
        always_show_tabline = true,
    },
    sections = {
        lualine_c = { lsp_progress.lualine }
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

-- cmp
local cmp = require 'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }
    },
    sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'vsnips' },
        { name = 'path' },
        { name = 'buffer' },
    },
}
