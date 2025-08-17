local wk = require("which-key")

-- which-key v3+ spec (list-based). Groups and mappings under <leader>
wk.add({
  -- Basic
  { "<leader>b", group = "Basic" },
  { "<leader>bw", ":w<CR>", desc = "保存 (write)" },
  { "<leader>bq", ":q<CR>", desc = "終了 (quit)" },
  { "<leader>bx", ":x<CR>", desc = "保存して終了" },
  { "<leader>be", ":e<CR>", desc = "再読み込み/開く (edit)" },

  -- Move
  { "<leader>m", group = "Move" },
  { "<leader>mg", "gg",  desc = "ファイル先頭へ" },
  { "<leader>mG", "G",   desc = "ファイル末尾へ" },
  { "<leader>m0", "0",   desc = "行頭へ" },
  { "<leader>m$", "$",   desc = "行末へ" },
  { "<leader>mu", "<C-u>", desc = "半画面上へ" },
  { "<leader>md", "<C-d>", desc = "半画面下へ" },

  -- Edit
  { "<leader>e", group = "Edit" },
  { "<leader>ex", "x",     desc = "1文字削除" },
  { "<leader>ed", "dd",    desc = "1行削除" },
  { "<leader>ey", "yy",    desc = "1行コピー" },
  { "<leader>ep", "p",     desc = "貼り付け" },
  { "<leader>eu", "u",     desc = "元に戻す (undo)" },
  { "<leader>er", "<C-r>", desc = "やり直し (redo)" },
  { "<leader>e>", ">>",    desc = "インデント増" },
  { "<leader>e<", "<<",    desc = "インデント減" },

  -- Search
  { "<leader>s", group = "Search" },
  { "<leader>ss", "/<C-r><C-w><CR>", desc = "カーソル下の単語を検索" },
  { "<leader>sn", "n",  desc = "次を検索" },
  { "<leader>sN", "N",  desc = "前を検索" },
  { "<leader>s/", "/",  desc = "検索プロンプトを開く" },

  -- Window/Tab
  { "<leader>w", group = "Window/Tab" },
  { "<leader>ws", ":split<CR>",  desc = "水平分割" },
  { "<leader>wv", ":vsplit<CR>", desc = "垂直分割" },
  { "<leader>wh", "<C-w>h", desc = "左の分割へ" },
  { "<leader>wj", "<C-w>j", desc = "下の分割へ" },
  { "<leader>wk", "<C-w>k", desc = "上の分割へ" },
  { "<leader>wl", "<C-w>l", desc = "右の分割へ" },
  { "<leader>wt", ":tabnew<CR>", desc = "新しいタブ" },
  { "<leader>wn", "gt",        desc = "次のタブ" },
  { "<leader>wp", "gT",        desc = "前のタブ" },
})