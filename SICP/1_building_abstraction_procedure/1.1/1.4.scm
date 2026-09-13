;;; 練習問題1.4
(define (a-plus-abs-b a b)
  ((if (> b 0) + -) a b))

(define (main args)
  (print (a-plus-abs-b 1 10))  ; => 11  (1 + 10)
  (print (a-plus-abs-b 1 -10)) ; => 11  (1 - -10)
  0)
