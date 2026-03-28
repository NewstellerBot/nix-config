local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

if cmp_nvim_lsp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "grt")
pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "x", "gra")

local lsp_group = vim.api.nvim_create_augroup("krystian-lsp-keymaps", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_group,
    callback = function(args)
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, {
                buffer = args.buf,
                silent = true,
                desc = desc,
            })
        end

        map("n", "gd", vim.lsp.buf.definition, "LSP: go to definition")
        map("n", "gr", vim.lsp.buf.references, "LSP: show references")
        map("n", "gi", vim.lsp.buf.implementation, "LSP: go to implementation")
        map("n", "gt", vim.lsp.buf.type_definition, "LSP: go to type definition")
        map("n", "<leader>mv", vim.lsp.buf.rename, "LSP: rename symbol")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
    end,
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "pyright",
        "lua_ls",
        "clangd",
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({
                capabilities = capabilities,
            })
        end,
    },
})
