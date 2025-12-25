{ config, pkgs, lib, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Provide problematic plugins via Nix (pre-compiled)
        # lazy.nvim will manage the rest
        plugins = with pkgs.vimPlugins; [
            # Treesitter with pre-compiled parsers (avoids compilation issues)
            (nvim-treesitter.withPlugins (p: [
                p.c
                p.cpp
                p.json
                p.cmake
                p.bash
                p.lua
                p.dockerfile
                p.vim
                p.vimdoc
                p.python
            ]))
            nvim-ts-autotag  # Treesitter dependency
        ];

        # Build tools for other lazy.nvim plugins (telescope-fzf, etc.)
        extraPackages = with pkgs; [
            gcc
            gnumake
            tree-sitter
            nodejs
        ];

        # Configure treesitter (since it's not managed by lazy.nvim)
        extraLuaConfig = ''
          -- Treesitter configuration (Nix-provided plugin)
          require('nvim-treesitter.configs').setup({
            highlight = { enable = true },
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
        '';
    };

    # Link individual neovim config files/directories
    # This allows lazy.nvim to create writable files like lazy-lock.json
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
