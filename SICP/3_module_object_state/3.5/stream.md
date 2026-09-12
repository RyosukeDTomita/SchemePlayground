# stream

## よく出てくる関数名

- `cons-stream`: ストリーム版`cons`。第一引数だけ今すぐ評価し、第二引数はdelayで包んでpromiseにする。
- `stream-car`: ストリーム版`car`(Haskellでいう`head`)
- `stream-cdr`: ストリーム版`cdr`(Haskellでいう`tail`)
- `stream-head`: 先頭n個をリストにする(Haskellでいう`take`)
- `add-streams`: 2本のストリームを要素ごとに足し合わせる。

---

## 無限ストリームの2つの作り方

同じ数列でも定義の仕方が2通りある。`fibs.scm`でフィボナッチ数列を両方実装して比較している。

| | 明示的版 | 暗黙的版 |
| --- | --- | --- |
| 定義 | `(define (fibgen a b) (cons-stream a (fibgen b (+ a b))))` | `(cons-stream 0 (cons-stream 1 (add-streams (stream-cdr fibs) fibs)))` |
| 考え方 | 直前2項を引数で持ち回り、要素を1つずつ計算する | ストリーム自身を材料にして、数列が満たす関係をそのまま書く |
| 漸化式の在り処 | 引数の渡し方の中 | 定義の見た目そのもの |

どちらもn項を得るのにn回程度の加算で、計算量は変わらない。暗黙的版が成立するのは、自己参照が`delay`の中にあって定義完了後に評価されること、そしてpromiseがメモ化されて同じ項を2度計算しないことによる。メモ化がないと暗黙的版は再計算が指数的に増える。

---

## ファイル

- `infiniteStream.scm`: 無限ストリームの基本部品と`integers` / `no-sevens`
- `fibs.scm`: フィボナッチ数列の明示的版と暗黙的版の比較
- `sieve.scm`: エラトステネスのふるい
