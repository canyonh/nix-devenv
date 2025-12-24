# Nix Development Environment

Cross-platform development environment using Nix and home-manager.

## Overview

This repository provides a declarative, reproducible development environment that works across:
- ✅ Ubuntu Linux (current laptop)
- ✅ macOS (future - Stage 3)
- ✅ NixOS (future - Stage 5)

## Current Status: Stage 1

**What's managed by home-manager:**
- Git configuration
- LSP servers (clangd, pyright, nil, lua-ls, etc.)
- Development tools (ripgrep, fd, fzf, etc.)
- Direnv integration for auto-loading project shells

**What's NOT managed yet (still using ~/devcfg):**
- Neovim configuration (keeping existing ~/devcfg/.config/nvim)
- Tmux configuration (keeping existing ~/devcfg/tmux/.tmux.conf)
- Zsh configuration (keeping existing ~/devcfg/.config/zsh)

**Coexists with:**
- Existing `nix profile` packages (latticectl, yubikey-cli, cachix)
- Existing dotfile symlinks from ~/devcfg

## Project Structure

```
nix-devenv/
├── flake.nix              # Entry point, defines all system configurations
├── flake.lock             # Locked dependency versions (auto-generated)
├── home.nix               # Main home-manager config, imports all modules
├── home/
│   ├── common.nix         # Shared configuration across all platforms
│   ├── linux.nix          # Linux-specific configuration
│   └── darwin.nix         # macOS-specific (future - Stage 3)
├── modules/
│   ├── git.nix           # Git configuration
│   ├── packages.nix      # LSP servers and dev tools
│   └── direnv.nix        # Direnv setup
└── README.md             # This file
```

## Prerequisites

- Nix 2.18+ installed with flakes enabled
  - Check: `nix --version` and `nix show-config | grep experimental-features`
  - ✅ Already installed on your system

## Installation

### Step 1: Test Configuration (Dry Run)

See what would change without actually applying:

```bash
cd ~/nix-devenv

# Dry-run shows what will happen
nix run home-manager/master -- switch --flake .#khuang@ubuntu-laptop --dry-run
```

Review the output to see:
- What packages will be installed
- What symlinks will be created
- Any potential conflicts

### Step 2: First Activation

If the dry-run looks good, activate home-manager:

```bash
cd ~/nix-devenv

# Activate home-manager
nix run home-manager/master -- switch --flake .#khuang@ubuntu-laptop
```

**What happens:**
- Installs LSP servers and dev tools
- Creates git configuration
- Sets up direnv integration
- Adds packages to `~/.nix-profile` (managed by home-manager)

**What DOESN'T happen:**
- Your existing nvim/tmux/zsh configs are untouched
- Your nix profile packages (latticectl, yubikey-cli, cachix) remain accessible
- No conflicts with existing dotfiles

### Step 3: Reload Shell

After activation, reload your shell to pick up changes:

```bash
# If using zsh
source ~/.zshrc

# Or just open a new terminal
```

### Step 4: Verify Installation

Check that everything works:

```bash
# Check LSP servers are installed
which clangd
which pyright
which nil
which lua-language-server

# Check dev tools
which rg       # ripgrep
which fd
which fzf

# Check direnv is enabled
direnv --version

# Check git config
git config --get user.name
git config --get user.email

# Verify old nix profile packages still work
which latticectl
which yubikey-cli
which cachix
```

## Usage

### Managing Packages

To add new packages, edit `modules/packages.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...

  # Add your new package here
  htop
  neofetch
];
```

Then apply changes:

```bash
cd ~/nix-devenv
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Updating Packages

Update all packages to latest versions:

```bash
cd ~/nix-devenv

# Update flake.lock to latest versions
nix flake update

# Apply updates
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Viewing Generations

home-manager keeps history of all configurations (like git commits):

```bash
# List all generations
home-manager generations

# Output shows:
# 2024-12-24 15:30 : id 3 -> /nix/store/xxx-home-manager-generation-3
# 2024-12-24 14:00 : id 2 -> /nix/store/yyy-home-manager-generation-2
# 2024-12-24 12:00 : id 1 -> /nix/store/zzz-home-manager-generation-1
```

### Rolling Back

If something breaks, easily rollback:

```bash
# Rollback to previous generation
home-manager switch --rollback

# Or activate a specific generation
/nix/store/xxx-home-manager-generation-2/activate
```

### Working with Project Shells

Your work repos use their own nix shells. home-manager works alongside them:

**Repos with .envrc (auto-loads):**
```bash
cd ~/source/autonomy-divexl
# direnv automatically loads the project shell
# LSP servers from project are now in PATH
```

**Repos without .envrc (manual):**
```bash
cd ~/source/dive-xl-payloads
nix develop
# Now in project shell with project-specific tools
```

**LSP Server Priority:**
1. Project shell (if active) - most specific
2. home-manager packages - your defaults
3. System packages - fallback

This means:
- In dive-xl-payloads shell → uses project's clangd for ARM cross-compile
- Outside project shell → uses home-manager's clangd for general C++ editing
- LSP always available!

## Troubleshooting

### Issue: Package conflicts with nix profile

**Symptom:** You installed a package with `nix profile install` and now it conflicts with home-manager.

**Solution:** Remove from nix profile and add to home-manager:
```bash
# See what's in nix profile
nix profile list

# Remove conflicting package (by index)
nix profile remove 0

# Add to modules/packages.nix instead
# Then: home-manager switch --flake .#khuang@ubuntu-laptop
```

### Issue: LSP server not found in editor

**Symptom:** Neovim can't find clangd/pyright/etc.

**Solution:** Check PATH:
```bash
echo $PATH | tr ':' '\n' | grep nix

# Should see:
# /home/khuang/.nix-profile/bin  ← home-manager packages

# Test LSP is installed
which clangd
clangd --version
```

If not in PATH, reload shell:
```bash
source ~/.zshrc  # or open new terminal
```

### Issue: direnv not loading project shells

**Symptom:** cd into project, but direnv doesn't activate.

**Solution:**
```bash
# For repos with .envrc, allow direnv
cd ~/source/autonomy-divexl
direnv allow

# For repos without .envrc, you must manually run:
nix develop
```

### Issue: Want to uninstall home-manager

**Symptom:** Want to go back to old setup.

**Solution:**
```bash
# Uninstall home-manager
home-manager uninstall

# Your old configs still work!
# ~/.config/nvim still points to ~/devcfg/.config/nvim
# ~/.tmux.conf still points to ~/devcfg/tmux/.tmux.conf
```

## Migration Roadmap

### Stage 1: Foundation (Current) ✅
- ✅ home-manager setup
- ✅ Git configuration
- ✅ LSP servers installed
- ✅ Development tools installed
- ✅ Direnv integration
- ✅ Coexists with existing ~/devcfg setup

### Stage 2: Migrate Core Tools (Future)
- [ ] Migrate tmux config to home-manager
- [ ] Migrate zsh config to home-manager
- [ ] Manage neovim package (keep Lua configs)
- [ ] Remove old install scripts from ~/devcfg

### Stage 3: macOS Support (Future)
- [ ] Test on macOS machine
- [ ] Add nix-darwin configuration
- [ ] Handle macOS-specific differences
- [ ] Create home/darwin.nix

### Stage 4: Cleanup (Future)
- [ ] Migrate nix profile packages to home-manager
- [ ] Delete all install scripts from ~/devcfg
- [ ] Archive old ~/devcfg setup

### Stage 5: NixOS Desktop (When Hardware Available)
- [ ] Add NixOS system configuration
- [ ] Full system + home-manager integration
- [ ] Hardware-specific configuration

## FAQ

**Q: Will this break my existing setup?**
A: No! Stage 1 doesn't touch your existing nvim/tmux/zsh configs. They continue to work via symlinks.

**Q: Can I use both nix profile and home-manager?**
A: Yes, but it's recommended to eventually migrate everything to home-manager for consistency.

**Q: What happens to my latticectl/yubikey-cli/cachix packages?**
A: They remain in your nix profile and stay accessible. You can migrate them to home-manager later.

**Q: How do I add a new LSP server?**
A: Edit `modules/packages.nix`, add the package, then run `home-manager switch --flake .#khuang@ubuntu-laptop`.

**Q: Do I need to run nix develop in every project?**
A: For projects with `.envrc`, direnv auto-loads them. For others, yes, manually run `nix develop`.

**Q: Can I customize this for my personal machine?**
A: Yes! Fork this repo, modify configs, and use on any machine with Nix installed.

## Resources

- [home-manager documentation](https://nix-community.github.io/home-manager/)
- [Nix flakes reference](https://nixos.wiki/wiki/Flakes)
- [direnv documentation](https://direnv.net/)
- [Nix package search](https://search.nixos.org/packages)

## Support

Issues or questions? Check:
1. This README's Troubleshooting section
2. Run with `--show-trace` for detailed errors: `home-manager switch --flake .#khuang@ubuntu-laptop --show-trace`
3. Check home-manager logs: `journalctl --user -u home-manager-*`
