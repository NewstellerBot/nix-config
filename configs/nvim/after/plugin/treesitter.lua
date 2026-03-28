-- Install parsers
require('nvim-treesitter').install {
    'python', 'javascript', 'typescript', 'rust', 'c', 'lua', 'go',
    'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline',
}

-- Enable treesitter highlighting via Neovim core
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        if vim.treesitter.get_parser(0, nil, { error = false }) then
            vim.treesitter.start()
        end
    end,
})
