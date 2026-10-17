;;; SICP 3.5.3: ストリームパラダイムの活用
;;; 平方根の推測値を、状態変数の代わりに無限ストリームとして生成する。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (delay b)))))

(define (stream-car s) (car s))

;; Gaucheのdelay/forceはR7RSのpromiseなのでメモ化される。
(define (stream-cdr s) (force (cdr s)))

;; Haskellでいうmap
;; 無限ストリーム専用なので空ストリームの判定は省略している。
(define (stream-map proc s)
  (cons-stream (proc (stream-car s))
               (stream-map proc (stream-cdr s))))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
      '()
      (cons (stream-car s)
            (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;; 3.5.3 sqrt-stream
;;; --------------------------------------------------------------------
(define (average a b)
  (/ (+ a b) 2))

(define (sqrt-improve guess x)
  (average guess (/ x guess)))

;; 元のsqrtでは状態変数guessを更新していたが、ここでは推測値の列そのものを返す。
;; guessesが自分自身を参照するので、各推測値は1回しか計算されない。
(define (sqrt-stream x)
  (define guesses
    (cons-stream
     1.0
     (stream-map (lambda (guess) (sqrt-improve guess x))
                 guesses)))
  guesses)

;;; --------------------------------------------------------------------
;;; 比較: 通常の再帰
;;; --------------------------------------------------------------------

;; guessを引数(状態変数)として持ち回り、最終値だけを返す。
;; 途中の推測値は捨てられるので、何回反復するかは呼び出し側から決められない。
(define (good-enough? guess x)
  (< (abs (- (* guess guess) x)) 0.001))

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (sqrt-improve guess x) x)))

;; sqrt-streamと同じように途中経過のリストを得られるようにしたもの。
;; 末尾再帰でなく、生成と打ち切りを1つの関数に混ぜる必要がある。
(define (sqrt-guesses guess x n)
  (if (= n 0)
      '()
      (cons guess
            (sqrt-guesses (sqrt-improve guess x) x (- n 1)))))

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  (banner "(stream-head (sqrt-stream 2) 5) => ")
  ;; (1.0 1.5 1.4166666666666665 1.4142156862745097 1.4142135623746899)
  (display (stream-head (sqrt-stream 2) 5))

  (banner "(sqrt-iter 1.0 2) => ")
  ;; 1.4142156862745097
  (display (sqrt-iter 1.0 2))

  (banner "(sqrt-guesses 1.0 2 5) => ")
  ;; (1.0 1.5 1.4166666666666665 1.4142156862745097 1.4142135623746899)
  (display (sqrt-guesses 1.0 2 5))


  (newline)
  0)
