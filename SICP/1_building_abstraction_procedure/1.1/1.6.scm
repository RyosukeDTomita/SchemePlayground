;;; 練習問題1.6
;;; ifを普通の手続きnew-ifで置き換えたらどうなるか
;;;
;;; ifは特殊形式なので、述語だけを評価し、その結果を踏まえていらないほうは評価しない。
;;; condもこれは同様
;;; だが、(define (new-if predicate then-clause else-clause)のように定義すると正格評価の言語ではすべての引数を評価することになってしまう。
;;; それ所以に、ifであれば再帰が停止する地点でも再帰が続き、無限再帰してしまう。

;;; 今回作ったcondあればifいらなくね?ってやつ
(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
    (else else-clause)))


;;;--------------------------------------------
;;; 評価に使うnewton法
;;;--------------------------------------------
(define (average x y)
  (/ (+ x y) 2))

(define (improve guess x)
  (average guess (/ x guess)))

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

;; new-if版のsqrt-iter。呼ぶと止まらない
(define (sqrt-iter guess x)
  (new-if (good-enough? guess x)
    guess
    (sqrt-iter (improve guess x) x)))

(define (main args)
  ;; 無限再帰になる
  (print (sqrt-iter 1.0 9))
  0)
