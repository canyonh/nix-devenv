# Neovim Hybrid Setup Improvements - Summary

**Date:** 2025-12-27
**Status:** ✅ COMPLETE

---

## 🎯 What Was Done

Enhanced the neovim hybrid setup to combine the best of Nix reproducibility with lazy.nvim's fast iteration.

## ✅ Changes Made

### 1. Added lazy.nvim to Nix-Provided Plugins

**File:** `modules/neovim.nix`

**Change:**
```nix
plugins = with pkgs.vimPlugins; [
  # NEW: Lazy.nvim plugin manager itself (from Nix for reproducibility)
  lazy-nvim

  # Existing: Treesitter with pre-compiled parsers
  (nvim-treesitter.withPlugins (p: [ ... ]))
  nvim-ts-autotag
];
```

**Benefit:** lazy.nvim version now managed by Nix, can rollback with home-manager.

---

### 2. Added lazy-lock.json to Version Control

**Files:**
- Copied `~/.config/nvim/lazy-lock.json` → `config/nvim/lazy-lock.json`
- Removed from `.gitignore`
- Added to git tracking
- Linked in home-manager: `xdg.configFile."nvim/lazy-lock.json".source`

**Benefit:** Plugin versions are now tracked in git and reproducible across machines.

---

### 3. Updated lazy.lua Bootstrap Logic

**File:** `config/nvim/lua/kxhuan/lazy.lua`

**Before:**
```lua
-- Always bootstrap from git
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", ... })
end
```

**After:**
```lua
-- Prefer Nix-provided lazy.nvim, fallback to git bootstrap
local has_nix_lazy = false
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
  if path:match("lazy%-nvim") then
    has_nix_lazy = true
    break
  end
end

-- Only bootstrap from git if not provided by Nix
if not has_nix_lazy then
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", ... })
  end
  vim.opt.rtp:prepend(lazypath)
end

-- Explicit lockfile location
require("lazy").setup(..., {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  ...
})
```

**Benefits:**
- Uses Nix-provided lazy.nvim when available
- Falls back to git bootstrap on non-Nix systems
- Explicit lockfile location for reproducibility

---

### 4. Added Documentation to CLAUDE.md

**New Section:** "Neovim Hybrid Architecture"

**Content:**
- Explains what Nix manages vs lazy.nvim manages
- Why this hybrid approach is better than pure Nix
- Plugin version control workflow
- Rollback procedures

---

## 🎉 Results

### What You Now Have

**Reproducibility:**
- ✅ lazy.nvim version controlled by Nix
- ✅ Plugin versions tracked in lazy-lock.json (git)
- ✅ Treesitter parsers pre-compiled by Nix
- ✅ LSP servers and dependencies from Nix
- ✅ Can rollback with `home-manager switch --rollback`

**Fast Iteration:**
- ✅ Update plugins: `:Lazy update` (instant)
- ✅ Reload config: `:source %` (instant)
- ✅ Test changes: No rebuild needed
- ✅ Copy community configs: Direct Lua paste

**Version Control:**
```bash
# View plugin versions
cat config/nvim/lazy-lock.json

# Update all plugins
nvim → :Lazy update

# Commit new versions
git add config/nvim/lazy-lock.json
git commit -m "Update neovim plugins"

# Restore old versions
git restore config/nvim/lazy-lock.json
nvim → :Lazy restore

# Rollback entire config
home-manager switch --rollback
```

---

## 📋 Workflow Examples

### Updating Neovim Plugins

```bash
# 1. Open neovim
nvim

# 2. Check for plugin updates
:Lazy check

# 3. Update all plugins
:Lazy update

# 4. Test that everything works
# ... use neovim normally ...

# 5. If satisfied, commit the new versions
git add config/nvim/lazy-lock.json
git commit -m "Update neovim plugins"

# 6. If something breaks, restore old versions
git restore config/nvim/lazy-lock.json
# Then in nvim: :Lazy restore
```

### Adding a New Plugin

```bash
# 1. Edit plugin config
nvim config/nvim/lua/kxhuan/plugins/my-new-plugin.lua

# 2. Add plugin spec
# return {
#   "author/plugin-name",
#   config = function() ... end,
# }

# 3. Restart neovim or :Lazy reload
# Plugin is automatically installed

# 4. Commit both the config and lockfile
git add config/nvim/lua/kxhuan/plugins/my-new-plugin.lua
git add config/nvim/lazy-lock.json
git commit -m "Add my-new-plugin"
```

### Deploying to Another Machine

```bash
# On new machine (after home-manager setup):
cd ~/nix-devenv
home-manager switch --flake .#khuang@macbook

# lazy.nvim provided by Nix ✅
# lazy-lock.json copied to ~/.config/nvim/ ✅
# All plugins installed automatically on first nvim run ✅
```

---

## 🔄 Comparison: Before vs After

| Aspect | Before | After |
|--------|--------|-------|
| **lazy.nvim version** | Git bootstrap | Nix package (rollback-able) |
| **Plugin versions** | Not tracked | Tracked in git (lazy-lock.json) |
| **Reproducibility** | Partial | Full (Nix + git) |
| **Iteration speed** | Fast ✅ | Fast ✅ (unchanged) |
| **Rollback** | Manual git restore | `home-manager switch --rollback` |
| **Cross-machine** | Manual setup | Automatic (home-manager) |

---

## 📚 Related Documents

- **NEOVIM_REVIEW.md** - Plugin audit and improvement suggestions
- **NEOVIM_NIX_ANALYSIS.md** - Why hybrid > pure Nix for your use case
- **CLAUDE.md** - Updated with hybrid architecture documentation

---

## ✅ Next Steps (Optional)

From NEOVIM_REVIEW.md, consider these high-priority improvements:

1. **Add snippet support** (LuaSnip + friendly-snippets)
2. **Configure gitsigns properly** (add keymaps)
3. **Add which-key.nvim** (discoverability)
4. **Fix LSP keymaps** (add K, [d, ]d)

But these are enhancements - your setup is now solid and reproducible!

---

## 🎓 Key Takeaways

**You now have the best of both worlds:**

✅ **Nix Benefits:**
- Reproducible LSP servers and build tools
- Pre-compiled treesitter (no build issues)
- lazy.nvim itself version-controlled
- Rollback capability

✅ **Lazy.nvim Benefits:**
- Fast plugin updates (no rebuild)
- Access to entire plugin ecosystem
- Direct use of community Lua configs
- Instant feedback loop

✅ **Git Benefits:**
- Plugin versions tracked (lazy-lock.json)
- Config history and collaboration
- Easy version restoration

**This is a pragmatic, production-ready setup!** 🚀
