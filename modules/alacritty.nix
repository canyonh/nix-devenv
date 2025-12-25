{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      # Font configuration with Nerd Font
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
        size = 14.0;
      };

      # Window settings
      window = {
        opacity = 0.95;
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "full";
      };

      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Terminal shell
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
      };

      # Colors (Tokyo Night theme - optional, feel free to change)
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
      };

      # Cursor
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
      };

      # Bell
      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };

      # Key bindings
      keyboard.bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
      ];
    };
  };
}
