(in-package :hex-utils)

;; list building utils
;; i'm probably going to have to organize all these
;; sometime soon...

; (load "macro-utils.lisp")

(defmacro! build-list (size &optional element-fn)
  "this is my handy-dandy list builder function,
as i couldn't find a generic one in the std-lib.
give it just a size & it reduces to `make-list`
give it a size *and* a starting element and it
will return a list containing *size* elements,
evaling *element* once each time, thus if you want
10,000 random numbers do: `(build-list 10000 (lambda (x) (random 1.0)))"
  (if (not element-fn)
    `(make-list ,size)
    `(let ((new-list '()))
      (dotimes (,g!count ,size)
        (setf new-list (cons (funcall ,element-fn ,g!count) new-list)))
      new-list)))


(defmacro! recurser (lst &body body)
  "this is for all those cases where you want to recursivly work
on a list, but are tired of writing `(if (not (nil? lst)) (blah) (halb))`
or whatever... so MACRO!"
  ; not yet implemented...
  )
