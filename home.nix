# Main home-manager configuration
# This file imports all the modules and sets up the base configuration
{ config, pkgs, lib, ... }:

{
  # Import all modules
  imports = [
    ./home/common.nix
    ./modules/git.nix
    ./modules/packages.nix
    ./modules/direnv.nix
    ./modules/tmux.nix
    ./modules/zsh.nix
    ./modules/neovim.nix
    ./modules/clangd.nix
  ];

  # Let home-manager install and manage itself
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
