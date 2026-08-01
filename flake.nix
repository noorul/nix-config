{
  description = "noorul's Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned to a specific emacs-31 commit rather than tracked live: every
    # source change shifts the Nix store path of emacs (and the store path
    # of gcc/libgccjit baked into native-comp-driver-options), which
    # invalidates the whole ~/.config/emacs/eln-cache fingerprint and forces
    # a full lazy-recompile of every package on next startup. Pinning keeps
    # that fingerprint -- and therefore the eln-cache -- stable across
    # ordinary rebuilds. Bump this rev deliberately when you want to update.
    emacs-src = {
      url = "github:emacs-mirror/emacs/d31d3245ba44c852356cb28e4dcc395df5ab0e3e";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, darwin, home-manager, emacs-src }:
    let
      system = "aarch64-darwin";
      username = "noorul";
      hostname = "Nooruls-MacBook-Pro";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./overlays/emacs.nix { inherit emacs-src; }) ];
      };
    in
    {
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          { nixpkgs.pkgs = pkgs; }
          ./config/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit username; };
              users.${username} = import ./config/home.nix;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations.${hostname}.pkgs;
    };
}
