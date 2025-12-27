# Neovim Plugin Management Workflow

**Date:** 2025-12-27

---

## 📋 Overview

Your neovim uses a **hybrid approach**:
- **Nix** provides: treesitter parsers (pre-compiled), build tools
- **Lazy.nvim** (git bootstrap) manages: lazy.nvim itself + all other plugins
- **Git** tracks: Plugin versions in `lazy-lock.json`

## 🔄 Plugin Update Workflow

### Updating Plugins

```bash
# 1. Open neovim
nvim

# 2. Check for plugin updates
:Lazy check

# 3. Update all plugins (or select specific ones in UI)
:Lazy update

# 4. Test that everything works
# ... use neovim normally, verify no breaking changes ...

# 5. If satisfied, sync lazy-lock.json to git
cd ~/nix-devenv
cp ~/.config/nvim/lazy-lock.json config/nvim/lazy-lock.json

# 6. Commit the new versions
git add config/nvim/lazy-lock.json
git commit -m "Update neovim plugins"
git push
```

### Restoring Plugin Versions

```bash
# Option 1: Restore from git (undo recent updates)
cd ~/nix-devenv
git restore config/nvim/lazy-lock.json
cp config/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json

# Then in neovim:
nvim
:Lazy restore

# Option 2: Rollback to previous commit
git checkout <commit-hash> -- config/nvim/lazy-lock.json
cp config/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json
# Then: nvim -> :Lazy restore
```

### Deploying to Another Machine

```bash
# On new machine (after home-manager setup):
cd ~/nix-devenv
git pull

# Copy lazy-lock.json to config directory
cp config/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json

# First time opening neovim, lazy.nvim will install all plugins
nvim
# Plugins automatically installed!
```

---

## ⚠️ Important Notes

### Why lazy.nvim Bootstraps from Git (Not Provided by Nix)

**Problem:** Nix store is read-only. lazy.nvim needs to generate helptags when it loads.

**Solution:** lazy.nvim bootstraps from git (standard approach) into `~/.local/share/nvim/lazy/lazy.nvim`.

**Reproducibility:** lazy-lock.json tracks lazy.nvim's version along with all other plugins.

### Why lazy-lock.json is NOT Linked by Home-manager

**Problem:** lazy.nvim needs to **write** to `lazy-lock.json` when updating plugins.

**Solution:** `lazy-lock.json` is a **regular writable file** in `~/.config/nvim/`, not a symlink.

**Trade-off:**
- ✅ Lazy.nvim can update plugins (`:Lazy update` works)
- ⚠️ You must manually copy `lazy-lock.json` to git after updates

### File Locations

```
~/.config/nvim/
├── init.lua                 → symlink to Nix store (read-only)
├── lua/                     → symlink to Nix store (read-only)
└── lazy-lock.json           → writable file (NOT linked)

~/nix-devenv/config/nvim/
├── init.lua                 → source file in git
├── lua/                     → source directory in git
└── lazy-lock.json           → tracked in git (manual sync)
```

---

## 🎯 Quick Reference

### Daily Usage

```bash
# Update plugins
nvim → :Lazy update

# Sync to git (after testing)
cp ~/.config/nvim/lazy-lock.json ~/nix-devenv/config/nvim/lazy-lock.json
cd ~/nix-devenv && git add config/nvim/lazy-lock.json && git commit -m "Update plugins"
```

### Adding New Plugins

```bash
# 1. Create plugin config
nvim ~/nix-devenv/config/nvim/lua/kxhuan/plugins/my-plugin.lua

# Add plugin spec:
# return {
#   "author/plugin-name",
#   config = function() ... end,
# }

# 2. Restart neovim or reload
nvim → :Lazy reload

# 3. Plugin is auto-installed

# 4. Commit config AND lazy-lock.json
cd ~/nix-devenv
git add config/nvim/lua/kxhuan/plugins/my-plugin.lua
cp ~/.config/nvim/lazy-lock.json config/nvim/lazy-lock.json
git add config/nvim/lazy-lock.json
git commit -m "Add my-plugin"
```

### Removing Plugins

```bash
# 1. Delete plugin config file
rm ~/nix-devenv/config/nvim/lua/kxhuan/plugins/unwanted-plugin.lua

# 2. Restart neovim
nvim → :Lazy clean

# 3. Sync lazy-lock.json
cp ~/.config/nvim/lazy-lock.json ~/nix-devenv/config/nvim/lazy-lock.json
git add config/nvim/lazy-lock.json
git rm config/nvim/lua/kxhuan/plugins/unwanted-plugin.lua
git commit -m "Remove unwanted-plugin"
```

---

## 🔧 New Keybindings Added

### Gitsigns (Git Hunks)

- `]c` - Next git hunk
- `[c` - Previous git hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line
- `<leader>hd` - Diff this
- `<leader>hS` - Stage entire buffer
- `<leader>hR` - Reset entire buffer
- `ih` - Text object: select hunk

### LSP Keymaps (Enhanced)

**Navigation:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `gI` - Go to implementation
- `gt` - Go to type definition
- `gr` - Show references (Telescope)

**Documentation:**
- `K` - Show hover documentation (**NEW!**)
- `gK` - Show signature help

**Actions:**
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol

**Diagnostics:**
- `[d` - Previous diagnostic (**NEW!**)
- `]d` - Next diagnostic (**NEW!**)
- `<leader>d` - Show diagnostic in float (**NEW!**)
- `<leader>q` - Open diagnostic location list

### Snippets (New!)

**In Insert Mode:**
- `<C-k>` - Expand snippet or jump to next placeholder
- `<C-j>` - Jump to previous placeholder

**Completion:**
- `<Tab>` - Next completion item
- `<S-Tab>` - Previous completion item
- `<CR>` - Confirm selection
- `<C-Space>` - Trigger completion

### Which-key (New!)

Press `<leader>` and wait briefly - a popup will show all available keybindings!

**Organized groups:**
- `<leader>e` - Explorer (nvim-tree)
- `<leader>f` - Find (telescope)
- `<leader>g` - Format (conform)
- `<leader>h` - Git Hunk (gitsigns)
- `<leader>s` - Split windows
- `<leader>t` - Tabs
- `<leader>x` - Diagnostics

---

## 📚 Plugin List (Managed by Lazy.nvim)

Run `:Lazy` in neovim to see all installed plugins and their status.

**Core Plugins:**
- lazy.nvim (git bootstrap, version tracked in lazy-lock.json)
- nvim-treesitter (from Nix, pre-compiled parsers)
- nvim-lspconfig
- nvim-cmp + sources
- LuaSnip + friendly-snippets (**NEW!**)
- telescope.nvim + fzf-native
- which-key.nvim (**NEW!**)
- gitsigns.nvim (now fully configured!)
- conform.nvim
- nvim-tree.lua
- nvim-dap + dapui
- tokyonight.nvim
- and more...

---

## 🎉 What's New

### Just Added (Week 1 Quick Wins)

1. **✅ Gitsigns fully configured** - Was completely empty before!
   - Stage/reset hunks with `<leader>hs` / `<leader>hr`
   - Navigate hunks with `]c` / `[c`
   - Preview and blame with `<leader>hp` / `<leader>hb`

2. **✅ Which-key.nvim added** - Discover keybindings as you type!
   - Press `<leader>` and wait to see all options
   - Organized into logical groups

3. **✅ LSP keymaps enhanced** - Added essential missing keymaps
   - `K` for hover documentation (was missing!)
   - `[d` / `]d` for diagnostic navigation (was missing!)
   - `<leader>d` for diagnostic float
   - Better organized keymap structure

4. **✅ Snippet support added** - LuaSnip + friendly-snippets
   - Full snippet engine for better LSP completions
   - `<C-k>` / `<C-j>` to navigate placeholders
   - Pre-configured snippets for many languages

### Configuration Files Changed

```
config/nvim/lua/kxhuan/plugins/
├── gitsigns.lua         (4 lines → 48 lines)
├── which-key.lua        (NEW! 51 lines)
├── nvim-cmp.lua         (snippet support added)
└── lsp/lspconfig.lua    (enhanced keymaps)
```

---

## 💡 Tips

1. **Check plugin health**: `:checkhealth lazy`
2. **View plugin logs**: `:Lazy log`
3. **Profile startup**: `:Lazy profile`
4. **Update single plugin**: `:Lazy update <plugin-name>`
5. **Pin plugin version**: Add `pin = true` to plugin spec

---

## 🐛 Troubleshooting

### Plugins Not Loading

```bash
# Check lazy.nvim status
nvim → :Lazy

# Force reload
nvim → :Lazy reload

# Clear cache and reinstall
rm -rf ~/.local/share/nvim/lazy
nvim  # Plugins will reinstall
```

### lazy-lock.json Out of Sync

```bash
# Your ~/.config/nvim/lazy-lock.json is the "truth"
# Sync it to git:
cp ~/.config/nvim/lazy-lock.json ~/nix-devenv/config/nvim/lazy-lock.json

# Or restore from git:
cp ~/nix-devenv/config/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json
```

### Which-key Not Showing

```bash
# Check which-key is installed
nvim → :Lazy

# Reload config
nvim → :source $MYVIMRC
```

---

**Remember:** Plugin versions are tracked in `lazy-lock.json`. After updating plugins, copy it to git!

**Workflow:** `:Lazy update` → Test → `cp ~/.config/nvim/lazy-lock.json ~/nix-devenv/config/nvim/` → `git commit`
