# Common configuration shared across all platforms
{ config, pkgs, lib, ... }:

{
  # Stage 1: Don't manage shell config files yet
  # Keep using existing ~/devcfg setup for bash/zsh
  # We'll migrate in Stage 2

  # Essential environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "alacritty";

    # Ensure nix profile packages stay in PATH
    # This is important to keep latticectl, yubikey-cli, cachix accessible
  };

  # XDG Base Directory specification
  xdg.enable = true;

  # Set default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = "Alacritty.desktop";
    };
  };

  # Desktop environment settings (via dconf/gsettings)
  dconf.settings = {
    # Cinnamon default terminal
    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "alacritty";
      exec-arg = "";
    };
  };

  # Allow unfree packages (needed for some Anduril tools)
  nixpkgs.config.allowUnfree = true;
}
