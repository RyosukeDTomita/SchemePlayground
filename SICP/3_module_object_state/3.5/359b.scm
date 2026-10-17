;;; 練習問題3.59 b
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))

(define (stream-null? s) (null? s))

;; 3.50の複数ストリーム版stream-map
;; NOTE: applyはリストを展開して関数の引数として渡す関数
;; applyによって(s1 s2 ...)のようにリストに格納されたストリームを展開している。
;;gosh> (apply + (list 1 2 3))
;; 6
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
    '()
    (cons-stream
      (apply proc (map stream-car argstreams))
      (apply stream-map
        (cons proc (map stream-cdr argstreams))))))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
    '()
    ;; consは遅延しない普通のリストのセルを作る
    (cons (stream-car s)
      (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;; 3.59 aで定義した部品
;;; --------------------------------------------------------------------
;; 1から順に出てくるやつ
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;; e^xの積分
;; Haskellの zipWith (/) s [1..]と同じようなことをしている。
(define (integrate-series s) (stream-map / s integers))

;;; --------------------------------------------------------------------
;;; 3.59 b
;;; sin' = cos, cos' = -sinという関係を使って正負を変えたり0を入れたりする
;;; --------------------------------------------------------------------

;; sin x' = cos xなのでテイラー展開風に書くとsin x = 0 + integrate cos
(define sine-series
  (cons-stream 0 (integrate-series cosine-series)))

;; cos x' = -sin xなのでテイラー展開風に書くとcos x = 1 + (-1 * integrate sin x)
(define cosine-series
  (cons-stream 1 (stream-map (lambda (x) (* x -1)) (integrate-series sine-series))))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; cos
  (banner "(stream-head cosine-series 8) => ")
  (display (stream-head cosine-series 8))
  ;; sin
  (banner "(stream-head sine-series 8) => ")
  (display (stream-head sine-series 8))
  (newline)
  0)
