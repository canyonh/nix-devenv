# Common configuration shared across all platforms
{ config, pkgs, lib, isLinux ? false, isDarwin ? false, ... }:

{
  # Stage 1: Don't manage shell config files yet
  # Keep using existing ~/devcfg setup for bash/zsh
  # We'll migrate in Stage 2

  # Essential environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    # TERMINAL set in platform-specific modules (alacritty on Linux, iTerm2 on macOS)

    # Ensure nix profile packages stay in PATH
    # This is important to keep latticectl, yubikey-cli, cachix accessible
  };

  # XDG Base Directory specification
  xdg.enable = true;

  # Set default applications (Linux only - macOS uses different app system)
  xdg.mimeApps = lib.mkIf isLinux {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = "Alacritty.desktop";
    };
  };

  # Allow unfree packages (needed for some Anduril tools)
  nixpkgs.config.allowUnfree = true;
}
