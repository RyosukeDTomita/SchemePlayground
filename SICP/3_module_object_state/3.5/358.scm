;;; 練習問題3.58
;;; expandが生成するストリームの意味を考える。
;;; (expand 1 7 10)と(expand 3 8 10)が生成する要素は何か。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
    '()
    (cons (stream-car s)
      (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;; 3.58
;;; num/denをradix進数で表したときの小数部の各桁を順に並べた無限ストリーム。
;;; (num < denを想定)
;;; 筆算の割り算と同じで、余りをradix倍して次の桁を求める。
;;; 1. 商(quotient (* num radix) den)が今の桁
;;; 2. 余り(remainder (* num radix) den)を次のnumにして繰り返す
;;; gosh$ (quotient 1 2)
;;; 0
;;; gosh$ (quotient 11 2)
;;; 5
;;; gosh$ (remainder 1 2)
;;; 1
;;; gosh$ (remainder 11 2)
;;; 1
;;; --------------------------------------------------------------------
(define (expand num den radix)
  (cons-stream
    (quotient (* num radix) den)
    (expand (remainder (* num radix) den) den radix)))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; 1/7 = 0.142857142857... なので 1 4 2 8 5 7 を繰り返す
  (banner "(stream-head (expand 1 7 10) 10) => ")
  (display (stream-head (expand 1 7 10) 10))
  ;; 3/8 = 0.375 なので 3 7 5 のあとは余りが0になり 0 が無限に続く
  (banner "(stream-head (expand 3 8 10) 10) => ")
  (display (stream-head (expand 3 8 10) 10))
  ;; 1/2 (2進数)
  (banner "(stream-head (expand 1 2 2) 10) => ")
  (display (stream-head (expand 1 2 2) 10))
  ;; 1/4 (2進数)
  (banner "(stream-head (expand 1 4 2) 10) => ")
  (display (stream-head (expand 1 4 2) 10))
  (newline)
  0)
