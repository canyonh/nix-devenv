return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      preset = "modern",
      icons = {
        rules = false,  -- Disable icon rules to avoid nerd font dependency issues
      },
    })

    -- Document existing leader key groups (which-key v3 API)
    wk.add({
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Format" },
      { "<leader>h", group = "Git Hunk" },
      { "<leader>n", group = "Clear" },
      { "<leader>r", group = "Rename" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Tab" },
      { "<leader>x", group = "Diagnostics" },
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Diagnostic" },
    })
  end,
}
