local mason_conform_status, mason_conform = pcall(require, "conform")
if not mason_conform_status then
	return
end

mason_conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		-- rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", stop_after_first = true },
		html = { "prettierd" },
		css = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		go = { "goimports", "gofmt" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
