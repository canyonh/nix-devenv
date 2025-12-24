# Direnv configuration
# Automatically loads project-specific nix shells when you cd into directories
{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # nix-direnv provides better caching and performance for nix shells
    nix-direnv.enable = true;

    # Optional: Configuration
    # config = {
    #   global = {
    #     hide_env_diff = true;  # Don't show environment variable changes
    #   };
    # };
  };

  # Direnv will automatically detect:
  # - .envrc files (like in autonomy-divexl)
  # - shell.nix files
  # - flake.nix files (with "use flake")
  #
  # For projects WITHOUT .envrc, you can manually run:
  #   cd ~/source/dive-xl-payloads
  #   echo "use flake" > .envrc
  #   direnv allow
  #
  # But since .envrc is tracked in git, we'll handle those manually
  # This setup enables the infrastructure for when .envrc exists
}
