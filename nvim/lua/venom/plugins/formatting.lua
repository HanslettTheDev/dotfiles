local mason_conform_status, mason_conform = pcall(require, "conform")
if not mason_conform_status then
	return
end

local function not_vtsls(client)
	return client.name ~= "vtsls"
end

mason_conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		-- rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", "vue_ls", lsp_format = "first", stop_after_first = true, filter = not_vtsls },
		html = { "prettierd" },
		css = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		go = { "goimports", "gofmt" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	log_level = vim.log.levels.ERROR,
})
