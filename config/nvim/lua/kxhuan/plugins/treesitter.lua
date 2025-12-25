return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  -- Don't lazy load - telescope and other plugins need it immediately
  lazy = false,
  priority = 100,  -- Load early
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({
      -- enable syntax highlighting
      highlight = {
        enable = true,
      },

      -- enable indentation
      indent = { enable = true },

      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },

      -- ensure these language parsers are installed
      ensure_installed = {
        "c",
        "cpp",
        "json",
        "cmake",
        "bash",
        "lua",
        "dockerfile",
        "vimdoc",
        "python",
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
