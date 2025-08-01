-- Collection of helper functions for wezterm config --

local wezterm = require("wezterm")

local M = {}

-- Determine if OS/WM type
local is_target_triple = function(target)
    return wezterm.target_triple:find(target) ~= nil
end

function M.is_windows()
    return is_target_triple("windows")
end

function M.is_macos()
    return is_target_triple("darwin")
end

function M.is_kde()
    return is_target_triple("KDE")
end

-- Set colour theme based on light/dark mode
function M.scheme_for_appearance(appearance)
    if appearance:find "Light" then
        return "Catppuccin Latte"
    else
        return "Catppuccin Mocha"
    end
end

return M
