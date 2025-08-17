-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- システムクリップボードを使用
vim.opt.clipboard:append({"unnamedplus"})

-- Setup lazy.nvim (single call)
require("lazy").setup({
  spec = {
    -- inline plugins here
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    -- and also import additional specs from lua/plugins/**
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Smart Command+P: メニューを表示しつつ f/c で即実行できる Telescope ピッカー
local function smart_command_p()
  local builtin = require("telescope.builtin")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values

  local entries = {
    { key = "f", name = "Files (find_files)", run = builtin.find_files },
    { key = "c", name = "Commands (:commands)", run = builtin.commands },
    -- 必要に応じてここに追加できます:
    -- { key = "g", name = "Live Grep (ripgrep)", run = builtin.live_grep },
    -- { key = "b", name = "Buffers", run = builtin.buffers },
  }

  local opts = {
    prompt_title = "Smart Command+P",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        return {
          value = item,
          display = string.format("[%s] %s", item.key, item.name),
          ordinal = item.key .. " " .. item.name, -- 並び替え用
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function run_selected()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection.value and selection.value.run then
          selection.value.run()
        end
      end

      -- Enter で現在選択を実行
      actions.select_default:replace(run_selected)

      -- f / c を押したら即実行（選択を無視してダイレクトに実行）
      map("i", "f", function()
        actions.close(prompt_bufnr)
        builtin.find_files()
      end)
      map("n", "f", function()
        actions.close(prompt_bufnr)
        builtin.find_files()
      end)
      map("i", "c", function()
        actions.close(prompt_bufnr)
        builtin.commands()
      end)
      map("n", "c", function()
        actions.close(prompt_bufnr)
        builtin.commands()
      end)

      return true
    end,
  }

  pickers.new({}, opts):find()
end

vim.keymap.set("n", "<M-p>", smart_command_p, { desc = "Smart Command+P (Telescope menu)" })
-- iTerm2はCmd+Pが印刷になってしまうのでF13もコマンドパレットモードとする
vim.keymap.set("n", "<F13>", smart_command_p, { desc = "Smart Command+P (Telescope menu)" })
vim.keymap.set("n", "<C-p>", smart_command_p, { desc = "Smart Command+P (Telescope menu)" })
vim.keymap.set("n", "<M-e>", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTreeをトグルする" })