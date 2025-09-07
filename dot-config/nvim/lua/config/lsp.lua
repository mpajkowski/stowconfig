vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local bufnr = ev.buf
        local opts = { buffer = bufnr, remap = false }

        vim.keymap.set('n', '<leader>e', ":Trouble diagnostics<CR>", opts)
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
