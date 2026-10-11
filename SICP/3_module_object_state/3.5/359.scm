;;; 練習問題3.59
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
;;; 3.59
;;; --------------------------------------------------------------------
;; 1から順に出てくるやつ
(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;; e^xの積分
;; Haskellの zipWith (/) s [1..]と同じようなことをしている。
(define (integrate-series s) (stream-map / s integers))

;; e^xのテイラー展開。
;; a0 + a1x + a2x^2 + a3x^3 + ... は、係数a0, a1, a2, a3, ... を要素として持つストリームとして表したもの。
;; e^8はは自分自身の導関数なので、定数項1に自分の積分をconsすればよい。
(define exp-series
  ;; cons-streamで作ったものは、ストリームになる。
  ;; つまり、cons 1 (delay (stream-map / exp-series integers))になっている。
  ;; mainでの使われ方のように、stream-headを使う場合、stream-headで1回再帰するたびにexp-seriesが先頭から順に取り出されて短くなっていく。
  ;; つまり、以下のようになる。
  ;; 1/1 1/2 1/3 1/4 1/5 1/6 1/7 1/8 -> stream-head初回
  ;;     1/1 1/2 1/3 1/4 1/5/1/6 1/7 -> stream-head再帰2回目
  ;;         1/1 1/2 1/3 1/4 1/5 1/6 -> stream-head再帰3回目
  ;;...
  ;; これを縦に掛け算したものがanになる。
  (cons-stream 1 (integrate-series exp-series)))

;;; --------------------------------------------------------------------
;;; 3.59 b
;;; sin' = cos, cos' = -sin
;;; --------------------------------------------------------------------
(define cosine-series
  (cons-stream 1 (error "TODO: cosine-series")))

(define sine-series
  (cons-stream 0 (error "TODO: sine-series")))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; 1, 1, 1/2, 1/6, 1/24, ...
  ;; NOTE: goshの/は整数同士だといい感じに分数になる
  ;; gosh$ (/ 1 2)
  ;; 1/2
  ;; gosh$ (/ 1/2 3)
  ;; 1/6
  (banner "(stream-head exp-series 8) => ")
  (display (stream-head exp-series 8))
  ;; 1, 0, -1/2, 0, 1/24, ...
  ; (banner "(stream-head cosine-series 8) => ")
  ; (display (stream-head cosine-series 8))
  ; ;; 0, 1, 0, -1/6, 0, 1/120, ...
  ; (banner "(stream-head sine-series 8) => ")
  ; (display (stream-head sine-series 8))
  (newline)
  0)
