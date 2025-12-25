# Stage 2 Cleanup Guide

Stage 2 migration is complete! All core tools are now managed by home-manager.

## What Was Migrated

The following configurations have been successfully migrated from `~/devcfg` to this repository:

- ✅ **Neovim** (`~/.config/nvim`) → `config/nvim/`
- ✅ **Tmux** (`~/.tmux.conf`) → `config/tmux/`
- ✅ **Zsh** (`~/.zshrc`, zsh modules) → `config/zsh/`
- ✅ **Clangd** (`~/.config/clangd`) → `config/clangd/`
- ✅ **Git** configuration → `modules/git.nix`

## Ready for Cleanup

The `~/devcfg` directory is now obsolete and can be archived or removed.

### Install Scripts (No Longer Needed)

These install scripts in `~/devcfg/` are replaced by Nix packages:

```
apt-install-neovim.sh       → Neovim managed by home-manager
apt-install.sh              → Packages managed by modules/packages.nix
dnf-install.sh              → Packages managed by modules/packages.nix
homebrew-install.sh         → Packages managed by modules/packages.nix
install-alacritty.sh        → Can be added to modules/packages.nix if needed
install-bcc.sh              → Can be added to modules/packages.nix if needed
install-bpfcc-tools.sh      → Can be added to modules/packages.nix if needed
install-mold.sh             → Can be added to modules/packages.nix if needed
install-mongodb.sh          → Can be added to modules/packages.nix if needed
install_nerd_fonts.sh       → Fonts can be managed via home-manager
install-zsh.sh              → Zsh managed by home-manager
setup-gdb.sh                → Can be migrated to a module if needed
setup-git.sh                → Git managed by modules/git.nix
setup-neovim.sh             → Neovim managed by home-manager
setup-tmux.sh               → Tmux managed by home-manager
bootstrap.sh                → No longer needed (use home-manager switch)
```

### Config Files (Migrated)

These config directories in `~/devcfg/.config/` have been migrated:

```
~/devcfg/.config/nvim/      → nix-devenv/config/nvim/
~/devcfg/.config/zsh/       → nix-devenv/config/zsh/
~/devcfg/.config/clangd/    → nix-devenv/config/clangd/
```

### Other Directories

```
~/devcfg/tmux/              → Migrated to nix-devenv/config/tmux/
~/devcfg/gdb/               → Can be migrated to nix-devenv/config/gdb/ if needed
```

## Cleanup Steps (Optional)

**⚠️ IMPORTANT: Make sure everything works before removing ~/devcfg!**

### Step 1: Verify Everything Works

Test all your tools to ensure they work correctly:

```bash
# Test neovim
nvim

# Test tmux
tmux

# Test zsh (restart shell)
exec zsh

# Test clangd (open a C++ file in neovim and check LSP)
nvim some_cpp_file.cpp

# Verify git config
git config --get user.name
git config --get user.email
```

### Step 2: Archive ~/devcfg (Recommended)

Instead of deleting, archive it first:

```bash
# Create backup
cd ~
tar czf devcfg-backup-$(date +%Y%m%d).tar.gz devcfg/

# Move backup to safe location
mv devcfg-backup-*.tar.gz ~/Backups/  # or wherever you keep backups
```

### Step 3: Remove ~/devcfg (When Ready)

Only after you're confident everything works:

```bash
# Remove the old directory
rm -rf ~/devcfg
```

## If Something Goes Wrong

If you need to rollback:

```bash
# Rollback home-manager
home-manager switch --rollback

# Or restore from backup
cd ~
tar xzf ~/Backups/devcfg-backup-*.tar.gz
```

## What's Next

With Stage 2 complete, you can now:

1. **Stage 3**: Add macOS support (when you have a Mac)
2. **Stage 4**: Migrate remaining nix profile packages to home-manager
3. **Stage 5**: Set up full NixOS system configuration (when you get NixOS hardware)

All your development environment is now:
- ✅ Declarative
- ✅ Reproducible
- ✅ Version controlled
- ✅ Easy to deploy on new machines
