# Nix configuration management
# Manages nix.conf settings, substituters, and build configuration
{ config, pkgs, lib, ... }:

{
  nix = {
    # Specify which nix package to use
    package = pkgs.nix;

    settings = {
      # Experimental features
      experimental-features = [ "nix-command" "flakes" ];

      # Netrc file location (file itself managed separately as a secret)
      netrc-file = "${config.home.homeDirectory}/.config/nix/netrc";

      # Cachix substituters with priorities
      # Priority order: anduril-aus (15), anduril-core (25), polyrepo (26), nixos.org (default 40)
      substituters = [
        "https://anduril-aus-core-nix-cache.cachix.anduril.au?priority=15"
        "https://anduril-core-nix-cache.cachix.anduril.dev?priority=25"
        "https://polyrepo.cachix.anduril.dev?priority=26"
        "https://cache.nixos.org"
      ];

      # Public keys for trusted substituters
      # Note: These are PUBLIC keys, not secrets
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "anduril-core-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
        "polyrepo.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
        "anduril-aus-core-nix-cache.cachix.anduril.au-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
      ];

      # Build optimization
      narinfo-cache-negative-ttl = 0;

      # Note: cores and max-jobs should match your system capabilities
      # These are reasonable defaults for an 8-core system
      cores = 8;
      max-jobs = 12;
    };
  };

  # NIX_PATH environment variable for Anduril nixpkgs
  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${config.home.homeDirectory}/sources/anduril-nixpkgs";
  };
}
