# Schemeの文法

## S式

これだけ覚えればいい

- アトム: それ以上分解できないもの。1, 3.14 "hello"
- リスト: `(1 2 3)`, `(+ 1 2)`

---

## よく使いそう

Haskellにある概念で例えてとりあえずメモ。右がHaskell

```
cons x xs = x : xs   -- (:)
car  = head
cdr  = tail
```
