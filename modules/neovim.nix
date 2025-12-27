{ config, pkgs, lib, isDarwin ? false, ... }:

{
    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        # Plugins managed by Nix (for build-time dependencies or problematic plugins)
        # Most plugins are managed by lazy.nvim in config/nvim/lua/kxhuan/plugins/
        plugins = with pkgs.vimPlugins; [
            # Currently empty - all plugins managed by lazy.nvim
        ];

        # Build tools for other lazy.nvim plugins (telescope-fzf, etc.)
        extraPackages = with pkgs; [
            # Use platform-appropriate C compiler
            # macOS: clang (standard), Linux: gcc (standard)
            (if isDarwin then clang else gcc)
            gnumake
            tree-sitter
            nodejs
        ];
    };

    # Link individual neovim config files/directories
    # This allows lazy.nvim to create writable files like lazy-lock.json
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
