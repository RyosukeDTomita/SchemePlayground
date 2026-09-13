{
  description = "Gauche (R7RS Scheme) development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # nix fmt / nix flake check で使う
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gauche
            treefmtEval.config.build.wrapper
          ];

          shellHook = ''
            echo "Gauche $(gosh -V | sed -n 's/.*version \([0-9.]*\).*/\1/p') ready. Run 'gosh' for a REPL."
          '';
        };

        packages.default = pkgs.gauche;
      }
    );
}
