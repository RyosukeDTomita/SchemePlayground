;;; 練習問題3.53
;;; (define s (cons-stream 1 (add-streams s s)))
;;; が作るストリームを説明する。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))

(define (add-streams s1 s2)
  (cons-stream (+ (stream-car s1) (stream-car s2))
               (add-streams (stream-cdr s1) (stream-cdr s2))))

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
;;; 3.53
;;; --------------------------------------------------------------------
;; 先頭は1。以降は「自分自身と自分自身を足したもの」なので各項が2倍ずつ増える。
;; s = 1, 2, 4, 8, 16, ... つまりs[n] = 2^n。
(define s (cons-stream 1 (add-streams s s)))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  ;; 先頭だけ評価されていて、残りはpromise
  (banner "s (未評価) => ")
  (display s)

  (banner "(stream-head s 10) => ")
  ;; (1 2 4 8 16 32 64 128 256 512)
  (display (stream-head s 10))

  (banner "(stream-ref s 20) => ")
  ;; 2^20 = 1048576
  (display (stream-ref s 20))

  (newline)
  0)
