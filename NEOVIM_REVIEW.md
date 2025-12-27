# Neovim Configuration Review

**Date:** 2025-12-27
**Configuration Location:** `config/nvim/`
**Plugin Manager:** lazy.nvim
**Package Management:** Nix (for treesitter parsers)

---

## 📊 Overall Assessment

Your neovim setup is **modern and well-structured** with good separation of concerns:
- ✅ Uses latest Neovim 0.11+ LSP API (`vim.lsp.config()`, `vim.lsp.enable()`)
- ✅ Lazy-loading optimizations
- ✅ Nix-managed treesitter parsers (avoids compilation issues)
- ✅ Clean directory structure

**Score: 8/10** - Solid foundation with room for modern improvements

---

## 🔍 Plugin Audit: Maintenance Status

### ✅ Actively Maintained (Updated in 2024-2025)

| Plugin | Last Update | Status | Notes |
|--------|-------------|---------|-------|
| **lazy.nvim** | Active | ⭐️ Excellent | Modern plugin manager |
| **nvim-lspconfig** | Active | ⭐️ Excellent | Core LSP support |
| **nvim-cmp** | Active | ⭐️ Excellent | Best completion plugin |
| **telescope.nvim** | Active | ⭐️ Excellent | Fuzzy finder standard |
| **nvim-treesitter** | Active | ⭐️ Excellent | Syntax highlighting |
| **conform.nvim** | Active | ⭐️ Excellent | Modern formatter (replaces null-ls) |
| **gitsigns.nvim** | Active | ✅ Good | Git integration |
| **nvim-tree.lua** | Active | ✅ Good | File explorer |
| **nvim-dap** | Active | ✅ Good | Debugger protocol |
| **nvim-autopairs** | Active | ✅ Good | Auto pair brackets |
| **tokyonight.nvim** | Active | ✅ Good | Popular colorscheme |
| **dressing.nvim** | Active | ✅ Good | Better UI elements |
| **indent-blankline.nvim** | Active | ✅ Good | Indent guides (v3 API) |

### ⚠️ Potentially Outdated

| Plugin | Status | Issue |
|--------|---------|-------|
| **vim-maximizer** | ⚠️ Low activity | Last update 2021, but still works |
| **vim-tmux-navigator** | ⚠️ Maintenance mode | Stable but old |

---

## 🔧 Configuration Issues & Improvements

### 1. LSP Configuration (lspconfig.lua)

**Issue:** Using new Neovim 0.11+ API correctly ✅

**Improvements:**

```lua
-- Add these missing LSP servers you have installed:
-- HTML/CSS/ESLint (from vscode-langservers-extracted)
vim.lsp.config("html", { capabilities = capabilities })
vim.lsp.config("cssls", { capabilities = capabilities })
vim.lsp.config("eslint", { capabilities = capabilities })

-- Then enable them:
vim.lsp.enable({
  "clangd", "pyright", "lua_ls", "bashls", "cmake", "yamlls",
  "nil_ls", "jsonls", "dockerls", "html", "cssls", "eslint",
})
```

**Missing Keymaps:**

```lua
-- Add these useful LSP keymaps in LspAttach:
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)  -- Show hover documentation
vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)  -- Go to type def
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)  -- Previous diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)  -- Next diagnostic
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)  -- Code action (more intuitive than 'ga')
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)  -- Show diagnostic in float
```

### 2. Completion (nvim-cmp.lua)

**Issue:** No snippet support

**Current sources:**
```lua
sources = {
  { name = "nvim_lsp" },
  { name = "buffer" },
  { name = "path" },
}
```

**Improvement:** Add LuaSnip for snippets

```lua
-- Add to dependencies:
dependencies = {
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",  -- NEW: Snippet engine
  "saadparwaiz1/cmp_luasnip",  -- NEW: Snippet completion source
  "rafamadriz/friendly-snippets",  -- NEW: Preconfigured snippets
},

-- In config:
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()  -- Load friendly-snippets

sources = cmp.config.sources({
  { name = "nvim_lsp" },
  { name = "luasnip" },  -- NEW
  { name = "buffer" },
  { name = "path" },
}),

-- Add snippet navigation:
["<C-k>"] = cmp.mapping(function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, { "i", "s" }),
["<C-j>"] = cmp.mapping(function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, { "i", "s" }),
```

### 3. Telescope (telescope.lua)

**Issue:** Missing useful pickers and extensions

**Improvements:**

```lua
-- Add these keymaps:
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help tags" })
keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find diagnostics" })
keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Find keymaps" })
keymap.set("n", "<leader>ft", "<cmd>Telescope treesitter<CR>", { desc = "Find treesitter symbols" })
```

### 4. Gitsigns (gitsigns.lua)

**Issue:** No configuration at all!

**Current:**
```lua
return {
    "lewis6991/gitsigns.nvim",
}
```

**Improvement:** Add proper config

```lua
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Navigation
        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer=bufnr, desc="Next git hunk"})

        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer=bufnr, desc="Previous git hunk"})

        -- Actions
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk, {buffer=bufnr, desc="Stage hunk"})
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk, {buffer=bufnr, desc="Reset hunk"})
        vim.keymap.set('n', '<leader>hS', gs.stage_buffer, {buffer=bufnr, desc="Stage buffer"})
        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, {buffer=bufnr, desc="Undo stage hunk"})
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer, {buffer=bufnr, desc="Reset buffer"})
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {buffer=bufnr, desc="Preview hunk"})
        vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, {buffer=bufnr, desc="Blame line"})
        vim.keymap.set('n', '<leader>hd', gs.diffthis, {buffer=bufnr, desc="Diff this"})
      end
    })
  end,
}
```

### 5. Options (options.lua)

**Issues:**

1. **Commented-out diagnostic config** (lines 39-70) - Should be removed or implemented
2. **Hardcoded tab width** - Should be 2 spaces (industry standard)

**Improvements:**

```lua
-- Change tabstop from 4 to 2 (modern standard):
opt.tabstop = 2
opt.shiftwidth = 2

-- Add these useful options:
opt.scrolloff = 8  -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8  -- Keep 8 columns left/right
opt.updatetime = 200  -- Faster CursorHold events (for gitsigns, etc)
opt.timeoutlen = 300  -- Faster which-key display
opt.mouse = "a"  -- Enable mouse support
opt.undofile = true  -- Persistent undo
opt.swapfile = false  -- Disable swap files (use git instead)
```

### 6. Conform (conform.lua)

**Issue:** Missing C/C++ formatter configuration

**Improvement:**

```lua
formatters_by_ft = {
  c = { "clang-format" },  -- NEW
  cpp = { "clang-format" },  -- NEW
  css = { "prettierd" },
  html = { "prettierd" },
  -- ... rest
},

-- Add format on save (optional):
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = true,
},
```

---

## 🆕 Recommended New Plugins

### High Priority

#### 1. **which-key.nvim** - Discover keybindings
**Why:** You have many keymaps - this shows them in a popup as you type

```lua
-- lua/kxhuan/plugins/which-key.lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
      },
    })
  end,
}
```

#### 2. **mini.nvim** suite - Multiple utilities
**Why:** Replaces several plugins with one maintained suite

Replace these:
- ❌ vim-maximizer → ✅ mini.misc (zoom splits)
- ❌ indent-blankline → ✅ mini.indentscope (better scope visualization)
- ➕ Add mini.surround (surround text with brackets/quotes)
- ➕ Add mini.ai (better text objects)

```lua
-- lua/kxhuan/plugins/mini.lua
return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.surround").setup()  -- ys/ds/cs for surround
    require("mini.ai").setup()  -- Better text objects
    require("mini.indentscope").setup({
      symbol = "│",
      options = { try_as_border = true },
    })

    -- Zoom split (replaces vim-maximizer)
    vim.keymap.set("n", "<leader>sm", function()
      require("mini.misc").zoom()
    end, { desc = "Toggle zoom split" })
  end,
}
```

#### 3. **oil.nvim** - Edit filesystem like a buffer
**Why:** Modern alternative to nvim-tree, more intuitive

```lua
-- Can replace nvim-tree OR use alongside it
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
      },
    })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}
```

#### 4. **trouble.nvim** - Better diagnostics list
**Why:** Better than quickfix for viewing errors/warnings

```lua
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("trouble").setup()

    vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
    vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
    vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
    vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
  end,
}
```

### Medium Priority

#### 5. **flash.nvim** - Better navigation/search
**Why:** Jump to any location with 2 keystrokes

```lua
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  },
}
```

#### 6. **nvim-ufo** - Better code folding
**Why:** Modern folding with treesitter + LSP

```lua
return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  config = function()
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require('ufo').setup()
  end,
}
```

#### 7. **todo-comments.nvim** - Highlight TODO/FIXME
**Why:** Find and highlight TODO comments across codebase

```lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup()
    vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
    vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })
    vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
```

### Nice to Have

#### 8. **nvim-spectre** - Project-wide search/replace
```lua
return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace" },
  },
}
```

#### 9. **Comment.nvim** - Better commenting
**Why:** More feature-rich than vim's built-in

```lua
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("Comment").setup()
  end,
}
```

#### 10. **git-conflict.nvim** - Better merge conflict resolution
```lua
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = function()
    require("git-conflict").setup()
  end,
}
```

---

## 🔨 Refactoring Opportunities

### 1. Consolidate Core Settings

**Create:** `lua/kxhuan/core/autocmds.lua`

```lua
-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Auto-resize splits on window resize
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})
```

### 2. LSP Server Organization

**Current:** All servers in one file
**Better:** Group by language/purpose

```
lua/kxhuan/plugins/lsp/
├── init.lua          # Main LSP config
├── servers/
│   ├── c_cpp.lua     # C/C++ specific (clangd settings)
│   ├── python.lua    # Python specific (pyright settings)
│   └── web.lua       # HTML/CSS/JS/TS
```

### 3. Remove Dead Code

**Files with commented-out code:**
- `options.lua` (lines 39-70) - Remove or implement
- `nvim-cmp.lua` (line 30) - Remove commented luasnip

---

## 📦 Plugins to Add to Nix

Update `modules/packages.nix` with new formatters:

```nix
# Add to packages.nix:
home.packages = with pkgs; [
  # Existing packages...

  # NEW: For conform.nvim C/C++ formatting
  clang-tools  # Already have this (includes clang-format)
];
```

---

## 🎯 Priority Action Plan

### Week 1: Critical Improvements
1. ✅ **Add snippet support** (LuaSnip + friendly-snippets)
2. ✅ **Configure gitsigns properly** (add keymaps)
3. ✅ **Add which-key.nvim** (discoverability)
4. ✅ **Fix LSP keymaps** (add K, [d, ]d, etc.)

### Week 2: Quality of Life
5. ✅ **Add trouble.nvim** (better diagnostics)
6. ✅ **Add mini.nvim suite** (modern utilities)
7. ✅ **Add Comment.nvim** (better commenting)
8. ✅ **Configure conform for C/C++**

### Week 3: Advanced Features
9. ⏭️ **Add flash.nvim** (faster navigation)
10. ⏭️ **Add todo-comments.nvim** (TODO tracking)
11. ⏭️ **Add nvim-ufo** (better folding)
12. ⏭️ **Refactor LSP servers** (separate files)

---

## 📚 Resources

**Learn more:**
- [Neovim 0.11 Release Notes](https://neovim.io/doc/user/news-0.11.html) - New LSP API
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager docs
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Reference config
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim) - Plugin discovery

**Plugin authors to follow:**
- [folke](https://github.com/folke) - which-key, trouble, tokyonight, flash, todo-comments
- [echasnovski](https://github.com/echasnovski) - mini.nvim suite
- [stevearc](https://github.com/stevearc) - conform, oil, dressing

---

## ✅ Summary

**Strengths:**
- Modern Neovim 0.11+ API usage
- Good lazy-loading setup
- Nix-managed treesitter (smart!)
- Clean directory structure
- DAP configuration is thorough

**Quick Wins:**
1. Add gitsigns keymaps (copy-paste from review)
2. Install which-key.nvim (huge QoL improvement)
3. Add snippet support (LSP completions will be better)
4. Fix tab width to 2 spaces

**Your config is solid!** The suggested improvements are enhancements, not fixes. You're ahead of most users by using the new LSP API.
