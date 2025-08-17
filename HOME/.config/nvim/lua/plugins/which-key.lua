return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- 起動後に遅延ロード
    opts = {
      -- ここに必要なら which-key の細かい設定
      -- e.g., window = { border = "rounded" },
    },
    dependencies = {
      "echasnovski/mini.icons", -- アイコン表示用
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      -- チートシートの中身を別ファイルに分離
      require("config.which-key")
    end,
  },
}