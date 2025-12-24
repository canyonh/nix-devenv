# Common configuration shared across all platforms
{ config, pkgs, lib, ... }:

{
  # Basic shell configuration
  programs.bash.enable = true;
  programs.zsh.enable = true;

  # Essential environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Ensure nix profile packages stay in PATH
    # This is important to keep latticectl, yubikey-cli, cachix accessible
  };

  # XDG Base Directory specification
  xdg.enable = true;

  # Allow unfree packages (needed for some Anduril tools)
  nixpkgs.config.allowUnfree = true;
}
