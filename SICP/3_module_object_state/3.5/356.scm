;;; 練習問題3.56
;;; 素因数が2, 3, 5のみからなる性の整数を昇順に重複なく列挙する
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))


(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
      '()
      (cons (stream-car s)
            (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;; 3.56
;;; --------------------------------------------------------------------
(define (add-streams s1 s2)
  (cons-stream (+ (stream-car s1) (stream-car s2))
               (add-streams (stream-cdr s1) (stream-cdr s2))))

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;; メモ化していないので遅い
(define (partial-sums s)
  (cons-stream (stream-car s) (add-streams (stream-cdr s) (partial-sums s))))

;; メモ化版。cdrを辿るたびに(partial-sums s)を呼び直すと毎回新しいストリームが
;; 作られてpromiseのメモ化が効かずO(2^n)になる。
;; 内部でpartial-sums sにpsという名前を付けて自己参照させると同じpromiseを共有できてO(n)になる。
(define (partial-sums-memo s)
  (define ps (cons-stream (stream-car s) (add-streams (stream-cdr s) ps)))
  ps)

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; integersのスタートは1 . #promise
  (banner "integers (未評価) => ")
  (display integers)
  ;; 2 . #promise
  (banner "stream-cdr integers (未評価) => ")
  (display (stream-cdr integers))

  ;; メモ化してないので遅いバージョン
  (banner "(stream-head (partial-sums integers) 10) => ")
  (display (stream-head (partial-sums integers) 10))


  ;; メモ化版なら大きいnでも即座に返る
  (banner "(stream-ref (partial-sums-memo integers) 1000) => ")
  (display (stream-ref (partial-sums-memo integers) 1000))

  (newline)
  0)
