-- Treesitter is provided by Nix (home-manager) with pre-compiled parsers
-- This avoids compilation issues on NixOS
-- Configuration is in modules/neovim.nix extraLuaConfig
return {
  "nvim-treesitter/nvim-treesitter",
  enabled = false,  -- Skip lazy.nvim management, use Nix version
}
