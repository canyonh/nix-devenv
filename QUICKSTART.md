# Quick Start Guide

Get up and running with home-manager in 5 minutes.

## Initial Setup (First Time Only)

### Step 1: Build Configuration

```bash
cd ~/nix-devenv
nix build '.#homeConfigurations."khuang@ubuntu-laptop".activationPackage'
```

This downloads and builds all packages (takes 5-10 minutes first time).

### Step 2: Activate home-manager

```bash
./result/activate
```

Applies the configuration and installs packages.

### Step 3: Reload Your Shell

```bash
source ~/.zshrc
# or open a new terminal
```

### Step 4: Verify Everything Works

```bash
# Check LSP servers
which clangd pyright nil lua-language-server

# Check versions
clangd --version
pyright --version

# Check dev tools
which fd fzf jq bat

# Check old packages still work
which latticectl yubikey cachix

# Check git config
git config --get user.name
```

### Step 5 (Optional): Enable direnv Auto-Loading

Add to `~/devcfg/.config/zsh/.zshrc`:

```bash
# Add at the end of file
eval "$(direnv hook zsh)"
```

Then reload: `source ~/.zshrc`

## Daily Usage

### Apply Changes After Editing Config

```bash
cd ~/nix-devenv
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Update All Packages to Latest Versions

```bash
cd ~/nix-devenv
nix flake update
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Add a New Package

1. Search for package: `nix search nixpkgs <name>`
2. Edit `modules/packages.nix`
3. Add to `home.packages` list
4. Apply: `home-manager switch --flake .#khuang@ubuntu-laptop`

### List Installed Packages

```bash
home-manager packages
```

### View History

```bash
home-manager generations
```

### Rollback

```bash
home-manager switch --rollback  # Go back one generation
```

## Working with Project Shells

### autonomy-divexl (has .envrc):
```bash
cd ~/source/autonomy-divexl
direnv allow  # First time only
# Shell automatically loads!
```

### dive-xl-payloads (no .envrc):
```bash
cd ~/source/dive-xl-payloads
nix develop  # Manual activation
```

## Troubleshooting

**LSP not found in neovim?**
- Reload shell: `source ~/.zshrc`
- Check PATH: `which clangd`

**Package conflict?**
- See what's in nix profile: `nix profile list`
- Remove from profile: `nix profile remove <index>`
- Add to home-manager instead

**Want to undo everything?**
```bash
home-manager uninstall
```

## Command Cheatsheet

```bash
# Apply config changes
home-manager switch --flake ~/nix-devenv#khuang@ubuntu-laptop

# Update everything
nix flake update && home-manager switch --flake ~/nix-devenv#khuang@ubuntu-laptop

# List packages
home-manager packages

# Search for package
nix search nixpkgs <package>

# View generations
home-manager generations

# Rollback
home-manager switch --rollback

# Clean up old generations
nix-collect-garbage -d

# Check package version
nix eval nixpkgs#<package>.version

# Rebuild after editing
cd ~/nix-devenv && home-manager switch --flake .#khuang@ubuntu-laptop
```

## What You Have Now

**✅ Installed LSP Servers:**
- clangd (C/C++)
- pyright (Python)
- pylsp (Python alternative)
- nil (Nix)
- lua-language-server (Lua)
- bash-language-server (Shell)
- cmake-language-server (CMake)
- yaml-language-server (YAML)

**✅ Development Tools:**
- fd, fzf, bat, jq, htop, tree
- git, git-lfs, tig
- cmake, ninja
- direnv, nix-direnv

**✅ Coexisting Safely:**
- Your nvim config unchanged
- Your tmux config unchanged
- Your zsh config unchanged
- Old nix profile packages (latticectl, yubikey, cachix) still work

## Next Steps

- Read full [README.md](README.md) for detailed documentation
- Customize packages in `modules/packages.nix`
- Eventually migrate tmux/zsh/neovim (Stage 2)

That's it! You now have a reproducible development environment. 🎉
