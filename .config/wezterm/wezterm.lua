local wezterm = require("wezterm")

local config = wezterm.config_builder()

local helpers = require("helpers")

config.font = wezterm.font "Hack Nerd Font"
config.font_size = 15.0

config.color_scheme = helpers.scheme_for_appearance(wezterm.gui.get_appearance())

config.use_fancy_tab_bar = false

if helpers.is_macos() then
    config.window_background_opacity = 0.85
    config.macos_window_background_blur = 50
end

if helpers.is_kde() then
    config.window_background_opacity = 0.85
    config.kde_window_background_blur = true
end

return config
