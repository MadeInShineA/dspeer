{
  description = "dspeer: peer-to-peer federation of Parquet datasets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # The Rust node (iroh + Axum HTTP API)
        dspeer = pkgs.rustPlatform.buildRustPackage {
          pname = "dspeer";
          version =
            (builtins.fromTOML (builtins.readFile ./peer-dataset-federation/node/Cargo.toml)).package.version;
          src = ./peer-dataset-federation/node;
          cargoLock.lockFile = ./peer-dataset-federation/node/Cargo.lock;

          meta = {
            description = "Peer-to-peer federation of Parquet datasets (node agent)";
            homepage = "https://github.com/nipreps/dspeer";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "dspeer";
          };
        };

      in
      {
        packages = {
          inherit dspeer;
          default = dspeer;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ dspeer ];
          packages = with pkgs; [
            clippy
            rustfmt
            rust-analyzer
            python314
            uv
            curl
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

          # manylinux wheels installed by uv (numpy, pyarrow, duckdb, ...) need these
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
          ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
