;; Jupyterカーネル(gauche_kernel.py)から起動されるgoshのREPLドライバ。
;; カーネルは標準入力に (%jupyter-eval "<セルのソース>") を1行で送り、
;; ドライバは評価結果を標準出力に書いたあと終端マーカーを出力する。

(define %jupyter-done-ok "\x02;JUPYTER-DONE:ok\x03;")
(define %jupyter-done-error "\x02;JUPYTER-DONE:error\x03;")

;; 未定義値(define等の戻り値)は表示しない
(define (%jupyter-show-values vals)
  (for-each
   (lambda (v)
     (unless (undefined? v)
       (write v)
       (newline)))
   vals))

(define (%jupyter-show-error e)
  (display "*** ERROR: ")
  (if (condition? e)
      (display (condition-message e))
      (write e))
  (newline))

;; セル内の式を順に評価し、最後の式の値を表示する
(define (%jupyter-eval src)
  (let ([ok
         (guard (e [else (%jupyter-show-error e) #f])
           (let ([port (open-input-string src)])
             (let loop ([vals '()])
               (let ([expr (read port)])
                 (if (eof-object? expr)
                     (begin (%jupyter-show-values vals) #t)
                     (loop (call-with-values
                               (lambda () (eval expr (interaction-environment)))
                             list)))))))])
    (display (if ok %jupyter-done-ok %jupyter-done-error))
    (flush)))

(define (main args)
  (let loop ()
    (let ([form (read)])
      (unless (eof-object? form)
        (guard (e [else (%jupyter-show-error e)
                        (display %jupyter-done-error)
                        (flush)])
          (eval form (interaction-environment)))
        (loop))))
  0)
