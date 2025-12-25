# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix-based home-manager configuration for managing development environments across multiple platforms (Ubuntu Linux, macOS, NixOS). The repository uses Nix flakes for declarative, reproducible development environments.

## Essential Commands

### Applying Configuration Changes
```bash
cd ~/nix-devenv
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Testing Changes (Dry Run)
```bash
home-manager switch --flake .#khuang@ubuntu-laptop --dry-run
```

### Updating All Packages
```bash
nix flake update
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Debugging Build Errors
```bash
home-manager switch --flake .#khuang@ubuntu-laptop --show-trace
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
   - `linux.nix` - Linux-specific settings
   - Future: `darwin.nix` for macOS support

4. **`modules/` directory** - Feature-based configuration modules
   - Each module configures one tool/aspect (git, packages, direnv, tmux, zsh, neovim)
   - Modules are imported by `home.nix`
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

### Current System Configuration

The active configuration is `khuang@ubuntu-laptop`:
- Platform: x86_64-linux
- Username: khuang
- Hostname: khuang-5690-ubuntu
- Imports: `home/linux.nix` plus all feature modules

## Key Technical Details

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

### Git Configuration

Git settings use home-manager's unified `settings` structure (24.05+), not the legacy `extraConfig` format. All git configuration is in `modules/git.nix` with neovim as the diff/merge tool.

## Adding New Packages

1. Search for package: `nix search nixpkgs <package-name>`
2. Edit `modules/packages.nix`
3. Add to the appropriate section in `home.packages`
4. Apply changes: `home-manager switch --flake .#khuang@ubuntu-laptop`

## Working with Existing nix profile Packages

Some packages (latticectl, yubikey-cli, cachix) are in the user's nix profile, not home-manager. These coexist without conflicts. To migrate them to home-manager, add to `modules/packages.nix` and remove from profile with `nix profile remove <index>`.

## Configuration File Naming

When creating new feature modules:
- Use descriptive names: `modules/tool-name.nix`
- Keep one tool per module for clarity
- Import the module in `home.nix`

## Platform-Specific Development

To add macOS support:
1. Create `home/darwin.nix` with macOS-specific settings
2. Uncomment macOS configuration in `flake.nix`
3. Adjust `mkHome` call with appropriate system string

## Migration Strategy

This repository follows a staged migration approach from an existing ~/devcfg setup:
- Stage 1 (complete): LSP servers, dev tools, git config managed by home-manager
- Stage 2 (complete): Full tmux, zsh, neovim, clangd management - ~/devcfg no longer needed
- Stage 3 (future): macOS support via nix-darwin
- Stage 4 (future): Migrate remaining nix profile packages
- Stage 5 (future): NixOS system configuration

All core development tools are now managed by home-manager. The old ~/devcfg directory can be archived/removed (see STAGE2_CLEANUP.md).
