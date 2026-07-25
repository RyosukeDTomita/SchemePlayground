{
  description = "Gauche (R7RS Scheme) development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gauche
          ];

          shellHook = ''
            echo "Gauche $(gosh -V | sed -n 's/.*version \([0-9.]*\).*/\1/p') ready. Run 'gosh' for a REPL."
          '';
        };

        packages.default = pkgs.gauche;
      });
}
