# ShemePlayground

## 魔導書勉強用環境

- [魔導書](https://www.vocrf.net/docs_ja/jsicp.pdf)
- [gauche](https://practical-scheme.net/gauche/index-j.html)

---

## ENVIRONMENT

- Gosh: 0.9.15
- Jupyter Notebook: 7.5 (Gauche用カーネル同梱、Vimキーバインド拡張`jupyterlab-vim`入り、テーマはSolarized Dark)
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

```shell
# Jupyter Notebook (カーネルは "Gauche (gosh)" を選ぶ)
jupyter notebook notebooks/
```

devShellの`shellHook`が`JUPYTER_PATH`に`jupyter/`を追加するので、Gaucheカーネルは`jupyter kernelspec list`に自動で表示される。セル内の式を順に評価し、最後の式の値を`write`で表示する(`define`などの未定義値は表示しない)。

### Jupyter Notebook

- セルの移動にもvimのキーバインドのjkが使える。
- セルに入るにはEnter
- 実行はCtrl + Enter

---

## DIRECTORY

- `SICP/`: 練習問題の解答。`章ディレクトリ/節ディレクトリ/練習問題番号.scm` の構成。
  - `SICP/3_module_object_state/3.5/351.scm`: 練習問題3.51 (遅延評価の観察)
  - `SICP/3_module_object_state/3.5/352.scm`: 練習問題3.52 (副作用のある手続きとメモ化)
  - `SICP/3_module_object_state/3.5/infiniteStream.scm`: 3.5.2 (無限ストリーム。正格リストとの比較つき)
- `memo/`: 用語や基本文法のメモ
- `notebooks/`: Jupyter Notebook (`hello.ipynb`は最初に開くハローワールド、`sample.ipynb`はGaucheカーネルの動作例)
- `jupyter/kernels/gauche/`: 自前のGauche用Jupyterカーネル
  - `gauche_kernel.py`: goshをサブプロセスで起動するipykernelベースのラッパー
  - `driver.scm`: gosh側の評価ループ。セルを評価し、終端マーカーを出力する

各 `.scm` は `main` を持つ自己完結スクリプトなので `gosh <file>` で単体実行できる。
