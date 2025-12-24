# Package management
# LSP servers, development tools, and utilities
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # === LSP Servers (Language Server Protocol) ===
    # C/C++ (for dive-xl-payloads, maritime-pandion, etc.)
    clangd_17

    # Python (for pybt, autonomy-divexl, test scripts)
    (python3.withPackages (ps: with ps; [
      python-lsp-server  # Main LSP server
      pylsp-mypy        # Type checking integration
      python-lsp-ruff   # Fast linting/formatting
      pynvim            # Neovim Python support
    ]))

    # Nix (for editing your flakes and nix files)
    nil               # Nix LSP
    nixpkgs-fmt      # Nix formatter

    # Lua (for editing your neovim config)
    lua-language-server

    # Bash/Shell scripting
    bash-language-server
    nodePackages.bash-language-server

    # CMake (for CMakeLists.txt files)
    cmake-language-server

    # YAML (for config files)
    yaml-language-server

    # === Code Formatters & Linters ===
    black           # Python formatter
    ruff            # Fast Python linter/formatter
    clang-tools     # clang-format, clang-tidy

    # === Development Tools ===
    # Search and navigation
    ripgrep         # Fast grep (rg)
    fd              # Fast find
    fzf             # Fuzzy finder

    # File operations
    tree            # Directory tree view
    bat             # Better cat with syntax highlighting

    # JSON/YAML tools
    jq              # JSON processor
    yq-go           # YAML processor

    # Network tools
    curl
    wget

    # Build tools
    cmake
    ninja

    # Git tools
    git
    git-lfs
    tig             # Text-mode interface for git

    # Other utilities
    htop            # Better top
    tmux            # Terminal multiplexer (if not using existing config)

    # NOTE: We're NOT including these from nix profile:
    # - latticectl (from anduril-nixpkgs)
    # - yubikey-cli (from Anduril)
    # - cachix (from your nix profile)
    # These remain in your existing nix profile for now
  ];

  # Note: We're intentionally NOT managing neovim here yet
  # Your existing nvim config at ~/devcfg/.config/nvim continues to work
  # We'll migrate neovim in Stage 2
}
