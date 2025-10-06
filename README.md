# My Nix Packages Flake

This repository serves as a Nix flake providing a collection of custom Nix packages and overlays.

## Structure

- `flake.nix`: Defines the flake's inputs and outputs, including custom packages and overlays.
- `pkgs/`: Contains the definitions for individual packages.

## Usage

To utilize the packages and overlays defined in this flake, you can add it as an input to your own `flake.nix`.

### Adding as an Input

Add the following to your `flake.nix` inputs:

```nix
{
  inputs = {
    # ... other inputs
    my-flakes.url = "github:ypcodes/nix-packages"; # Replace with your actual repository URL if forked
    my-flakes.inputs.nixpkgs.follows = "nixpkgs"; # Ensures consistency and allows overriding the nixpkgs version used by 'my-flakes'
  };

  # ... outputs
}
```

### Using with NixOS Configurations

To integrate packages from this flake into your NixOS system configuration (e.g., in `configuration.nix`):

```nix
{
  # ... inputs and outputs as above

  outputs = { self, nixpkgs, my-flakes, ... }: {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Or your system architecture
      modules = [
        # Your existing modules
        {
                    environment.systemPackages = with nixpkgs; [
                          my-flakes.packages.${nixpkgs.system}.algermusicplayer-bin            # Add other packages from this flake here
          ];

          # If this flake provided an overlay you wanted to apply globally:
          # nixpkgs.overlays = [ my-flakes.overlays.default ];
        }
      ];
    };
  };
}
```

### Using with Home Manager Configurations

To use packages from this flake within your Home Manager configuration (e.g., in `home.nix`):

```nix
{
  # ... inputs and outputs as above

  outputs = { self, nixpkgs, my-flakes, ... }: {
    homeConfigurations.my-user = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${nixpkgs.system};
      modules = [
        # Your existing Home Manager modules
        {
          home.packages = with nixpkgs; [
            my-flakes.packages.${nixpkgs.system}.algermusicplayer-bin
            # Add other packages from this flake here
          ];
        }
      ];
    };
  };
}
```

### Development Shell

To create a development shell that includes packages from this flake:

```nix
{
  # ... inputs and outputs as above

  outputs = { self, nixpkgs, my-flakes, ... }: {
    devShells.${nixpkgs.system}.default = nixpkgs.mkShell {
      packages = with nixpkgs; [
        my-flakes.packages.${nixpkgs.system}.algermusicplayer-bin
      ];
    };
  };
}
```

### Building a specific package

You can build a package directly from this flake using `nix build`:

```bash
nix build github:ypcodes/nix-packages#algermusicplayer
```

### Running a specific package

You can run a package directly from this flake using `nix run`:

```bash
nix run github:ypcodes/nix-packages#algermusicplayer
```
