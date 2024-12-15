-- paq
local function clone_paq()
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
    local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
    if not is_installed then
        vim.fn.system { 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', path }
        return true
    end
end

local function bootstrap_paq(packages)
    local first_install = clone_paq()
    vim.cmd.packadd('paq-nvim')
    local paq = require('paq')
    if first_install then
        vim.notify('Installing plugins... If prompted, hit Enter to continue.')
    end

    -- Read and install packages
    paq(packages)
    paq.install()
end

bootstrap_paq {
    'savq/paq-nvim',
    'BurntSushi/ripgrep',
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope.nvim', tag = '0.1.8' },
    'nvim-tree/nvim-tree.lua',
    { 'nvim-treesitter/nvim-treesitter', dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' }, build = ':TSUpdate' },
    'tpope/vim-fugitive',
    'kristijanhusak/vim-hybrid-material',
    'ojroques/nvim-bufdel',
    'RRethy/nvim-base16',
    'nvim-tree/nvim-web-devicons',
    'nvim-lualine/lualine.nvim',
    'akinsho/bufferline.nvim',
    'neovim/nvim-lspconfig',
    { 'j-hui/fidget.nvim' },
    'folke/trouble.nvim',
    'lervag/vimtex',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'FabijanZulj/blame.nvim'
}

-- settings
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.updatetime = 50
vim.opt.signcolumn = 'yes'

-- Trim trailing whitespaces on save for all files except markdown
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= "markdown" then
            local save = vim.fn.winsaveview()
            vim.cmd([[silent! %s/\s\+$//e]])
            vim.fn.winrestview(save)
        end
    end,
})

-- remap
vim.g.mapleader = ' '

local opts = { noremap = true };

vim.keymap.set('n', '<TAB>', vim.cmd.bnext, opts)
vim.keymap.set('n', '<S-TAB>', vim.cmd.bprev, opts)
vim.keymap.set('n', 'zs', ':w<CR>')

local function set_wincmd(arg)
    vim.keymap.set('n', '<leader>' .. arg, function() vim.cmd.wincmd(arg) end, opts)
end

set_wincmd('h')
set_wincmd('j')
set_wincmd('k')
set_wincmd('l')

vim.keymap.set('n', '<M-x>', ':')
vim.keymap.set('n', '<leader>jq', ':%!jq<CR>')

-- bufdel
require('bufdel').setup {
    next = 'tabs',
    quit = false
}

vim.keymap.set('n', '<C-x>k', vim.cmd.BufDel, { noremap = true })

-- LSP
local cmp = require('cmp')
cmp.setup({
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
})

require('fidget').setup {}

local lspconfig = require('lspconfig')

local function on_attach(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set('n', '<leader>dg', ':Trouble diagnostics<CR>', opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>mv', vim.lsp.buf.rename, opts)
    vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)

    vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format({ async = false })]]
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local is_in_styx_bare_crates = function()
    return string.match(vim.fn.expand('%:p'), 'styx/bare_crates')
end

lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    on_init = function(client)
        local path = client.workspace_folders[1].name

        if string.match(path, 'styx/kernel') then
            print('executing styx quirks')
            client.config.settings['rust-analyzer'].check.allTargets = false
            client.config.settings['rust-analyzer'].cargo.target = 'x86_64-unknown-none'

            client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
        end

        return true
    end,
    settings = {
        ['rust-analyzer'] = {
            check = {
                allTargets = true,
            },
            checkOnSave = {
                enable = true,
                command = 'clippy',
                extraArgs = { '--target-dir', '/tmp/rust-analyzer-check' }
            },
            cargo = {
                allFeatures = true,
            }
        }
    },
}

lspconfig.taplo.setup {
    capabilities = capabilities,
    on_attach = on_attach
}

lspconfig.clangd.setup {
    capabilities = capabilities,
    on_attach = on_attach
}

lspconfig.gopls.setup {
    capabilities = capabilities,
    on_attach = on_attach
}

lspconfig.zls.setup {
    capabilities = capabilities,
    on_attach = on_attach
}

lspconfig.asm_lsp.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { 'asm', 's', 'S', 'inc' },
}

vim.diagnostic.config {
    virtual_text = false
}

-- lualine

vim.g.base16_no_fallback = true

require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename', },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location', function() return os.date('%H:%M') end }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

-- theme
vim.o.background = 'dark'
vim.cmd.colorscheme('hybrid_reverse')

-- tree
require('nvim-tree').setup {}

vim.keymap.set('n', '<leader>nn', ':NvimTreeToggle<CR>')

-- telescope
local telescope = require('telescope')
local builtin = require('telescope.builtin')

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
vim.keymap.set('n', '<leader>b', builtin.buffers, {})

telescope.setup {
    wrap_results = true,
    color_devicons = false,
    extensions = {}
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
local trouble = require('trouble')
trouble.setup{}
