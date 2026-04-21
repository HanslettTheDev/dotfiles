local setup, live_server = pcall(require, "live_server")
if not setup then
	return
end

live_server.setup(opts)
