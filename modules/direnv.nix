# Direnv configuration
# Automatically loads project-specific nix shells when you cd into directories
{ config, pkgs, lib, ... }:

{
  # Stage 1: Install direnv but don't integrate with shell config yet
  # We'll manually add direnv hook to your existing ~/.zshrc from ~/devcfg

  # Just install the direnv package
  home.packages = with pkgs; [
    direnv
    nix-direnv
  ];

  # Create direnv config directory and settings
  xdg.configFile."direnv/direnvrc".text = ''
    # Load nix-direnv for better caching
    source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
  '';

  # Note: You'll need to manually add this to your ~/.zshrc or ~/devcfg/.config/zsh/.zshrc:
  #   eval "$(direnv hook zsh)"
  #
  # Or in Stage 2, we'll enable full integration:
  #   programs.direnv = {
  #     enable = true;
  #     enableBashIntegration = true;
  #     enableZshIntegration = true;
  #     nix-direnv.enable = true;
  #   };
}
