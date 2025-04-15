require("venom.plugins-setup")
require("venom.core.options")
require("venom.core.keymaps")
require("venom.core.colorscheme")
require("venom.plugins.comment")
require("venom.plugins.nvim-tree")
require("venom.plugins.lualine")
require("venom.plugins.telescope")
require("venom.plugins.nvim-cmp")
require("venom.plugins.lsp.mason")
require("venom.plugins.lsp.lspsaga")
require("venom.plugins.lsp.lspconfig")
require("venom.plugins.autopairs")
require("venom.plugins.treesitter")
require("venom.plugins.gitsigns")
require("venom.plugins.formatting")
require("venom.plugins.ts-context")

-- colorscheme
-- vim.cmd([[ colorscheme palenight ]])
vim.cmd([[ set background=dark ]])
-- set termguicolors to enable highlight groups
vim.g.termuguicolors = true

print("status: plugins sourced successfully")
-- vim.cmd([[ let g:python_host_prog = 'C:/Users/DELL/AppData/Local/Programs/Python/Python310' ]])
