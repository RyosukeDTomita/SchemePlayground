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

;;; --------------------------------------------------------------------
;;; 無限ストリームの定義
;;; --------------------------------------------------------------------
;; nから始まる整数の無限ストリームを作って返す関数。
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;;; --------------------------------------------------------------------
;;; integersから別の無限ストリームを作る
;;; --------------------------------------------------------------------

(define (divisible? x y) (= (remainder x y) 0))

;; integersから7で割り切れない整数のストリームを作る。
(define no-sevens
  (stream-filter (lambda (x) (not (divisible? x 7)))
    integers))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; 先頭だけ評価されていて、残りはpromise
  (banner "(integers) => ")
  (display integers)

  (banner "(stream-car integers) => ")
  (display (stream-car integers))

  ;; 複数回実行しても2 . #promiseの結果なのは変わらん
  (banner "(stream-cdr integers) => ")
  (display (stream-cdr integers))
  (banner "(stream-cdr integers) => ")
  (display (stream-cdr integers))

  ;; 先頭10個
  (banner "(stream-head integers 10) => ")
  (display (stream-head integers 10))

  ;; 7 14 21が7の倍数なので含まれず、それ以外で20個の要素を返す
  (banner "(stream-head no-sevens 20) => ")
  (display (stream-head no-sevens 20))

  (newline)
  0)
