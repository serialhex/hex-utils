(in-package :hex-utils)

;; defmacro-BANG!

;; gotta make sure it loads and compiles!
(eval-when (:execute :load-toplevel :compile-toplevel)

(defun g!-symbol-p (s)
  (and (symbolp s)
       (> (length (symbol-name s)) 2)
       (string= (symbol-name s)
                "G!"
                :start1 0
                :end1 2)))

#|
; this works, but i can't get it to work with defmacro/g! :'(
(defmacro set-macro-docs (&rest code)
  `(if (and (stringp (car body)) (cdr body))
      (list (car body)
            (let ((body (cdr body)))
              ,@code))
      (progn ,@code)))

(defmacro defmacro/g! (name args &rest body)
  (let ((syms (remove-duplicates
                (remove-if-not #'g!-symbol-p
                               (flatten body)))))
    `(defmacro ,name ,args
      ,@(if (and (stringp (car body)) (cdr body))
            `(,(car body)
              (let ,(mapcar
                    (lambda (s)
                      `(,s (gensym ,(subseq
                                      (symbol-name s)
                                      2))))
                    syms)
              ,@(cdr body)))
            `(let ,(mapcar
                    (lambda (s)
                      `(,s (gensym ,(subseq
                                      (symbol-name s)
                                      2))))
                    syms)
              ,@body)))))
|#

(defmacro defmacro/g! (name args &rest body)
  (let ((syms (remove-duplicates
                (remove-if-not #'g!-symbol-p
                               (flatten body)))))
    `(defmacro ,name ,args
       (let ,(mapcar
               (lambda (s)
                 `(,s (gensym ,(subseq
                                 (symbol-name s)
                                 2))))
               syms)
         ,@body))))


(defun o!-symbol-p (s)
  (and (symbolp s)
       (> (length (symbol-name s)) 2)
       (string= (symbol-name s)
                "O!"
                :start1 0
                :end1 2)))

(defun o!-symbol-to-g!-symbol (s)
  (symb "G!"
        (subseq (symbol-name s) 2)))

;; find a way to get rid of the
;(defmacro! makro (simz &body body)
;  (let ((vars (mapcar (lambda (v) (cons v (gensym "CLAUSE")))
;                      (remove-duplicates
;                        (mapcar #'car
;                                (mappend #'cdr simz))))))
;     ...))
; bs!!
; seen in the following "On Lisp" macros:
; with-gensyms condlet >case mvpsetq mvdo
; to get an idea of the abstraction needed


;origional defmacro! function
(defmacro defmacro! (name args &rest body)
  (let* ((os (remove-if-not #'o!-symbol-p args))
         (gs (mapcar #'o!-symbol-to-g!-symbol os)))
    `(defmacro/g! ,name ,args
        `(let ,(mapcar #'list (list ,@gs) (list ,@os))
          ,(progn ,@body)))))

#|
(defmacro defmacro! (name args &rest body)
  (let* ((os (remove-if-not #'o!-symbol-p args))
         (gs (mapcar #'o!-symbol-to-g!-symbol os)))
    `(progn
      (defmacro/g! ,name ,args
        `(let ,(mapcar #'list (list ,@gs) (list ,@os))
          ,(progn ,@body)))
      (if (stringp ,(car body))
        (setf (documentation ',name 'function) ,(car body)))
      ',name)))
(setf (documentation 'defmacro! 'function)
  "awesome macro making utiltity, with auto-gensyms and once-only functionality!
  oh, and the ability to add docs like regular macros... except in ecl, cause ecl
  people don't like to be able to `setf` docs! :'(")
|#
)
