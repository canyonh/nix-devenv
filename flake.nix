{
  description = "Cross-platform development environment using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: nix-darwin for macOS (Stage 3)
    # darwin = {
    #   url = "github:lnl7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Supported systems
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper to create home-manager configuration
      mkHome = { system, username, hostname, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules = [
            ./home.nix
            {
              home = {
                inherit username;
                homeDirectory =
                  if (nixpkgs.lib.strings.hasSuffix "darwin" system)
                  then "/Users/${username}"
                  else "/home/${username}";
                stateVersion = "24.05";
              };

              # Pass system info to modules
              _module.args = {
                inherit hostname;
                isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
                isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
              };
            }
          ] ++ extraModules;
        };
    in
    {
      # Home-manager configurations for different machines
      homeConfigurations = {
        # Ubuntu laptop (Stage 1 - current machine)
        "khuang@ubuntu-laptop" = mkHome {
          system = "x86_64-linux";
          username = "khuang";
          hostname = "khuang-5690-ubuntu";
          extraModules = [
            ./home/linux.nix
          ];
        };

        # macOS machine (Stage 3)
        "khuang@macbook" = mkHome {
          system = "aarch64-darwin";  # Apple Silicon
          username = "khuang";
          hostname = "KHUANG-MACBOOK16";
          extraModules = [
            ./home/darwin.nix
          ];
        };

        # NixOS desktop (Stage 5 - future)
        # "khuang@nixos-desktop" = mkHome {
        #   system = "x86_64-linux";
        #   username = "khuang";
        #   hostname = "nixos-desktop";
        #   extraModules = [
        #     ./home/linux.nix
        #     ./home/nixos.nix
        #   ];
        # };
      };

      # Development shell for working on this flake
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            home-manager
            git
          ];

          shellHook = ''
            echo "Nix development environment"
            echo ""
            echo "Available commands:"
            echo "  home-manager switch --flake .#khuang@ubuntu-laptop"
            echo "  home-manager generations"
            echo "  home-manager packages"
            echo ""
            echo "Dry-run (see what would change):"
            echo "  home-manager switch --flake .#khuang@ubuntu-laptop --dry-run"
          '';
        };
      });
    };
}
