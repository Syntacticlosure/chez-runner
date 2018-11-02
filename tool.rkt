#lang racket
(require racket/gui pict mrlib/include-bitmap
         drracket/tool
         mrlib/switchable-button)
(provide tool@)
(define icon (include-bitmap "favicon.png"))
(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)
    (define phase1 void)
    (define phase2 void)
    (define chez-runner-mixin
      (mixin (drracket:unit:frame<%>) ()
        (super-new)
        (inherit register-toolbar-button
                 get-button-panel
                 get-definitions-text
                 get-interactions-text
                 ensure-rep-shown)
        (define run-chez (new switchable-button%
                              [label "Run Chez"]
                              [parent (get-button-panel)]
                              [bitmap icon]
                              [callback (λ (self)
                                          (define codes (send (get-definitions-text) get-text))
                                          (define tmpfile (make-temporary-file "chezscheme_temp_file~a"
                                                                               #f
                                                                               (get-preference 'files-viewer:directory)))
                                          (call-with-output-file tmpfile
                                            (lambda (p)
                                              (display codes p))
                                            #:exists 'append)
                                          (match-define (list stdout stdin pid stderr _)
                                            (process (format "scheme --script ~a" tmpfile)))
                                          (send (get-interactions-text) reset-console)
                                          (ensure-rep-shown #f)
                                          (send (get-interactions-text)
                                                insert
                                                (format "~a~a\n" (port->string stdout)
                                                        (port->string stderr))
                                                (send (get-interactions-text) get-end-position))
                                          (close-output-port stdin)
                                                                               
                                          )]))
        (register-toolbar-button run-chez #:number 99)
        ))
    (drracket:get/extend:extend-unit-frame chez-runner-mixin)
    ))
