{ config, pkgs, lib, isLinux ? false, isDarwin ? false, ... }:

{
  # iTerm2 is macOS-only
  config = lib.mkIf isDarwin {
    # Install iTerm2 via homebrew (home-manager doesn't directly manage GUI apps)
    # Note: You'll need nix-darwin or homebrew integration for this
    # For now, we'll just manage the configuration

    # Copy iTerm2 preferences if they exist
    # home.file.".config/iterm2/com.googlecode.iterm2.plist" = lib.mkIf (builtins.pathExists ../config/iterm2/com.googlecode.iterm2.plist) {
    #   source = ../config/iterm2/com.googlecode.iterm2.plist;
    # };

    # Set iTerm2 as default terminal
    home.sessionVariables = {
      TERMINAL = "iTerm";
    };
  };
}
