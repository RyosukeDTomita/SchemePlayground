;;; SICP 練習問題3.52: 副作用のある手続きとストリームのメモ化
;; cons-streamは特殊形式なのでマクロで定義する。
;; (cons-stream a b) => (cons a (delay b)) で、cdrだけが遅延される。
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define the-empty-stream '())

(define (stream-null? s) (null? s))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
;; SICP本文のmemo-proc付きdelayと同じ挙動 = call-by-need。
(define (stream-cdr s) (force (cdr s)))

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

;; 練習問題3.50: 複数の引数を取る手続きを使えるよう一般化した版。
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
      the-empty-stream
      (cons-stream
       (apply proc (map stream-car argstreams))
       (apply stream-map
              (cons proc (map stream-cdr argstreams))))))

(define (stream-filter pred s)
  (cond ((stream-null? s) the-empty-stream)
        ((pred (stream-car s))
         (cons-stream (stream-car s)
                      (stream-filter pred (stream-cdr s))))
        (else (stream-filter pred (stream-cdr s)))))

(define (stream-for-each proc s)
  (if (stream-null? s)
      'done
      (begin (proc (stream-car s))
             (stream-for-each proc (stream-cdr s)))))

;; 各要素についてdelayをつけて遅延リストを作る。
(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream low
                   (stream-enumerate-interval (+ low 1) high))))

(define (display-line x)
  (newline)
  (display x))

(define (display-stream s)
  (stream-for-each display-line s))

;;; --------------------------------------------------------------------
;;; 練習問題3.52 本体
;;; --------------------------------------------------------------------

(define sum 0)

;; 呼ばれるたびにsumを破壊的に更新する(累積和)
(define (accum x)
  (set! sum (+ x sum)) ;; setでグローバルなsumを破壊的に更新できる。
  sum)

;; seqはストリーム
;; 正格なのでseq定義時にストリームは先頭だけ実体化して、残りはサンクみたいな状態になる。
;; seq =  1 : _
;; そのためsum = 1になる。
(define seq (stream-map accum (stream-enumerate-interval 1 20)))

;; 正格なのでy定義時にseqの評価が再度進む。
;; accumへの戻り値がeven?に渡るので
;; enumerate の要素:  1   2   3   4   5   6  ...  ← accum への引数
;;                    ↓  ↓  ↓  ↓  ↓  ↓
;; accum の戻り値  :  1   3   6  10  15  21  ...  ← これが seq の要素 = even? が見る値
;; 結果y = 6 : (stream-filter even? _)のような形になる。
;; そのためsum = 6
(define y (stream-filter even? seq))

;; 正格なのでz定義時にseqの評価が進む。
;; yと同様にしてaccumの戻り値が10がでたところで止まるので
;; z = 10 : (stream-filter (lambda (x) (= (remainder x 5) 0)) _) みたいな感じになる
;; そのためsum = 10
(define z (stream-filter (lambda (x) (= (remainder x 5) 0)) seq))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)

  (banner "sum start (just define seq) => ")
  (display sum) ;; 10

  (banner "(stream-ref y 7) => ")
  ;; 7番目の要素を取り出す。累積和のうち、偶数かつ、7番目は136
  ;; y :  6  10  28  36  66  78  120  136  190  210
  ;; idx  0   1   2   3   4   5    6    7
  (display (stream-ref y 7))

  (banner "sum after (stream-ref y 7 ...) => ")
  (display sum) ;; 136

  ;; displayすると最後まで評価が進む。
  (banner "(display-stream z)")
  (display-stream z)

  (banner "sum after (display-stream z ...) => ")
  (display sum) ;; 210
  (newline)
  0)
