;;; 練習問題3.54
;;; n番目の要素が(n+1)の階乗となるストリームfactorialsを定義する。
;;; mul-streamsも併せて定義する。
;;; --------------------------------------------------------------------
;;; ストリームの基本部品
;;; --------------------------------------------------------------------
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
;;; 3.54
;;; --------------------------------------------------------------------
;;; mul-streamsが両方の引数をcdrして再帰している。
;;; これにより、integersとfactorialsが次の要素に更新されている。
(define (mul-streams s1 s2)
  (cons-stream (* (stream-car s1) (stream-car s2))
               (mul-streams (stream-cdr s1) (stream-cdr s2))))

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))

;; 先頭だけ評価されており、残りはpromise
(define integers (integers-starting-from 1))

;; 0から数えてn番目の要素がn+1の階乗になるストリーム
;; factorialsは1 . #<promiseになっており、stream-cdr integersでintegersの次の要素が得られる
;; 0番目は1が返され、1番目にはstream-cdr integersの先頭2とfactorials(1)で2が、2番目には3*factorials(2)のように進む
(define factorials (cons-stream 1 (mul-streams (stream-cdr integers) factorials)))

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

  ;; 先頭だけ評価されていて、残りはpromise
  (banner "factorials (未評価) => ")
  (display factorials)

  (banner "(stream-head factorials 10) => ")
  (display (stream-head factorials 10))

  (newline)
  0)
