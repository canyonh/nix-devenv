{ config, pkgs, lib, isDarwin ? false, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Provide problematic plugins via Nix (pre-compiled)
        # lazy.nvim will recognize and configure them (see config/nvim/lua/kxhuan/plugins/)
        plugins = with pkgs.vimPlugins; [
            # Treesitter with pre-compiled parsers (avoids compilation issues)
            # Configuration is in config/nvim/lua/kxhuan/plugins/treesitter.lua
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

            # Note: lazy.nvim is NOT provided by Nix - it bootstraps from git
            # Reason: Nix store is read-only, lazy.nvim can't generate helptags
            # lazy-lock.json provides reproducibility for lazy.nvim's version
        ];

        # Build tools for other lazy.nvim plugins (telescope-fzf, etc.)
        extraPackages = with pkgs; [
            # Use platform-appropriate C compiler
            # macOS: clang (standard), Linux: gcc (standard)
            (if isDarwin then clang else gcc)
            gnumake
            tree-sitter
            nodejs
        ];
    };

    # Link individual neovim config files/directories
    # Note: lazy-lock.json is NOT linked - lazy.nvim needs to write to it
    # Copy it manually from source when you want to sync plugin versions
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
