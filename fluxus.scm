;;;; fluxus.scm - load this from your ~/.fluxus.scm file in order to make fluxus-mode for emacs work properly!
;; for example:
;; (load "/home/user/.emacs.d/fluxus-mode/fluxus.scm")

(define (eval-each input-string)
  (let ((what (read input-string)))
    (when (not (eof-object? what))
      (eval what)
      (eval-each input-string))))

(define (osc-repl)
  (cond ((osc-msg "/code")
         (begin
           (with-handlers ([exn:fail? (lambda (exn)
                                        (println exn)
                                        'eval-error)])
             (eval-each (open-input-string (osc 0))))))
        ((osc-msg "/spawn-task")
         (let ([task-name (read (open-input-string (osc 0)))])
           (with-handlers ([exn:fail? (lambda (exn) 'spawn-error)])
             (spawn-task (eval task-name) task-name))))
        ((osc-msg "/rm-task")
         (with-handlers ([exn:fail? (lambda (exn) 'rm-task-error)])
           (rm-task (read (open-input-string (osc 0))))))
        ((osc-msg "/rm-all-tasks")
         (rm-all-tasks)
         (spawn-task osc-repl 'osc-repl))
        ((osc-msg "/clear")
         (clear)
         (load "camera.flx"))
        ((osc-msg "/load")
         (with-handlers ([exn:fail? (lambda (exn) 'load-error)])
           (load (osc 0))))
        ((osc-msg "/ping")
         (begin (display "ping")
                (newline)))))

(osc-source "34343")

(spawn-task osc-repl 'osc-repl)