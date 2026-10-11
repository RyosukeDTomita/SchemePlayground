;;; 練習問題3.57
;;; add-streamsを使ったfibsでn番目のフィボナッチ数を計算するとき、加算は何回行われるか。
;;; delayがメモ化しない場合、加算の回数が指数関数的に増えることを示す。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
;; SICP 3.5.1と同じくdelayを「引数なしのlambda」+ memo-procで自前実装する。
;; 常にメモ化する。

;; 最初の呼び出し結果を覚えておき、2回目以降は計算せずに返す。
(define (memo-proc proc)
  (let ((already-run? #f)
        (result #f))
       (lambda ()
         (if (not already-run?)
           (begin (set! result (proc))
                  (set! already-run? #t)
                  result)
           result))))

(define-syntax cons-stream
  (syntax-rules ()
    ((_ a b) (cons a (memo-proc (lambda () b))))))

(define (stream-car s) (car s))

;; forceは単にthunkを呼ぶだけ
(define (stream-cdr s) ((cdr s)))

;; Haskellでいうtake
(define (stream-head s n)
  (if (= n 0)
    '()
    (cons (stream-car s)
      (stream-head (stream-cdr s) (- n 1)))))

;;; --------------------------------------------------------------------
;;; 3.57
;;; --------------------------------------------------------------------
;; 加算の回数を数えるカウンタ
(define *additions* 0)

;; 加算のカウンタを更新しつつ、足し算を行う
(define (counting-add a b)
  (set! *additions* (+ *additions* 1)) ;; グローバル変数への再代入
  (+ a b))

;; 2本のストリームを要素ごとに足し合わせる。加算はcounting-addで数える。
(define (add-streams s1 s2)
  (cons-stream (counting-add (stream-car s1) (stream-car s2))
    (add-streams (stream-cdr s1) (stream-cdr s2))))

;; fibs.scmの暗黙的版。加算回数を数え直せるように、呼ぶたびに新しいfibsを作る関数にしている。
;; 内部defineで自己参照させるので、同じpromiseが共有される。
(define (fibs)
  (define s
    (cons-stream
      0
      (cons-stream 1 (add-streams (stream-cdr s) s))))
  s)

;; n番目のフィボナッチ数列(n >= 1)を求める加算はn-1回。
;; n = 0 -> (初期値) 加算回数0
;; n = 1 -> (初期値) 0
;; n = 2 -> fib (n-1) + fib(n-2) で加算回数1回
;; n = 3 -> fib (n-1) + fib(n-2) で加算回数1回
;; よってn番目の加算回数はn*1 - 2 + 1(0スタートのため)=n-1回

;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  (set! *additions* 0)
  (banner "(stream-head (fibs) 15) => ")
  (display (stream-head (fibs) 15))
  (banner "加算回数=n-1回: ")
  (display *additions*)

  (newline)
  0)
