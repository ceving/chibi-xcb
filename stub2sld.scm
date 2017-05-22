(define (while-stdin r  ;; Function to read from the file.
                     c  ;; Function to call for each expression. First
                        ;; argument is the currently read value. Second
                        ;; argument is list of already processed input.
                     )
  (let ((p (current-input-port)))
    (let loop ((v (r p))
               (a (list)))
      (if (eof-object? v)
          (begin
            (close-input-port p)
            a)
          (let ((r (c v a)))
            (loop (read p) r))))))

(define (export-symbol a d)
  (if (pair? a)
      (case (car a)
        ((define-c-type) (cons (cadddr a) d))
        ((define-c-enum) (cons (caadr a) d))
        (else d))
      d))

(write `(define-library (xcb)
          (import (scheme base))
          (export ,@(while-stdin read export-symbol))
          (include-shared "xcb")))
(newline)
