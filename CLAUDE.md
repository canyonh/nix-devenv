# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix-based home-manager configuration for managing development environments across multiple platforms (Ubuntu Linux, macOS, NixOS). The repository uses Nix flakes for declarative, reproducible development environments.

## Essential Commands

**Note:** Replace `khuang@macbook` with your configuration name (`khuang@ubuntu` on Linux, `khuang@macbook` on macOS).

### Applying Configuration Changes
```bash
cd ~/nix-devenv
home-manager switch --flake .#khuang@macbook
```

### Testing Changes (Dry Run)
```bash
home-manager switch --flake .#khuang@macbook --dry-run
```

### Updating All Packages
```bash
nix flake update
home-manager switch --flake .#khuang@macbook
```

### Debugging Build Errors
```bash
home-manager switch --flake .#khuang@macbook --show-trace
```

### Managing Generations
```bash
# View history
home-manager generations

# Rollback to previous
home-manager switch --rollback

# Clean up old generations
nix-collect-garbage -d
```

## Architecture

### Flake Structure

The repository uses a modular architecture with these key components:

1. **`flake.nix`** - Entry point defining all system configurations
   - Uses `mkHome` helper function to generate home-manager configurations
   - Supports multiple systems (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
   - Each configuration specifies username, hostname, and platform-specific modules

2. **`home.nix`** - Main home-manager config that imports all modules
   - Acts as the central aggregator
   - Imports both platform-specific configs (`home/`) and feature modules (`modules/`)

3. **`home/` directory** - Platform-specific configurations
   - `common.nix` - Shared settings across all platforms (environment variables, XDG, unfree packages)
   - `linux.nix` - Linux-specific settings and Alacritty terminal
   - `darwin.nix` - macOS-specific settings and iTerm2 integration

4. **`modules/` directory** - Feature-based configuration modules
   - Each module configures one tool/aspect
   - Core modules: `git.nix`, `nix.nix`, `packages.nix`, `direnv.nix`
   - Shell/Editor: `tmux.nix`, `zsh.nix`, `neovim.nix`, `clangd.nix`
   - Terminal emulators: `alacritty.nix` (Linux), `iterm2.nix` (macOS)
   - All modules are imported by `home.nix`
   - Some modules read config files from `config/` directory

5. **`config/` directory** - Raw configuration files
   - `tmux/` - tmux configuration files
   - `zsh/` - zsh configuration files (zsh-functions, zsh-exports, zsh-vim-mode, zsh-aliases, zsh-prompt)

### Configuration Flow

```
flake.nix (defines system)
    ↓
home.nix (imports platform + modules)
    ↓
    ├── home/common.nix (shared settings)
    ├── home/linux.nix (platform-specific)
    └── modules/*.nix (feature modules)
            ↓
        config/* (raw config files, sourced by modules)
```

### Module Organization Principle

When adding new configuration:
- **Platform differences** → Add to `home/linux.nix` or `home/darwin.nix`
- **Tool/feature configuration** → Create/edit module in `modules/`
- **Raw config files** (e.g., shell scripts) → Place in `config/` and reference from module

### System Configurations

Multiple system configurations are available:

1. **`khuang@macbook`** (CURRENTLY ACTIVE):
   - Platform: aarch64-darwin (Apple Silicon)
   - Username: khuang
   - Hostname: KHUANG-MACBOOK16
   - Imports: `home/darwin.nix` plus all feature modules

2. **`khuang@ubuntu`**:
   - Platform: x86_64-linux
   - Username: khuang
   - Hostname: khuang-5690-ubuntu
   - Imports: `home/linux.nix` plus all feature modules

3. **`kxhuan@nixos`** (Future):
   - Platform: x86_64-linux
   - For future NixOS system integration

## Key Technical Details

### Nix Configuration Management

The `modules/nix.nix` file manages critical Nix settings:
- **Experimental features**: Flakes and nix-command enabled
- **Cachix substituters**: Anduril-specific binary caches (anduril-aus-core, anduril-core, polyrepo)
- **Build optimization**: cores=8, max-jobs=12 for parallel builds
- **Authentication**: Configures netrc-file location for private caches
- **NIX_PATH**: Points to anduril-nixpkgs for company-specific packages

This module ensures fast builds by using Anduril's binary caches with proper priority ordering.

### LSP Server Management

LSP servers are managed in `modules/packages.nix`. The architecture handles LSP priority:
1. Project-specific nix shells (highest priority when active)
2. home-manager packages (default fallback)
3. System packages (final fallback)

This ensures LSP servers are always available while allowing project-specific overrides (e.g., ARM cross-compile toolchains).

### Shell Integration

Zsh configuration (`modules/zsh.nix`) uses a hybrid approach:
- Core shell settings managed by home-manager
- Modular config files in `config/zsh/` sourced via `initContent`
- This allows sharing shell config snippets across different setups

### Direnv Integration

Direnv (`modules/direnv.nix`) automatically loads project-specific nix shells when entering directories with `.envrc` files. Configuration uses nix-direnv for better caching of nix develop environments.

### Neovim Hybrid Architecture

Neovim uses a **hybrid approach** combining Nix and lazy.nvim:

**Nix Manages (Declarative & Reproducible):**
- Neovim package itself
- lazy.nvim plugin manager (from nixpkgs)
- Treesitter parsers (pre-compiled, avoids build issues)
- Build dependencies (gcc/clang, make, nodejs, tree-sitter)
- Configuration files (init.lua, lua/, lazy-lock.json)

**Lazy.nvim Manages (Fast Iteration):**
- Plugin installation and updates (`:Lazy update`)
- Plugin lazy-loading and startup optimization
- Plugin version locking (tracked in lazy-lock.json)

**Why This Hybrid Approach:**
1. **Fast iteration**: `:source %` and `:Lazy reload` for instant feedback (no rebuild)
2. **Nix solves hard problems**: Treesitter compilation, C dependencies
3. **Access full ecosystem**: Use any plugin from GitHub, not just nixpkgs
4. **Community configs**: Copy Lua configs directly from community
5. **Reproducibility**: lazy-lock.json tracked in git, Nix handles core components
6. **Easy debugging**: Pure Lua config, no Nix DSL translation needed

**Plugin Version Control:**
- Plugin versions locked in `config/nvim/lazy-lock.json` (tracked in git)
- Update all plugins: `:Lazy update` in neovim
- Restore versions: `git restore config/nvim/lazy-lock.json && :Lazy restore`
- Rollback entire config: `home-manager switch --rollback`

This approach provides the best of both worlds: Nix's reproducibility for system dependencies, and lazy.nvim's speed for plugin management.

### Git Configuration

Git settings use home-manager's unified `settings` structure (24.05+), not the legacy `extraConfig` format. All git configuration is in `modules/git.nix` with neovim as the diff/merge tool.

## Adding New Packages

1. Search for package: `nix search nixpkgs <package-name>`
2. Edit `modules/packages.nix`
3. Add to the appropriate section in `home.packages`
4. Apply changes: `home-manager switch --flake .#khuang@ubuntu`

## Package Management Best Practices

All packages should be managed through home-manager in `modules/packages.nix` for consistency and reproducibility. Avoid using `nix profile install` directly, as it can create conflicts during home-manager activation.

To add packages:
1. Search: `nix search nixpkgs <package-name>`
2. Add to `modules/packages.nix` in the appropriate section
3. Apply: `home-manager switch --flake .#your-config-name`

If you have packages in your nix profile that conflict, remove them first using the newer nix version:
```bash
/nix/store/*-nix-*/bin/nix profile remove <package-name>
```

## Configuration File Naming

When creating new feature modules:
- Use descriptive names: `modules/tool-name.nix`
- Keep one tool per module for clarity
- Import the module in `home.nix`

## Adding New Configurations

To add a new machine configuration:
1. Create platform-specific settings in `home/linux.nix` or `home/darwin.nix` (or create new file)
2. Add new configuration in `flake.nix` using the `mkHome` helper
3. Specify system, username, hostname, and extraModules
4. Apply with: `home-manager switch --flake .#your-config-name`

## Migration Strategy

This repository follows a staged migration approach from an existing ~/devcfg setup:
- Stage 1 (✅ COMPLETE): LSP servers, dev tools, git config managed by home-manager
- Stage 2 (✅ COMPLETE): Full tmux, zsh, neovim, clangd management
- Stage 3 (✅ COMPLETE): macOS support with platform-specific configurations
- Stage 4 (✅ COMPLETE): All nix profile packages migrated to home-manager
- Stage 5 (⏭️ FUTURE): NixOS system configuration

**Current Status:** All development tools and packages are fully managed by home-manager across both Linux and macOS platforms. The old ~/devcfg directory has been archived to ~/devcfg-backup-YYYYMMDD.tar.gz.
