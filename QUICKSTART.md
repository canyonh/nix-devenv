# Quick Start Guide

Get up and running with home-manager in 5 minutes.

## Step 1: Dry-Run (See What Will Happen)

```bash
cd ~/nix-devenv
nix run home-manager/master -- switch --flake .#khuang@ubuntu-laptop --dry-run
```

This shows what will be installed without actually doing it.

## Step 2: Activate home-manager

If the dry-run looks good:

```bash
cd ~/nix-devenv
nix run home-manager/master -- switch --flake .#khuang@ubuntu-laptop
```

This will take a few minutes on first run as it downloads packages.

## Step 3: Reload Your Shell

```bash
source ~/.zshrc
# or open a new terminal
```

## Step 4: Verify Everything Works

```bash
# Check LSP servers
which clangd
which pyright
which nil

# Check dev tools
which rg
which fd
which fzf

# Check old packages still work
which latticectl
which yubikey-cli

# Check direnv
direnv --version
```

## Daily Usage

### Update packages to latest:
```bash
cd ~/nix-devenv
nix flake update
home-manager switch --flake .#khuang@ubuntu-laptop
```

### Add new package:
1. Edit `modules/packages.nix`
2. Add package to `home.packages` list
3. Run: `home-manager switch --flake .#khuang@ubuntu-laptop`

### Rollback if something breaks:
```bash
home-manager generations  # See history
home-manager switch --rollback  # Go back one step
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

## Next Steps

- Read full [README.md](README.md) for detailed documentation
- Customize packages in `modules/packages.nix`
- Eventually migrate tmux/zsh/neovim (Stage 2)

That's it! You now have a reproducible development environment. 🎉
