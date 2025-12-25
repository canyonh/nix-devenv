# macOS-specific configuration
{ config, pkgs, lib, ... }:

{
  # Import common configuration
  imports = [ ./common.nix ];

  # macOS-specific environment variables
  home.sessionVariables = {
    # Add any macOS-specific variables here
  };

  # macOS-specific packages
  # home.packages = with pkgs; [
  #   # macOS-only tools
  # ];
}
