local cyberdream_setup, cyberdream = pcall(require, "cyberdream")
if not cyberdream_setup then
    print("error,Cyberdream theme not found")
    return
end

cyberdream.setup({
    variant = "auto", -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`

    -- Enable transparent background
    transparent = true,

    -- Enable italics comments
    italic_comments = true,

    -- Replace all fillchars with ' ' for the ultimate clean look
    hide_fillchars = true,

    -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
    borderless_pickers = false,

    -- Set terminal colors used in `:terminal`
    terminal_colors = true,

    -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
    cache = false,

    -- Override a highlight group entirely using the built-in colour palette
    overrides = function(colors) -- NOTE: This function nullifies the `highlights` option Example:
        return {
            Comment = { fg = colors.green, bg = "none", italic = true },
            -- ["@property"] = { fg = colors.magenta, bold = true },
        }
    end,
})
