{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History settings
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      share = false;
      expireDuplicatesFirst = true;
    };

    # Shell options
    initContent = ''
      # Ensure nix-managed binaries take precedence over system binaries
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

      # Basic options
      setopt autocd extendedglob nomatch menucomplete
      setopt interactive_comments
      stty stop undef         # Disable ctrl-s to freeze terminal
      zle_highlight=('paste:none')

      # Disable beeping
      unsetopt BEEP

      # Completion styling
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      _comp_options+=(globdots)  # Include hidden files

      # Line navigation
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      # Colors
      autoload -Uz colors && colors

      # Source modular config files
      source ${../config/zsh/zsh-functions}
      source ${../config/zsh/zsh-exports}
      source ${../config/zsh/zsh-vim-mode}
      source ${../config/zsh/zsh-aliases}
      source ${../config/zsh/zsh-prompt}

      # Key bindings
      bindkey '^[[P' delete-char
      bindkey "^p" up-line-or-beginning-search
      bindkey "^n" down-line-or-beginning-search
      bindkey "^k" up-line-or-beginning-search
      bindkey "^j" down-line-or-beginning-search
      bindkey -r "^u"
      bindkey -r "^d"

      # Edit line in vim
      autoload edit-command-line; zle -N edit-command-line

      # Source work-specific environment (if exists)
      [ -f ~/nix-secrets/work-env.sh ] && source ~/nix-secrets/work-env.sh

      # Fix PATH after work-env.sh (which prepends /usr/bin)
      # Ensure nix binaries take precedence over system binaries
      export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

      # Fix TERM if it was incorrectly set by work tools (Xilinx, etc)
      # Only reset if not already in tmux/screen
      if [[ -z "$TMUX" ]] && [[ "$TERM" == "screen"* ]]; then
        export TERM="xterm-256color"
      fi
    '';
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv integration (we already have it, but ensure zsh integration)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
