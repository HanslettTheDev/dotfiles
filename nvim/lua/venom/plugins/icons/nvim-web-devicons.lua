local nvim_web_devicons_setup, nvim_web_devicons = pcall(require, "nvim-web-devicons")
if not nvim_web_devicons_setup then
	return
end

nvim_web_devicons.setup({
	overide = {
		css = {
			icon = "e749",
		},
	},
})
