local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

treesitter.setup({
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	autotag = { enable = true },
	ensure_installed = {
		"json",
		"javascript",
		"typescript",
		"c",
		"cpp",
		"css",
		"csv",
		"gdscript",
		"html",
		"json",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"php",
		"python",
		"vue",
	},
	auto_install = true,
})
