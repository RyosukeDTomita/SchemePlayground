;;; フィボナッチ数列を2通りで作って比較する。
;;;   1. 明示的にストリーム要素を1つずつ計算する
;;;   2. 遅延評価を使って暗黙的にストリームを作る

;;; --------------------------------------------------------------------
;;; ストリームの基本部品(infiniteStream.scmと同じ)
;;; --------------------------------------------------------------------

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

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
      '()
      (cons (stream-car s)
            (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;;   1. 明示的にストリーム要素を1つずつ計算する
;;; --------------------------------------------------------------------
;; (a b)が「いま出す項」と「次の項」。状態を引数で持ち回って前に進む。
;; 数列の漸化式はfibgenの引数の渡し方の中に埋め込まれている。
(define (fibgen a b) (cons-stream a (fibgen b (+ a b))))

(define fibs-explicit (fibgen 0 1))

;;; --------------------------------------------------------------------
;;;   2. 遅延評価を使って暗黙的にストリームを作る
;;; --------------------------------------------------------------------
;; 2本のストリームを要素ごとに足し合わせる。
(define (add-streams s1 s2)
  (cons-stream (+ (stream-car s1) (stream-car s2))
               (add-streams (stream-cdr s1) (stream-cdr s2))))

;; fibs     = 0 1 1 2 3 5  8 ...
;; cdr fibs = 1 1 2 3 5 8 13 ...
;; 上下を足すと2つ目以降の項が出てくる、という関係をそのまま定義にする。
;; 定義の途中でfibs-implicit自身を参照しているが、delayの中なので
;; 評価されるころには定義が完了している。
(define fibs-implicit
  (cons-stream
   0
   (cons-stream 1 (add-streams (stream-cdr fibs-implicit) fibs-implicit))))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; どちらも先頭だけ評価されていて、残りはpromise
  (banner "fibs-explicit (未評価) => ")
  (display fibs-explicit)
  (banner "fibs-implicit (未評価) => ")
  (display fibs-implicit)

  ;; 同じ数列になることを確認する
  (banner "(stream-head fibs-explicit 15) => ")
  (display (stream-head fibs-explicit 15))
  (banner "(stream-head fibs-implicit 15) => ")
  (display (stream-head fibs-implicit 15))

  ;; さらに先を要求すると、その分だけ追加で計算される。
  (banner "(stream-ref fibs-explicit 60) => ")
  (display (stream-ref fibs-explicit 60))
  (banner "(stream-ref fibs-implicit 60) => ")
  (display (stream-ref fibs-implicit 60))

  (newline)
  0)
