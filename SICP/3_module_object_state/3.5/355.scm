;;; 練習問題3.55
;;; ストリームSを引数としてとり、要素がS0, S0+S1,S0+S1+S2であるストリームを返す手続きを定義する。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
;; cons-stream a bと書くと(cons a (delay b))に書き換わるというマクロ
;; _はcons-stream自身にマッチする。
;; Schemeの関数は引数を先に全部評価してから呼び出されるので遅延できない。
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
;;; 3.55
;;; --------------------------------------------------------------------
;; 各要素を足す
(define (add-streams s1 s2)
  (cons-stream (+ (stream-car s1) (stream-car s2))
    (add-streams (stream-cdr s1) (stream-cdr s2))))

;; 1から順に出てくるやつ
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;; メモ化していないので遅い
;; 先頭がstream-car sでそれ以降の要素はintegersの次の要素 + 1つ前の答え(partial-sums s)で再計算している。
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

  ;; (1 2 3 4 5)
  (banner "(stream-head integers 5) => ")
  (display (stream-head integers 5))

  ;; 2 . #promise (先頭1+1だけ評価済み)
  (banner "add-streams integers integers (未評価) => ")
  (display (add-streams integers integers))
  ;; (2 4 6 8 10)
  (banner "(stream-head (add-streams integers integers) 5) => ")
  (display (stream-head (add-streams integers integers) 5))

  ;; メモ化してないので遅いバージョン
  (banner "(stream-head (partial-sums integers) 10) => ")
  (display (stream-head (partial-sums integers) 10))
  (banner "(stream-ref (partial-sums integers) 1000) => ")
  (display (stream-ref (partial-sums integers) 1000))

  ;;; メモ化版なら大きいnでも即座に返る
  (banner "(stream-head (partial-sums-memo integers) 10) => ")
  (display (stream-head (partial-sums-memo integers) 10))
  (banner "(stream-ref (partial-sums-memo integers) 100000) => ")
  (display (stream-ref (partial-sums-memo integers) 100000))

  (newline)
  0)
