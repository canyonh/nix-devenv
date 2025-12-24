# Nix & home-manager Deep Dive Learning Plan

A structured learning path to deeply understand your home-manager setup and sharpen your Nix skills.

**Estimated Time:** 8-12 hours (spread over multiple sessions)
**Prerequisite:** Moderate Nix knowledge (you already have this!)

---

## Learning Path Overview

```
Module 1: Nix Foundations Refresher (1-2 hours)
    ↓
Module 2: Nix Flakes Deep Dive (2-3 hours)
    ↓
Module 3: home-manager Architecture (2-3 hours)
    ↓
Module 4: Your Setup Dissected (2-3 hours)
    ↓
Module 5: Advanced Topics & Patterns (1-2 hours)
```

---

## Module 1: Nix Foundations Refresher (1-2 hours)

### 1.1 The Nix Store Model

**Concepts to Review:**
- How `/nix/store/hash-name` paths work
- Content-addressed storage
- Derivations (.drv files)
- Build outputs vs source inputs

**Hands-on Exercises:**

```bash
# Exercise 1.1.1: Explore the Nix store
ls /nix/store/ | head -20
# What do you see? Each path has a hash prefix

# Exercise 1.1.2: Find where clangd actually lives
which clangd
# Output: /home/khuang/.nix-profile/bin/clangd

ls -l $(which clangd)
# It's a symlink! Follow it:
readlink -f $(which clangd)
# Shows the actual /nix/store path

# Exercise 1.1.3: Understand derivations
nix show-derivation nixpkgs#hello
# This shows the .drv file - the build recipe

# Exercise 1.1.4: What depends on a package?
nix-store --query --referrers $(which clangd)
# Shows what packages reference clangd
```

**Key Questions to Answer:**
- Q: Why does the hash change when package version changes?
- Q: What happens to old store paths after updates?
- Q: How does Nix ensure reproducibility?

**Reading:**
- [Nix Pills - Store Paths](https://nixos.org/guides/nix-pills/our-first-derivation.html)

---

## Module 2: Nix Flakes Deep Dive (2-3 hours)

### 2.1 What Problem Do Flakes Solve?

**Before Flakes (channels):**
- Mutable, imperative (`nix-channel --update`)
- No version locking
- Hard to reproduce exactly
- No hermetic builds

**With Flakes:**
- Immutable inputs
- `flake.lock` pins exact versions
- Pure evaluation by default
- Composable

### 2.2 Anatomy of Your flake.nix

**Exercise 2.2.1: Dissect Your Flake**

```bash
cd ~/nix-devenv

# View your flake structure
nix flake show

# Output explains:
# homeConfigurations.khuang@ubuntu-laptop
#   ↳ This is an "output" that home-manager understands
# devShells.x86_64-linux.default
#   ↳ Development shell for working on the flake itself
```

**Exercise 2.2.2: Understand Inputs**

```bash
# View your flake.lock
cat flake.lock | jq .

# Key sections:
# - "nodes" - dependency graph
# - "nixpkgs" - pinned to specific commit
# - "home-manager" - pinned to specific commit

# Where does nixpkgs come from?
jq '.nodes.nixpkgs.locked' flake.lock

# Example output:
# {
#   "owner": "nixos",
#   "repo": "nixpkgs",
#   "rev": "abc123...",  ← exact commit hash
#   "type": "github"
# }
```

**Exercise 2.2.3: Update Dependencies**

```bash
# See what would change
nix flake lock --update-input nixpkgs --dry-run

# Actually update nixpkgs
nix flake lock --update-input nixpkgs

# Check what changed
git diff flake.lock

# Rollback if needed
git checkout flake.lock
```

### 2.3 Understanding Flake Outputs

**Exercise 2.3.1: Explore Your Outputs**

Open `flake.nix` and analyze:

```nix
outputs = { self, nixpkgs, home-manager, ... }:
  # ↑ These are the INPUTS (dependencies)

  # Everything after this is OUTPUTS (what your flake provides)
```

**Key Concept:** Flakes are functions!
```
inputs → flake.nix (pure function) → outputs
```

**Exercise 2.3.2: Understanding the mkHome Helper**

In your `flake.nix`:

```nix
mkHome = { system, username, hostname, extraModules ? [] }:
  home-manager.lib.homeManagerConfiguration {
    # This is creating a home-manager configuration
    # It's calling home-manager's library function
  };
```

**Questions to Answer:**
- Q: Why use `mkHome` helper instead of writing each config directly?
- Q: What does `home-manager.lib.homeManagerConfiguration` do?
- Q: How does `extraModules` work?

### 2.4 The Module System

**Core Concept:** Nix modules are mergeable configurations.

```nix
# Module A
{ config, pkgs, ... }: {
  home.packages = [ pkgs.git ];
}

# Module B
{ config, pkgs, ... }: {
  home.packages = [ pkgs.vim ];
}

# Result when both imported:
# home.packages = [ pkgs.git pkgs.vim ];
```

**Exercise 2.4.1: Module Merging**

```bash
# Create a test module
cat > /tmp/test-module.nix <<'EOF'
{ config, pkgs, ... }: {
  home.packages = [ pkgs.hello ];
}
EOF

# Add it to your imports temporarily
# Edit home.nix, add: ./tmp/test-module.nix to imports

# Rebuild and verify
home-manager switch --flake .#khuang@ubuntu-laptop
which hello

# Clean up
# Remove from imports, rebuild
```

**Key Questions:**
- Q: What happens if two modules set the same option differently?
- Q: How does priority/override work?
- Q: What's the difference between `=` and `mkDefault` and `mkForce`?

---

## Module 3: home-manager Architecture (2-3 hours)

### 3.1 What home-manager Actually Does

**Core Function:** Manages files in `$HOME` declaratively using Nix.

**Architecture:**

```
Your config (home.nix)
    ↓
home-manager library
    ↓
Generates activation script
    ↓
Creates symlinks in $HOME
```

### 3.2 Understanding Activation

**Exercise 3.2.1: Watch an Activation**

```bash
cd ~/nix-devenv

# Build but don't activate
nix build '.#homeConfigurations."khuang@ubuntu-laptop".activationPackage'

# Inspect what was built
ls -la result/

# Key files:
# - activate: The activation script
# - home-files: Symlinks to be created
# - home-path: Your user environment

# Read the activation script
cat result/activate | less

# What does it do?
# 1. Checks for file conflicts
# 2. Creates symlinks
# 3. Runs service activations
# 4. Updates profile generation
```

**Exercise 3.2.2: Generations**

```bash
# List all generations
home-manager generations

# Each generation is a full environment snapshot
ls -la ~/.local/state/home-manager/gcroots/

# Pick a generation and inspect
ls -la /nix/store/<generation-hash>/

# What's inside?
# - activate: Activation script for that generation
# - home-files: Files for that generation
# - home-path: Environment for that generation
```

**Key Insight:** Generations are immutable. Rollback is just changing a symlink!

### 3.3 Profile vs Environment vs Generation

**Confusing Terms Clarified:**

```
Profile: ~/.nix-profile (user's default environment)
    ↓ symlinks to
Profile Generation: ~/.local/state/nix/profiles/profile-N-link
    ↓ contains
Environment: Collection of packages
    ↓ created by
Derivation: Build instructions
```

**Exercise 3.3.1: Trace the Symlinks**

```bash
# Start from clangd
which clangd
# → ~/.nix-profile/bin/clangd

ls -la ~/.nix-profile
# → points to home-manager profile

readlink ~/.nix-profile
# → points to profile generation

# Follow the chain
readlink -f $(which clangd)
# Final destination in /nix/store
```

### 3.4 How Packages Are Merged

**Exercise 3.4.1: buildEnv Explained**

Your `home.packages` list becomes a `buildEnv` derivation:

```bash
# See what's in your home-path
ls ~/.nix-profile/bin/ | wc -l
# Many binaries!

# These come from multiple packages merged together
# home-manager uses pkgs.buildEnv to merge them

# Simulate buildEnv
nix-shell -p 'pkgs.buildEnv {
  name = "test-env";
  paths = [ pkgs.git pkgs.vim ];
}'

# Inside the shell:
which git
which vim
# Both available from the same environment!
```

**Key Concept:** `buildEnv` creates a unified directory structure from multiple packages.

---

## Module 4: Your Setup Dissected (2-3 hours)

### 4.1 File-by-File Deep Dive

#### flake.nix

**Line-by-Line Analysis:**

```nix
{
  description = "...";
  # This is metadata, not functional

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # ↑ Where to get packages from
    # Format: <type>:<owner>/<repo>/<branch>

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      # ↑ IMPORTANT: Reuse the SAME nixpkgs as root
      # Avoids downloading nixpkgs twice
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    # ↑ Function parameters = inputs
    # "self" is this flake itself

    let
      # Helper function to avoid repetition
      mkHome = { system, username, hostname, extraModules ? [] }:
        # ↑ Parameters with default (extraModules = [])

        home-manager.lib.homeManagerConfiguration {
          # Using home-manager's library function

          pkgs = nixpkgs.legacyPackages.${system};
          # ↑ Get packages for this system (x86_64-linux, etc.)
          # legacyPackages = all packages in nixpkgs

          modules = [
            ./home.nix
            # ↑ Import your main config

            {
              home = {
                inherit username;
                # ↑ Shorthand for: username = username;

                homeDirectory =
                  if (nixpkgs.lib.strings.hasSuffix "darwin" system)
                  then "/Users/${username}"
                  else "/home/${username}";
                # ↑ Mac vs Linux home directory

                stateVersion = "24.05";
                # ↑ home-manager release, for compatibility
              };

              _module.args = {
                # Pass extra arguments to all modules
                inherit hostname;
                isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
                isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
              };
            }
          ] ++ extraModules;
          # ↑ Concatenate extra modules
        };
    in
    {
      homeConfigurations = {
        "khuang@ubuntu-laptop" = mkHome {
          system = "x86_64-linux";
          username = "khuang";
          hostname = "khuang-5690-ubuntu";
          extraModules = [
            ./home/linux.nix
          ];
        };
      };
    };
}
```

**Exercise 4.1.1: Modify and Experiment**

```bash
# Add a new system
# Edit flake.nix, add:

"khuang@test-machine" = mkHome {
  system = "x86_64-linux";
  username = "khuang";
  hostname = "test-machine";
  extraModules = [];
};

# Verify it exists
nix flake show

# Build it (won't activate, just test)
nix build '.#homeConfigurations."khuang@test-machine".activationPackage'

# Remove it after testing
```

#### home.nix

**Analysis:**

```nix
{ config, pkgs, lib, ... }:
# ↑ These are the module system arguments
# - config: The merged configuration
# - pkgs: Package set (nixpkgs)
# - lib: Utility functions
# - ...: Allow other arguments

{
  imports = [
    # Module imports are merged together
    ./home/common.nix
    ./modules/git.nix
    ./modules/packages.nix
    ./modules/direnv.nix
  ];

  programs.home-manager.enable = true;
  # ↑ Let home-manager manage itself
  # Adds `home-manager` command to your PATH

  systemd.user.startServices = "sd-switch";
  # ↑ Restart systemd user services when config changes
  # (Not applicable on Ubuntu without systemd user services enabled)
}
```

**Exercise 4.1.2: Understanding config vs pkgs**

```bash
# Create a test module
cat > /tmp/test-config.nix <<'EOF'
{ config, pkgs, lib, ... }:
{
  # Set an option
  home.username = "test";

  # Read back the option
  # This would create a file containing the username
  home.file."debug.txt".text = "My username is: ${config.home.username}";
}
EOF

# What happened?
# - We SET home.username
# - We READ config.home.username
# - The module system merges everything
```

#### modules/packages.nix

**Deep Dive:**

```nix
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ↑ "with pkgs" brings all package names into scope
    # Equivalent to: pkgs.clang-tools, pkgs.nil, etc.

    clang-tools
    # ↑ This is a derivation from nixpkgs

    (python3.withPackages (ps: with ps; [
      # ↑ withPackages creates a Python environment
      # ps = Python packages set
      python-lsp-server
      pylsp-mypy
      python-lsp-ruff
      pynvim
    ]))
    # ↑ Result: Python with these packages installed

    pyright
    # ↑ Separate package, not part of Python environment
  ];
}
```

**Exercise 4.1.3: Understanding withPackages**

```bash
# What's the difference between these?

# Option 1: Separate Python packages
home.packages = [
  python3
  python3Packages.numpy
  python3Packages.pandas
];
# Result: Each creates separate /nix/store paths
# python can't find numpy/pandas!

# Option 2: Python environment (what we use)
home.packages = [
  (python3.withPackages (ps: [
    ps.numpy
    ps.pandas
  ]))
];
# Result: Single /nix/store path with Python + packages
# python CAN find numpy/pandas!

# Test it:
nix-shell -p 'python3.withPackages(ps: [ps.requests])'
python3 -c "import requests; print(requests.__version__)"
# Works!

exit

nix-shell -p python3 -p python3Packages.requests
python3 -c "import requests"
# Error! Can't find requests
```

#### modules/git.nix

**Settings Structure:**

```nix
programs.git = {
  enable = true;
  # ↑ home-manager will manage git config

  settings = {
    # ↑ Everything under settings goes to ~/.gitconfig

    user = {
      name = "...";
      email = "...";
    };
    # ↑ Becomes [user] section in gitconfig

    init.defaultBranch = "main";
    # ↑ Becomes [init] section

    alias = {
      st = "status";
      co = "checkout";
    };
    # ↑ Becomes [alias] section
  };
};
```

**Exercise 4.1.4: See Generated Config**

```bash
# home-manager generates ~/.gitconfig
cat ~/.gitconfig

# Compare with your module
cat ~/nix-devenv/modules/git.nix

# They match! home-manager converted Nix → gitconfig
```

### 4.2 The Build Process

**What Happens When You Run `home-manager switch`?**

```
Step 1: Evaluate Configuration
   ↓
   Read flake.nix
   Read home.nix and all imports
   Merge all modules
   Resolve all options
   Result: Attribute set (Nix data structure)

Step 2: Build Derivations
   ↓
   For each package in home.packages:
     - Download source (if needed)
     - Build (if needed)
     - Put in /nix/store
   Build activation script
   Build home-path (merged environment)

Step 3: Activate
   ↓
   Run activation script:
     - Create ~/.gitconfig
     - Create ~/.config/direnv/direnvrc
     - Link ~/.nix-profile to new generation
     - Update home-manager gcroot
```

**Exercise 4.2.1: Trace a Build**

```bash
cd ~/nix-devenv

# Build with detailed output
nix build '.#homeConfigurations."khuang@ubuntu-laptop".activationPackage' \
  --print-build-logs \
  --verbose

# What did you see?
# - Evaluating flake.nix
# - Evaluating home-manager modules
# - Building derivations (or using cache)
# - Creating final output
```

**Exercise 4.2.2: Understanding Lazy Evaluation**

```nix
# Nix is lazy! Things only evaluate when needed

# This is valid:
let
  broken = throw "This breaks!";
in
{
  good = "hello";
  # bad = broken;  # If uncommented, would fail
}

# Test it:
nix eval --expr 'let broken = throw "error"; in { good = "hello"; }'
# Works! broken never evaluated

nix eval --expr 'let broken = throw "error"; in { bad = broken; }.bad'
# Fails! Now we need broken
```

### 4.3 How Options Work

**Exercise 4.3.1: Discover Available Options**

```bash
# List ALL home-manager options
home-manager options | less

# Search for specific option
home-manager options | grep git

# Get detailed info about an option
home-manager option programs.git.enable

# Output shows:
# - Type (boolean, string, list, etc.)
# - Default value
# - Description
# - Example usage
```

**Exercise 4.3.2: Option Types**

```nix
# Different option types in your config:

# Boolean
programs.git.enable = true;

# String
home.username = "khuang";

# Attribute set (like a dictionary)
programs.git.settings = {
  user.name = "...";
  init.defaultBranch = "main";
};

# List
home.packages = [ pkgs.git pkgs.vim ];

# Function (less common)
programs.git.extraConfig = {
  # This is an attribute set, but home-manager
  # converts it to gitconfig format
};
```

---

## Module 5: Advanced Topics & Patterns (1-2 hours)

### 5.1 Overlays & Overrides

**Concept:** Modify or add packages to nixpkgs.

**Exercise 5.1.1: Create an Overlay**

```bash
# Create overlays directory
mkdir -p ~/nix-devenv/overlays

cat > ~/nix-devenv/overlays/default.nix <<'EOF'
# Overlay: Modify or add packages
final: prev: {
  # final = resulting package set (after all overlays)
  # prev = package set before this overlay

  # Example: Add a custom hello package
  my-hello = prev.hello.overrideAttrs (oldAttrs: {
    patchPhase = ''
      substituteInPlace src/hello.c \
        --replace "Hello, world!" "Hello from Nix overlay!"
    '';
  });
}
EOF

# Use it in home.nix
# Add to home.nix:
#   nixpkgs.overlays = [ (import ./overlays) ];
#   home.packages = [ pkgs.my-hello ];

# Test
home-manager switch --flake .#khuang@ubuntu-laptop
my-hello
# Output: Hello from Nix overlay!
```

### 5.2 Secrets Management

**Problem:** How to manage API keys, passwords, etc. in Nix?

**Solutions:**

1. **agenix** - Encrypted secrets in repository
2. **sops-nix** - SOPS (Secrets OPerationS) integration
3. **External files** - Keep secrets outside git

**Exercise 5.2.1: Simple Secret Pattern**

```bash
# Create secrets directory (outside git)
mkdir -p ~/nix-secrets

cat > ~/nix-secrets/github-token <<'EOF'
ghp_fake_token_for_demo
EOF

chmod 600 ~/nix-secrets/github-token

# Reference in home-manager
cat > ~/nix-devenv/modules/git-secrets.nix <<'EOF'
{ config, pkgs, lib, ... }:
{
  home.file.".config/gh/config.yml".text = ''
    git_protocol: https
    oauth_token: ${builtins.readFile /home/khuang/nix-secrets/github-token}
  '';
}
EOF

# Import in home.nix
# Add: ./modules/git-secrets.nix to imports

# Important: ~/nix-secrets should NOT be in git!
```

### 5.3 Cross-Platform Patterns

**Exercise 5.3.1: Conditional Configuration**

```nix
{ config, pkgs, lib, isLinux, isDarwin, ... }:
{
  home.packages = with pkgs; [
    # Common packages
    git
    vim
  ] ++ lib.optionals isLinux [
    # Linux-only
    alacritty
  ] ++ lib.optionals isDarwin [
    # macOS-only
    # (No Darwin-specific packages needed yet)
  ];

  # Platform-specific config
  programs.git.extraConfig = lib.mkMerge [
    # Common config
    {
      init.defaultBranch = "main";
    }

    # Linux-specific
    (lib.mkIf isLinux {
      credential.helper = "store";
    })

    # macOS-specific
    (lib.mkIf isDarwin {
      credential.helper = "osxkeychain";
    })
  ];
}
```

### 5.4 Development Shells per Project

**Pattern:** Create per-project dev environments.

**Exercise 5.4.1: Add Dev Shell to Your Flake**

```nix
# In flake.nix, add to outputs:

devShells = forAllSystems (system: {
  default = nixpkgs.legacyPackages.${system}.mkShell {
    packages = with nixpkgs.legacyPackages.${system}; [
      home-manager
      git
    ];

    shellHook = ''
      echo "home-manager dev environment"
    '';
  };

  # Add a Python dev shell
  python-dev = nixpkgs.legacyPackages.${system}.mkShell {
    packages = with nixpkgs.legacyPackages.${system}; [
      (python3.withPackages (ps: [
        ps.pytest
        ps.black
        ps.mypy
      ]))
    ];
  };
});

# Use it:
nix develop .#python-dev
# Now you have pytest, black, mypy available
```

### 5.5 Understanding Flake Follows

**Concept:** Avoid dependency duplication.

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    # ↑ IMPORTANT: home-manager reuses YOUR nixpkgs
  };
};
```

**Without follows:**
```
Your flake uses: nixpkgs commit abc123
home-manager uses: nixpkgs commit def456

Result: TWO copies of nixpkgs downloaded and built!
```

**With follows:**
```
Your flake uses: nixpkgs commit abc123
home-manager uses: (follows your nixpkgs) commit abc123

Result: ONE copy of nixpkgs!
```

**Exercise 5.5.1: Visualize Flake Dependencies**

```bash
cd ~/nix-devenv

# Show dependency graph
nix flake metadata --json | jq '.locks.nodes'

# See what home-manager's nixpkgs follows
jq '.nodes."home-manager".inputs.nixpkgs' flake.lock

# Output: ["nixpkgs"]
# Meaning: It follows the root nixpkgs input
```

---

## Study Sessions Breakdown

### Session 1 (2-3 hours): Foundations
- Module 1: Nix Store Model
- Module 2: Flakes basics
- Hands-on: Explore your flake.nix

### Session 2 (2-3 hours): home-manager Internals
- Module 3: home-manager architecture
- Hands-on: Trace activations and generations
- Understand the build process

### Session 3 (2-3 hours): Deep Dive Your Setup
- Module 4: File-by-file analysis
- Modify each module
- Experiment with changes

### Session 4 (1-2 hours): Advanced Topics
- Module 5: Overlays, secrets, cross-platform
- Plan your next improvements

---

## Hands-On Projects (After Completing Modules)

### Project 1: Add a Custom Package

Create a package from scratch:

```nix
# overlays/my-script.nix
final: prev: {
  my-script = prev.writeShellScriptBin "my-script" ''
    #!/usr/bin/env bash
    echo "Hello from my custom script!"
    echo "My home: ${prev.lib.getEnv "HOME"}"
  '';
}
```

### Project 2: Module Composition

Create a module that composes multiple programs:

```nix
# modules/dev-environment.nix
{ config, pkgs, lib, ... }:
{
  options.myDevEnv.enable = lib.mkEnableOption "my dev environment";

  config = lib.mkIf config.myDevEnv.enable {
    programs.git.enable = true;
    programs.neovim.enable = true;
    home.packages = with pkgs; [ ripgrep fd fzf ];
  };
}
```

### Project 3: Multi-Machine Setup

Add configurations for different machines:

- Work laptop (different git email)
- Personal desktop (different packages)
- Server (minimal, no GUI tools)

---

## Resources for Continued Learning

### Official Documentation
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [home-manager Manual](https://nix-community.github.io/home-manager/)

### Deep Dives
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Excellent tutorial series
- [Nix Language Basics](https://nixos.wiki/wiki/Nix_Expression_Language)

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [r/NixOS](https://reddit.com/r/NixOS)
- [Nix Dev Discord](https://discord.gg/RbvHtGa)

### Advanced Topics to Explore Later
- NixOS system configuration
- nix-darwin for macOS
- Flake schemas and templates
- Building custom packages
- Contributing to nixpkgs

---

## Completion Checklist

After completing all modules, you should be able to:

- [ ] Explain how the Nix store works
- [ ] Understand flake inputs, outputs, and locking
- [ ] Trace symlinks from `which <cmd>` to `/nix/store`
- [ ] Read and modify home-manager modules
- [ ] Add/remove packages confidently
- [ ] Create your own modules
- [ ] Understand the build and activation process
- [ ] Debug issues using Nix tools
- [ ] Use overlays to customize packages
- [ ] Design cross-platform configurations

---

## Next Steps After Mastery

1. **Contribute to nixpkgs**
   - Fix a small bug
   - Add a missing package
   - Improve documentation

2. **Build a NixOS System**
   - Set up a VM with NixOS
   - Integrate home-manager system-wide

3. **Create Flake Templates**
   - Language-specific dev environments
   - Project templates with nix flake init

4. **Advanced Patterns**
   - CI/CD with Nix
   - Docker images from Nix
   - Binary caching with Cachix

---

**Ready to start?** Begin with Session 1, take notes, and experiment freely. Nix is declarative - you can always rollback!
