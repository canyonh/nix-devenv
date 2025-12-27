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
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Enable completion capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Diagnostic symbols in the sign column (gutter)
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "❌",
          [vim.diagnostic.severity.WARN] = "⚠️",
          [vim.diagnostic.severity.HINT] = "💡",
          [vim.diagnostic.severity.INFO] = "ℹ️",
        },
      },
    })

    -- ============================================================================
    -- LSP Server Configurations (New API - Neovim 0.11+)
    -- Each server is provided by Nix (modules/packages.nix)
    -- ============================================================================

    -- C/C++ (clangd from clang-tools)
    vim.lsp.config("clangd", {
      capabilities = capabilities,
    })

    -- Python (pyright)
    vim.lsp.config("pyright", {
      capabilities = capabilities,
    })

    -- Lua (lua-language-server)
    vim.lsp.config("lua_ls", {
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
    vim.lsp.config("bashls", {
      capabilities = capabilities,
    })

    -- CMake (cmake-language-server)
    vim.lsp.config("cmake", {
      capabilities = capabilities,
    })

    -- YAML (yaml-language-server)
    vim.lsp.config("yamlls", {
      capabilities = capabilities,
    })

    -- Nix (nil)
    vim.lsp.config("nil_ls", {
      capabilities = capabilities,
    })

    -- JSON (from vscode-langservers-extracted)
    vim.lsp.config("jsonls", {
      capabilities = capabilities,
    })

    -- Dockerfile (dockerfile-language-server)
    vim.lsp.config("dockerls", {
      capabilities = capabilities,
    })

    -- Enable all configured LSP servers
    vim.lsp.enable({
      "clangd", "pyright", "lua_ls", "bashls", "cmake", "yamlls", "nil_ls", "jsonls", "dockerls",
    })

    -- LspAttach autocmd for buffer-local keymaps (replaces on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local opts = { buffer = bufnr, silent = true }

        -- These keymaps are only active when LSP is attached to the buffer

        -- Go to definitions/declarations
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        -- References and hover
        vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "Show LSP references" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show hover documentation" }))
        vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Show signature help" }))

        -- Code actions and rename
        vim.keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

        -- Diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostic loclist" }))
      end,
    })
  end,
}
