{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  # mdformat本体はthematic breakを変換するため、`---`のまま出力する
  # mdformat-simple-breaksプラグインを使う。programs.mdformatはpackage
  # 上書きを尊重しないためsettings.formatterで直接指定する。
  settings.formatter.mdformat = {
    command = "${pkgs.mdformat.withPlugins (ps: with ps; [ ps.mdformat-simple-breaks ])}/bin/mdformat";
    includes = [ "*.md" ];
  };

  # treefmt-nixにSchemeの組み込みprogramsがないためsettings.formatterで指定する。
  # schematはPATHを引数に取り、その場で書き換える。
  settings.formatter.schemat = {
    command = "${pkgs.schemat}/bin/schemat";
    includes = [
      "*.scm"
      "*.ss"
      "*.sld"
    ];
  };
}
