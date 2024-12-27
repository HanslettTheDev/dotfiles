local setup, nvim_comment = pcall(require, "nvim_comment")
if not setup then
	return
end

nvim_comment.setup()
