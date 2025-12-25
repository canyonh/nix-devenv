{ config, pkgs, lib, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
    };

    # Link the neovim configuration from this repository
    xdg.configFile."nvim".source = ../config/nvim;
}
