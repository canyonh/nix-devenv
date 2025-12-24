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
}
