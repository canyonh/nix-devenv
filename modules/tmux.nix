{ config, pkgs, lib, ...}:

{
    programs.tmux = {
        enable = true;

        extraConfig = builtins.readFile ../config/tmux/.tmux.conf;
    };
}
