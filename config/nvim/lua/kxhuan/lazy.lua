-- Bootstrap lazy.nvim from git (standard approach)
-- Note: lazy.nvim is NOT provided by Nix to avoid read-only store issues
-- lazy-lock.json tracks the version for reproducibility
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
  { { import = "kxhuan.plugins" }, { import = "kxhuan.plugins.lsp"} },
  {
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",  -- Explicit lockfile location
    checker = {
      enabled = true,
      notify = false,
    },
    change_detection = {
      notify = false
    },
  }
)
