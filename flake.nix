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
        # nixpkgsにないためPyPIのビルド済みwheelから入れる
        solarizedDarkTheme = pkgs.python3Packages.buildPythonPackage rec {
          pname = "jupyterlab_theme_solarized_dark";
          version = "3.0.1";
          format = "wheel";
          src = pkgs.fetchPypi {
            inherit pname version format;
            dist = "py3";
            python = "py3";
            hash = "sha256-8GyHYypZywPRxBCyTSmsu2rON5tznVznd23lipnFWOg=";
          };
        };
        # Jupyter Notebook + 自前のGaucheカーネル(jupyter/kernels/gauche)が使うipykernel + Vimキーバインド拡張
        # Notebookは{sys.prefix}/share/jupyter/lab/settings/overrides.d/*.jsonを読むので、
        # そこに置いてデフォルトテーマをSolarized Darkにする
        jupyterEnv = pkgs.python3.buildEnv.override {
          extraLibs = with pkgs.python3Packages; [
            notebook
            ipykernel
            jupyterlab-vim
            solarizedDarkTheme
          ];
          postBuild = ''
            mkdir -p $out/share/jupyter/lab/settings/overrides.d
            cat > $out/share/jupyter/lab/settings/overrides.d/theme.json <<'JSON'
            ${builtins.toJSON {
              "@jupyterlab/apputils-extension:themes".theme = "JupyterLab Solarized Dark";
            }}
            JSON
          '';
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # nix fmt / nix flake check で使う
        formatter = treefmtEval.config.build.wrapper;
        checks.formatting = treefmtEval.config.build.check self;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gauche
            jupyterEnv
            treefmtEval.config.build.wrapper
          ];

          shellHook = ''
            export JUPYTER_PATH="$PWD/jupyter''${JUPYTER_PATH:+:$JUPYTER_PATH}"
            echo "Gauche $(gosh -V | sed -n 's/.*version \([0-9.]*\).*/\1/p') ready. Run 'gosh' for a REPL."
          '';
        };

        packages.default = pkgs.gauche;
      }
    );
}
