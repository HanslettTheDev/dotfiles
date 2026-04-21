-- =========================================
-- LOCAL VARIABLES AND FUNCTION DECLARATIONS
-- =========================================

local mason_registry = require("mason-registry")
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok_cmp then
	return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

local keymap = vim.keymap

-- enable keybinds for available lsp server
local on_attach = function(client, buffnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = buffnr }

	-- set keybinds
	keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
	keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
	keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
	keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
	keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
	keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
	keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
	keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
	keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side
end

local vue_ls_path = vim.fn.expand("$MASON/packages") .. "/vue-language-server" .. "/node_modules/@vue/language-server"
local vue_ts_plugin_path = vue_ls_path .. "/node_modules/@vue/language-server"

-- Defining the  Vue TypeScript plugin
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_ts_plugin_path,
	languages = { "javascript", "typescript", "vue" },
}

local tsserver_filetypes = {
	"typescript",
	"javascript",
	"javascriptreact",
	"typescriptreact",
	"vue",
}

-- =========================================
-- SETTING UP LSP CONFIGURATIONS
-- =========================================

-- DEFAULT CONFIGURATIONS FOR ALL LSP
vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = capabilities,
})

-- configure html server
vim.lsp.config("html", {})

-- configure php server
vim.lsp.config("intelephense", {})

-- configure css server
vim.lsp.config("cssls", {})

-- configure emmet language server
vim.lsp.config("emmet_ls", {
	filetypes = {
		"html",
		"typescriptreact",
		"javascriptreact",
		"javascript",
		"css",
		"sass",
		"scss",
		"less",
		"svelte",
		"htmldjango",
	},
})

-- configure lua server (with special settings)
vim.lsp.config("lua_ls", {
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

-- configure python
vim.lsp.config("pyright", {})

-- configure Go lang
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			gofumpt = true,
		},
	},
})

-- configure C
vim.lsp.config("clangd", {})

-- Configure ts_ls
vim.lsp.config("ts_ls", {
	init_options = {
		plugins = { vue_plugin },
	},
	filetypes = tsserver_filetypes,
	root_markers = { "package.json" },
	single_file_support = false,
})

-- Configure vue_ls
vim.lsp.config("vue_ls", {})

-- =========================================
-- ENABLE LSP
-- =========================================

vim.lsp.enable("html")
vim.lsp.enable("intelephense")
vim.lsp.enable("cssls")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("clangd")
vim.lsp.enable("vue_ls")
vim.lsp.enable("ts_ls")
