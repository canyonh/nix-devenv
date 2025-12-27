# Package management
# LSP servers, development tools, and utilities
{ config, pkgs, lib, isLinux ? false, isDarwin ? false, ... }:

{
  home.packages = with pkgs; [
    # === LSP Servers (Language Server Protocol) ===
    # C/C++ (for dive-xl-payloads, maritime-pandion, etc.)
    clang-tools  # Includes clangd, clang-format, clang-tidy

    # Python (for pybt, autonomy-divexl, test scripts)
    (python3.withPackages (ps: with ps; [
      python-lsp-server  # Main LSP server
      pylsp-mypy        # Type checking integration
      python-lsp-ruff   # Fast linting/formatting
      pynvim            # Neovim Python support
      debugpy           # Python debugger (DAP)
    ]))
    pyright           # Alternative Python LSP (Microsoft's implementation)

    # Nix (for editing your flakes and nix files)
    nil               # Nix LSP
    nixpkgs-fmt      # Nix formatter

    # Lua (for editing your neovim config)
    lua-language-server

    # Bash/Shell scripting
    nodePackages.bash-language-server

    # CMake (for CMakeLists.txt files)
    cmake-language-server

    # YAML (for config files)
    yaml-language-server

    # JSON/HTML/CSS/ESLint (extracted from VSCode)
    nodePackages.vscode-langservers-extracted

    # Dockerfile
    dockerfile-language-server

    # === Code Formatters & Linters ===
    # Note: black and ruff are available via python-lsp-server above
    # clang-tools already included above with LSP servers

    # Formatters (used by conform.nvim)
    prettierd        # Fast Prettier daemon (JS/TS/JSON/HTML/CSS/MD/YAML)
    stylua           # Lua formatter
    shfmt            # Shell script formatter

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
    gnumake      # GNU Make (needed for building native plugins)
    tree-sitter  # Tree-sitter CLI (needed for nvim-treesitter)

    # Git tools
    git
    git-lfs
    tig             # Text-mode interface for git

    # Other utilities
    htop            # Better top
    tmux            # Terminal multiplexer (if not using existing config)
    # Note: alacritty is configured in modules/alacritty.nix

    # Fonts (Nerd Fonts for terminal icons)
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack

    # NOTE: We're NOT including these from nix profile:
    # - latticectl (from anduril-nixpkgs)
    # - yubikey-cli (from Anduril)
    # - cachix (from your nix profile)
    # These remain in your existing nix profile for now
  ]
  # Linux-specific packages
  ++ lib.optionals isLinux [
    dconf           # Configuration system (needed for desktop settings on Linux)
    gcc             # GNU C compiler (standard on Linux)
  ]
  # macOS-specific packages
  ++ lib.optionals isDarwin [
    # macOS uses Clang by default (from Xcode/CLT), but ensure it's available
    # nixpkgs stdenv.cc provides the right compiler
  ];

  # Note: We're intentionally NOT managing neovim here yet
  # Your existing nvim config at ~/devcfg/.config/nvim continues to work
  # We'll migrate neovim in Stage 2
}
