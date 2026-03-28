-- require('rose-pine').setup({
--     vim.cmd("colorscheme rose-pine"),
--     -- enable = {
--     --     terminal = true,
--     --     legacy_highlights = true,
--     --     migrations = true,
--     -- }
-- })

function ColorMyPencils(color)
	color = color or "oxocarbon"
	vim.opt.background = "dark"
	vim.cmd.colorscheme(color)
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
