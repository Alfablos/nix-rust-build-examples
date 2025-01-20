{
  pkgs ? import <nixpkgs> { },
}:
let
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
in
pkgs.rustPlatform.buildRustPackage {
  pname = manifest.name;
  version = manifest.version;
  nativeBuildInputs = [ pkgs.llvmPackages.bintools ];
  src = pkgs.lib.cleanSource ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
    # Needed since using tokio from git, not from crates registry!
    outputHashes = {
      # "tokio-1.43.0" = pkgs.lib.fakeHash;
      "tokio-1.43.0" = "sha256-GPRWTO4GlRAx2XxhIHJ43icyLRQIKemNMlKMh139nko=";
    };
  };
}
