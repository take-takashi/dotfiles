-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
config.automatically_reload_config = true

-- This is where you actually apply your config choices

-- For example, changing the initial geometry for new windows:
config.initial_cols = 240
config.initial_rows = 48

config.font_size = 14
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.font = wezterm.font 'HackGen Console NF'

-- key読み込み
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
-- デフォルトのキー設定を無効化
config.disable_default_key_bindings = true
-- CapsLock
-- config.leader = { key = 'CapsLock', mods = '', timeout_milliseconds = 1000 }
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- For example, changing the color scheme:
config.color_scheme = 'idleToes'

-- and finally, return the configuration to wezterm
return config