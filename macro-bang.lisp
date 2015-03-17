(in-package :hex-utils)

;; macro utils
;; utilities for making macros & made of macros
;; all of these are general-purpose, and thus are 'utilities'
;; don't think that I'm gonna stick all my macros here...
;; that's be silly...
;; like sticking all my functions in one file
;;
;; these are non-attributed, to keep the file size small,
;; but you may be able to find these (or variants thereof)
;; in the following books:
;; "Let Over Lambda" by Doug Hoyte
;; "On Lisp" by Paul Graham

; (load "./utils.lisp")

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

(defmacro defmacro! (name args &rest body)
  (let* ((os (remove-if-not #'o!-symbol-p args))
         (gs (mapcar #'o!-symbol-to-g!-symbol os)))
    `(defmacro/g! ,name ,args
        `(let ,(mapcar #'list (list ,@gs) (list ,@os))
          ,(progn ,@body)))))

