-- LSP Configuration
-- All LSP servers are provided by Nix (see modules/packages.nix)
-- This file configures nvim-lspconfig to use those servers
--
-- NOTE: nvim-lspconfig is deprecated in neovim 0.11+ in favor of vim.lsp.config
-- This configuration still uses lspconfig for compatibility but should be migrated

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",  -- LSP completion source for nvim-cmp
  },
  config = function()
    -- Suppress deprecation warnings (temporary)
    ---@diagnostic disable-next-line: deprecated
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Enable completion capabilities
    -- This tells LSP servers that neovim supports advanced completion
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Diagnostic symbols in the sign column (gutter)
    -- These are the icons you see next to line numbers for errors/warnings
    -- Using Nerd Font icons (you have JetBrainsMono and Hack Nerd Fonts installed)
    local signs = {
      Error = "", -- nf-fa-times_circle (U+F057)
      Warn = "",  -- nf-fa-exclamation_triangle (U+F071)
      Hint = "󰌶",  -- nf-md-lightbulb_on (U+F0336)
      Info = "",  -- nf-fa-info_circle (U+F05A)
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- ============================================================================
    -- LSP Server Configurations
    -- Each server is provided by Nix (modules/packages.nix)
    -- We just need to tell lspconfig they exist and how to configure them
    -- ============================================================================

    -- C/C++ (clangd from clang-tools)
    lspconfig.clangd.setup({
      capabilities = capabilities,
    })

    -- Python (pyright)
    lspconfig.pyright.setup({
      capabilities = capabilities,
    })

    -- Lua (lua-language-server)
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            -- Recognize 'vim' global in neovim config files
            globals = { "vim" },
          },
          workspace = {
            -- Make server aware of neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })

    -- Bash (bash-language-server)
    lspconfig.bashls.setup({
      capabilities = capabilities,
    })

    -- CMake (cmake-language-server)
    lspconfig.cmake.setup({
      capabilities = capabilities,
    })

    -- YAML (yaml-language-server)
    lspconfig.yamlls.setup({
      capabilities = capabilities,
    })

    -- Nix (nil)
    lspconfig.nil_ls.setup({
      capabilities = capabilities,
    })

    -- JSON (from vscode-langservers-extracted)
    lspconfig.jsonls.setup({
      capabilities = capabilities,
    })

    -- Dockerfile (dockerfile-language-server-nodejs)
    lspconfig.dockerls.setup({
      capabilities = capabilities,
    })
  end,
}
