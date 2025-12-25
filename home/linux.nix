# Linux-specific configuration
{ config, pkgs, lib, ... }:

{
  # Import common configuration
  imports = [ ./common.nix ];

  # Linux-specific environment variables
  home.sessionVariables = {
    # Add any Linux-specific variables here
  };

  # Linux-specific packages can be added here if needed
  # home.packages = with pkgs; [
  #   # Linux-only tools
  # ];

  # Desktop environment settings (Linux only - Cinnamon/GNOME)
  dconf.settings = {
    # Cinnamon default terminal
    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "alacritty";
      exec-arg = "";
    };
  };

  # Ensure Cinnamon picks up the terminal setting on login
  # (dconf.settings alone doesn't always trigger Cinnamon to reload)
  home.activation.setCinnamonTerminal = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${pkgs.glib}/bin/gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'
  '';
}
