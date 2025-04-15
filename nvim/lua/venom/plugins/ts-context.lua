local setup, ts_context = pcall(require, "ts_context_commentstring")
if not setup then
	return
end

ts_context.setup({
	enable_autocmd = false,
})
