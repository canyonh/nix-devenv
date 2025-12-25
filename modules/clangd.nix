{ config, pkgs, lib, ... }:

{
  # Clangd LSP configuration
  xdg.configFile."clangd/config.yaml".source = ../config/clangd/config.yaml;
}
