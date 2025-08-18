return {
  "akinsho/toggleterm.nvim",
  version = "*",
  lazy = false,
  config = function()
    require("toggleterm").setup({})
    -- ターミナルジョブモードのkeymapでESCに<C-\><C-n>を割り当てる
    vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], { silent = true })
  end,
}