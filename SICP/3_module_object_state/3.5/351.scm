;;; SICP 練習問題3.51: 遅延評価の観察
;;; stream-mapは練習問題3.50の一般化版(多引数)をベースにする。

;; cons-streamは特殊形式なのでマクロで定義する。
;; (cons-stream a b) => (cons a (delay b)) で、cdrだけが遅延される。
;; carは即座に評価される点が、Haskellの (:) と違うところ。
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

;; 各要素についてdelayをつけて遅延リストを作る。
(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream low
                   (stream-enumerate-interval (+ low 1) high))))

;;; --------------------------------------------------------------------
;;; 練習問題3.51: 引数を表示してそのまま返す手続き
;;; --------------------------------------------------------------------

(define (display-line x)
  (newline)
  (display x))

(define (show x)
  (display-line x)
  x)

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; cons-streamのcarは即評価なので、この定義の時点で (show 0) が走り 0 が出力される。
  (banner "(define x (stream-map show (stream-enumerate-interval 0 10)))")
  (let ((x (stream-map show (stream-enumerate-interval 0 10))))

    ;; 0はすでに評価済み。cdrを5回forceする過程で 1 2 3 4 5 が出力される。
    (banner "(stream-ref x 5)")
    (let ((r5 (stream-ref x 5)))
      (banner "=> ")
      (display r5))

    ;; 0〜5はpromiseがメモ化済みなので再評価されず、6 7 だけが出力される。
    ;; メモ化しないdelayだと 1..7 が全部出力されることになる。
    (banner "(stream-ref x 7)")
    (let ((r7 (stream-ref x 7)))
      (banner "=> ")
      (display r7)))

  (newline)
  0)
