local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
    return
end

vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

-- local supermaven_ok, supermaven = pcall(require, "supermaven-nvim")
-- if not supermaven_ok then
-- 	return
-- end

-- supermaven.setup({
--     disable_inline_completion = true,
--     disable_keymaps = true,
-- })

cmp.setup({
    preselect = cmp.PreselectMode.None,
    completion = {
        completeopt = "menu,menuone,noinsert,noselect",
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if cmp.get_selected_entry() == nil then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                end
                cmp.confirm({ select = true })
                return
            end

            fallback()
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                return
            end

            fallback()
        end, { "i", "s" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
    }),
    sources = cmp.config.sources({
        -- { name = "supermaven", priority = 1000 },
        { name = "nvim_lsp", priority = 900 },
    }, {
        { name = "path" },
        { name = "buffer" },
    }),
    formatting = {
        format = function(entry, vim_item)
            local menu_labels = {
                -- supermaven = "[SM]",
                nvim_lsp = "[LSP]",
                path = "[Path]",
                buffer = "[Buf]",
            }

            vim_item.menu = menu_labels[entry.source.name] or string.format("[%s]", entry.source.name)
            return vim_item
        end,
    },
})
