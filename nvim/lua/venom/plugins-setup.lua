local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

vim.g.coc_global_extensions = { "coc-json", "coc-tsserver", "coc-json", "coc-html", "coc-css" }

local packer_bootstrap = ensure_packer()

-- Autocommand that reloads neovim whenever you save this file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

local status, packer = pcall(require, "packer")
if not status then
	return
end

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- lua functions that many plugins use
	use("nvim-lua/plenary.nvim")

	-- color schemes
	use("bluz71/vim-nightfly-guicolors")

	use("drewtempelmeyer/palenight.vim")

	-- tmux and split window navigation
	use("christoomey/vim-tmux-navigator")

	-- maximizes and restores current window
	use("szw/vim-maximizer")

	-- commentng with gc
	use("numToStr/Comment.nvim")

	-- file explorer
	use("nvim-tree/nvim-tree.lua")

	-- icons
	use("nvim-tree/nvim-web-devicons")

	-- status line
	use("nvim-lualine/lualine.nvim")

	-- fuzzy finding
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.3",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- autocompletion
	use("neovim/nvim-lspconfig")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")

	-- snippets
	use("L3MON4D3/LuaSnip")

	-- LSP servers and Configuring lsp servers
	use({
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	})

	use({ "glepnir/lspsaga.nvim", branch = "main" })
	use("onsails/lspkind.nvim")

	-- formatting and linters
	use("stevearc/conform.nvim")

	-- Go Lang fmt
	use("fatih/vim-go")

	-- treesitter
	use("nvim-treesitter/nvim-treesitter")

	-- autoclose
	use("windwp/nvim-autopairs")
	use("windwp/nvim-ts-autotag")

	-- Git signs
	use("lewis6991/gitsigns.nvim")
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins

	-- Codeium Coding assistant
	-- use("Exafunction/codeium.vim")

	-- Laravel
	use("adalessa/laravel.nvim")

	-- context commenting for multiple language buffers
	use("JoosepAlviste/nvim-ts-context-commentstring")

	-- Live server
	use("barrett-ruth/live-server.nvim")

	if packer_bootstrap then
		require("packer").sync()
	end
end)
