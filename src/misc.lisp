(in-package :hex-utils)

; (load "macro-utils.lisp")
(defmacro! conditional (o!itm pred &body body)
  (flet ((mk-conds (items)
            (mapcar
              (lambda (x)
                `((funcall ,pred ,g!itm ,(car x)) ,@(cdr x)))
              items)))
    `(cond
      ,@(if (eq t (caar (last body)))
            (append (mk-conds
                      (butlast body))
                    (last body))
            (mk-conds body)))))
;; example:
; (defun run-game (msg)
;   (conditional
;     (car msg) 'string=
;     ("isready"      "readyok")
;     ("newgame"      (newgame))
;     ("setposition"  (setposition (second msg) (third msg)))
;     ("setoption"    (setoption (second msg) (cddr msg)))
;     ("makemove"     (makemove (cdr msg)))
;     ("go"           (go))
;     ("stop"         (stop-engine))
;     ("quit"         (setf *quit* t)))
;     (t              "I gots nuttin..."))

(defmacro whens (&rest args)
  `(progn
    ,@(mapcar
        (lambda (x)
          `(when ,(car x) ,(cadr x)))
        args)))
