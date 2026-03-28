-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup({ function(use)
    -- Packer can manage itself
    use { "wbthomason/packer.nvim", opts = {} }
    use({
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" } },
    })
    use({ "nyoom-engineering/oxocarbon.nvim" })
    use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
    use("nvim-treesitter/playground")
    use("theprimeagen/harpoon")
    use("mbbill/undotree")
    use("tpope/vim-fugitive")
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    })
    use("prisma/vim-prisma")
    use("Civitasv/cmake-tools.nvim")
    use("mason-org/mason.nvim")
    use("mason-org/mason-lspconfig.nvim")
    use("neovim/nvim-lspconfig")
    use("hrsh7th/nvim-cmp")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    -- use({
    -- 	"supermaven-inc/supermaven-nvim",
    -- })
end,
config = {
    compile_path = vim.fn.stdpath("data") .. "/packer_compiled.lua"
}
})
