{ pkgs, ... }:
# devenv inputs add fenix github:nix-community/fenix --follows nixpkgs
# Read the value of RUST_SRC_PATH to use it in Rust Rover or other IDEs
# https://github.com/cachix/devenv/issues/1369
{
  languages.rust.enable = true;
  languages.rust.channel = "stable";
  languages.rust.components = [
    "rust-src" # Provides the stdlib (required by Rust Rover): https://rust-lang.github.io/rustup/concepts/components.html
    "rustc"
    "cargo"
    "clippy"
    "rustfmt"
    "rust-analyzer"
  ];

  packages = with pkgs; [
    pkg-config
    git
    tmux
    cargo-watch
    openssl
    clippy
  ];

  env.GREET = "<-- Rust in Nix -->";
  env.NIX_ENFORCE_PURITY = 0;
  env.RUST_BACKTRACE = "full";

  scripts.build.exec = ''
    cargo build
  '';
  scripts.release.exec = "cargo build --release";
  scripts.run.exec = "cargo run";

  # Convenience scripts to run RustRover (not included)
  # Before first usage: `nix shell nixpkgs#kleopatra --command kleopatra` and add a gpg key
  # scripts.rustrover.exec = "~/.local/share/JetBrains/Toolbox/apps/rustrover/bin/rustrover . & disown";
  scripts.rustrover.exec = "tmux new -d '~/.local/share/JetBrains/Toolbox/apps/rustrover/bin/rustrover .'";
  # scripts.zeditor.exec = "zeditor .";

  enterShell = ''
    echo "Rust version: $(rustc --version)"
    echo "Cargo version: $(cargo --version)"
    echo "Rust toolchain location: $(which cargo | sed 's@/cargo@@g')"
    echo "Rust stdlib alt location: $(which cargo | sed 's@bin/cargo@lib/rustlib/src/rust@g')"
    echo "RUST_SRC_PATH (stdlib location): $RUST_SRC_PATH"
    exec -l zsh
  '';
}
