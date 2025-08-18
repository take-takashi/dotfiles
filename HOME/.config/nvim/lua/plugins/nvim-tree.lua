return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- nvim-treeがフォーカスしているときのみ使えるキーを定義
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")

      -- まずデフォルトのマッピングを設定
      api.config.mappings.default_on_attach(bufnr)

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Use `l` to open file/folder
      vim.keymap.set("n", "zl", api.node.open.edit, opts("Open"))
      -- Use `h` to close folder
      vim.keymap.set("n", "zh", api.node.navigate.parent_close, opts("Close Folder"))
    end

    -- Smart open/focus/close rotation for NvimTree
    local function nvimtree_smart()
      local api = require("nvim-tree.api")
      local visible = api.tree.is_visible()
      local in_tree = (vim.bo.filetype == "NvimTree")

      if visible and in_tree then
        -- 既にツリーにフォーカスしているなら閉じる
        api.tree.close()
      elseif visible then
        -- ツリーは開いているが他ウィンドウにいる → フォーカスを移す
        api.tree.focus()
      else
        -- ツリーが開いていない → 開いてフォーカス
        api.tree.open()
        api.tree.focus()
      end
    end
    -- ユーザーコマンドとして公開（キーマップは別ファイルで一元管理可能）
    vim.api.nvim_create_user_command("NvimTreeSmartOpen", nvimtree_smart, {})

    require("nvim-tree").setup {
      on_attach = on_attach,
    }
  end,
}