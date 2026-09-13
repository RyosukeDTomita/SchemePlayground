;;; 練習問題1.3
;;; 3つの数を引数として取り、そのうち大きい方から2つの数の二乗の和を返す手続き

(define (square x) (* x x))

(define (sum-of-squares x y)
  (+ (square x) (square y)))

(define (sum-of-larger-squares a b c)
  (cond ((and (<= a b) (<= a c)) (sum-of-squares b c))  ; aが最小
        ((and (<= b a) (<= b c)) (sum-of-squares a c))  ; bが最小
        (else (sum-of-squares a b))))                   ; cが最小

(define (main args)
  (print (sum-of-larger-squares 1 2 3)) ; => 13  (2^2 + 3^2)
  (print (sum-of-larger-squares 5 4 3)) ; => 41  (5^2 + 4^2)
  (print (sum-of-larger-squares 2 2 2)) ; => 8   全部同じ
  0)
