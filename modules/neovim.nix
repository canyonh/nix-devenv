{ config, pkgs, lib, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Provide pre-compiled treesitter grammars for NixOS
        # This avoids compilation issues with lazy.nvim's nvim-treesitter
        plugins = with pkgs.vimPlugins; [
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
        ];
    };

    # Link individual neovim config files/directories
    # This allows lazy.nvim to create writable files like lazy-lock.json
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
