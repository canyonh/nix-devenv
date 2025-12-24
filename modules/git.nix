# Git configuration
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName = "Kun-Yao Huang";
    userEmail = "khuang@anduril.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;

      # Use neovim as diff/merge tool (from your existing setup)
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";

      # Credential helper
      credential.helper = "store";

      # Better diffs
      diff.algorithm = "histogram";

      # Reuse recorded resolution
      rerere.enabled = true;
    };

    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };
  };

  # Git LFS (if you use it)
  # programs.git.lfs.enable = true;
}
