;;; Newton法による平方根 (SICP 1.1.7)
;;; 推測値guessを繰り返し改善して sqrt(x) に近づける

;; 二乗。Gaucheには組み込みのsquareがあるが、SICPに合わせて自前で定義する
(define (square x) (* x x))

;; 相加平均
(define (average x y)
  (/ (+ x y) 2))

;; 改善: guessと x/guess の平均を取る。
(define (improve guess x)
  (average guess (/ x guess)))

;; 「十分によい」の判定。答えの二乗と被開平数の差が許容誤差0.001未満か
(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

;; 2分探索との違いはxが固定してguessを都度作り直すこと。
(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x) x))) ;; 末尾再帰

;; 
;; 初期推定値は1.0。1ではなく1.0にすることで以降の計算を小数に強制する
;; (整数同士の割り算は有理数になる処理系があるため)
(define (sqrt x)
  (sqrt-iter 1.0 x))

(define (main args)
  (print (sqrt 9))        ; => 3.00009155413138
  0)
