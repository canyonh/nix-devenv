-- Treesitter is provided by Nix (home-manager) with pre-compiled parsers
-- lazy.nvim will use the Nix-provided version and just run this config
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,  -- Load immediately (before other plugins need it)
  priority = 100,  -- Load early but after colorscheme
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- Configure the Nix-provided treesitter plugin
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      autotag = { enable = true },
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
