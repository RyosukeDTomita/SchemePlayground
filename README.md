# ShemePlayground

## 魔導書勉強用環境

- [魔導書](https://www.vocrf.net/docs_ja/jsicp.pdf)
- [gauche](https://practical-scheme.net/gauche/index-j.html)

---

## ENVIRONMENT

- Gosh: 0.9.15
- Nix Flake

---

## HOW TO USE

```shell
# REPL
gosh
```

```shell
# run source
gosh hello.scm
```

---

## DIRECTORY

- `SICP/`: 練習問題の解答。`章ディレクトリ/節ディレクトリ/練習問題番号.scm` の構成。
  - `SICP/3_module_object_state/3.5/351.scm`: 練習問題3.51 (遅延評価の観察)
  - `SICP/3_module_object_state/3.5/352.scm`: 練習問題3.52 (副作用のある手続きとメモ化)
- `memo/`: 用語や基本文法のメモ

各 `.scm` は `main` を持つ自己完結スクリプトなので `gosh <file>` で単体実行できる。
