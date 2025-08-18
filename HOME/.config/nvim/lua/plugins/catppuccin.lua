return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- Ensures the colorscheme loads early
  opts = {
    -- Optional: Configure Catppuccin options here
    term_colors = true,
    transparent_background = true,
    -- ... other options like dim_inactive, integrations
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-mocha") -- Set your preferred flavor
  end,
}