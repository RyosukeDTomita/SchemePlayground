;;; エラトステネスの篩(ふるい)を無限ストリームで実装する。
;;; 実行: gosh sieve.scm

(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define the-empty-stream '())

(define (stream-null? s) (null? s))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))

(define (stream-ref s n)
  (if (= n 0)
    (stream-car s)
    (stream-ref (stream-cdr s) (- n 1))))

(define (stream-filter pred s)
  (cond ((stream-null? s) the-empty-stream) ;; 終了
    ;; 先頭が条件を満たすならそれを結果の先頭にしつつ、再帰
    ((pred (stream-car s))
      (cons-stream (stream-car s)
        (stream-filter pred (stream-cdr s))))
    ;; 先頭が条件を満たさないならそれを捨てて再帰
    (else (stream-filter pred (stream-cdr s)))))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
    '()
    (cons (stream-car s)
      (stream-head (stream-cdr s) (- n 1)))))

;; nから始まる整数の無限ストリームを作って返す関数。
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; xがyで割り切れるかを返す関数
(define (divisible? x y) (= (remainder x y) 0))

;;; --------------------------------------------------------------------
;;; エラトステネスのふるい
;;; --------------------------------------------------------------------
(define (sieve stream)
  (cons-stream
    (stream-car stream)
    ;; ある数がそれまでにでてきた素数で割り切れたら捨てる。
    (sieve (stream-filter
            (lambda (x)
              (not (divisible? x (stream-car stream))))
            (stream-cdr stream)))))

;; 2から始めるので、先頭は2で確定する。
(define primes (sieve (integers-starting-from 2)))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; 先頭だけ評価されていて、残りはpromise
  (banner "(primes) => ")
  (display primes)

  ;; 素数の先頭20個
  (banner "(stream-head primes 20) => ")
  (display (stream-head primes 20))

  ;; 50番目(0起点)の素数
  (banner "(stream-ref primes 50) => ")
  (display (stream-ref primes 50))

  (newline)
  0)
