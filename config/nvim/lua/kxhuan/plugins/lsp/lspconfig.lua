-- LSP Configuration (Phase 1 - Working!)
-- All LSP servers are provided by Nix (see modules/packages.nix)
-- This file configures nvim-lspconfig to use those servers

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",  -- LSP completion source for nvim-cmp
  },
  config = function()
    -- Suppress deprecation warnings (nvim-lspconfig still works fine in 0.11)
    ---@diagnostic disable-next-line: deprecated
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Enable completion capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Diagnostic symbols in the sign column (gutter)
    local signs = { Error = "", Warn = "", Hint = "󰌶", Info = "" }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- ============================================================================
    -- LSP Server Configurations
    -- Each server is provided by Nix (modules/packages.nix)
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
            globals = { "vim" }, -- Recognize 'vim' global
          },
          workspace = {
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

    -- Dockerfile (dockerfile-language-server)
    lspconfig.dockerls.setup({
      capabilities = capabilities,
    })
  end,
}
