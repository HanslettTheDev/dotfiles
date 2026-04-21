-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")

if not mason_lspconfig_status then
	return
end

-- enable mason
mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	-- list of servers for mason to install by default
	ensure_installed = {
		"html",
		"vue_ls",
		"ts_ls",
		"cssls",
		"lua_ls",
		"emmet_ls",
		"clangd",
		"jsonls",
		"marksman",
		"intelephense",
		"powershell_es",
		"pyright",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})
