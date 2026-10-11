;;; 練習問題3.56
;;; 素因数が2, 3, 5のみからなる正の整数を昇順に重複なく列挙する
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

(define (stream-map proc s)
  (if (stream-null? s)
    '()
    (cons-stream (proc (stream-car s))
      (stream-map proc (stream-cdr s)))))

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
;;; 素因数が
;;; 2, 3, 5 のみからなる正の整数を昇順に重複なく列挙する
;;; 1つずつ整数をチェックして2,3,5以外の素因数がないことをチェックするのは非効率。
;;; そのため、以下の方法で実施する
;;; 1. Sは1から始まる
;;; 2. (scale-stream S 2) の要素もまた、Sの要素である。
;;; 3. 同じことが(scale-stream S 3)と(scale-stream S 5)についても言える。
;;; --------------------------------------------------------------------

;; ストリームの全要素にfactor倍する
;; Haskellでいうmap (\x -> x * factor) xsみたいなことをやっている。
(define (scale-stream s factor)
  (stream-map (lambda (x) (* x factor)) s))

;; merge対象になっている2つのストリームのうち、それぞれの先頭を1つずつ取り出して、小さい方を1つずつ取り出す。
(define (merge s1 s2)
  (cond ((stream-null? s1) s2) ;; condはHaskellのガードに近い。nullチェックを行っている。
    ((stream-null? s2) s1)
    (else
      (let ((s1car (stream-car s1))
            (s2car (stream-car s2)))
        (cond ((< s1car s2car)
               (cons-stream s1car (merge (stream-cdr s1) s2)))
          ((> s1car s2car)
            (cons-stream s2car (merge s1 (stream-cdr s2))))
          (else ;; 統合成立
            (cons-stream s1car
              (merge (stream-cdr s1)
                (stream-cdr s2)))))))))
;; Sは答えの数列をストリームで表したもの
(define S (cons-stream 1 (merge (scale-stream S 2)
                          (merge (scale-stream S 3)
                            (scale-stream S 5)))))
;;; --------------------------------------------------------------------
;;; 実行
;;; --------------------------------------------------------------------

(define (banner msg)
  (newline)
  (display ";; ")
  (display msg))

(define (main args)
  (banner "(stream-head S 20) => ")
  (display (stream-head S 20))
  (newline)
  0)
