{ config, pkgs, lib, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Let lazy.nvim manage all plugins
        # Just ensure neovim has access to required build tools via environment
        extraPackages = with pkgs; [
            gcc
            gnumake
            tree-sitter
            # Add node for some plugins that need it
            nodejs
        ];
    };

    # Link individual neovim config files/directories
    # This allows lazy.nvim to create writable files like lazy-lock.json
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
