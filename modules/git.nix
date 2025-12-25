# Git configuration
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    # New unified settings structure (home-manager 24.05+)
    settings = {
      user = {
        name = "Kun-Yao Huang";
        email = "khuang@anduril.com";
      };

      init.defaultBranch = "main";
      pull.rebase = false;

      # Use neovim as diff/merge tool (from your existing setup)
      diff = {
        tool = "nvimdiff";
        algorithm = "histogram";
      };

      merge.tool = "nvimdiff";

      # Credential helper
      credential.helper = "store";

      # Reuse recorded resolution
      rerere.enabled = true;

      # Git aliases
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
      };
    };
  };

  # Git LFS (if you use it)
  # programs.git.lfs.enable = true;
}
