(in-package :hex-utils)

;; general utils
;; useful prettymuch everywhere
;; included by probably most of the rest of the util files...
;;
;; these are non-attributed, to keep the file size small,
;; but you may be able to find these (or variants thereof)
;; in the following books:
;; "Let Over Lambda" by Doug Hoyte
;; "On Lisp" by Paul Graham

(proclaim '(inline last1 single append1 conc1 mklist))

(defun last1 (lst)
  (car (last lst)))

; way better than (= (length lst 1)) !
(defun single (lst)
  (and (consp lst) (not (cdr lst))))

(defun append1 (lst obj)
  (append lst (list obj)))

(defun conc1 (lst obj)
  (nconc lst (list obj)))

(defun mklist (obj)
  (if (listp obj) obj (list obj)))


(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))

(defun symb (&rest args)
  (values (intern (apply #'mkstr args))))

(defun group (source n)
  (if (zerop n) (error "zero length"))
  (labels ((rec (source acc)
              (let ((rest (nthcdr n source)))
                (if (consp rest)
                    (rec rest (cons
                                (subseq source 0 n)
                                acc))
                    (nreverse
                      (cons source acc))))))
    (if source (rec source nil) nil)))

(defun flatten (x)
  (labels ((rec (x acc)
              (cond ((null x) acc)
                    ((atom x) (cons x acc))
                    (t (rec
                          (car x)
                          (rec (cdr x) acc))))))
  (rec x nil)))

