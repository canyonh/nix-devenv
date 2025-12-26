-- Native LSP Configuration (Neovim 0.11+)
-- Uses vim.lsp.config instead of nvim-lspconfig plugin
-- All LSP servers are provided by Nix (see modules/packages.nix)

return {
  name = "native-lsp-config",
  -- No plugin dependency! This is native neovim functionality
  lazy = false,  -- Load immediately
  priority = 100,  -- Load early

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",  -- Still need this for completion capabilities
  },

  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Helper function to merge capabilities
    local function make_capabilities(extra)
      return vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim_lsp.default_capabilities(),
        extra or {}
      )
    end

    -- Diagnostic symbols in the sign column (gutter)
    -- Using Nerd Font icons (you have JetBrainsMono and Hack Nerd Fonts installed)
    local signs = {
      Error = "X", -- nf-fa-times_circle
      Warn = "!",  -- nf-fa-exclamation_triangle
      Hint = "󰌶",  -- nf-md-lightbulb_on
      Info = "i",  -- nf-fa-info_circle
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- ============================================================================
    -- LSP Server Configurations (Native API)
    -- Each server is provided by Nix and configured explicitly here
    -- ============================================================================

    -- C/C++ (clangd from clang-tools)
    vim.lsp.config.clangd = {
      cmd = { 'clangd' },
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
      root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git',
      },
      capabilities = make_capabilities({
        offsetEncoding = { 'utf-8', 'utf-16' },
      }),
    }

    -- Python (pyright)
    vim.lsp.config.pyright = {
      cmd = { 'pyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
      },
      capabilities = make_capabilities(),
    }

    -- Lua (lua-language-server)
    -- Special settings for neovim config editing
    vim.lsp.config.lua_ls = {
      cmd = { 'lua-language-server' },
      filetypes = { 'lua' },
      root_markers = {
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
        '.git',
      },
      capabilities = make_capabilities(),
      settings = {
        Lua = {
          diagnostics = {
            -- Recognize 'vim' global in neovim config files
            globals = { 'vim' },
          },
          workspace = {
            -- Make server aware of neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    }

    -- Bash (bash-language-server)
    vim.lsp.config.bashls = {
      cmd = { 'bash-language-server', 'start' },
      filetypes = { 'sh' },
      root_markers = { '.git' },
      capabilities = make_capabilities(),
    }

    -- CMake (cmake-language-server)
    vim.lsp.config.cmake = {
      cmd = { 'cmake-language-server' },
      filetypes = { 'cmake' },
      root_markers = { 'CMakeLists.txt', 'CMakePresets.json', '.git' },
      capabilities = make_capabilities(),
    }

    -- YAML (yaml-language-server)
    vim.lsp.config.yamlls = {
      cmd = { 'yaml-language-server', '--stdio' },
      filetypes = { 'yaml', 'yaml.docker-compose' },
      root_markers = { '.git' },
      capabilities = make_capabilities(),
    }

    -- Nix (nil)
    vim.lsp.config.nil_ls = {
      cmd = { 'nil' },
      filetypes = { 'nix' },
      root_markers = { 'flake.nix', 'default.nix', 'shell.nix', '.git' },
      capabilities = make_capabilities(),
    }

    -- JSON (from vscode-langservers-extracted)
    vim.lsp.config.jsonls = {
      cmd = { 'vscode-json-language-server', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      root_markers = { '.git' },
      capabilities = make_capabilities(),
    }

    -- Dockerfile (dockerfile-language-server)
    vim.lsp.config.dockerls = {
      cmd = { 'docker-langserver', '--stdio' },
      filetypes = { 'dockerfile' },
      root_markers = { 'Dockerfile', '.git' },
      capabilities = make_capabilities(),
    }

  end,
}
