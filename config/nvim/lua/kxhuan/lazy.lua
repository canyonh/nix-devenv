-- Prefer Nix-provided lazy.nvim (in runtimepath), fallback to git bootstrap
local has_nix_lazy = false

-- Check if lazy.nvim is in the runtimepath (Nix provides it in vim-pack-dir)
for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
  if path:match("vim%-pack%-dir") then
    local lazy_path = path .. "/pack/*/start/lazy.nvim"
    if vim.fn.glob(lazy_path) ~= "" then
      has_nix_lazy = true
      break
    end
  end
end

-- Bootstrap from git if not provided by Nix
if not has_nix_lazy then
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
end

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
