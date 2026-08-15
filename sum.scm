;; 閉じた式でO(1)
(define (sum n)
  (/ (* (+ 1 n) n) 2)
)

;; 素朴な再帰。nの深さだけスタックを積む
(define (sum-rec n)
  (if (= n 0)
      0
      (+ n (sum-rec (- n 1)))))

;; 末尾再帰。名前付きletでアキュムレータを回すのでスタックは一定
(define (sum-iter n)
  (let loop ((i n) (acc 0))
    (if (= i 0)
        acc
        (loop (- i 1) (+ acc i)))))

(define (main args)
  (print (sum 10))
  (print (sum-rec 10))
  (print (sum-iter 10))
  0)
