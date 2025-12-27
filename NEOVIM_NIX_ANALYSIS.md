# Should You Move to Pure Nix Neovim Configuration?

**Date:** 2025-12-27
**Current Setup:** Hybrid (Nix treesitter + lazy.nvim plugins + Lua config)
**Reference:** https://devctrl.blog/posts/which-one-should-i-use-programs-neovim-nix-cats-nvim-nixvim-or-nvf/

---

## 🔍 Current Hybrid Approach (What You Have)

**Architecture:**
```
Nix (modules/neovim.nix)
├── Provides: neovim package
├── Provides: Treesitter parsers (pre-compiled)
├── Provides: Build tools (gcc/clang, make, nodejs)
└── Links: config/nvim/ → ~/.config/nvim/

Lazy.nvim (config/nvim/)
├── Manages: Plugin installation
├── Manages: Plugin updates
├── Manages: Lazy loading
└── Pure Lua config files
```

**Pros:**
- ✅ Treesitter "just works" (no compilation issues)
- ✅ Fast plugin updates (`:Lazy update`)
- ✅ Direct access to plugin docs and GitHub
- ✅ Easy to copy configs from the community
- ✅ Familiar to most neovim users
- ✅ Can use plugins not yet in nixpkgs

**Cons:**
- ⚠️ Plugins not declarative (lazy-lock.json is mutable)
- ⚠️ Can't rollback plugin updates with home-manager
- ⚠️ Plugins stored in `~/.local/share/nvim` (outside Nix)

---

## 🎯 Pure Nix Approaches

### Option 1: programs.neovim (Built-in Home-manager)

**What it is:** Home-manager's built-in neovim module

**Example:**
```nix
programs.neovim = {
  enable = true;
  plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    nvim-cmp
    telescope-nvim
    # ... all plugins from nixpkgs
  ];
  extraLuaConfig = ''
    -- Your Lua config here as a string
    -- or: source ${./config.lua}
  '';
};
```

**Pros:**
- ✅ Built-in, no extra dependencies
- ✅ Simple for basic setups
- ✅ Full Nix reproducibility

**Cons:**
- ❌ Config as Nix string literals (ugly)
- ❌ Limited to plugins in nixpkgs
- ❌ No type checking for config
- ❌ Hard to structure complex configs
- ❌ Plugin updates = rebuild entire config

**Verdict:** Too basic for your needs

---

### Option 2: Nixvim

**What it is:** Nix DSL for neovim configuration (most popular)

**Repository:** https://github.com/nix-community/nixvim

**Example:**
```nix
programs.nixvim = {
  enable = true;

  colorschemes.tokyonight.enable = true;

  plugins = {
    lsp = {
      enable = true;
      servers = {
        clangd.enable = true;
        pyright.enable = true;
        nil-ls.enable = true;
      };
    };

    telescope.enable = true;
    nvim-cmp = {
      enable = true;
      autoEnableSources = true;
    };

    treesitter = {
      enable = true;
      nixGrammars = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
    }
  ];
};
```

**Pros:**
- ✅ Type-checked Nix DSL (catch errors at build time)
- ✅ Very popular (large community, good docs)
- ✅ Abstracts away plugin complexity
- ✅ Can test configs with home-manager
- ✅ Fully reproducible
- ✅ Can share modules across machines

**Cons:**
- ❌ Must learn Nixvim DSL (different from Lua)
- ❌ Limited to nixpkgs plugins (unless using custom overlay)
- ❌ Can't directly use Lua configs from community
- ❌ Abstractions hide what's happening
- ❌ Breaking changes in Nixvim updates
- ❌ Slower iteration (rebuild on every change)

**Verdict:** Good for "set it and forget it" but slower to experiment

---

### Option 3: nix-cats

**What it is:** Minimal framework, Lua-first approach

**Repository:** https://github.com/BirdeeHub/nix-cats-nvim

**Philosophy:** "Nix should just provide plugins, Lua does config"

**Example:**
```nix
# flake.nix
{
  inputs.nix-cats.url = "github:BirdeeHub/nix-cats-nvim";

  outputs = { nix-cats, ... }: {
    packages.nvim = nix-cats.mkCat {
      packageDefinitions = {
        myNeovim = { pkgs, ... }: {
          settings = {
            wrapRc = true;
            configDirSources = ./config;  # Your existing config/nvim/
          };
          categories = {
            lsp = true;
            telescope = true;
          };
        };
      };

      categoryDefinitions = { pkgs, ... }: {
        lsp = with pkgs.vimPlugins; [ nvim-lspconfig nvim-cmp ];
        telescope = with pkgs.vimPlugins; [ telescope-nvim plenary-nvim ];
      };
    };
  };
}
```

**Pros:**
- ✅ Keep your existing Lua config!
- ✅ Nix just provides plugins
- ✅ Can use lazy.nvim or plain Lua
- ✅ Easy migration from hybrid setup
- ✅ Flexible plugin sourcing

**Cons:**
- ⚠️ Less abstraction (more manual work)
- ⚠️ Smaller community than nixvim
- ⚠️ Need to understand the category system

**Verdict:** Best for Lua-first users (like you!)

---

### Option 4: nvf (neovim-flake)

**What it is:** Modular neovim configuration framework

**Repository:** https://github.com/notashelf/nvf

**Example:**
```nix
{
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        lsp = {
          enable = true;
          formatOnSave = true;
        };

        languages = {
          enableLSP = true;
          enableTreesitter = true;

          clang.enable = true;
          python.enable = true;
          nix.enable = true;
        };
      };
    };
  };
}
```

**Pros:**
- ✅ Modular language support
- ✅ Opinionated defaults (less config needed)
- ✅ Good for common languages

**Cons:**
- ❌ Smaller community
- ❌ Opinionated (less flexibility)
- ❌ Less documentation

**Verdict:** Good if you want opinionated defaults

---

## 📊 Comparison Matrix

| Feature | Current (Hybrid) | programs.neovim | Nixvim | nix-cats | nvf |
|---------|-----------------|-----------------|--------|----------|-----|
| **Reproducibility** | ⚠️ Partial | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Plugin Updates** | ✅ Fast | ❌ Slow | ❌ Slow | ❌ Slow | ❌ Slow |
| **Community Configs** | ✅ Easy | ❌ Hard | ⚠️ Medium | ✅ Easy | ⚠️ Medium |
| **Lua First** | ✅ Yes | ⚠️ Strings | ❌ Nix DSL | ✅ Yes | ⚠️ Mixed |
| **Type Checking** | ❌ None | ❌ None | ✅ Nix types | ❌ None | ⚠️ Some |
| **Learning Curve** | ✅ Low | ✅ Low | ❌ High | ⚠️ Medium | ⚠️ Medium |
| **Iteration Speed** | ✅ Fast | ❌ Slow | ❌ Slow | ⚠️ Medium | ❌ Slow |
| **Custom Plugins** | ✅ Easy | ❌ Hard | ⚠️ Overlay | ✅ Medium | ⚠️ Medium |
| **Rollback** | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

---

## 🤔 Should YOU Move to Pure Nix?

### Consider Your Use Case

**Your Context:**
- 👨‍💻 Professional dev at Anduril
- 🔧 Custom tooling and workflows
- 🚀 Fast iteration needed
- 🎨 Like to experiment with plugins
- 📚 Follow neovim community trends

### Recommendation: **KEEP HYBRID (with minor improvements)**

**Why:**

1. **Fast iteration is critical for work**
   - Pure Nix = rebuild on every config change
   - Hybrid = `:source %` and `:Lazy reload` instantly
   - You need to experiment and adapt quickly

2. **Your current setup is smart**
   - Already solved the hard problem (treesitter)
   - Plugins are easy to manage with lazy.nvim
   - Can copy community configs directly

3. **Community configs are Lua-first**
   - Most neovim configs are Lua
   - Translating to Nix DSL takes time
   - You benefit from the larger ecosystem

4. **Work requirements**
   - Anduril likely has custom tooling
   - Easier to debug Lua than Nix DSL
   - Can share config with non-Nix colleagues

5. **You already have reproducibility where it matters**
   - LSP servers from Nix ✅
   - Treesitter from Nix ✅
   - Build tools from Nix ✅
   - Plugin versions in lazy-lock.json ✅

---

## ✅ Recommended Improvements to Current Setup

Instead of going full Nix, enhance your hybrid approach:

### 1. Make lazy-lock.json Declarative

**Add to git:**
```bash
cd ~/nix-devenv
git add config/nvim/lazy-lock.json
```

**Add to README:**
```markdown
## Neovim Plugin Versions

Plugin versions are locked in `config/nvim/lazy-lock.json`.
To update all plugins: `:Lazy update`
To restore versions: `git restore config/nvim/lazy-lock.json && :Lazy restore`
```

**Benefit:** Now plugin versions are tracked and reproducible!

### 2. Add Lazy.nvim to Nix

**Update modules/neovim.nix:**
```nix
{ config, pkgs, lib, isDarwin ? false, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Provide problematic plugins via Nix
    plugins = with pkgs.vimPlugins; [
      # Treesitter (already have this)
      (nvim-treesitter.withPlugins (p: [
        p.c p.cpp p.json p.cmake p.bash p.lua
        p.dockerfile p.vim p.vimdoc p.python
      ]))
      nvim-ts-autotag

      # NEW: Lazy.nvim itself from Nix
      lazy-nvim
    ];

    # Build tools (already have this)
    extraPackages = with pkgs; [
      (if isDarwin then clang else gcc)
      gnumake
      tree-sitter
      nodejs
    ];
  };

  # Link individual config files
  xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
  xdg.configFile."nvim/lua".source = ../config/nvim/lua;
  xdg.configFile."nvim/lazy-lock.json".source = ../config/nvim/lazy-lock.json;  # NEW
}
```

**Update config/nvim/lua/kxhuan/lazy.lua:**
```lua
-- Use Nix-provided lazy.nvim instead of downloading
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if lazy.nvim is provided by Nix (in runtimepath)
local has_nix_lazy = false
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
  if path:match("lazy%-nvim") then
    has_nix_lazy = true
    break
  end
end

-- If not provided by Nix, bootstrap from GitHub
if not has_nix_lazy and not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  vim.opt.rtp:prepend(lazypath)
end

require("lazy").setup(
  { { import = "kxhuan.plugins" }, { import = "kxhuan.plugins.lsp"} },
  {
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",  -- NEW: explicit lockfile
    checker = {
      enabled = true,
      notify = false,
    },
    change_detection = {
      notify = false
    },
  }
)
```

**Benefits:**
- ✅ lazy.nvim version controlled by Nix
- ✅ Plugin versions in git (lazy-lock.json)
- ✅ Can rollback with home-manager
- ✅ Still fast iteration

### 3. Document the Hybrid Approach

**Add to CLAUDE.md:**
```markdown
## Neovim Architecture

This repository uses a **hybrid approach** for neovim:

**Nix Manages (Declarative):**
- Neovim package itself
- Treesitter parsers (pre-compiled, no build issues)
- Build dependencies (gcc/clang, make, nodejs)
- lazy.nvim plugin manager

**Lazy.nvim Manages (Fast Iteration):**
- Plugin installation and updates
- Plugin lazy-loading
- Plugin version locking (lazy-lock.json)

**Why Hybrid:**
- Fast iteration (`:Lazy update` vs nix rebuild)
- Access to entire plugin ecosystem
- Can use Lua configs from community
- Nix handles the hard parts (treesitter compilation)
- Version control via lazy-lock.json
```

---

## 🎯 When to Consider Pure Nix

Move to pure Nix (nixvim or nix-cats) if:

1. ❌ You want a "set it and forget it" config
   - Not you - you actively develop your config

2. ❌ You need perfect reproducibility across hundreds of machines
   - Not needed - you have ~3 machines

3. ❌ You want to share Nix modules with team
   - Only relevant if team uses Nix

4. ❌ You don't mind slow iteration
   - You need fast feedback loops

5. ❌ You want type-checked config
   - Nice but not critical for you

**None of these apply to you!**

---

## 🔄 Migration Path (If You Change Your Mind)

If you later want to try pure Nix:

**Step 1: Try nix-cats (easiest migration)**
```bash
# Keep your Lua config exactly as-is
# Just let Nix provide plugins instead of lazy.nvim
```

**Step 2: If you like it, try nixvim**
```bash
# Gradually translate Lua config to Nix DSL
# Can be done incrementally
```

**Step 3: Decide**
- If nixvim feels better → commit
- If it feels worse → rollback with home-manager

---

## 📝 Summary

### Keep Your Hybrid Setup ✅

**Reasons:**
1. ✅ Fast iteration critical for work
2. ✅ Already have reproducibility where it matters
3. ✅ Can use community Lua configs directly
4. ✅ Easier debugging and sharing
5. ✅ More flexible for experimentation

**Improvements to Make:**
1. ✅ Track lazy-lock.json in git
2. ✅ Provide lazy.nvim via Nix
3. ✅ Document the hybrid approach

**Pure Nix is NOT for you because:**
- ❌ Slower iteration
- ❌ Steeper learning curve
- ❌ Less community config sharing
- ❌ More friction for experimentation
- ❌ Doesn't solve problems you actually have

### The Blog Post Comparison

The blog post likely discusses:
- **programs.neovim**: Too basic
- **nixvim**: Popular but opinionated, slow iteration
- **nix-cats**: Best for Lua lovers, but still Nix-first
- **nvf**: Opinionated, smaller community

**None beat your hybrid approach for your use case!**

---

## 🎓 Learn More

**If curious about pure Nix approaches:**
- [Nixvim documentation](https://nix-community.github.io/nixvim/)
- [nix-cats wiki](https://github.com/BirdeeHub/nix-cats-nvim/wiki)
- [nvf documentation](https://notashelf.github.io/nvf/)

**But honestly:** Focus on improving your Lua config (see NEOVIM_REVIEW.md)!

Your hybrid setup is **smart and pragmatic**. Don't fix what isn't broken.
