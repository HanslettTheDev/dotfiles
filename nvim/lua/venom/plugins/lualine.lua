local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- get lualine theme
local lualine_theme = require("lualine.themes.onedark")

-- -- new colors for theme
-- local new_colors = {
-- 	blue = "#65D1FF",
-- 	green = "#3EFFDC",
-- 	violet = "#FF61EF",
-- 	yellow = "#FFDA7B",
-- 	black = "#000000",
-- }
--
-- -- change nightlfy theme colors
-- lualine_theme.normal.a.bg = new_colors.blue
-- lualine_theme.insert.a.bg = new_colors.green
-- lualine_theme.visual.a.bg = new_colors.violet
lualine_theme.command = {
	a = {
		gui = "bold",
	},
}

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = "auto",
	},
})
