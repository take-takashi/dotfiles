return {
  -- インストーラ
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  -- LSPをMasonで入れる橋渡し
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- 必要に応じて追加/削除
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ts_ls",
          "bashls",
          "jsonls",
          "html",
        },
        automatic_installation = true,
      })
    end,
  },

  -- サーバ定義の“データ集”として（setupは使わない）
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")
      local util = require("lspconfig.util")

      ----------------------------------------------------------------
      -- 共通: アタッチ時のキー割り当て（バッファローカル）
      ----------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("n", "grn", vim.lsp.buf.rename,        "LSP Rename")
          map("n", "gra", vim.lsp.buf.code_action,   "LSP Code Action")
          map("n", "gD",  vim.lsp.buf.declaration,   "LSP Declaration")
          map("n", "gd",  vim.lsp.buf.definition,    "LSP Definition")
          map("n", "gI",  vim.lsp.buf.implementation,"LSP Implementation")
          map("n", "gr",  vim.lsp.buf.references,    "LSP References")
          map("n", "K",   vim.lsp.buf.hover,         "LSP Hover")
          map("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "LSP Format")
        end,
      })

      ----------------------------------------------------------------
      -- 必要なら補完のcapabilities（nvim-cmp導入時に有効化）
      ----------------------------------------------------------------
      local caps = vim.lsp.protocol.make_client_capabilities()
      -- caps = require("cmp_nvim_lsp").default_capabilities(caps) -- nvim-cmp使用時

      ----------------------------------------------------------------
      -- 各サーバ設定（純正API）
      ----------------------------------------------------------------
      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = caps,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            completion  = { callSnippet = "Replace" },
          },
        },
      })

      -- TypeScript/JavaScript（Node系プロジェクト）
      lspconfig.ts_ls.setup({
        capabilities = caps,
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentFormattingProvider then
            client.server_capabilities.documentFormattingProvider = false
          end
        end,
      })

      -- Deno（入れる場合は ts_* と排他になるよう root を厳密化）
      lspconfig.denols.setup({
        capabilities = caps,
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        root_dir = util.root_pattern("deno.json", "deno.jsonc"),
      })

      -- Python
      lspconfig.pyright.setup({
        capabilities = caps,
        root_dir = util.root_pattern("pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", ".git"),
      })

      -- Bash
      lspconfig.bashls.setup({
        capabilities = caps,
      })

      -- JSON
      lspconfig.jsonls.setup({
        capabilities = caps,
      })

      -- HTML
      lspconfig.html.setup({
        capabilities = caps,
      })

      -- Denoを使うなら、上の wanted には入れず、
      -- Denoプロジェクトでだけ手動で:  vim.lsp.enable("denols")
      -- （ts_ls/tsserver と重複しないよう root を分ける）
    end,
  },
}