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
    #
    # IMPORTANT: These create read-only symlinks via the nix store, which means:
    # - Changes to config/nvim/ require `home-manager switch` to take effect
    # - Provides reproducibility and atomic updates
    # - Config is tied to home-manager generations (can rollback)
    #
    # For faster iteration (changes apply immediately after nvim restart):
    # Replace with mkOutOfStoreSymlink to symlink directly to source files:
    #   xdg.configFile."nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-devenv/config/nvim/init.lua";
    #   xdg.configFile."nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-devenv/config/nvim/lua";
    # Trade-off: Loses reproducibility guarantees and generation rollback for nvim config.
    xdg.configFile."nvim/init.lua".source = ../config/nvim/init.lua;
    xdg.configFile."nvim/lua".source = ../config/nvim/lua;
}
