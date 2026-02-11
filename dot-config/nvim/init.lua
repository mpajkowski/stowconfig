require 'paq' {
    'savq/paq-nvim',
    'neovim/nvim-lspconfig',
    'BurntSushi/ripgrep', -- telescope
    'nvim-lua/plenary.nvim', -- telescope
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-tree.lua',
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', branch = "v0.10.0" },
    'FabijanZulj/blame.nvim',
    'ojroques/nvim-bufdel',
    'nvim-tree/nvim-web-devicons',
    'nvim-lualine/lualine.nvim',
    'linrongbin16/lsp-progress.nvim',
    'kristijanhusak/vim-hybrid-material',
    { 'Saghen/blink.cmp', build = "cargo +nightly build --release", branch = 'v1.9.1' },
    { 'rafamadriz/friendly-snippets' },
}

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
vim.opt.showmode = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.updatetime = 50
vim.opt.signcolumn = 'yes'
vim.opt.undofile = true
vim.opt.winborder = 'rounded'
vim.opt.showtabline = 1

vim.opt.inccommand = "split"

-- Trim trailing whitespaces on save for all files except markdown
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= 'markdown' then
            local save = vim.fn.winsaveview()
            vim.cmd [[silent! %s/\s\+$//e]]
            vim.fn.winrestview(save)
        end
    end,
})

-- Close quickfix list using single 'q'
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'q', function()
      if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd('lclose')
      else
        vim.cmd('cclose')
      end
    end, { buffer = true, silent = true })
  end,
})

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

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local bufnr = ev.buf
        local opts = { buffer = bufnr, remap = false }

        vim.keymap.set('n', '<leader>e', function() vim.diagnostic.setqflist({ open = true }) end, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>mv', vim.lsp.buf.rename, opts)

        if client:supports_method("textDocument/formatting") then
            local augroup = vim.api.nvim_create_augroup("LspFormat." .. bufnr, { clear = true })

            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
})

vim.lsp.enable { 'rust_analyzer' }

vim.lsp.config('rust_analyzer', {
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
    }
})

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
local telescope = require 'telescope'
local builtin = require 'telescope.builtin'
local telescope_themes = require 'telescope.themes'

local find_files = function()
    return builtin.find_files {
        hidden = true,
        file_ignore_patterns = { 'node_modules', '.git', 'target' },
        previewer = false,
    }
end

local live_grep = function()
    return builtin.live_grep {
        hidden = true,
        file_ignore_patterns = { 'node_modules', '.git', 'target' },
    }
end

vim.keymap.set('n', '<leader>pf', find_files, {})
vim.keymap.set('n', '<leader>rg', live_grep, {})
vim.keymap.set('n', '<leader>rr', builtin.resume, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})

telescope.setup {
    wrap_results = true,
    defaults = {
        layout_config = {
          preview_width = 0.6,
        },
    },
}

-- treesitter
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { 'c', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline', 'rust', 'bash', 'lua', 'javascript', 'typescript' },
    sync_install = false,
    auto_install = false,
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
