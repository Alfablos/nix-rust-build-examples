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

          # First you need to generate a Cargo.lock file! Then `cd ccrate2nix-example && crate2nix generate`
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

        devShells.default = pkgs.mkShell {
          inputsFrom = [ (pkgs.callPackage ./default.nix { }) ];
          buildInputs = with pkgs; [
            rust-analyzer
            rustfmt
            clippy
          ];
        };
      }
    );
}
