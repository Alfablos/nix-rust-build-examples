{
  description = "buildRustPackage example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=041c867bad68dfe34b78b2813028a2e2ea70a23c";
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      crate2nix,
      flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          default = pkgs.symlinkJoin {
            name = "nix-rust";
            paths = [
              buildRustPackageExample
              crate2nixExample
            ];
          };
          buildRustPackageExample =
            nixpkgs.legacyPackages.${system}.callPackage ./buildrustpackage-example { };

          # First you need to generate a Cargo.lock file for the WORKSPACE! No other Cargo.lock must be present!
          crate2nixExample =
            # let
            #   cargoNix = pkgs.callPackage ./Cargo.nix { };
            # in cargoNix.workspaceMembers.crate2nix-example.build;
            let
              cargoNix = crate2nix.tools.${system}.appliedCargoNix {
                name = "crate2nixExample";
                src = ./.;
              };
            in
            cargoNix.workspaceMembers.crate2nix-example.build;
        };

        devShells =
        let
            shellHook = ''
            alias rustrover="tmux new -d '/home/antonio/.local/share/JetBrains/Toolbox/apps/rustrover/bin/rustrover .'"
            alias v=nvim
            '';
            commonBuildInputs = with pkgs; [
                rust-analyzer
                rustfmt
                clippy
                llvmPackages.bintools
            ];
        in
        {
            buildRustPackage = pkgs.mkShell {
              inputsFrom = [ (pkgs.callPackage ./buildrustpackage-example/default.nix { }) ];
              buildInputs = commonBuildInputs;

              inherit shellHook;
            };

            crate2nix = pkgs.mkShell {
              # inputsFrom = [ (pkgs.callPackage ./crate2nix-example/default.nix { }) ];
              inputsFrom = [ self.packages.${system}.crate2nixExample ];
              buildInputs = commonBuildInputs;
              inherit shellHook;
            };
        };
      }
    );
}
